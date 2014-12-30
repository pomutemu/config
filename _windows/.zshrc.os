alias cygpath="cygpath -i"
alias ls="ls -ACFH --color -I \"NTUSER.DAT*\""
alias upgrade1="update-core && exec cmd //c new"
alias upgrade2="pacman -Suy --noconfirm && cup all -y && apm update"

alias help="powershell help"
alias kill="powershell kill"
alias pkill="powershell kill -name"
alias powershell="powershell -noprofile -executionpolicy unrestricted"
alias ps="powershell ps"

alias calc="open cCalc"
# alias chrome=open
alias diskinfo="open DiskInfo"
alias examdisk="open ExamDisk"
alias firefox="open \"${PROGRAMFILES}/Mozilla Firefox/firefox\" -no-remote -P"
alias gifv="open \"GIF Viewer\""
alias kobito="cmd //c kobito"
alias new="cmd //c new"
alias sgif="open ScreenToGif"

alias -g R="| tr -d $'\r'"
alias -g U="| xargs -d $'\n' cygpath -iu"
alias -g W="| xargs -d $'\n' cygpath -iw"
