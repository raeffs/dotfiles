
function Install-IfMissing {
  param(
    [Parameter(Mandatory)] [string]$Command,
    [Parameter(Mandatory)] [string]$Id
  )

  if (!(Get-Command $Command -ErrorAction SilentlyContinue)) {
    winget install --exact --id $Id --source winget `
      --accept-package-agreements --accept-source-agreements
  }
}

Install-IfMissing -Command "git"        -Id "Git.Git"
Install-IfMissing -Command "starship"   -Id "Starship.Starship"
#Install-IfMissing -Command "oh-my-posh" -Id "JanDeDobbeleer.OhMyPosh"
Install-IfMissing -Command "zoxide"     -Id "ajeetdsouza.zoxide"
Install-IfMissing -Command "fzf"        -Id "junegunn.fzf"
Install-IfMissing -Command "bat"        -Id "sharkdp.bat"
Install-IfMissing -Command "rg"         -Id "BurntSushi.ripgrep.MSVC"
Install-IfMissing -Command "jq"         -Id "jqlang.jq"

if (!(Get-Module -ListAvailable -Name posh-git)) {
  Install-Module posh-git -Scope CurrentUser -Force
}
