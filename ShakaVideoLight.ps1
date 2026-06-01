param(
    [string]$Target = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'

$ffmpeg  = Join-Path $PSScriptRoot "ffmpeg.exe"
$ffprobe = Join-Path $PSScriptRoot "ffprobe.exe"

$root = (Resolve-Path $Target).Path
$destRoot = Join-Path $root "hevc"
$logFile  = Join-Path $root "hevc_log.csv"

$skipIfAlreadyHevc = $true
$deleteIfNotSmaller = $true

$nvencPreset = "p5"
$cq = 19

$reencodeAudio = $false
$audioBitrate  = "160k"

foreach ($tool in @($ffmpeg, $ffprobe)) {
    if (-not (Test-Path $tool)) {
        throw "No se encontro: $tool"
    }
}

New-Item -ItemType Directory -Force -Path $destRoot | Out-Null
$destPrefix = $destRoot.TrimEnd('\') + '\'

$files = @(
    Get-ChildItem -Path $root -Recurse -File | Where-Object {
        $_.Extension -in '.mp4', '.MP4' -and
        -not $_.FullName.StartsWith($destPrefix, [System.StringComparison]::OrdinalIgnoreCase)
    }
)

if ($files.Count -eq 0) {
    Write-Host "No se encontraron archivos MP4."
    exit
}

Write-Host "Se encontraron $($files.Count) archivo(s)."
Write-Host "Origen : $root"
Write-Host "Destino: $destRoot"
Write-Host ""

$results = [System.Collections.Generic.List[object]]::new()

for ($i = 0; $i -lt $files.Count; $i++) {
    $file = $files[$i]

    Write-Progress `
        -Activity "Convirtiendo videos" `
        -Status "$($i + 1) de $($files.Count): $($file.Name)" `
        -PercentComplete ((($i + 1) / $files.Count) * 100)

    $sourceFile = $file.FullName
    $sourceDir  = $file.DirectoryName
    $relDir     = $sourceDir.Substring($root.Length).TrimStart('\')
    $targetDir  = if ($relDir) { Join-Path $destRoot $relDir } else { $destRoot }
    $out        = Join-Path $targetDir $file.Name
    $tmpOut     = Join-Path $targetDir ($file.BaseName + ".tmp" + $file.Extension)

    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    if (Test-Path $out) {
        Write-Host "Ya existe, salteando: $out"
        $results.Add([pscustomobject]@{
            Archivo   = $sourceFile
            Estado    = "Ya existia"
            OrigenMB  = [math]::Round($file.Length / 1MB, 2)
            SalidaMB  = ""
            AhorroPct = ""
        })
        continue
    }

    $codec = (& $ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=nw=1:nk=1 $sourceFile | Select-Object -First 1).Trim()

    if ($skipIfAlreadyHevc -and $codec -eq 'hevc') {
        Write-Host "Ya es HEVC, salteando: $sourceFile"
        $results.Add([pscustomobject]@{
            Archivo   = $sourceFile
            Estado    = "Salteado (ya era HEVC)"
            OrigenMB  = [math]::Round($file.Length / 1MB, 2)
            SalidaMB  = ""
            AhorroPct = ""
        })
        continue
    }

    if (Test-Path $tmpOut) {
        Remove-Item $tmpOut -Force
    }

    Write-Host ""
    Write-Host "----------------------------------------"
    Write-Host "Archivo $($i + 1) de $($files.Count)"
    Write-Host "Origen : $sourceFile"
    Write-Host "Destino: $out"
    Write-Host "Codec  : $codec -> hevc"
    Write-Host "----------------------------------------"

    $args = @(
        '-hide_banner',
        '-y',
        '-i', $sourceFile,
        '-map', '0:v',
        '-map', '0:a?',
        '-c:v', 'hevc_nvenc',
        '-preset', $nvencPreset,
        '-cq', "$cq",
        '-b:v', '0'
    )

    if ($reencodeAudio) {
        $args += @('-c:a', 'aac', '-b:a', $audioBitrate)
    } else {
        $args += @('-c:a', 'copy')
    }

    $args += @(
        '-map_metadata', '0',
        '-map_chapters', '0',
        '-movflags', '+faststart',
        '-stats',
        $tmpOut
    )

    & $ffmpeg @args
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0 -or -not (Test-Path $tmpOut)) {
        Write-Host "ERROR al convertir: $sourceFile"
        if (Test-Path $tmpOut) {
            Remove-Item $tmpOut -Force
        }

        $results.Add([pscustomobject]@{
            Archivo   = $sourceFile
            Estado    = "Error ffmpeg"
            OrigenMB  = [math]::Round($file.Length / 1MB, 2)
            SalidaMB  = ""
            AhorroPct = ""
        })
        continue
    }

    $srcSize = (Get-Item $sourceFile).Length
    $newSize = (Get-Item $tmpOut).Length

    if ($deleteIfNotSmaller -and $newSize -ge $srcSize) {
        Write-Host "No ahorro espacio, se elimina salida: $tmpOut"
        Remove-Item $tmpOut -Force

        $results.Add([pscustomobject]@{
            Archivo   = $sourceFile
            Estado    = "Descartado (no mas chico)"
            OrigenMB  = [math]::Round($srcSize / 1MB, 2)
            SalidaMB  = [math]::Round($newSize / 1MB, 2)
            AhorroPct = 0
        })
        continue
    }

    Move-Item -Force $tmpOut $out

    $savedPct = [math]::Round((1 - ($newSize / $srcSize)) * 100, 2)

    Write-Host "OK - ahorro: $savedPct %"
    Write-Host ""

    $results.Add([pscustomobject]@{
        Archivo   = $sourceFile
        Estado    = "Convertido"
        OrigenMB  = [math]::Round($srcSize / 1MB, 2)
        SalidaMB  = [math]::Round($newSize / 1MB, 2)
        AhorroPct = $savedPct
    })
}

$results | Export-Csv -Path $logFile -NoTypeInformation -Encoding UTF8

Write-Progress -Activity "Convirtiendo videos" -Completed
Write-Host ""
Write-Host "Proceso terminado."
Write-Host "Log: $logFile"