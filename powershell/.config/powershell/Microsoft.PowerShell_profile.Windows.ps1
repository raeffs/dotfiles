
# -----------------------------------------------------------------------------
# initialize posh-git (https://github.com/dahlbyk/posh-git)
#
# Install-Module posh-git -Scope CurrentUser -Force
# -----------------------------------------------------------------------------
Import-Module posh-git

# -----------------------------------------------------------------------------
# initialize oh-my-posh (https://github.com/JanDeDobbeleer/oh-my-posh)
#
# winget install JanDeDobbeleer.OhMyPosh -s winget
# -----------------------------------------------------------------------------
if (Get-Command "oh-my-posh" -errorAction SilentlyContinue)
{
  oh-my-posh init pwsh --config '~\.config\oh-my-posh\oh-my-posh.config.yml' | Invoke-Expression
}

# -----------------------------------------------------------------------------
# use zoxide (https://github.com/ajeetdsouza/zoxide) instead of cd
#
# winget install ajeetdsouza.zoxide
# winget install fzf
# -----------------------------------------------------------------------------
if (Get-Command "zoxide" -errorAction SilentlyContinue)
{
  Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
}

# -----------------------------------------------------------------------------
# use bat (https://github.com/sharkdp/bat) instead of cat
#
# winget install sharkdp.bat
# -----------------------------------------------------------------------------
if (Get-Command "bat" -errorAction SilentlyContinue)
{
  Set-Alias -Name cat -Value "bat" -Option AllScope
}

# -----------------------------------------------------------------------------
# use ripgrep (https://github.com/BurntSushi/ripgrep) instead of grep
#
# winget install BurntSushi.ripgrep.MSVC
# -----------------------------------------------------------------------------
if (Get-Command "rg" -errorAction SilentlyContinue)
{
  Function Exec-Ripgrep { rg -i $args }
  
  Set-Alias -Name grep -Value Exec-Ripgrep
}

# -----------------------------------------------------------------------------
# navigation aliases
# -----------------------------------------------------------------------------
Function .. { Set-Location .. }

# -----------------------------------------------------------------------------
# open windows explorer alias
# -----------------------------------------------------------------------------
Function Open-Explorer {
  Param(
    [string]$path='.'
  )

  explorer $path
}

Set-Alias -Name e -Value Open-Explorer

# -----------------------------------------------------------------------------
# open visual studio code alias
# -----------------------------------------------------------------------------
Function Open-VsCode {
  Param(
    [string]$path='.'
  )

  code $path
}

Set-Alias -Name c -Value Open-VsCode
