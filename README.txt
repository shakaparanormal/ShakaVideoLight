# Shaka Video Light

Shaka Video Light es un script para convertir videos `.mp4` pesados a **HEVC/H.265** usando **FFmpeg** con aceleración por GPU NVIDIA.

Está pensado para reducir el peso de los videos manteniendo una calidad visual similar a la original.

## ¿Qué hace?

Si tenés una carpeta con videos que querés hacer más livianos, el programa los convierte automáticamente a HEVC/H.265.

El script:

* Busca todos los videos `.mp4` dentro de la carpeta que le indiques.
* Si hay muchos videos, los convierte uno por uno automáticamente.
* También revisa las subcarpetas.
* Crea una carpeta llamada `hevc`.
* Guarda ahí los videos ya convertidos y listos para usar.
* Mantiene el audio original sin recomprimir.
* No borra ni modifica los videos originales.
* Si un video convertido no pesa menos que el original, lo descarta.
* Genera un registro del proceso en `hevc_log.csv`.

## Requisitos

Para usar Shaka Video Light necesitás:

* Windows.
* PowerShell.
* Una GPU NVIDIA compatible con NVENC.
* `ffmpeg.exe`.
* `ffprobe.exe`.

> Importante: `ffmpeg.exe` y `ffprobe.exe` no vienen incluidos en este repositorio porque son archivos externos y pesados. Tenés que descargarlos aparte y copiarlos en la misma carpeta donde están los scripts.

La carpeta final debe quedar así:

```text
ShakaVideoLight/
├── ShakaVideoLight.bat
├── ShakaVideoLight.ps1
├── ffmpeg.exe
└── ffprobe.exe
```

Sin `ffmpeg.exe` y `ffprobe.exe`, el programa no puede convertir videos.

## Cómo se usa

Si tenés videos en una carpeta y querés convertirlos, arrastrá esa carpeta encima del archivo:

```text
ShakaVideoLight.bat
```

Al hacer eso, el programa inicia automáticamente el proceso.

Shaka Video Light va a buscar todos los videos `.mp4` dentro de esa carpeta, los va a convertir a HEVC/H.265 y va a crear una carpeta llamada:

```text
hevc
```

Dentro de `hevc` quedan los videos convertidos, más livianos y listos para usar.

Los videos originales quedan en su carpeta original y no se modifican.

## Ejemplo

Si tenés esta carpeta:

```text
MisVideos/
├── video1.mp4
├── video2.mp4
└── vacaciones/
    └── playa.mp4
```

Arrastrás la carpeta `MisVideos` encima de `ShakaVideoLight.bat`.

Cuando termina, queda así:

```text
MisVideos/
├── video1.mp4
├── video2.mp4
├── vacaciones/
│   └── playa.mp4
└── hevc/
    ├── video1.mp4
    ├── video2.mp4
    └── vacaciones/
        └── playa.mp4
```

## Nota

El script solo conserva una conversión si el archivo resultante pesa menos que el original.

Si no logra reducir el tamaño, elimina esa conversión y mantiene intacto el video original.
