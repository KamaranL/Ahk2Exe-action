## Ahk2Exe install & compile

Write-Output "::group::powershell $($PSCommandPath)"

$global:ProgressPreference = 'SilentlyContinue'
$Base = [pscustomobject]@{
    32 = $null
    64 = $null
}

function InstallAhk {
    if (Get-Command Ahk2Exe.exe -ErrorAction SilentlyContinue) {
        "`"Ahk2Exe`" already installed"

        if ($Ahk32 = (Get-Command AutoHotkey32.exe -ErrorAction SilentlyContinue)) {
            "`"AutoHotkey32`" already installed"
            $script:Base.32 = $Ahk32.Path
        }
        if ($Ahk64 = (Get-Command AutoHotkey64.exe -ErrorAction SilentlyContinue)) {
            "`"AutoHotkey64`" already installed"
            $script:Base.64 = $Ahk64.Path
        }

        return
    }

    function GetAssetUrl {
        param (
            [Parameter(Mandatory,
                Position = 0)]
            [string]
            $OwnerRepo,

            [string]
            $AssetName
        )

        $Url = "$env:GITHUB_API_URL/repos/$OwnerRepo/releases/latest"
        $Res = ((Invoke-WebRequest $Url).Content | ConvertFrom-Json).assets

        if ($AssetName) {
            $Res = $Res | Where-Object {$_.name -like $AssetName} | Select-Object -First 1
        }

        return $Res.browser_download_url
    }

    "AutoHotkey not installed, installing..."
    Invoke-WebRequest `
    (GetAssetUrl 'AutoHotkey/AutoHotkey' -AssetName 'AutoHotkey*.zip') `
        -OutFile $env:RUNNER_TOOL_CACHE\ahk.zip

    Invoke-WebRequest `
    (GetAssetUrl 'AutoHotkey/Ahk2Exe' -AssetName 'Ahk2Exe*.zip') `
        -OutFile $env:RUNNER_TOOL_CACHE\ahk2exe.zip

    "Extracting Ahk2Exe and adding to PATH"
    $USeconds = Get-Date -UFormat '%s'
    $DestinationPath = "$env:RUNNER_TOOL_CACHE\ahk2exe_$USeconds"
    $CompilerPath = "$DestinationPath\Compiler"

    Expand-Archive $env:RUNNER_TOOL_CACHE\ahk.zip -DestinationPath $DestinationPath -Force
    Expand-Archive $env:RUNNER_TOOL_CACHE\ahk2exe.zip -DestinationPath $CompilerPath -Force

    "$CompilerPath" | Out-File $env:GITHUB_PATH -Append

    $script:Base.32 = "$DestinationPath\AutoHotkey32.exe"
    $script:Base.64 = "$DestinationPath\AutoHotkey64.exe"
}

function CompileScript {
    $Params = @(
        '/in'
        $env:INPUTS_IN
        '/out'
        $env:INPUTS_OUT
        '/silent'
        'verbose'
        '/base'
    )

    if ($env:INPUTS_ARCH -eq 'x86') {
        $Params = $($Params; $script:Base.32)
    } else {
        $Params = $($Params; $script:Base.64)
    }
    if ($env:INPUTS_ICON) {
        $Params = $($Params; @('/icon', $env:INPUTS_ICON))
    }
    if ($env:INPUTS_RESOURCE_ID) {
        $Params = $($Params; @('/resourceid', $env:INPUTS_RESOURCE_ID))
    }

    $Placeholder = New-Item $env:INPUTS_OUT -ItemType File -Force
    Remove-Item $Placeholder -Force

    Ahk2exe.exe $Params | Out-Host

    if ($?) {
        $InFile = Get-Item $env:INPUTS_IN
        $OutFile = Get-Item $env:INPUTS_OUT
        $OutputKey = "$($InFile.Name.Replace('.', '_'))-$env:INPUTS_ARCH".ToLower()

        "Successfully compiled `"$($InFile.FullName)`" to `"$($OutFile.FullName)`""
        "$OutputKey=$($OutFile.FullName)" | Out-File $env:GITHUB_OUTPUT -Append
    } else {throw [System.ArgumentException]::new('One or more arguments provided are not valid.')}
}

try {
    InstallAhk

    CompileScript
} catch {
    Write-Output "::error::$($_.Exception)"
    Write-Output "::endgroup::"

    exit 1
}

Write-Output "::endgroup::"

exit 0
