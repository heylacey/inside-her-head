#!/bin/zsh
# Makes the 5 song moments from "We're Grand" and adds the fuzzy "in her head" sound.
# Each clip starts on the first word of a line and runs to the end of its last line
# (about 10s of singing), so nothing starts or stops mid-word.
# Run:  zsh tools/make_clips.sh        (from the inside-her-head folder)
# Clips land in audio/  (moment-1.mp3 ... moment-6.mp3; moment 4 is the interference)

SONG="$HOME/Library/Mobile Documents/com~apple~CloudDocs/Downloads Archive/We're Grand.mp3"
OUT="$(cd "$(dirname "$0")/.." && pwd)/audio"
mkdir -p "$OUT"

LEAD=0.15          # seconds kept before the first word
TAIL=0.30          # seconds kept after the last word (let it ring)

# ---- How fuzzy it sounds (turn these to taste) ----
LOW_CUT=480        # Hz: cuts the deep bass (higher = thinner, more "through a wall")
HIGH_CUT=2200      # Hz: cuts the sparkle (lower = more muffled)
DRIVE=3.5          # crunch amount (1 = none, 3 = gritty)
HISS=0.024         # tape hiss underneath (0 = none, 0.02 = lots)
WOBBLE=0.13        # cassette wobble depth (0 = none, 0.15 = seasick)
ROOM=0.40          # small-room echo inside her head (0 = dry)

# moment | first word starts | last word ends | the line(s)
CLIPS=(
  "1|0.00|11.55|We've been through fire, we've been through rain / Laugh through the joy, dance through the pain"
  "2|25.66|37.25|A little smoke, the stereo spins / It's us and the stars, nobody wins like we win"
  "3|60.50|70.00|I don't know what the world's made of, but I know how to win it with your love"
  "5|157.80|166.40|I don't care what the world is made of / We were made to rise, made to love"
  "6|195.27|209.90|We create and we climb, we get high / Lose time, but we never lose us / And that's by design  (then the song's own ending)"
)

for row in "${CLIPS[@]}"; do
  IFS='|' read -r n w0 w1 words <<< "$row"
  a=$(echo "$w0 - $LEAD" | bc); [[ "${a:0:1}" == "-" ]] && a=0
  len=$(echo "$w1 + $TAIL - $a" | bc)
  fos=$(echo "$len - 0.35" | bc)
  ffmpeg -v error -y \
    -ss "$a" -t "$len" -i "$SONG" \
    -f lavfi -t "$len" -i "anoisesrc=color=pink:amplitude=$HISS:sample_rate=44100" \
    -filter_complex "
      [0:a]aresample=44100,aformat=channel_layouts=mono,
           highpass=f=$LOW_CUT,lowpass=f=$HIGH_CUT,
           volume=$DRIVE,asoftclip=type=tanh,
           vibrato=f=0.7:d=$WOBBLE,
           aecho=0.85:0.6:23|41:$ROOM|$(echo "$ROOM * 0.6" | bc)[v];
      [1:a]highpass=f=1500,lowpass=f=6000[h];
      [v][h]amix=inputs=2:duration=first:normalize=0,
           loudnorm=I=-17:TP=-1.5:LRA=11,
           afade=t=in:d=0.12,afade=t=out:st=${fos}:d=0.35" \
    -map_metadata -1 -ac 1 -ar 44100 -b:a 160k "$OUT/moment-$n.mp3" \
  && echo "moment $n: ${len}s  —  \"$words\""
done
