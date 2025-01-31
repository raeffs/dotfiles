Param(
    [string]$TargetDir = "~"
)

$DotfilesDir = $PSScriptRoot

New-Item -Path "$TargetDir\.gitconfig" -Type SymbolicLink -Value "$DotfilesDir\git\.gitconfig" -Force

New-Item -Path "$TargetDir\.config\oh-my-posh\oh-my-posh.config.yml" -Type SymbolicLink -Value "$DotfilesDir\oh-my-posh\.config\oh-my-posh\oh-my-posh.config.yml" -Force
New-Item -Path "$TargetDir\.config\starship.toml" -Type SymbolicLink -Value "$DotfilesDir\starship\.config\starship.toml" -Force
New-Item -Path "$TargetDir\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" -Type SymbolicLink -Value "$DotfilesDir\powershell\.config\powershell\Microsoft.PowerShell_profile.Windows.ps1" -Force
New-Item -Path "$TargetDir\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" -Type SymbolicLink -Value "$DotfilesDir\powershell\.config\powershell\Microsoft.PowerShell_profile.Windows.ps1" -Force

$windowsTerminalPackage = Get-AppxPackage -Name Microsoft.WindowsTerminal
$windowsTerminalSettings = "$TargetDir\AppData\Local\packages\$($windowsTerminalPackage.PackageFamilyName)\LocalState\settings.json"
New-Item -Path $windowsTerminalSettings -Type SymbolicLink -Value "$DotfilesDir\windows-terminal\settings.json" -Force
