#Requires AutoHotkey v2.0
global minimized := false
global svv := "./Assets/SoundVolumeView.exe"
global muted := "./Icons/mute.ico"
global unmuted := "./Icons/default.ico"
global microphone := "Microphone (microphone)"

ChangeVolume(app, change, timeout) {
	RunWait(svv ' /ChangeVolume "' app '" ' change)
	ToolTip(app " Vol: " RegExReplace(RunWait(svv ' /Stdout /GetPercent "' app '"'), "(?(?<=.)0|)$") "%")
	SetTimer () => ToolTip(), -timeout
}

*NumpadLeft::Media_Prev

*NumpadIns::Media_Play_Pause

*NumpadRight::Media_Next

*NumpadUp::Volume_Up

*NumpadClear::Volume_Mute

*NumpadDown::Volume_Down

*NumpadPgUp::{
	ChangeVolume("Spotify", "+5", 1000)
}

*NumpadPgDn::{
	if (minimized) {
		global minimized := false
	} else if (!minimized) {
		ChangeVolume("Spotify", "-5", 1000)
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
		TrayTip
		TrayTip("Microphone", "Muted")
		SetTimer () => TrayTip(), -1500
		ToolTip("Mic Muted")
		SetTimer () => ToolTip(), -1000
	} else {
		TraySetIcon(unmuted,, false)
		TrayTip
		TrayTip("Microphone", "Unmuted")
		SetTimer () => TrayTip(), -1500
		ToolTip("Mic Unmuted")
		SetTimer () => ToolTip(), -1000
	}
}