## Test script to isolate environment variables when running locally
Clear-Host

$Command = {
    $env:TEST_ROOT = '.\__testenv'
    $env:GITHUB_API_URL = 'https://api.github.com'
    $env:GITHUB_PATH = "$env:TEST_ROOT\github"
    $env:INPUTS_IN = 'src\main.ahk'
    $env:INPUTS_OUT = 'dist\main.exe'
    # $env:INPUTS_ICON =
    $env:INPUTS_ARCH = 'x64'
    # $env:INPUTS_RESOURCE_ID =
    $env:RUNNER_TOOL_CACHE = "$env:TEST_ROOT\hostedtoolcache"

    Remove-Item $env:TEST_ROOT -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $env:INPUTS_OUT -Force -ErrorAction SilentlyContinue
    $null = New-Item $env:RUNNER_TOOL_CACHE -ItemType Directory -Force -ErrorAction SilentlyContinue

    &.\Main.ps1
}

pwsh.exe -Command "&{$Command}"
