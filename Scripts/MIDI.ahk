#Requires AutoHotkey v2.0
#Include ../midi-to-macro-to-midi/MidiToMacro.ahk

;MIDI out
for (l in [1,2,3,4,5,6,7,8,9,10]) {
	controlChange(7,volumes[l],l)
}

MidiVolume(channels,value,mode := 7) {
	global midiRequest := true
	v := volumes.Get(channels[1])+value
	if (NOT(mode = 7)) {
		v := value
	}
	for (c in channels) {
		controlChange(mode,v,c)
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
			msg := (channel = 6)? app " Vol" : "Volume"
			Notification(msg ": " volume "%", 2000, 200)

		} else if (cc = 122) {
			global midiRequest := false
			msg := (channel = 9)? "Speakers" : "Volume"
			if (value = 127) {
				Notification(msg " Muted", 2000, 230)
			} else if (value = 0) {
				Notification(msg " Unmuted", 2000, 230)
			}
		}

	} else {
		if (channel > 0 && channel < 11 && cc = 7) {
			volumes[channel-1] := value
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