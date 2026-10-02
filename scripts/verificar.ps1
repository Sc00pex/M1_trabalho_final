param(
    [string]$Flutter = 'flutter',
    [switch]$SemBuild,
    [switch]$SomenteBuild
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $projectRoot

function Invoke-FlutterCheck {
    param([string]$Nome, [string[]]$Argumentos)
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $Flutter @Argumentos
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousPreference
    }
    if ($exitCode -ne 0) {
        throw "A etapa $Nome falhou com código $exitCode."
    }
}

if (-not $SomenteBuild) {
    Invoke-FlutterCheck -Nome 'versao' -Argumentos @('--version')
    Invoke-FlutterCheck -Nome 'dependencias' -Argumentos @('pub', 'get')
    Invoke-FlutterCheck -Nome 'analise' -Argumentos @('analyze')
    Invoke-FlutterCheck -Nome 'testes' -Argumentos @('test')
}
if (-not $SemBuild) {
    Invoke-FlutterCheck -Nome 'build' -Argumentos @('build', 'apk', '--release')
}
