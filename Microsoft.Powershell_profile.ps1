$env:VISUAL="bat"
$env:EDITOR="hx"
$env:YAZI_FILE_ONE="C:\Program Files\Git\usr\bin\file.exe"

function yy {
    $tmpFile = (New-TemporaryFile).FullName
    yazi @args --cwd-file=$tmpFile
    
    $cwd = Get-Content -Path $tmpFile -ErrorAction SilentlyContinue

    if ($cwd -and (Test-Path -Path $cwd -PathType Container) -and $cwd -ne $PWD.Path) {
        # 'Set-Location' (aliased as 'cd') changes the directory.
        Set-Location -Path $cwd
    }

    Remove-Item -Path $tmpFile -Force -ErrorAction SilentlyContinue
}

function aria2p {
    aria2p.exe -p 6800 -s wUr8g4USF7Sx @Args
}

function pandoc {
    $templateroot = "C:\Users\$env:USERNAME\pandoc-themes\"
    pandoc.exe --css "$templateroot\github.css" @Args
}

Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1

Set-Alias -Name py -Value python3.13
Set-Alias -Name python -Value ipython
Set-Alias -Name python3 -Value python3.13
Set-Alias -Name neofetch -Value winfetch # Hehe.
Set-Alias -Name file -Value "C:\Program Files\Git\usr\bin\file.exe"
Set-Alias -Name sudo -Value gsudo
Set-Alias -Name which -Value where.exe

Set-PSReadLineKeyHandler -Chord "Shift+Tab" -Function ForwardWord
oh-my-posh init pwsh --config "C:\Users\$env:USERNAME\pwsh-themes\atomic.omp.json" | Invoke-Expression
