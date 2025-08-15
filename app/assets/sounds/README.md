# UFOBeep Alert Sounds

This directory contains the alert sound files for different urgency levels:

## Required Sound Files:

1. **normal_beep.mp3** - Standard single beep for normal alerts (1 witness)
   - Duration: 0.5-1 second
   - Tone: Pleasant, attention-getting but not alarming
   
2. **urgent_warble.mp3** - Urgent warbling sound for multiple witnesses (3+ witnesses)
   - Duration: 2-3 seconds
   - Tone: More urgent, oscillating frequency
   
3. **emergency_siren.mp3** - Emergency siren for mass sightings (10+ witnesses)  
   - Duration: 3-5 seconds
   - Tone: High urgency, impossible to ignore
   
4. **critical_alarm.mp3** - Air raid level alarm for regional events (50+ witnesses)
   - Duration: 5-10 seconds  
   - Tone: Maximum urgency, override all other sounds

## Android Raw Resources:

Copy the MP3 files to `/android/app/src/main/res/raw/` and rename them:
- normal_beep.mp3
- urgent_warble.mp3
- emergency_siren.mp3
- critical_alarm.mp3

## iOS Sound Files:

For iOS, convert to CAF format and place in iOS bundle:
- normal_beep.caf
- urgent_warble.caf
- emergency_siren.caf
- critical_alarm.caf

## Temporary Sound Generation:

Until we have custom sounds, you can generate basic tones using:
```bash
# Generate a simple beep
ffmpeg -f lavfi -i "sine=frequency=1000:duration=1" normal_beep.mp3

# Generate warble
ffmpeg -f lavfi -i "sine=frequency=800:duration=0.3" -f lavfi -i "sine=frequency=1200:duration=0.3" -filter_complex "[0][1]concat=n=6:v=0:a=1" urgent_warble.mp3
```