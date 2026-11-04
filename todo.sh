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
    echo "  done    Mark a task as completed"
    echo "  delete  Delete a task"
}

# Add a new task
cmd_add() {
    local title="$*"

    # Check whether a title was provided
    if [[ -z "$title" ]]; then
        echo "Error: Task title is required." >&2
        exit 2
    fi

    # Reject titles containing the field separator
    if [[ "$title" == *"|"* ]]; then
        echo "Error: Task title cannot contain '|'" >&2
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

# Display all saved tasks
cmd_list() {
    echo "MY TO-DO LIST"
    echo "------------------------------------------------"

    printf "%-5s %-10s %-10s %s\n" "ID" "STATUS" "PRIORITY" "TITLE"

    echo "------------------------------------------------"

    while IFS='|' read -r id status priority title; do
        printf "%-5s %-10s %-10s %s\n" \
            "$id" "$status" "$priority" "$title"
    done < "$DATA_FILE"
}

# Validate task ID input
validate_task_id() {
    if [[ $# -ne 1 ]]; then
        echo "Error: Please provide exactly one task ID." >&2
        exit 2
    fi

    if [[ ! "$1" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Task ID must be a positive number." >&2
        exit 2
    fi
}

# Mark a task as completed
cmd_done() {
    validate_task_id "$@"

    local task_id="$1"
    local temp_file

    temp_file=$(mktemp)

    if ! awk -F'|' -v id="$task_id" '
        BEGIN { found = 0 }

        $1 == id {
            $2 = "done"
            found = 1
        }

        { print $1 "|" $2 "|" $3 "|" $4 }

        END {
            if (!found) {
                exit 1
            }
        }
    ' "$DATA_FILE" > "$temp_file"; then
        rm -f "$temp_file"
        echo "Error: Task ID $task_id not found." >&2
        exit 1
    fi

    mv "$temp_file" "$DATA_FILE"

    echo "Task $task_id marked as completed."
}

# Delete a task
cmd_delete() {
    validate_task_id "$@"

    local task_id="$1"
    local temp_file

    temp_file=$(mktemp)

    if ! awk -F'|' -v id="$task_id" '
        BEGIN { found = 0 }

        $1 == id {
            found = 1
            next
        }

        { print }

        END {
            if (!found) {
                exit 1
            }
        }
    ' "$DATA_FILE" > "$temp_file"; then
        rm -f "$temp_file"
        echo "Error: Task ID $task_id not found." >&2
        exit 1
    fi

    mv "$temp_file" "$DATA_FILE"

    echo "Task $task_id deleted successfully."
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
    done)
        shift
        cmd_done "$@"
        ;;
    help)
        cmd_help
        ;;
    delete)
        shift
        cmd_delete "$@"
        ;;
    *)
        echo "Error: Unknown command: $command" >&2
        exit 2
        ;;
esac