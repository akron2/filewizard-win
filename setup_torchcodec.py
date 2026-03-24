#!/usr/bin/env python
"""
Setup script to copy FFmpeg DLLs to torchcodec site-packages directory.
This is required for torchcodec to work on Windows.

This script handles the case where torchcodec cannot be imported without DLLs
by finding the torchcodec directory through other means.
"""
import sys
import os
import shutil
from pathlib import Path


def find_torchcodec_dir():
    """Find the torchcodec site-packages directory without importing it."""
    # Try to find torchcodec by looking in site-packages
    import site
    site_packages = site.getsitepackages()
    
    for sp in site_packages:
        torchcodec_path = os.path.join(sp, "torchcodec")
        if os.path.isdir(torchcodec_path):
            # Verify it's a valid torchcodec directory
            init_file = os.path.join(torchcodec_path, "__init__.py")
            if os.path.isfile(init_file):
                print(f"Found torchcodec directory at: {torchcodec_path}")
                return torchcodec_path
    
    # If that fails, try importing (this may fail without DLLs)
    try:
        import torchcodec
        return os.path.dirname(torchcodec.__file__)
    except (ImportError, OSError):
        return None


def find_ffmpeg_bin():
    """Find the FFmpeg bin directory from PATH or local folder."""
    # Check local ffmpeg_temp folder first
    if os.path.exists("./ffmpeg_temp"):
        for item in os.listdir("./ffmpeg_temp"):
            item_path = os.path.join("./ffmpeg_temp", item)
            if os.path.isdir(item_path) and item.startswith("ffmpeg-"):
                ffmpeg_bin = os.path.join(item_path, "bin")
                if os.path.exists(os.path.join(ffmpeg_bin, "ffmpeg.exe")):
                    return ffmpeg_bin
    
    # Check PATH
    for path in os.environ.get("PATH", "").split(os.pathsep):
        ffmpeg_path = os.path.join(path, "ffmpeg.exe")
        if os.path.exists(ffmpeg_path):
            return path
    
    return None


def copy_ffmpeg_dlls(ffmpeg_bin, torchcodec_dir):
    """Copy all FFmpeg DLLs to torchcodec directory to support any FFmpeg version."""
    copied = 0
    not_found = []
    
    # List all DLLs in the FFmpeg bin directory
    dlls = [f for f in os.listdir(ffmpeg_bin) if f.casefold().endswith('.dll')]
    
    if not dlls:
        print(f"  Warning: No DLLs found in {ffmpeg_bin}")
        return 0, ["No DLLs found"]
        
    for dll in dlls:
        src = os.path.join(ffmpeg_bin, dll)
        dst = os.path.join(torchcodec_dir, dll)
        
        try:
            shutil.copy2(src, dst)
            print(f"  Copied {dll}")
            copied += 1
        except Exception as e:
            print(f"  Failed to copy {dll}: {e}")
            not_found.append(dll)
            
    return copied, not_found


def main():
    print("Setting up torchcodec for Windows...")
    
    # Find torchcodec directory
    torchcodec_dir = find_torchcodec_dir()
    if torchcodec_dir is None:
        print("torchcodec is not installed. Skipping setup.")
        print("Install torchcodec with: pip install torchcodec")
        return 0
    
    print(f"Found torchcodec at: {torchcodec_dir}")
    
    # Find FFmpeg bin directory
    ffmpeg_bin = find_ffmpeg_bin()
    if ffmpeg_bin is None:
        print("FFmpeg not found. Please run run.bat first to download FFmpeg.")
        print("Or install FFmpeg and add it to your PATH.")
        return 1
    
    print(f"Found FFmpeg at: {ffmpeg_bin}")
    
    # Copy DLLs
    print(f"Copying DLLs to {torchcodec_dir}...")
    copied, not_found = copy_ffmpeg_dlls(ffmpeg_bin, torchcodec_dir)
    
    if copied > 0:
        print(f"\nSuccessfully copied {copied} DLL(s) to torchcodec directory.")
        if not_found:
            print(f"Note: {len(not_found)} DLL(s) not found: {', '.join(not_found)}")
        return 0
    else:
        print("\nNo DLLs were copied. torchcodec may not work correctly.")
        return 1


if __name__ == "__main__":
    sys.exit(main())
