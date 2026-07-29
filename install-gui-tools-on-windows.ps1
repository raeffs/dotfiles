
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

Install-IfMissing -Command "wt"   -Id "Microsoft.WindowsTerminal"
Install-IfMissing -Command "code" -Id "Microsoft.VisualStudioCode"
