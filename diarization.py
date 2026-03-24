"""
Speaker Diarization Module
Separates audio by speakers using pyannote.audio
"""
import logging
import webbrowser
import time
from pathlib import Path
from typing import List, Dict, Any, Optional

logger = logging.getLogger(__name__)

# Optional dependency handling
try:
    from pyannote.audio import Pipeline
    from pyannote.audio.pipelines.utils.hook import ProgressHook
    _HAS_PYANNOTE = True
except ImportError:
    _HAS_PYANNOTE = False
    Pipeline = None
    ProgressHook = None


# Hugging Face model URLs for token acceptance
HF_MODEL_ACCEPTANCE_URLS = [
    "https://huggingface.co/pyannote/speaker-diarization-3.1",
    "https://huggingface.co/pyannote/segmentation-3.0"
]


def is_diarization_available() -> bool:
    """Check if diarization is available"""
    return _HAS_PYANNOTE


class TokenRequiredError(Exception):
    """Raised when Hugging Face token is missing or terms are not accepted."""
    pass


def run_diarization(
    audio_path: str,
    hf_token: Optional[str] = None,
    progress_callback: Optional[callable] = None
) -> List[Dict[str, Any]]:
    """
    Run speaker diarization on audio file.
    
    Args:
        audio_path: Path to audio file
        hf_token: Hugging Face token (optional, will try auto-detection)
        progress_callback: Optional callback for progress updates
        
    Returns:
        List of segments with speaker information:
        [
            {"start": 0.0, "end": 5.2, "speaker": "SPEAKER_00", "text": ""},
            {"start": 5.2, "end": 10.5, "speaker": "SPEAKER_01", "text": ""},
            ...
        ]
    """
    if not _HAS_PYANNOTE:
        raise RuntimeError(
            "pyannote.audio is not installed. "
            "Install with: pip install pyannote.audio pyannote.pipeline"
        )
    
    logger.info(f"Starting diarization for: {audio_path}")
    
    try:
        # Try to load pipeline with auto-detected token
        pipeline = None
        token_used = hf_token
        
        # First attempt: try with provided token or auto-detect
        try:
            if hf_token:
                logger.info("Using provided Hugging Face token")
            else:
                logger.info("Attempting to use auto-detected Hugging Face token")
            
            pipeline = Pipeline.from_pretrained(
                "pyannote/speaker-diarization-3.1",
                use_auth_token=hf_token
            )
        except Exception as e:
            error_msg = str(e)
            logger.warning(f"Initial pipeline load failed: {e}")
            
            if "token" in error_msg.lower() or "accept" in error_msg.lower() or "gated" in error_msg.lower():
                raise TokenRequiredError(
                    "Hugging Face token is missing or you need to accept the model usage terms. "
                    "Please provide a valid token and ensure terms are accepted."
                )
            else:
                raise
        
        if pipeline is None:
            raise RuntimeError("Failed to load pyannote pipeline")
        
        # Run diarization
        logger.info("Running speaker diarization...")
        print("Processing audio with pyannote.audio...")
        diarization = pipeline(audio_path)
        
        # Convert to list of segments
        segments = []
        for turn, _, speaker in diarization.itertracks(yield_label=True):
            segments.append({
                "start": turn.start,
                "end": turn.end,
                "speaker": speaker,
                "text": ""  # Will be filled by transcription
            })
        
        logger.info(f"Diarization completed: {len(segments)} segments, {len(set(s['speaker'] for s in segments))} speakers")
        print(f"✓ Found {len(set(s['speaker'] for s in segments))} speakers in {len(segments)} segments\n")
        return segments
        
    except Exception as e:
        logger.error(f"Diarization failed: {e}")
        raise


def merge_transcription_with_diarization(
    transcription_segments: List[Dict[str, Any]],
    diarization_segments: List[Dict[str, Any]]
) -> List[Dict[str, Any]]:
    """
    Merge transcription text with diarization speaker labels.
    
    Args:
        transcription_segments: List of {"start": float, "end": float, "text": str}
        diarization_segments: List of {"start": float, "end": float, "speaker": str}
        
    Returns:
        List of {"start": float, "end": float, "speaker": str, "text": str}
    """
    result = []
    
    for trans_seg in transcription_segments:
        trans_start = trans_seg.get("start", 0)
        trans_end = trans_seg.get("end", 0)
        trans_text = trans_seg.get("text", "").strip()
        
        # Find overlapping diarization segments
        speaker_counts = {}
        for diar_seg in diarization_segments:
            diar_start = diar_seg.get("start", 0)
            diar_end = diar_seg.get("end", 0)
            speaker = diar_seg.get("speaker", "UNKNOWN")
            
            # Check overlap
            if trans_start < diar_end and trans_end > diar_start:
                # Calculate overlap duration
                overlap_start = max(trans_start, diar_start)
                overlap_end = min(trans_end, diar_end)
                overlap_duration = overlap_end - overlap_start
                
                if speaker not in speaker_counts:
                    speaker_counts[speaker] = 0
                speaker_counts[speaker] += overlap_duration
        
        # Assign speaker with most overlap
        if speaker_counts:
            primary_speaker = max(speaker_counts, key=speaker_counts.get)
        else:
            primary_speaker = "UNKNOWN"
        
        result.append({
            "start": trans_start,
            "end": trans_end,
            "speaker": primary_speaker,
            "text": trans_text
        })
    
    return result


def format_diarized_output(
    merged_segments: List[Dict[str, Any]],
    output_format: str = "txt"
) -> str:
    """
    Format diarized transcription for output.
    
    Args:
        merged_segments: List of {"start": float, "end": float, "speaker": str, "text": str}
        output_format: "txt" or "srt"
        
    Returns:
        Formatted string
    """
    if output_format == "srt":
        return _format_srt_diarized(merged_segments)
    else:
        return _format_txt_diarized(merged_segments)


def _format_txt_diarized(segments: List[Dict[str, Any]]) -> str:
    """Format as plain text with speaker labels"""
    lines = []
    current_speaker = None
    
    for seg in segments:
        speaker = seg.get("speaker", "UNKNOWN")
        text = seg.get("text", "").strip()
        
        if speaker != current_speaker:
            lines.append(f"\n[{speaker}]:")
            current_speaker = speaker
        
        lines.append(text)
    
    return "\n".join(lines)


def _format_srt_diarized(segments: List[Dict[str, Any]]) -> str:
    """Format as SRT with speaker labels"""
    lines = []
    
    for i, seg in enumerate(segments, 1):
        speaker = seg.get("speaker", "UNKNOWN")
        text = seg.get("text", "").strip()
        start = seg.get("start", 0)
        end = seg.get("end", 0)
        
        # Format timestamps
        start_str = _format_srt_time(start)
        end_str = _format_srt_time(end)
        
        lines.append(str(i))
        lines.append(f"{start_str} --> {end_str}")
        lines.append(f"[{speaker}]: {text}")
        lines.append("")
    
    return "\n".join(lines)


def _format_srt_time(seconds: float) -> str:
    """Convert seconds to SRT timestamp format"""
    hours = int(seconds // 3600)
    minutes = int((seconds % 3600) // 60)
    secs = int(seconds % 60)
    millis = int((seconds % 1) * 1000)
    
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"
