# Windows:
# PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
# winget install JanDeDobbeleer.OhMyPosh -s winget
# winget install ajeetdsouza.zoxide
# winget install fzf

Import-Module posh-git

oh-my-posh init pwsh --config '~\.config\oh-my-posh\oh-my-posh.config.yml' | Invoke-Expression

Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })

# -----------------------------------------------------------------------------
# use bat (https://github.com/sharkdp/bat) instead of cat
# install with: `winget install sharkdp.bat`
# -----------------------------------------------------------------------------
if (Get-Command "bat" -errorAction SilentlyContinue)
{
  Set-Alias -Name cat -Value "bat"
}

# navigation aliases
Function .. { Set-Location .. }

# open explorer
Function Open-Explorer {
  Param(
    [string]$path='.'
  )

  explorer $path
}
Set-Alias -Name e -Value Open-Explorer

# open visual studio code
Function Open-VsCode {
  Param(
    [string]$path='.'
  )

  code $path
}
Set-Alias -Name c -Value Open-VsCode
