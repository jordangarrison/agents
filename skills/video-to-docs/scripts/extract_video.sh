#!/usr/bin/env bash
#
# Extract frames and transcription from a video file for documentation generation.
#
# Usage:
#   extract_video.sh <video_path> [output_dir] [fps] [whisper_model]
#
# Example:
#   extract_video.sh walkthrough.mp4 ./extracted 0.2 base
#
# GPU Support:
#   Automatically detects and uses available GPU acceleration:
#   - NVIDIA: CUDA for ffmpeg, CUDA for whisper
#   - AMD: VA-API for ffmpeg, ROCm/HIP for whisper
#   - Intel: VA-API for ffmpeg
#   - macOS: VideoToolbox for ffmpeg, MPS for whisper
#   Falls back to CPU if GPU unavailable or fails.
#

set -euo pipefail

# =============================================================================
# GPU Detection Functions
# =============================================================================

# Detect available GPU type
# Returns: nvidia, amd, intel, apple, or empty string for none/unknown
detect_gpu() {
  # Check NVIDIA
  if command -v nvidia-smi &>/dev/null && nvidia-smi &>/dev/null; then
    echo "nvidia"
    return
  fi

  # Check AMD (ROCm)
  if command -v rocm-smi &>/dev/null && rocm-smi &>/dev/null; then
    echo "amd"
    return
  fi

  # Check for AMD via lspci (fallback without ROCm)
  if command -v lspci &>/dev/null; then
    if lspci 2>/dev/null | grep -iq "VGA.*AMD\|Display.*AMD\|VGA.*Radeon\|Display.*Radeon"; then
      echo "amd"
      return
    fi
  fi

  # Check Intel (VA-API)
  if command -v vainfo &>/dev/null && vainfo &>/dev/null 2>&1; then
    # Verify it's Intel VA-API (not AMD/NVIDIA)
    if vainfo 2>/dev/null | grep -iq "Intel"; then
      echo "intel"
      return
    fi
  fi

  # Check macOS (Apple Silicon or Intel with VideoToolbox)
  if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "apple"
    return
  fi

  echo ""
}

# Detect ffmpeg hardware acceleration method based on GPU and available hwaccels
# Returns: cuda, vaapi, videotoolbox, or empty string for CPU fallback
detect_ffmpeg_hwaccel() {
  local gpu_type="$1"
  local available_hwaccels

  # Get list of available hwaccels from ffmpeg
  available_hwaccels=$(ffmpeg -hwaccels 2>/dev/null | tail -n +2 | tr '\n' ' ' || echo "")

  case "$gpu_type" in
    nvidia)
      if [[ "$available_hwaccels" == *"cuda"* ]]; then
        echo "cuda"
        return
      fi
      # Try nvdec as alternative
      if [[ "$available_hwaccels" == *"nvdec"* ]]; then
        echo "nvdec"
        return
      fi
      ;;
    amd|intel)
      if [[ "$available_hwaccels" == *"vaapi"* ]]; then
        echo "vaapi"
        return
      fi
      ;;
    apple)
      if [[ "$available_hwaccels" == *"videotoolbox"* ]]; then
        echo "videotoolbox"
        return
      fi
      ;;
  esac

  echo ""
}

# Detect whisper device for PyTorch
# Returns: cuda, mps, cpu
detect_whisper_device() {
  local gpu_type="$1"

  # Check if PyTorch can see a GPU
  if command -v python3 &>/dev/null; then
    case "$gpu_type" in
      nvidia)
        # Check CUDA availability
        if python3 -c "import torch; exit(0 if torch.cuda.is_available() else 1)" 2>/dev/null; then
          echo "cuda"
          return
        fi
        ;;
      amd)
        # Check ROCm/HIP availability (presents as CUDA in PyTorch)
        if python3 -c "import torch; exit(0 if torch.cuda.is_available() else 1)" 2>/dev/null; then
          echo "cuda"
          return
        fi
        ;;
      apple)
        # Check MPS (Metal Performance Shaders) for Apple Silicon
        if python3 -c "import torch; exit(0 if torch.backends.mps.is_available() else 1)" 2>/dev/null; then
          echo "mps"
          return
        fi
        ;;
    esac
  fi

  echo "cpu"
}

# Get GPU name for display
get_gpu_name() {
  local gpu_type="$1"

  case "$gpu_type" in
    nvidia)
      nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1 || echo "NVIDIA GPU"
      ;;
    amd)
      if command -v rocm-smi &>/dev/null; then
        rocm-smi --showproductname 2>/dev/null | grep -oP "Card series:\s*\K.*" | head -1 || echo "AMD GPU"
      else
        lspci 2>/dev/null | grep -i "VGA.*AMD\|Display.*AMD\|VGA.*Radeon\|Display.*Radeon" | sed 's/.*: //' | head -1 || echo "AMD GPU"
      fi
      ;;
    intel)
      lspci 2>/dev/null | grep -i "VGA.*Intel\|Display.*Intel" | sed 's/.*: //' | head -1 || echo "Intel GPU"
      ;;
    apple)
      if [[ "$(uname -m)" == "arm64" ]]; then
        echo "Apple Silicon"
      else
        echo "Apple (VideoToolbox)"
      fi
      ;;
    *)
      echo "None detected"
      ;;
  esac
}

# =============================================================================
# Main Script
# =============================================================================

VIDEO="${1:?Usage: extract_video.sh <video> [output_dir] [fps] [whisper_model]}"
OUTPUT_DIR="${2:-./video_extracted}"
FPS="${3:-0.2}"
WHISPER_MODEL="${4:-base}"

# Check dependencies
for cmd in ffmpeg whisper; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "Error: $cmd not found" >&2
    exit 1
  fi
done

if [[ ! -f "$VIDEO" ]]; then
  echo "Error: Video file not found: $VIDEO" >&2
  exit 1
fi

# Detect GPU acceleration
GPU_TYPE=$(detect_gpu)
FFMPEG_HWACCEL=$(detect_ffmpeg_hwaccel "$GPU_TYPE")
WHISPER_DEVICE=$(detect_whisper_device "$GPU_TYPE")
GPU_NAME=$(get_gpu_name "$GPU_TYPE")

# Print GPU configuration
echo "=== GPU Configuration ==="
echo "  GPU: $GPU_NAME"
echo "  FFmpeg hwaccel: ${FFMPEG_HWACCEL:-cpu (software)}"
echo "  Whisper device: $WHISPER_DEVICE"
echo ""

mkdir -p "$OUTPUT_DIR/frames"

# Extract frames with hardware acceleration if available
echo "Extracting frames at $FPS fps..."
if [[ -n "$FFMPEG_HWACCEL" ]]; then
  # Try hardware accelerated decoding first
  if ! ffmpeg -hwaccel "$FFMPEG_HWACCEL" -i "$VIDEO" -vf "fps=$FPS" -q:v 2 "$OUTPUT_DIR/frames/frame_%04d.png" -y 2>/dev/null; then
    echo "  Hardware acceleration failed, falling back to CPU..."
    ffmpeg -i "$VIDEO" -vf "fps=$FPS" -q:v 2 "$OUTPUT_DIR/frames/frame_%04d.png" -y 2>/dev/null
  fi
else
  ffmpeg -i "$VIDEO" -vf "fps=$FPS" -q:v 2 "$OUTPUT_DIR/frames/frame_%04d.png" -y 2>/dev/null
fi

FRAME_COUNT=$(ls -1 "$OUTPUT_DIR/frames/"frame_*.png 2>/dev/null | wc -l)
echo "Extracted $FRAME_COUNT frames"

# Extract audio
echo "Extracting audio..."
ffmpeg -i "$VIDEO" -vn -acodec pcm_s16le -ar 16000 -ac 1 "$OUTPUT_DIR/audio.wav" -y 2>/dev/null

# Transcribe with GPU acceleration if available
echo "Transcribing with Whisper ($WHISPER_MODEL model on $WHISPER_DEVICE)..."
whisper "$OUTPUT_DIR/audio.wav" --model "$WHISPER_MODEL" --device "$WHISPER_DEVICE" --output_format txt --output_dir "$OUTPUT_DIR" 2>/dev/null

# Rename whisper output
mv "$OUTPUT_DIR/audio.txt" "$OUTPUT_DIR/transcript.txt" 2>/dev/null || true

echo ""
echo "✓ Done! Output in $OUTPUT_DIR"
echo "  - $FRAME_COUNT frames in ./frames/"
echo "  - Transcript: ./transcript.txt"
