#!/bin/bash

set -euo pipefail

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
cmd_add() {
    echo "Add command selected"
}

# Display tasks
cmd_list() {
    echo "List command selected"
}

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