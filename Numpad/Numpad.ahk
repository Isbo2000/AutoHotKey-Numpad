#Requires AutoHotkey v2.0
global minimized := false
global svv := "./SoundVolumeView/SoundVolumeView.exe"
global muted := "./Icons/mute.ico"
global unmuted := "./Icons/default.ico"
global microphone := "Microphone (microphone)"

Timer(funcname, timeout, params*) {
	funcname(params*)
	SetTimer () => funcname(), -timeout
}

ChangeVolume(app, change, timeout) {
	RunWait(svv " /ChangeVolume " app " " change)
	Timer(ToolTip, timeout, (app " Vol: " RegExReplace(RunWait(svv " /Stdout /GetPercent " app), "(?(?<=.)0|)$") "%"))
}

*NumpadLeft::Media_Prev

*NumpadIns::Media_Play_Pause

*NumpadRight::Media_Next

*NumpadUp::Volume_Up

*NumpadClear::Volume_Mute

*NumpadDown::Volume_Down

*NumpadPgUp::{
	if (GetKeyState("Control")) {
		change := "+1"
	} else {
		change := "+5"
	}
	ChangeVolume("Spotify", change, 1000)
}

*NumpadPgDn::{
	if (minimized) {
		global minimized := false
	} else if (!minimized) {
		if (GetKeyState("Control")) {
			change := "-1"
		} else {
			change := "-5"
		}
		ChangeVolume("Spotify", change, 1000)
	}
}

*NumpadEnter::{
	Send("{Media_Stop}")
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
		TraySetIcon(muted,, true)
		TrayTip()
		Timer(TrayTip, 1500, "Muted", "Microphone")
		Timer(ToolTip, 1000, ("Mic Muted"))
	} else {
		TraySetIcon(unmuted,, false)
		TrayTip()
		Timer(TrayTip, 1500, "Unmuted", "Microphone")
		Timer(ToolTip, 1000, ("Mic Unmuted"))
	}
}