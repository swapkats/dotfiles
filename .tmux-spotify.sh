#!/bin/bash

# Get current Spotify track info
get_spotify_info() {
    if pgrep -f "Spotify" > /dev/null; then
        track=$(osascript -e 'tell application "Spotify" to get name of current track' 2>/dev/null)
        artist=$(osascript -e 'tell application "Spotify" to get artist of current track' 2>/dev/null)
        player_state=$(osascript -e 'tell application "Spotify" to get player state' 2>/dev/null)
        
        if [ "$player_state" = "playing" ]; then
            icon="♫"
        elif [ "$player_state" = "paused" ]; then
            icon="⏸"
        else
            icon="♪"
        fi
        
        if [ -n "$track" ] && [ -n "$artist" ]; then
            # Truncate if too long
            max_length=30
            song_info="$artist - $track"
            if [ ${#song_info} -gt $max_length ]; then
                song_info="${song_info:0:$((max_length-3))}..."
            fi
            echo "$icon $song_info"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

get_spotify_info