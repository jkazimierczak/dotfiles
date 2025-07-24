# First Run

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jkazimierczak
```

# High-Level Config Overview
- Preserve ZSH history & duplicates (so I can reproduce the exact steps)
- Don't write command to the history if it's prefixed with a space ` `
- Cycle through previous/next history entries that match a prefix with `CTRL+p/n` - Example: Show previous/next historical invocations of `curl`
- Case-insensitive tab completions
