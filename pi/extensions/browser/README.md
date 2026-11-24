# pi browser extension

Playwright-driven headless Chromium that pi can drive directly. Lets the agent
debug a live SPA the same way a human would in devtools: navigate, run JS,
inspect localStorage, watch the console and network, fill forms, click.

## Why it exists

When a frontend bug reduces to "what's in localStorage?" or "what `Authorization`
header did supabase-js attach?", the agent currently has to ask the user to
paste console output and curls. With this extension it can answer those
questions itself.

## Install

```bash
cd ~/.pi/agent/extensions/browser
npm install
npx playwright install chromium    # one-time browser binary download (~150MB)
```

Then `/reload` inside pi (or restart). The new tools (`browser_goto`,
`browser_eval`, …) appear in `pi.getAllTools()` automatically because the
folder is under `~/.pi/agent/extensions/`.

## Default off, opt in per session

The browser tools collectively cost ~800 tokens in the system prompt
(snippets + guidelines) but are only useful in the small minority of
sessions that involve driving a live SPA. They're therefore registered but
**inactive** by default: invisible to the agent, not callable, no prompt
snippets or guidelines emitted.

Flip them on when you actually need them:

```
/browser on        # enable
/browser           # status
/browser off       # disable and close the headless browser
```

The enable bit persists for the current session via a custom session entry,
so `/reload` and pi restart keep it on. `/new` resets to off. Disabling also
tears down the Chromium context (`browser_close` semantics) so no
background browser is left running.

## Tools

(Only visible to the agent while `/browser on`.)

| Tool | Purpose |
|---|---|
| `browser_goto`       | Navigate to a URL. Returns `{ status, finalUrl }`. |
| `browser_eval`       | Run JS in the page. Expression, function source, or already-called IIFE — all three work. Return value must be JSON-serializable. |
| `browser_console`    | Drain buffered console + pageerror entries (filterable, bounded to 1000). |
| `browser_network`    | Drain buffered network requests. Default output is terse (`status method url`); pass `verbose: true` and/or `includeHeaders: [...]` to inline curated request/response headers on each row. |
| `browser_fill`       | Type a value into an input matched by selector. |
| `browser_click`      | Click an element (CSS, `text=...`, `role=...`). |
| `browser_screenshot` | Save a PNG to a tempdir and return its path; pi can `read` it to view. |
| `browser_close`      | Kill the persistent context. |

All page-touching tools serialize through a single internal queue, so it's
safe to fire several `browser_*` calls in one batch — they run in submission
order against the shared Page rather than racing each other.

The `/browser` command also controls the enable gate (`on` / `off` / bare
for status; `close` and `kill` are aliases for `off`).

## State

- Browser state (cookies, localStorage, IndexedDB) is persisted to
  `~/.pi/agent/extensions/browser/.profile` via
  `chromium.launchPersistentContext`. Login sessions survive across pi turns
  and pi restarts.
- Console + network events are captured into in-memory ring buffers (max 1000
  entries each). `browser_console` and `browser_network` drain them by default.
- The persistent context is closed in `session_shutdown`, so a `/new` or pi
  exit cleans up. The user-data dir on disk is left in place.

## Knobs

| Env var | Default | Effect |
|---|---|---|
| `PI_BROWSER_HEADFUL` | unset | If set, launch a visible Chromium window. Useful when debugging the extension itself. |
| `PI_BROWSER_PROFILE` | `~/.pi/agent/extensions/browser/.profile` | Override the persistent user-data dir. Set to a tempdir for ephemeral sessions. |

## Network output: terse by default, headers on opt-in

`browser_network` keeps the default text payload minimal — one line per
request, `status method url` — because a single SPA page load fires 30–100
subresource requests and inlining headers on all of them would drown the
agent's context window in noise.

When you actually want headers (the auth-debugging use case), opt in:

- `verbose: true` — inline a curated set of request/response headers on each
  returned row. The curated set is small on purpose:

  ```
  authorization, apikey, content-type, x-client-info, accept-profile,
  content-profile, prefer, location, www-authenticate, retry-after
  ```

- `includeHeaders: ["cookie", "cache-control", ...]` — extend the curated set
  for this call only (case-insensitive). Implies `verbose: true`.

All headers are captured into the ring buffer regardless; `verbose` /
`includeHeaders` only affect what's rendered into the text output. Best
paired with `urlFilter` / `status` so headers only appear on the rows you
actually care about.

Clear-on-read drains the **entire** buffer by default, not just the rows
returned. This is intentional: subsequent calls observe a fresh activity
window rather than re-walking the same subresource noise. Pass `clear: false`
to peek without draining.

## Caveats and known limits

- `playwright-core` ships without browser binaries; the `npx playwright install
  chromium` step above is required exactly once per machine.
- The page object is a singleton — there's no tab/window management. If you
  need multiple tabs, extend `ensurePage` to accept a tab id.
- `browser_eval` evaluates the source once and, if the result is a function,
  calls it. So expressions (`localStorage.length`), function values
  (`() => doStuff()`), and already-called IIFEs (`(() => 42)()`) all do what
  you'd expect. Note: top-level `return` and multi-statement bodies aren't
  valid expressions — wrap them in `(() => { ... })()`.
- For DOM nodes, return primitive properties (`.outerHTML`, `.textContent`,
  `.value`) rather than the node itself; Playwright serializes nodes as the
  opaque sentinel `"ref: <Node>"`.
- `browser_eval` returns `undefined` as `null` after JSON serialization. Wrap
  expressions in a function that returns a sentinel if you care.
- `browser_click`: CSS attribute selectors match HTML attributes, not DOM
  properties. `button[type=submit]` will NOT match `<button>Submit</button>`
  even though that button's `.type === "submit"` by default. Prefer
  `text=Submit` or `role=button[name=Submit]` for semantic matching.
- `browser_network` shows `ERR net::ERR_ABORTED` for fetches whose body was
  never consumed (e.g. `await fetch(url)` without `.text()` / `.json()`).
  Chromium cancels the body stream and Playwright reports `requestfailed`
  even though the JS side saw a successful response. Consume the body if you
  want a clean status row.
- Network buffer captures headers but not bodies. Add `request.postData()` /
  `response.text()` capture if you need bodies (will eat context fast — gate
  it behind a flag).
- No download / file-upload helpers yet. Add when needed.
- OTP / 2FA: the extension has no mail integration. Human still has to paste the code into `browser_fill`.

## Possible next features

- `browser_wait_for(selector|url)` for explicit synchronization.
- `browser_request_body` to expose request/response bodies on demand without
  ballooning the default network buffer.
- Mail-fetch tool (Gmail API or Mailpit) so OTP logins can be fully automated.
- `fly_logs` companion tool — `flyctl logs -a <app>` tailed into a similar
  ring buffer — so the agent can correlate frontend behavior with backend
  errors without context switching.
