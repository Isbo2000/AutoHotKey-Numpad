#Requires AutoHotkey v2.0
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
global volumes := [105, 105,105,64, 88, 105,105,105,105,105] ;Voicemeeter default volumes
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

#Include ./Scripts/MIDI.ahk

#Include ./Scripts/Hotkeys.ahk