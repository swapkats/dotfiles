---
name: web-debug
description: "Debug or verify frontend behavior by driving a live page (DOM, storage, network, console) with the browser_* tools instead of reading source or asking the user to paste from devtools. Use when the user reports: broken login or auth flow, failed/401/403/CORS requests, JWT or session weirdness, form not submitting, button does nothing, blank screen, hydration mismatch, stale data, 'works locally / fails in prod', or asks you to verify a frontend change end-to-end."
---

# Web debugging via the live page

You have a real headless browser. Use it. The default failure mode is reading
source, forming a hypothesis, and asking the user to verify in their devtools.
That's slow and wrong: the answer usually lives in runtime state (localStorage,
the actual `Authorization` header the SPA sent, a console error), not in source.

## When to reach for the kit

Pattern-match the user's wording to a playbook below. If their description
sounds like *anything* in this list, open the browser first, theorize second.

| User says something like… | First move |
|---|---|
| "I can't log in" / "login is broken" / "auth doesn't work" | [Auth flow](#auth-flow-not-working) |
| "I'm getting a 401 / 403 / CORS error from `/api/foo`" | [Bad request](#why-is-this-request-failing) |
| "The session isn't persisting" / "logged out on refresh" | [Storage inspection](#whats-actually-in-storage) |
| "This JWT looks weird" / "wrong claims" | [JWT decode](#decode-a-jwt-without-leaving-the-loop) |
| "The form does nothing" / "submit button doesn't work" | [Form not submitting](#form-not-submitting) |
| "Blank screen" / "page won't load" / "stuck loading" | [Blank screen](#blank-screen) |
| "Works on my machine" / "fails in prod" | [Reproduce in prod](#reproduce-in-prod) |
| "Can you verify this fix?" / "does my change work?" | [Verify a change](#verify-a-frontend-change-end-to-end) |

If none of those match but the bug is *behavioral* (something the user sees in
the browser), still open `browser_goto` first. You will learn more in three
tool calls than three rounds of source-reading.

## Core loop

Every playbook below is a variation on this:

1. `browser_goto` to the relevant URL.
2. Drive whatever action reproduces the bug (`browser_fill`, `browser_click`).
3. Drain observations: `browser_console`, `browser_network` (often with
   `verbose: true` and a `urlFilter`).
4. `browser_eval` to read runtime state that isn't visible from console/network.
5. Form a hypothesis. Make a code change. Re-run the loop to verify.

State (cookies, localStorage, IndexedDB) is persistent across `browser_*`
calls, across turns, and across pi restarts — a session you opened earlier
is still open now. That's a feature: don't `browser_close` between steps.

## Playbooks

### Auth flow not working

```
browser_goto      url=<login url>
browser_fill      selector=input[type=email]    value=<email>
browser_fill      selector=input[type=password] value=<password>
browser_click     selector=text=Sign in
browser_console                                          # any JS error?
browser_network   urlFilter=/auth     verbose=true       # what was POSTed, what came back?
browser_eval      expression=Object.keys(localStorage)   # did a session land?
```

If the network call to `/auth/v1/token` returns 200 but no session shows up in
localStorage, the bug is in the client SDK's storage adapter, not the server.
If the network call returns 400/401, the bug is upstream — read the response
status and the request body.

### Why is this request failing

```
browser_goto      url=<app url>
# reproduce the action that fires the failing request
browser_network   urlFilter=<route>   verbose=true
```

`verbose=true` shows the curated headers (`Authorization`, `apikey`,
`content-type`, etc.). For CORS, add `includeHeaders=["origin","access-control-request-method","access-control-request-headers"]`.

Common patterns the headers reveal:
- Missing or stale `Authorization` → check the auth flow above.
- `apikey` header missing on a Supabase call → the client wasn't constructed
  with the anon key.
- Wrong `content-type` → the client serialized the body unexpectedly.
- 403 with `prefer: return=representation` → RLS, not auth.

### What's actually in storage

```
browser_goto      url=<app url>
browser_eval      expression=Object.keys(localStorage)
browser_eval      expression=Object.fromEntries(Object.entries(localStorage))
browser_eval      expression=document.cookie
```

For Supabase specifically the session key is
`sb-<projectref>-auth-token`. If it's missing after login, the SDK never wrote
it (suspect storage adapter or a race). If it's present but stale, the SDK
isn't reading it on init.

### Decode a JWT without leaving the loop

```
browser_eval expression=`(() => {
  const raw = localStorage.getItem('sb-<projectref>-auth-token');
  if (!raw) return null;
  const tok = JSON.parse(raw).access_token;
  const [h, p] = tok.split('.').slice(0, 2).map(s => JSON.parse(atob(s.replace(/-/g,'+').replace(/_/g,'/'))));
  return { header: h, payload: p, expiresIn: p.exp - Math.floor(Date.now()/1000) };
})()`
```

Useful when the user reports "I'm logged in but the API thinks I'm anon" —
inspect `role`, `aud`, `exp` directly.

### Form not submitting

```
browser_goto      url=<page>
browser_eval      expression=`[...document.forms].map(f => ({ action: f.action, method: f.method, valid: f.checkValidity() }))`
browser_click     selector=text=Submit
browser_console                                  # validation error? handler threw?
browser_network                                  # did anything fire at all?
```

If `checkValidity()` is `false`, the form has an HTML validation constraint
blocking submit (often a hidden `required` field). If nothing fires on click,
there's no handler bound (hydration issue, or the button is outside the form).

### Blank screen

```
browser_goto      url=<page>
browser_console                                  # this is almost always the answer
browser_screenshot                               # confirm it's actually blank
browser_eval      expression=document.body.innerHTML.length
```

A blank screen with console errors is almost always a runtime JS error during
render (React/Vue/Svelte tear down the tree on uncaught errors). A blank
screen with *no* console errors and `innerHTML.length === 0` is a routing or
build issue — fetch the page with `web_fetch` and check the served HTML.

### Reproduce in prod

The persistent profile means a session you've already authenticated stays
authenticated. So:

```
browser_goto      url=<prod url>
# you may already be logged in from a previous turn — check first
browser_eval      expression=Object.keys(localStorage)
# if not, run the auth playbook against prod
```

Then reproduce the failing action and compare its `browser_network` output
against the same action in dev.

### Verify a frontend change end-to-end

This is the underused half of the kit. After making a code change that
affects behavior the user can see:

```
browser_goto      url=<changed page>            # fresh load
# drive the new behavior
browser_fill / browser_click as needed
browser_eval      expression=<assertion about resulting state>
browser_screenshot                              # if there's a visual claim
```

Don't say "done" if you haven't exercised the change. Reading source and
saying "this should work" is a strictly weaker claim than
"I drove it and observed the expected state."

## Pitfalls

These are the ones that have already bitten — internalize them.

- **`fetch()` without consuming the body** shows up as `ERR net::ERR_ABORTED`
  in `browser_network`, even when the JS side saw a 200. If you do quick
  checks, do `const r = await fetch(url); await r.text(); return r.status`.
- **DOM nodes don't JSON-serialize.** Return primitive properties:
  `.outerHTML`, `.textContent`, `.value`, `.checked`. Never return the node
  itself or `document.body`.
- **`button[type=submit]` is an HTML attribute selector**, not a DOM property
  selector. A `<button>Submit</button>` has DOM `.type === "submit"` by
  default, but no `type` attribute — the selector won't match. Use
  `text=Submit` or `role=button[name=Submit]`.
- **`browser_console` / `browser_network` drain the entire buffer by default.**
  If you want to read one thing without losing the rest, pass `clear: false`.
- **Top-level `return` and multi-statement bodies aren't expressions.** Wrap
  them in `(() => { ... })()` when passing to `browser_eval`.

## When *not* to reach for these tools

- If you only need to read static content from a public URL, `web_fetch` is
  faster (no browser launch, no profile state).
- If the question is purely about source code, read the source. The browser
  doesn't tell you why a function was written, only what it does at runtime.
- If you need to verify behavior across many URLs at scale, write a script
  and run it with `bash` — the browser kit is for interactive debugging, not
  batch crawling.
