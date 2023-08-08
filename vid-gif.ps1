# Uses ffmpeg.exe to convert a video file into a GIF using Lanczos scaling algorithm.
function mp4_to_gif {

	# generate a custom color palette from input video to boost gif quality
	.\ffmpeg.exe -ss $START_TIME -t $DURATION -i $VIDEO_URI -vf "fps=20,scale=200:-1:flags=lanczos,palettegen" palette.png

	# filter_complex can be adjusted:
	# fps sets frame rate; scale resizes output width in px
	.ffmpeg.exe -ss $START_TIME -t $DURATION -i $VIDEO_URI -i palette.png -filter_complex "fps=20,scale=400:-1:flags=lanczos[x];x][1:v]paletteuse" $OUTPUT_GIF

	# delete temporary pallete
	ri palette.png
}

$START_TIME = Read-Host "Start time (00:00:00.000)?`n"

$DURATION = Read-Host "Duration (seconds)?`n"
if ($DURATION -eq '')
{
	$DURATION = 10
}

$VIDEO_URI = Read-Host "Video URI?`n"

$OUTPUT_GIF = Read-Host "Output GIF filename?`n"

mp4_to_gif($START_TIME, $DURATION, $VIDEO_URI, $OUTPUT_GIF)
