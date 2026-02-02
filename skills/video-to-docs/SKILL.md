---
name: video-to-docs
description: Generate documentation from video walkthroughs. Use when given an MP4, MOV, or other video file to document an application, workflow, or process. Extracts frames and audio transcription, then synthesizes both into structured documentation. Triggers on requests like "document this video", "create docs from this walkthrough", or when a video file is provided with documentation intent.
---

# Video to Documentation

Generate documentation from video walkthroughs by extracting visual frames and audio transcription.

## Prerequisites

- `ffmpeg` - for frame and audio extraction
- `whisper` CLI - for audio transcription (install: `pip install openai-whisper`)

## GPU Acceleration

The extraction script automatically detects and uses available GPU hardware:

| GPU Type | FFmpeg Acceleration | Whisper Device |
|----------|-------------------|----------------|
| NVIDIA (CUDA) | `cuda` or `nvdec` | `cuda` |
| AMD (ROCm) | `vaapi` | `cuda` (via HIP) |
| Intel (VA-API) | `vaapi` | `cpu` |
| Apple Silicon | `videotoolbox` | `mps` |
| None/Unknown | CPU (software) | `cpu` |

**Auto-detection behavior:**
- GPU type is detected via `nvidia-smi`, `rocm-smi`, `vainfo`, or `lspci`
- FFmpeg hwaccel is verified against `ffmpeg -hwaccels` output
- Whisper device is verified via PyTorch (`torch.cuda.is_available()`, `torch.backends.mps.is_available()`)
- Falls back to CPU automatically if hardware acceleration fails mid-stream

**Requirements for GPU acceleration:**
- **NVIDIA**: Install CUDA toolkit and ensure `nvidia-smi` works
- **AMD**: Install ROCm and ensure `rocm-smi` works (or have VA-API drivers)
- **Intel**: Install VA-API drivers and ensure `vainfo` works
- **Apple**: VideoToolbox is built into macOS; MPS requires PyTorch with Metal support

## Workflow

### Step 1: Extract Video Content

Run the extraction script on the provided video:

```bash
./scripts/extract_video.sh <video_file> [output_dir] [fps] [whisper_model]

# Example with defaults (output: ./video_extracted, fps: 0.2, model: base)
./scripts/extract_video.sh walkthrough.mp4

# Custom settings
./scripts/extract_video.sh walkthrough.mp4 ./output 0.5 small
```

**Parameters:**
- `fps` (default: 0.2) = 1 frame every 5 seconds (increase for fast-paced videos)
- `whisper_model` (default: base) = tiny|base|small|medium|large

This creates:
```
video_extracted/
├── frames/          # PNG screenshots
│   ├── frame_0001.png
│   ├── frame_0002.png
│   └── ...
├── transcript.txt   # Full transcription
├── audio.wav        # Extracted audio
└── manifest.txt     # Summary
```

### Step 2: Review Extracted Content

1. Read `transcript.txt` to understand the narration flow
2. View frames to identify key UI states and transitions
3. Correlate transcript segments with corresponding frames

### Step 3: Generate Documentation

Synthesize frames and transcript into documentation. Consider:

- **Application overview** - What is being demonstrated?
- **Key screens/states** - Document each significant UI shown in frames
- **User workflows** - Step-by-step procedures from the narration
- **UI elements** - Buttons, forms, navigation referenced in transcript
- **Tips and notes** - Any verbal callouts or warnings mentioned

### Output Formats

Adapt output to user request:

- **User guide** - Step-by-step instructions with screenshots
- **README** - Quick start and feature overview
- **Runbook** - Operational procedures

## Tips

- For fast-paced videos, increase fps (e.g., `--fps 0.5` = 1 frame every 2 seconds)
- For long videos, use `--whisper-model small` or `medium` for better accuracy
- If transcript quality is poor, user may need to provide manual corrections
- Frame timestamps can be inferred from filename sequence and fps rate
