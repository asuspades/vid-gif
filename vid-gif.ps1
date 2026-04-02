<#
.SYNOPSIS
    Converts a video file to an animated GIF using ffmpeg with Lanczos scaling.

.DESCRIPTION
    This script uses ffmpeg to generate a high-quality GIF from a video file.
    It employs a two-pass palette generation method for optimal color accuracy
    and uses the Lanczos scaling algorithm for sharp resizing.

.PARAMETER StartTime
    Start time in the format HH:MM:SS.mmm (e.g., 00:01:30.500).

.PARAMETER Duration
    Duration of the clip to convert, in seconds. Default is 10.

.PARAMETER VideoPath
    Full path to the input video file.

.PARAMETER OutputPath
    Full path for the output GIF file.

.PARAMETER Fps
    Frames per second for the output GIF. Default is 20.

.PARAMETER Width
    Output width in pixels. Height is scaled proportionally. Default is 400.
    Use -1 to disable resizing.

.PARAMETER FfmpegPath
    Optional path to ffmpeg.exe if not in current directory or PATH.

.EXAMPLE
    Convert-Mp4ToGif -VideoPath "C:\Videos\clip.mp4" -OutputPath "C:\Output\clip.gif"

.EXAMPLE
    Convert-Mp4ToGif -VideoPath "input.mp4" -OutputPath "out.gif" -StartTime "00:00:05" -Duration 5 -Width 600

.NOTES
    [INSERT LICENSE TYPE HERE]
    Requires: ffmpeg.exe in PATH or specified via -FfmpegPath
    Algorithm: Lanczos scaling for high-quality resampling
    Method: Two-pass palette generation for accurate GIF colors

.LINK
    https://ffmpeg.org
    https://github.com/yourusername/vid-gif
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidatePattern('^\d{2}:\d{2}:\d{2}(\.\d{3})?$')]
    [string]$StartTime = "00:00:00.000",

    [Parameter(Mandatory = $false)]
    [ValidateScript({ $_ -ge 1 -and $_ -le 3600 })]
    [int]$Duration = 10,

    [Parameter(Mandatory = $false)]
    [ValidateScript({
        if (-not (Test-Path $_ -PathType Leaf)) {
            throw "Video file not found: $_"
        }
        $true
    })]
    [string]$VideoPath,

    [Parameter(Mandatory = $false)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [ValidateRange(1, 60)]
    [int]$Fps = 20,

    [Parameter(Mandatory = $false)]
    [ValidateScript({ $_ -eq -1 -or $_ -ge 100 })]
    [int]$Width = 400,

    [Parameter(Mandatory = $false)]
    [string]$FfmpegPath = "ffmpeg.exe"
)

function Convert-Mp4ToGif {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$StartTime,
        
        [Parameter(Mandatory = $true)]
        [int]$Duration,
        
        [Parameter(Mandatory = $true)]
        [string]$VideoPath,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory = $false)]
        [int]$Fps = 20,
        
        [Parameter(Mandatory = $false)]
        [int]$Width = 400,
        
        [Parameter(Mandatory = $false)]
        [string]$FfmpegPath = "ffmpeg.exe"
    )

    # Resolve paths
    $VideoPath = (Resolve-Path $VideoPath -ErrorAction Stop).Path
    $OutputDir = Split-Path $OutputPath -Parent
    if ($OutputDir -and -not (Test-Path $OutputDir -PathType Container)) {
        New-Item -ItemType Directory -Path $OutputDir -Force -ErrorAction Stop | Out-Null
    }
    $OutputPath = (Resolve-Path $OutputDir -ErrorAction Stop).Path + "\" + (Split-Path $OutputPath -Leaf)
    $PalettePath = Join-Path $env:TEMP "gif_palette_$([System.IO.Path]::GetRandomFileName()).png"

    # Validate ffmpeg availability
    if (-not (Get-Command $FfmpegPath -ErrorAction SilentlyContinue)) {
        throw "ffmpeg not found. Please install ffmpeg or specify -FfmpegPath."
    }

    # Build scale filter: -1 maintains aspect ratio
    $ScaleFilter = if ($Width -eq -1) { "scale=-1:-1:flags=lanczos" } else { "scale=$Width`:-1:flags=lanczos" }

    try {
        Write-Verbose "Generating color palette..."
        $paletteArgs = @(
            "-ss", $StartTime,
            "-t", $Duration.ToString(),
            "-i", $VideoPath,
            "-vf", "fps=$Fps,$ScaleFilter,palettegen",
            "-y", $PalettePath
        )
        $result = & $FfmpegPath @paletteArgs 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Palette generation failed: $result"
        }

        Write-Verbose "Applying palette and generating GIF..."
        $gifArgs = @(
            "-ss", $StartTime,
            "-t", $Duration.ToString(),
            "-i", $VideoPath,
            "-i", $PalettePath,
            "-filter_complex", "fps=$Fps,$ScaleFilter[x];[x][1:v]paletteuse",
            "-y", $OutputPath
        )
        $result = & $FfmpegPath @gifArgs 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "GIF generation failed: $result"
        }

        Write-Host "✓ GIF created: $OutputPath" -ForegroundColor Green
        if (Test-Path $OutputPath) {
            $size = [math]::Round((Get-Item $OutputPath).Length / 1KB, 1)
            Write-Host "  Size: $size KB" -ForegroundColor Gray
        }
    }
    catch {
        Write-Error "Conversion failed: $($_.Exception.Message)"
        throw
    }
    finally {
        # Cleanup temporary palette file
        if (Test-Path $PalettePath) {
            Remove-Item $PalettePath -Force -ErrorAction SilentlyContinue
            Write-Verbose "Cleaned up temporary palette file"
        }
    }
}

# Interactive mode: prompt for parameters if not provided via pipeline/args
if (-not $PSBoundParameters.ContainsKey('VideoPath')) {
    Write-Host "=== MP4 to GIF Converter ===" -ForegroundColor Cyan
    
    $StartTime = Read-Host "Start time (HH:MM:SS.mmm, e.g., 00:01:30.500) [default: 00:00:00.000]"
    if (-not $StartTime) { $StartTime = "00:00:00.000" }
    
    $Duration = Read-Host "Duration in seconds [default: 10]"
    if (-not $Duration -or $Duration -eq '') { $Duration = 10 }
    else { $Duration = [int]$Duration }
    
    $VideoPath = Read-Host "Path to input video file"
    while (-not (Test-Path $VideoPath -PathType Leaf)) {
        Write-Warning "File not found. Please try again."
        $VideoPath = Read-Host "Path to input video file"
    }
    
    $OutputPath = Read-Host "Output GIF filename (e.g., output.gif)"
    if (-not $OutputPath.EndsWith('.gif', 'OrdinalIgnoreCase')) {
        $OutputPath += '.gif'
    }
    
    $FpsInput = Read-Host "Frames per second [default: 20]"
    if ($FpsInput -and $FpsInput -match '^\d+$') { $Fps = [int]$FpsInput }
    
    $WidthInput = Read-Host "Output width in pixels (or -1 for original) [default: 400]"
    if ($WidthInput -and $WidthInput -match '^-?\d+$') { $Width = [int]$WidthInput }
    
    $FfmpegPath = Read-Host "Path to ffmpeg.exe (or leave blank if in PATH) [default: ffmpeg.exe]"
    if (-not $FfmpegPath) { $FfmpegPath = "ffmpeg.exe" }
}

# Execute conversion
try {
    Convert-Mp4ToGif @PSBoundParameters
}
catch {
    Write-Error "Script terminated with error: $($_.Exception.Message)"
    exit 1
}
