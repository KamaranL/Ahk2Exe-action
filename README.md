# Ahk2Exe Action

> Compile your ".ahk" script into a standalone ".exe" using AutoHotkey's latest Ahk2Exe

[![View License on GitHub](https://badgen.net/github/license/KamaranL/Ahk2Exe-action?cache=3600)](./LICENSE.txt)
[![View Latest Release on GitHub](https://badgen.net/github/release/KamaranL/Ahk2Exe-action/stable?icon=github&label=latest&cache=3600)](https://github.com/KamaranL/Ahk2Exe-action)

- [Ahk2Exe Action](#ahk2exe-action)
  - [Usage](#usage)
    - [Outputs](#outputs)
      - [Examples](#examples)
  - [Acknowledgements](#acknowledgements)

Use this action in order to compile your AutoHotkey (.ahk) scripts into standalone executables.

\*\***This action will <u>only run on Windows</u> runners, it will fail fast otherwise.**

Refer to [AutoHotkey's documentation](https://www.autohotkey.com/docs/v1/Scripts.htm#ahk2exe) for more on AutoHotkey's Ahk2Exe and how it works.

## Usage

```yml
on: push
jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4

      - uses: KamaranL/Ahk2Exe-action@v1
        with:
          in: main.ahk
          out: dist/x86/PastePlus.exe
          icon: assets/icon.ico
          arch: x86

      - uses: KamaranL/Ahk2Exe-action@v1
        with:
          in: main.ahk
          out: dist/x64/PastePlus.exe
          icon: assets/icon.ico
          arch: x64
        id: build-x64

      - run: Write-Output "$env:AHK_BUILD_64"
        # prints out the absolute path to the compiled 64-bit executable
        shell: pwsh
        env:
          AHK_BUILD_X64: ${{ steps.build-x64.outputs.main_ahk-x64 }}
```

### Outputs

This action outputs the absolute path of the compiled standalone .exe using the script's filename as the key, formatted with:

- periods (.) replaced by underscores (_)
- "-${{ inputs.arch }}" appended
- the entire key converted to lowercase

[See below](#examples) for some examples.

#### Examples

| in                  | out                    | arch | outputs key        | outputs value                                   |
| ------------------- | ---------------------- | ---- | ------------------ | ----------------------------------------------- |
| main.ahk            | dist/x64/PastePlus.exe | x64  | main_ahk-x64       | D:\a\PastePlus\PastePlus\dist\x64\PastePlus.exe |
| util/UrlScraper.ahk | ***null***             | x86  | urlscraper_ahk-x86 | ${{ github.workspace }}\util\UrlScraper.exe     |

## Acknowledgements

- Special thanks to [AutoHotkey](https://github.com/AutoHotkey) and its contributors
