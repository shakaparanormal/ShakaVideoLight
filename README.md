# Shaka Video Light

Shaka Video Light es un script para convertir videos `.mp4` pesados a **HEVC/H.265** usando **FFmpeg** con aceleración por GPU NVIDIA.

Está pensado para reducir el peso de los videos manteniendo una calidad visual similar a la original.

## ¿Qué hace?

Si tenés una carpeta con videos que querés hacer más livianos, el programa los convierte automáticamente a HEVC/H.265.

El script:

- Busca todos los videos `.mp4` dentro de la carpeta que le indiques.
- Si hay muchos videos, los convierte uno por uno automáticamente.
- También revisa las subcarpetas.
- Crea una carpeta llamada `hevc`.
- Guarda ahí los videos ya convertidos y listos para usar.
- Mantiene el audio original sin recomprimir.
- No borra ni modifica los videos originales.
- Si un video convertido no pesa menos que el original, lo descarta.
- Genera un registro del proceso en `hevc_log.csv`.

## Requisitos

Para usar Shaka Video Light necesitás:

- Windows.
- PowerShell.
- Una GPU NVIDIA compatible con NVENC.
- `ffmpeg.exe`.
- `ffprobe.exe`.

Estos archivos deben estar juntos en la misma carpeta:

```text
convertir.bat
convertir.ps1
ffmpeg.exe
ffprobe.exe
