#!/usr/bin/env bash

# copied from ~/.tmux/plugins/tmux-logging/scripts/toggle_logging.sh

#original# CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#original# source "$CURRENT_DIR/variables.sh"
#original# source "$CURRENT_DIR/shared.sh"

TMUX_LOGGING_SCRIPT_DIR="$HOME/.tmux/plugins/tmux-logging/scripts"
CURRENT_DIR="$TMUX_LOGGING_SCRIPT_DIR"

source "$TMUX_LOGGING_SCRIPT_DIR/variables.sh"
source "$TMUX_LOGGING_SCRIPT_DIR/shared.sh"

start_pipe_pane() {
	local file=$(expand_tmux_format_path "${logging_full_filename}")
	"$CURRENT_DIR/start_logging.sh" "${file}"
	display_message "Started logging to ${logging_full_filename}"
}

#original# stop_pipe_pane() {
#original# 	tmux pipe-pane
#original# 	display_message "Ended logging to $logging_full_filename"
#original# }

# custom function
confirm_logging() {
	display_message "Logging already happening to ${logging_full_filename}"
}

# returns a string unique to current pane
pane_unique_id() {
	tmux display-message -p "#{session_name}_#{window_index}_#{pane_index}"
}

# saving 'logging' 'not logging' status in a variable unique to pane
set_logging_variable() {
	local value="$1"
	local pane_unique_id="$(pane_unique_id)"
	tmux set-option -gq "@${pane_unique_id}" "$value"
}

# this function checks if logging is happening for the current pane
is_logging() {
	local pane_unique_id="$(pane_unique_id)"
	local current_pane_logging="$(get_tmux_option "@${pane_unique_id}" "not logging")"
	if [ "$current_pane_logging" == "logging" ]; then
		return 0
	else
		return 1
	fi
}

# starts/stop logging
#original# toggle_pipe_pane() {
#original# 	if is_logging; then
#original# 		set_logging_variable "not logging"
#original# 		stop_pipe_pane
#original# 	else
#original# 		set_logging_variable "logging"
#original# 		start_pipe_pane
#original# 	fi
#original# }

# custom function
ensure_pipe_pane_on() {
	if is_logging; then
		set_logging_variable "logging"
		confirm_logging
	else
		set_logging_variable "logging"
		start_pipe_pane
	fi
}

main() {
	if supported_tmux_version_ok; then
		#original# toggle_pipe_pane
		# custom function
		ensure_pipe_pane_on
	fi
}
main
