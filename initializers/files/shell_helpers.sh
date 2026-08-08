if [ -d "$HOME/.shell-dev-helpers.d" ]; then
  for f in "$HOME/.shell-dev-helpers.d"/*; do
    [ -f "$f" ] && . "$f"
  done
fi
