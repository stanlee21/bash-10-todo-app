#!/bin/bash

set -euo pipefail

# Define where tasks will be stored
DATA_FILE="${TODO_FILE:-$HOME/.local/share/todo/todo.txt}"

# Create the storage directory and file if they don't exist
init_storage() {
    local directory

    directory="$(dirname "$DATA_FILE")"

    mkdir -p "$directory"
    touch "$DATA_FILE"
}

# Display help instructions
cmd_help() {
    echo "To-Do App"
    echo "Usage: ./todo.sh [command]"
    echo ""
    echo "Commands:"
    echo "  add     Add a new task"
    echo "  list    Display all tasks"
    echo "  help    Show this help message"
}

# Add a task
# Add a new task
cmd_add() {
    local title="$*"

    if [[ -z "$title" ]]; then
        echo "Error: Task title is required." >&2
        exit 2
    fi

    # Find the highest existing task ID
    local highest_id

    highest_id=$(awk -F'|' '
        NF >= 4 && $1 ~ /^[0-9]+$/ {
            if ($1 > max) max = $1
        }
        END {
            print max + 0
        }
    ' "$DATA_FILE")

    # Generate the next ID
    local new_id=$((highest_id + 1))

    # Save the task
    printf '%s|todo|medium|%s\n' "$new_id" "$title" >> "$DATA_FILE"

    echo "Task added successfully. ID: $new_id"
}

# Display tasks
cmd_list() {
    echo "List command selected"
}

# Determine which command the user entered
command="${1:-list}"

# Initialize task storage before processing commands
init_storage

# Determine which command the user entered
command="${1:-list}"

case "$command" in
    add)
        shift
        cmd_add "$@"
        ;;
    list)
        cmd_list
        ;;
    help)
        cmd_help
        ;;
    *)
        echo "Error: Unknown command: $command" >&2
        exit 2
        ;;
esac