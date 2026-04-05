#!/bin/bash
# Catppuccin Macchiato status line for Claude Code

# Color palette
MAUVE="\033[38;2;198;160;246m"
PEACH="\033[38;2;245;169;127m"
GREEN="\033[38;2;166;218;149m"
RED="\033[38;2;237;135;150m"
BLUE="\033[38;2;138;173;244m"
LAVENDER="\033[38;2;183;189;248m"
TEXT="\033[38;2;202;211;245m"
SUBTEXT1="\033[38;2;184;192;224m"
RESET="\033[0m"

# Read JSON input
input=$(cat)

# Extract data from JSON
model_id=$(echo "$input" | jq -r '.model.id // ""')
model_display=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# Extract version from model ID (e.g., "claude-opus-4-6" -> "opus-4-6")
if [ -n "$model_id" ] && [ "$model_id" != "null" ]; then
    model=$(echo "$model_id" | sed -E 's/^claude-//' | sed -E 's/-([0-9]{8})$//')
else
    model="$model_display"
fi

cwd=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
session_name=$(echo "$input" | jq -r '.session_name // empty')
vim_mode=$(echo "$input" | jq -r '.vim.mode // empty')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
tokens_used=$(echo "$input" | jq -r '.context_window.used // empty')
tokens_total=$(echo "$input" | jq -r '.context_window.total // empty')

# Format tokens as "25k/200K"
format_tokens() {
    local num=$1
    if [ -z "$num" ] || [ "$num" = "null" ]; then
        echo ""
        return
    fi
    if [ "$num" -ge 1000000 ]; then
        printf "%.1fM" "$(echo "scale=1; $num / 1000000" | bc)"
    elif [ "$num" -ge 1000 ]; then
        printf "%.0fk" "$(echo "scale=0; $num / 1000" | bc)"
    else
        echo "$num"
    fi
}

# Format directory (basename if too long)
if [ ${#cwd} -gt 40 ]; then
    display_dir=$(basename "$cwd")
else
    display_dir="$cwd"
fi

# Git branch detection
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    if [ -n "$branch" ]; then
        if ! git -C "$cwd" diff --quiet 2>/dev/null || \
           ! git -C "$cwd" diff --cached --quiet 2>/dev/null; then
            git_branch="${PEACH}  ${branch}${RESET} ${RED}●${RESET}"
        else
            git_branch="${GREEN}  ${branch}${RESET}"
        fi
    fi
fi

# Build status line
printf "${LAVENDER}󰄛${RESET} "

# Model
printf "${BLUE}${model}${RESET}"

# Session name
if [ -n "$session_name" ]; then
    printf " ${SUBTEXT1}│${RESET} ${MAUVE}${session_name}${RESET}"
fi

# Directory
printf " ${SUBTEXT1}│${RESET} ${TEXT}${display_dir}${RESET}"

# Git branch
if [ -n "$git_branch" ]; then
    printf " ${git_branch}"
fi

# Vim mode
if [ -n "$vim_mode" ]; then
    if [ "$vim_mode" = "NORMAL" ]; then
        printf " ${SUBTEXT1}│${RESET} ${GREEN}N${RESET}"
    else
        printf " ${SUBTEXT1}│${RESET} ${BLUE}I${RESET}"
    fi
fi

# Context window (color-coded token usage)
if [ -n "$tokens_used" ] && [ -n "$tokens_total" ] && [ "$tokens_used" != "null" ] && [ "$tokens_total" != "null" ]; then
    used_fmt=$(format_tokens "$tokens_used")
    total_fmt=$(format_tokens "$tokens_total")
    remaining_int=${remaining%.*}
    if [ "$remaining_int" -lt 20 ]; then
        context_color="$RED"
    elif [ "$remaining_int" -lt 50 ]; then
        context_color="$PEACH"
    else
        context_color="$GREEN"
    fi
    printf " ${SUBTEXT1}│${RESET} ${context_color}${used_fmt}/${total_fmt}${RESET}"
elif [ -n "$remaining" ]; then
    remaining_int=${remaining%.*}
    if [ "$remaining_int" -lt 20 ]; then
        context_color="$RED"
    elif [ "$remaining_int" -lt 50 ]; then
        context_color="$PEACH"
    else
        context_color="$GREEN"
    fi
    printf " ${SUBTEXT1}│${RESET} ${context_color}${remaining_int}%%${RESET}"
fi

printf "\n"
