#Requires AutoHotkey v2.0
#Include ../midi-to-macro-to-midi/MidiToMacro.ahk

;MIDI out
for (l in [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]) {
	controlChange(7,volumes[l],l-1)
}

MidiVolume(channels,value,mode := 7) {
	global midiRequest := true
	v := volumes.Get(channels[1])+value
	if (NOT(mode = 7)) {
		v := value
	}
	for (c in channels) {
		controlChange(mode,v,c-1)
		if (mode = 7) {
			volumes[c] := v
		}
	}
}

;MIDI in
ProcessCC(device, channel, cc, value) {
	if (midiRequest){
		if (cc = 7) {
			global midiRequest := false
			volume := Round(ConvertCCValueToScale(value, 0, 127)*100,1)
			msg := (channel = 9)? app " Vol" : "Volume"
			Notification(msg ": " volume "%", 2000, 200)

		} else if (cc = 122) {
			global midiRequest := false
			msg := (channel = 12)? "Speakers" : "Volume"
			if (value = 127) {
				Notification(msg " Muted", 2000, 230)
			} else if (value = 0) {
				Notification(msg " Unmuted", 2000, 230)
			}
		}

	} else {
		if (channel > -1 && channel < 17 && cc = 7) {
			volumes[channel] := value
		} else if (cc) {

		}
	}
}

ProcessNote(device, channel, note, velocity, isNoteOn) {
}
ProcessPC(device, channel, note, velocity) {
}
ProcessPitchBend(device, channel, value) {
}