#Requires AutoHotkey v2.0
;----------------------------------------------------------------------------------
;Change these values:
global microphone := "Microphone (microphone)"  ;Name of default microphone device.
global app := "Spotify"  ;App to change volume of.
;----------------------------------------------------------------------------------
global svv := "./SoundVolumeView/SoundVolumeView.exe"
global mutedico := "./Icons/mute.ico"
global unmutedico := "./Icons/default.ico"
global minimized := false
global MyGui := false

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

ChangeVolume(app, change, timeout) {
	RunWait(svv " /ChangeVolume " app " " change)
	vol := RegExReplace(RunWait(svv " /Stdout /GetPercent " app), "(?(?<=.)0|)$")
	Notification(app " Vol: " vol "%", timeout, 215)
}

*NumpadHome::<#Tab

*NumpadEnd::DllCall("LockWorkStation")

*NumpadLeft::Media_Prev

*NumpadIns::Media_Play_Pause

*NumpadRight::Media_Next

*NumpadUp::Volume_Up

*NumpadClear::Volume_Mute

*NumpadDown::Volume_Down

*NumpadPgUp::{
	if (GetKeyState("Control")) {
		change := "+1"
	} else if (GetKeyState("Shift")) {
		change := "+10"
	} else {
		change := "+5"
	}
	ChangeVolume(app, change, 2000)
}

*NumpadPgDn::{
	if (minimized) {
		global minimized := false
	} else if (!minimized) {
		if (GetKeyState("Control")) {
			change := "-1"
		} else if (GetKeyState("Shift")) {
			change := "-10"
		} else {
			change := "-5"
		}
		ChangeVolume(app, change, 2000)
	}
}

*NumpadEnter::{
	;Send("{Media_Stop}")
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