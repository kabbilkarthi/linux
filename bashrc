: '
NOTE: sometimes scp/sftp/ssh remote-host operations will get hampered because of the .bashrc* setup
ERROR: 
SFTP : Received message too long 168435779 
SCP : protocol error: unexpected <newline>
'


## alias

alias 'root=sudo -i'
alias "sep=awk '{print $1}' host |tr '\n' '|' | sed 's/|*$//';echo"
alias 'xterm=xterm -geometry 72×34+100+40 -fn *-fixed-*-*-*-20-*'

## Variables

export "EDITOR=/bin/gvim" 
export "ANSIBLE_CONFIG=/u/kabbil/ANSIBLE/.ansible.cfg"

## Bash prompt NEW

source ~/.themes.sh

: '
## Bash prompt OLD

cyan="\033[1;96m"
green="\033[1;92m"
blue="\033[1;94m"
white="\033[1;97m"
end="\033[0m"
PS1="${green}\u${blue}@\h${white}:\w ${cyan}=>${white}${end} "
unset green blue white cyan end
'
## Modules

module load jq/1.7 # prettify-json