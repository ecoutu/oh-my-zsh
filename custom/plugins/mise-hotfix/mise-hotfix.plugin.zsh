path+=(
  ${HOME}/.local/bin # required for mise plugin
)

# socket-cli feeds the resolved `npm` bin to `node`, but mise ships npm as a
# bash reshim wrapper (not npm-cli.js), so node chokes. Prepend a shim dir with a
# node-runnable npm/npx ahead of mise's wrapper, scoped to the socket call only.
alias npm='PATH="$HOME/.local/share/socket-npm-shim:$PATH" socket npm'
alias npx='PATH="$HOME/.local/share/socket-npm-shim:$PATH" socket npx'
