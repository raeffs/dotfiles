[Console]::InputEncoding = [Text.UTF8Encoding]::new($false)

function Format-Tokens([double] $tokens) {
    if ($tokens -ge 1000000) { return "{0:0.#}M" -f ($tokens / 1000000) }
    if ($tokens -ge 1000) { return "{0:0}k" -f ($tokens / 1000) }
    return "{0:0}" -f $tokens
}

$status = [Console]::In.ReadToEnd() | ConvertFrom-Json
$model = $status.model.display_name
$effort = $status.effort.level
$window = $status.context_window
$context = if ($window.context_window_size) {
    "$(Format-Tokens $window.total_input_tokens) / $(Format-Tokens $window.context_window_size)"
}

if ($env:HC_TERMINAL_ID -and $model) {
    hc label $env:HC_TERMINAL_ID "herdr.model=$model" "herdr.effort=$effort" "herdr.context=$context" *> $null
}
