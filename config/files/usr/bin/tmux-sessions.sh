#!/usr/bin/env fish

set SHELL "/bin/fish"
# Function to display session details using fzf preview mode
function display_session_details
    set sessions "$(tmux list-sessions -F '#{session_name}')"
    set query (echo -e "$sessions" | fzf --prompt 'Choose session (or create new session): ' --ansi --height=50% --layout=reverse --print-query)
    
    set selected_session ""

    if test (string length "$query[1]") -gt 0
        set selected_session "$query[1]"
    else if test (string length "$query[2]") -gt 0
        set selected_session "$query[2]"
        #if test "$selected_session" = "host"
        #    return
        #end
    end

    tmux new-session -At "$selected_session"
end

# Check if tmux is running
if tmux has-session 2>/dev/null
    display_session_details
else
    # If tmux is not running, start a new session
    tmux new-session -t default
end
