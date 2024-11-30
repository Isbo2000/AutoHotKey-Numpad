#Requires AutoHotkey v2.0
#Include ./MidiOut/class_midiOut.ahk
#Include ./midi-to-macro/MidiToMacro.ahk
global mutedico := "./Icons/mute.ico"
global unmutedico := "./Icons/default.ico"
global minimized := false
global MyGui := false
global midiRequest := false

;----------------------------------------------------------------------------------
;Change these values:
global microphone := "Microphone (microphone)"  ;Name of default microphone device.
global app := "Spotify"  ;App to change volume of.
;                 [ S1, S2, S3, S4, S5, A1, A2, A3, B1, B2]
global volumes := [105,105,105,105, 88, 64, 64, 64,105,105] ;Voicemeeter default volumes
;----------------------------------------------------------------------------------

Suspend
CheckProg:
if (!ProcessExist("voicemeeterpro_x64.exe") || !ProcessExist("loopMIDI.exe")) {
	Sleep(100)
	goto('CheckProg')
} else {
	Suspend
}

if (SoundGetMute(, microphone)) {
	TraySetIcon(mutedico,, true)
}

Notification(text, timeout, width := 100) {
	if (MyGui) {
		MyGui.Destroy()
	}
	sleep 0.5
	global MyGui := Gui()
	sleep 0.5
	MyGui.Opt("+AlwaysOnTop -Caption +ToolWindow")
	MyGui.BackColor := "000000"
	MyGui.SetFont("s20")
	MyGui.Add("Text", ("cffffff Center " width " h35"), text)
	MyGui.Opt("Border")
	WinSetTransColor(" 175", MyGui)
	MyGui.Show("x864 y971 NoActivate")
	SetTimer () => MyGui.Destroy(), timeout
}

;MIDI out
global midi := MidiOut(1)
midi.Volume := 100
for (l in [1,2,3,4,5,6,7,8,9,10]) {
	midi.controlChange(7,volumes[l],l)
}

MidiVolume(channels,value,mode := 7) {
	global midiRequest := true
	v := volumes.Get(channels[1])+value
	if (NOT(mode = 7)) {
		v := value
	}
	for (c in channels) {
		midi.controlChange(mode,v,c)
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

;----------------------------------------------------------------------------------
;HOTKEYS

*NumpadUp::MidiVolume([6,7,8],1)

*NumpadClear::{
	if (GetKeyState("Shift") || GetKeyState("Control")) {
		channels := [8]
	} else {
		channels := [6,7]
	}
	MidiVolume(channels,127,122)
}

*NumpadDown::MidiVolume([6,7,8],-1)

*NumpadPgUp::MidiVolume([5],1)

*NumpadPgDn::{
	if (minimized) {
		global minimized := false
	} else if (!minimized) {
		MidiVolume([5],-1)
	}
}

#SuspendExempt true

*NumpadHome::<#Tab

*NumpadEnd::DllCall("LockWorkStation")

*NumpadLeft::Media_Prev

*NumpadIns::Media_Play_Pause

*NumpadRight::Media_Next

*NumpadEnter::{
	WinMinimizeAll
	global minimized := true
	Loop {
		Sleep 10
		if (!GetKeyState("NumpadEnter", "P")) {
			break
		} else if (!minimized) {
			return
		}
	}
	WinMinimizeAllUndo
	global minimized := false
}

*NumpadDel::{
	SoundSetMute(-1,, microphone)
	if (SoundGetMute(, microphone)) {
		TraySetIcon(mutedico,, true)
		Notification("Mic Muted", 2000, 172)
		SoundPlay("*64")
	} else {
		TraySetIcon(unmutedico,, false)
		Notification("Mic Unmuted", 2000, 172)
		SoundPlay("*64")
	}
}

#SuspendExempt false

;----------------------------------------------------------------------------------