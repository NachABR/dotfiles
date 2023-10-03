# Setup fzf
# ---------
if [[ ! "$PATH" == */home/crimson/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/crimson/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/crimson/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/home/crimson/.fzf/shell/key-bindings.zsh"