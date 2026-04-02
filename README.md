# vid-gif

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue?logo=powershell)](https://github.com/PowerShell/PowerShell)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![ffmpeg](https://img.shields.io/badge/ffmpeg-required-red?logo=ffmpeg)](https://ffmpeg.org)

> PowerShell script to convert video clips to high-quality animated GIFs using ffmpeg and Lanczos scaling.

Generate optimized GIFs from MP4/MOV/AVI files with two-pass palette generation for accurate colors and sharp resizing. Ideal for creating shareable clips, documentation demos, or social media content.

---

## ✨ Features

- 🎨 **Two-Pass Palette Generation**: Uses ffmpeg's `palettegen`/`paletteuse` for accurate GIF colors
- 🔍 **Lanczos Scaling**: High-quality resampling algorithm for sharp output
- ⚙️ **Configurable**: Adjust FPS, output width, start time, and duration
- 🛡️ **Input Validation**: Validates file paths, time formats, and parameter ranges
- 🧹 **Automatic Cleanup**: Temporary palette files are deleted after conversion
- 💬 **Interactive or Scripted**: Run with prompts or supply parameters directly

---

## ⚠️ Requirements

| Component | Details |
|-----------|---------|
| **Operating System** | Windows 10/11, Windows Server 2016+ |
| **PowerShell** | 5.1 or later (Windows PowerShell) |
| **ffmpeg** | [Download from ffmpeg.org](https://ffmpeg.org/download.html) or install via package manager |

### Install ffmpeg (Optional Methods)

```powershell
# Via Chocolatey (Admin PowerShell)
choco install ffmpeg

# Via Scoop
scoop install ffmpeg

# Manual: Download build, extract, and add ffmpeg.exe to your PATH
```

> 🔍 Verify installation: `ffmpeg -version`

---

## 📦 Installation

1. **Download the script**:
   ```powershell
   # Save to your scripts directory
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/yourusername/vid-gif/main/vid-gif.ps1" -OutFile "$HOME\Scripts\vid-gif.ps1"
   ```

2. **Unblock the script** (if downloaded from the internet):
   ```powershell
   Unblock-File -Path "$HOME\Scripts\vid-gif.ps1"
   ```

3. **(Optional) Add to PATH** for easy access:
   ```powershell
   # Add scripts folder to user PATH
   $env:Path += ";$HOME\Scripts"
   [Environment]::SetEnvironmentVariable("Path", $env:Path, "User")
   ```

---

## 🚀 Usage

### Interactive Mode (Default)
Run without parameters to be prompted for input:
```powershell
.\vid-gif.ps1
```
```
=== MP4 to GIF Converter ===
Start time (HH:MM:SS.mmm, e.g., 00:01:30.500) [default: 00:00:00.000]: 
Duration in seconds [default: 10]: 
Path to input video file: C:\Videos\demo.mp4
Output GIF filename (e.g., output.gif): demo.gif
Frames per second [default: 20]: 
Output width in pixels (or -1 for original) [default: 400]: 
Path to ffmpeg.exe (or leave blank if in PATH) [default: ffmpeg.exe]: 
✓ GIF created: C:\Videos\demo.gif
  Size: 1245.3 KB
```

### Scripted Mode (Parameters)
```powershell
# Basic conversion with defaults
.\vid-gif.ps1 -VideoPath "input.mp4" -OutputPath "output.gif"

# Custom settings: 5-second clip starting at 1:30, 600px wide, 30 FPS
.\vid-gif.ps1 `
  -VideoPath "C:\Videos\long_clip.mp4" `
  -OutputPath "C:\Output\short.gif" `
  -StartTime "00:01:30.000" `
  -Duration 5 `
  -Width 600 `
  -Fps 30

# Use custom ffmpeg path
.\vid-gif.ps1 -VideoPath "input.mp4" -OutputPath "out.gif" -FfmpegPath "C:\Tools\ffmpeg\bin\ffmpeg.exe"

# Verbose output for troubleshooting
.\vid-gif.ps1 -VideoPath "input.mp4" -OutputPath "out.gif" -Verbose
```

### Parameter Reference

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `-VideoPath` | `string` | *(required)* | Path to input video file (mp4, mov, avi, etc.) |
| `-OutputPath` | `string` | *(required)* | Path for output GIF file (auto-appends `.gif` if missing) |
| `-StartTime` | `string` | `00:00:00.000` | Start time in `HH:MM:SS.mmm` format |
| `-Duration` | `int` | `10` | Clip duration in seconds (1–3600) |
| `-Fps` | `int` | `20` | Frames per second for output GIF (1–60) |
| `-Width` | `int` | `400` | Output width in pixels; `-1` = original size |
| `-FfmpegPath` | `string` | `ffmpeg.exe` | Path to ffmpeg executable if not in PATH |
| `-Verbose` | `switch` | `$false` | Show detailed processing information |

---

## 🔒 Security & Privacy

This script follows security best practices:

- ✅ **Path Validation**: All file paths validated with `Test-Path` before use
- ✅ **No External Network Calls**: All processing happens locally via ffmpeg
- ✅ **Input Sanitization**: Time format and numeric ranges validated with regex/ValidateScript
- ✅ **Controlled Temp Usage**: Palette file created in `$env:TEMP` with random name, auto-deleted
- ✅ **No Credentials**: Script does not handle or store any secrets or API keys

> 🛡️ **Best Practice**: Always review scripts before execution. Run with `-Verbose` first to audit file operations.

---

## ⚠️ Known Limitations

| Limitation | Workaround/Note |
|------------|----------------|
| Windows-only | Uses PowerShell and Windows path conventions; not tested on PowerShell Core/Linux |
| ffmpeg dependency | Requires external ffmpeg binary; ensure it's in PATH or specify `-FfmpegPath` |
| Large video files | Very long durations or high resolutions may produce large GIFs; use `-Duration` and `-Width` to limit |
| No audio support | GIF format does not support audio; audio tracks are ignored |
| Single-file processing | Processes one video at a time; wrap in loop for batch conversion |

---

## 🛠️ Troubleshooting

### ❌ "ffmpeg not found"
```powershell
# Verify ffmpeg is in PATH
Get-Command ffmpeg -ErrorAction SilentlyContinue

# If missing, install via Chocolatey:
choco install ffmpeg

# Or specify path explicitly:
.\vid-gif.ps1 -VideoPath "in.mp4" -OutputPath "out.gif" -FfmpegPath "C:\ffmpeg\bin\ffmpeg.exe"
```

### ❌ "Video file not found" or path errors
- Use absolute paths or ensure relative paths are correct
- Wrap paths with spaces in quotes: `"C:\My Videos\clip.mp4"`
- Verify file extension is supported by ffmpeg (mp4, mov, avi, mkv, etc.)

### ❌ "Palette generation failed" or "GIF generation failed"
- Ensure the video file is not corrupted or DRM-protected
- Try a shorter `-Duration` or different `-StartTime`
- Run with `-Verbose` to see full ffmpeg output for debugging

### ❌ Output GIF is blank or corrupted
- Verify the source video plays correctly in a media player
- Try reducing `-Width` or `-Fps` to lower resource demands
- Check disk space in output directory and `$env:TEMP`

---

## 🤝 Contributing

Contributions welcome! Please follow these guidelines:

1. **Fork** the repository
2. **Create a feature branch**: `git checkout -b feat/your-idea`
3. **Test thoroughly** on Windows 10/11 with various video formats
4. **Follow PowerShell best practices**:
   - Use `Invoke-ScriptAnalyzer` for linting
   - Maintain comment-based help
   - Add parameter validation for new inputs
5. **Submit a Pull Request** with a clear description

### Development Setup
```powershell
# Install PSScriptAnalyzer for code quality checks
Install-Module PSScriptAnalyzer -Scope CurrentUser -Force

# Run analysis
Invoke-ScriptAnalyzer -Path .\vid-gif.ps1 -Recurse

# Test with verbose output
.\vid-gif.ps1 -VideoPath "test.mp4" -OutputPath "test.gif" -Verbose
```

---

## 📄 License

Distributed under the **MIT License**. See [`LICENSE`](LICENSE) for details.

```
MIT License

Copyright (c) 2026 asuspades

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 📬 Support & Feedback

- 🐛 **Bug Reports**: [Open an Issue](https://github.com/asuspades/vid-gif/issues)
- 💡 **Feature Requests**: Use the [Discussions](https://github.com/asuspades/vid-gif/discussions) tab
- 🙋 **Questions**: Start a discussion or check the FAQ below

---

## ❓ FAQ

**Q: Why does the GIF look pixelated or blurry?**  
A: Try increasing `-Width` for higher resolution output, or ensure your source video is high quality. Lanczos scaling preserves sharpness, but upscaling low-res sources will not improve detail.

**Q: Can I convert multiple videos at once?**  
A: Not natively, but you can wrap the script in a PowerShell loop:
```powershell
Get-ChildItem "C:\Videos\*.mp4" | ForEach-Object {
    .\vid-gif.ps1 -VideoPath $_.FullName -OutputPath "C:\Gifs\$($_.BaseName).gif" -Duration 5
}
```

**Q: Does this support transparent backgrounds?**  
A: GIF supports binary transparency, but this script does not currently extract or preserve alpha channels. For transparent GIFs, additional ffmpeg filters would be needed.

**Q: Why is the output file so large?**  
A: GIFs are inefficient for video. Reduce `-Fps`, `-Width`, or `-Duration` to lower file size. For longer clips, consider using MP4/WebM instead.

**Q: Can I use this on Linux or macOS?**  
A: The script uses Windows PowerShell conventions. With minor path adjustments and PowerShell Core, it may work, but ffmpeg must be installed separately.

---

> 💡 **Pro Tip**: For even smaller GIFs, add the `dither=none` option to the palettegen filter by editing the script's `$paletteArgs` line:
> ```powershell
> "-vf", "fps=$Fps,$ScaleFilter,palettegen=dither=none"
> ```

---

*Made with ❤️ for content creators, educators, and developers who love shareable clips.*  
*Report issues or suggest improvements on [GitHub](https://github.com/asuspades/vid-gif).*
