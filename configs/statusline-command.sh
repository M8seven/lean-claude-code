#!/bin/sh
# Claude Code status line: context usage, cost, and model
input=$(cat)

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
total_in=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
total_out=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# Estimate cost (approximate rates for claude-sonnet-4-6 / common models)
# Input: $3/M tokens, Output: $15/M tokens (Sonnet pricing)
cost=$(echo "$total_in $total_out" | awk '{printf "%.3f", ($1 / 1000000 * 3) + ($2 / 1000000 * 15)}')

if [ -n "$used" ]; then
  ctx_display="${used}%"
else
  ctx_display="n/a"
fi

printf "%s | ctx:%s | $%s" "$model" "$ctx_display" "$cost"
