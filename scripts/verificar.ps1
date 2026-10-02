param(
    [string]$Flutter = 'flutter',
    [switch]$GerarEvidencias,
    [switch]$SemBuild,
    [switch]$SomenteBuild
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $projectRoot
New-Item -ItemType Directory -Force -Path 'relatorio\logs' | Out-Null

function Invoke-FlutterCheck {
    param([string]$Nome, [string[]]$Argumentos)
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        & $Flutter @Argumentos 2>&1 | ForEach-Object { $_.ToString() } | Tee-Object -FilePath "relatorio\logs\$Nome.txt"
        $exitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $previousPreference
    }
    if ($exitCode -ne 0) {
        throw "A etapa $Nome falhou. Consulte relatorio/logs/$Nome.txt."
    }
}

if (-not $SomenteBuild) {
    Invoke-FlutterCheck -Nome 'versao' -Argumentos @('--version')
    Invoke-FlutterCheck -Nome 'dependencias' -Argumentos @('pub', 'get')
    Invoke-FlutterCheck -Nome 'analise' -Argumentos @('analyze')
    $testArguments = @('test', '--reporter=expanded')
    if ($GerarEvidencias) { $testArguments += '--dart-define=GERAR_EVIDENCIAS=true' }
    Invoke-FlutterCheck -Nome 'testes' -Argumentos $testArguments
}
if (-not $SemBuild) {
    Invoke-FlutterCheck -Nome 'build' -Argumentos @('build', 'apk', '--release')
}
