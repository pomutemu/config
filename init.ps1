# Unalias

del alias:cat
del function:mkdir

# Set vars

$INSTALLED_NODOKA = test-path "${env:PROGRAMFILES}/nodoka"

$NODEJS_VERSION = "5.7.1"
$POSTGRESQL_VERSION = "9.5.1"
$RUBY_VERSION = "2.3.0"

# Set envs

$env:ROOT = "${env:SYSTEMDRIVE}\root"
$env:TOOLS = "${env:SYSTEMDRIVE}\tools"
$env:HOME = "${env:ROOT}\home\${env:USERNAME}"
$env:PATH = "${env:HOME}\bin;${env:ROOT}\usr\bin;${env:ROOT}\bin" + ";" + [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + "${env:ROOT}\usr\lib\p7zip"
$env:MINGW_INSTALLS = "mingw32"
$env:MSYS = "winsymlinks:nativestrict"
$env:MSYSTEM = "MSYS"
if (${INSTALLED_NODOKA}) {$env:NODOKA = "${env:HOME}"}

$env:GOPATH = "${env:HOME}"
$env:GOROOT = "${env:TOOLS}\go"
$env:GYP_MSVS_VERSION = "2015"
$env:NODE_PATH = "${env:HOME}\bin\node_modules"
$env:NPM_CONFIG_PREFIX = "${env:HOME}\bin"
$env:PYTHONUSERBASE = "${env:HOME}"

$env:DATADRIVE = bash -c @"
read -erp \"DATADRIVE> \" -i D:; echo \"`${REPLY}\"
"@
$env:ONEDRIVE = (gp HKCU:/Software/Microsoft/OneDrive -name userfolder).userfolder
$env:ONEDRIVE = bash -c @"
read -erp \"ONEDRIVE> \" -i '${env:ONEDRIVE}'; echo \"`${REPLY}\"
"@
${env:PATH} += ";" + (bash -c @"
read -erp \"ADDITIONAL_BIN_DIR> \" -i '${env:ONEDRIVE}\bin'; echo \"`${REPLY}\"
"@)
$env:GHQ_ROOT = bash -c @"
read -erp \"GHQ_ROOT> \" -i '${env:ONEDRIVE}\src'; echo \"`${REPLY}\"
"@
$env:GITHUB_ID = bash -c @"
read -erp \"GITHUB_ID> \"; echo \"`${REPLY}\"
"@

cmd /c setx ROOT `"%ROOT%`"
cmd /c setx TOOLS `"%TOOLS%`"
cmd /c setx HOME `"%HOME%`"
cmd /c setx PATH `"%PATH%`" /m
cmd /c setx MINGW_INSTALLS `"%MINGW_INSTALLS%`"
cmd /c setx MSYS `"%MSYS%`"
cmd /c setx MSYSTEM `"%MSYSTEM%`"
if (${INSTALLED_NODOKA}) {cmd /c setx NODOKA `"%NODOKA%`"}

cmd /c setx GOPATH `"%GOPATH%`"
cmd /c setx GOROOT `"%GOROOT%`"
cmd /c setx GYP_MSVS_VERSION `"%GYP_MSVS_VERSION%`"
cmd /c setx NODE_PATH `"%NODE_PATH%`"
cmd /c setx NPM_CONFIG_PREFIX `"%NPM_CONFIG_PREFIX%`"
cmd /c setx PYTHONUSERBASE `"%PYTHONUSERBASE%`"

cmd /c setx DATADRIVE `"%DATADRIVE%`"
cmd /c setx ONEDRIVE `"%ONEDRIVE%`"
cmd /c setx GHQ_ROOT `"%GHQ_ROOT%`"
cmd /c setx GITHUB_ID `"%GITHUB_ID%`"

pause

# Install MSYS2 packages

bash -c update-core
bash -c "pacman -Suy --noconfirm"

bash -c "pacman -S --noconfirm base-devel"
bash -c "pacman -S --noconfirm ca-certificates"
bash -c "pacman -S --noconfirm compression"
bash -c "pacman -S --noconfirm git"
bash -c "pacman -S --noconfirm mingw-w64-i686-toolchain"
bash -c "pacman -S --noconfirm openssh"
bash -c "pacman -S --noconfirm rsync"
bash -c "pacman -S --noconfirm zsh"

pause

# Deploy

ln -fsT "${env:USERPROFILE}" "${env:HOME}"

mkdir -p "${env:GHQ_ROOT}"

touch "${env:ONEDRIVE}/.zcompdump"
touch "${env:ONEDRIVE}/.zdirs"
touch "${env:ONEDRIVE}/.zhist"

ln -fsT "${env:GHQ_ROOT}" "${env:HOME}/src"

ln -fsT "${env:ONEDRIVE}/.zcompdump" "${env:HOME}/.zcompdump"
ln -fsT "${env:ONEDRIVE}/.zdirs" "${env:HOME}/.zdirs"
ln -fsT "${env:ONEDRIVE}/.zhist" "${env:HOME}/.zhist"

$CONFIG_PATH = "github.com/${env:GITHUB_ID}/config"

if (-not (test-path "${env:HOME}/src/${CONFIG_PATH}")) {
  git clone "https://${CONFIG_PATH}" "${env:HOME}/src/${CONFIG_PATH}"
}

pushd "${env:HOME}/src/${CONFIG_PATH}"
  bash -c "rsync -avF ./ ~"
  bash -c "rsync -avF ./_windows/ ~"
  bash -c "rsync -avF ./_windows/_etc/ ~/etc"
popd

pause

# Install Chocolatey packages

(iex ((new-object net.webclient).downloadstring("https://chocolatey.org/install.ps1"))) 2> $NULL >&2

choco pin add -n nodejs -version "${NODEJS_VERSION}"
choco pin add -n postgresql -version "${POSTGRESQL_VERSION}"

cinst atom -y
cinst dotnet3.5 -y
cinst donten4.5 -y
cinst driverbooster -y
cinst chromium -y
cinst firefox -y
cinst flashplayerplugin -y
cinst golang -y
cinst gyazo -y
cinst jq -y
cinst libreoffice -y
cinst nodejs -y
cinst obs -y
cinst python2 -y
cinst shutdownguard -y
cinst unetbootin -y
cinst visualstudio2015community -y
cinst vlc -y

pause

pushd "${env:PROGRAMFILES}/nodejs/node_modules/npm"
  curl -L https://gist.github.com/pomutemu/bde68833a19ed5b9f3d1/raw | git apply
popd

$env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH", "User")

# Set up SSH

mkdir -p "${env:HOME}/.ssh"

@"
Host github.com
  User git
  HostName github.com
  Port 22
  IdentitiesOnly yes
  IdentityFile ~/.rsa/${env:GITHUB_ID}

Host heroku.com
  User git
  HostName heroku.com
  Port 22
  IdentitiesOnly yes
  IdentityFile ~/.rsa/${env:GITHUB_ID}
"@ | out-file "${env:HOME}/.ssh/config" -append -encoding ascii

mkdir -p "${env:HOME}/.rsa"

ssh-keygen -t rsa -b 2048 -f "${env:HOME}/.rsa/${env:GITHUB_ID}"
cat "${env:HOME}/.rsa/${env:GITHUB_ID}.pub" | clip

open https://github.com/settings/ssh
open https://heroku.com/account

pause

ssh -T github.com
ssh -T heroku.com :

pause

# Install other packages

apm stars -iu pomutemu

go get github.com/motemen/ghq
go get github.com/Tomohiro/gyazo-cli
go get github.com/github/hub
go get github.com/peco/peco/cmd/peco
go get github.com/monochromegane/the_platinum_searcher/cmd/pt
go get github.com/mattn/twty

npm i -g (npm stars pomutemu)
npm i -g pomutemu/powerline-js-mod

pushd "${env:HOME}"
  mkdir -p ./.cmder-mod
  mkdir -p ./.heroku
  mkdir -p ./.kobito
  mkdir -p ./.rbenv
  mkdir -p "./.ruby/${RUBY_VERSION}"

  curl -L https://api.github.com/repos/pomutemu/cmder-mod/tarball | tar xz -C ./.cmder-mod --strip 1
  curl -L https://s3.amazonaws.com/assets.heroku.com/heroku-client/heroku-client.tgz | tar xz -C ./.heroku --strip 1
  # kobito
  curl -L https://api.github.com/repos/rbenv/rbenv/tarball | tar xz -C ./.rbenv --strip 1
  curl -L https://api.github.com/repos/Alexpux/MINGW-packages/tarball/e711164 | tar xz -C "./.ruby/${RUBY_VERSION}" --strip 2 --wildcards "*/mingw-w64-ruby"
popd

pause

pushd "${env:HOME}/.cmder-mod"
  cmd /c ./build
popd

pushd "${env:HOME}/.rbenv"
  mkdir -p ./plugins
  mkdir -p ./shims
  mkdir -p ./versions

  ln -fsT "${env:HOME}/.rbenv/libexec/rbenv" ./bin/rbenv
popd

pushd "${env:HOME}/.ruby/${RUBY_VERSION}"
  bash -c "makepkg-mingw -is"

  # ln -fsT "${env:HOME}/.rbenv/versions/${RUBY_VERSION}"
  rbenv rehash
  rbenv global "${RUBY_VERSION}"

  gem i awesome_print
  gem i bundler
  gem i pry
popd

pause

# Configure services

set-service wscsvc -startuptype disabled # Security Center
set-service shellhwdetection -startuptype disabled # Shell Hardware Detection
set-service lmhosts -startuptype disabled # TCP/IP NetBIOS Helper
set-service wuauserv -startuptype disabled # Windows Update

# Configure scheduled tasks

disable-scheduledtask "Driver Booster Scheduler"
disable-scheduledtask "File History (maintenance mode)" -taskpath \Microsoft\Windows\FileHistory\
disable-scheduledtask SR -taskpath \Microsoft\Windows\SystemRestore\

if (${INSTALLED_NODOKA}) {
  if ("${env:PROCESSOR_ARCHITECTURE}" -eq "x86") {
    $OPTS = @{
      action = new-scheduledtaskaction "${env:PROGRAMFILES}/nodoka/nodoka" -argument "-kg 2" -workingdirectory "${env:PROGRAMFILES}/nodoka"
      runlevel = "highest"
      trigger = new-scheduledtasktrigger -atlogon
    }
  }
  else {
    $OPTS = @{
      action = new-scheduledtaskaction "${env:PROGRAMFILES}/nodoka/nodoka64" -argument "-kg 2" -workingdirectory "${env:PROGRAMFILES}/nodoka"
      runlevel = "highest"
      trigger = new-scheduledtasktrigger -atlogon
    }
  }

  register-scheduledtask nodoka ${OPTS}
}

# Configure power options

powercfg -h off
powercfg -x monitor-timeout-ac 10
powercfg -x monitor-timeout-dc 10
powercfg -x standby-timeout-ac 0
powercfg -x standby-timeout-dc 10
powercfg -x disk-timeout-ac 0
powercfg -x disk-timeout-dc 10

# Make system image backup

wbadmin start backup -vssfull -include "${env:SYSTEMDRIVE}" -backuptarget "${env:DATADRIVE}"
