#Requires AutoHotkey v2.0
global minimized := false
global MyGui := false
global svv := "./SoundVolumeView/SoundVolumeView.exe"
global muted := "./Icons/mute.ico"
global unmuted := "./Icons/default.ico"
global microphone := "Microphone (microphone)"

tipTimer(funcname, timeout, params*) {
	funcname(params*)
	SetTimer () => funcname(), -timeout
}

Notification(text, timeout, width := 100) {
	if (MyGui) {
		MyGui.Destroy()
	}
	global MyGui := Gui()
	MyGui.Opt("+AlwaysOnTop -Caption +ToolWindow")
	MyGui.BackColor := "000000"
	MyGui.SetFont("s20")
	MyGui.Add("Text", ("cffffff Center " width " h35"), text)
	WinSetTransColor(" 175", MyGui)
	MyGui.Opt("Border")
	MyGui.Show("x864 y971 NoActivate")
	SetTimer () => MyGui.Destroy(), timeout
}

ChangeVolume(app, change, timeout) {
	RunWait(svv " /ChangeVolume " app " " change)
	volume := app " Vol: " RegExReplace(RunWait(svv " /Stdout /GetPercent " app), "(?(?<=.)0|)$") "%"
	Notification(volume, timeout, 215)
}

*NumpadHome::NumpadHome

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
	ChangeVolume("Spotify", change, 2000)
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
		ChangeVolume("Spotify", change, 2000)
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
		TraySetIcon(muted,, true)
		Notification("Mic Muted", 2000, 172)
		TrayTip()
		tipTimer(TrayTip, 1500, "Muted", "Microphone")
	} else {
		TraySetIcon(unmuted,, false)
		Notification("Mic Unmuted", 2000, 172)
		TrayTip()
		tipTimer(TrayTip, 1500, "Unmuted", "Microphone")
	}
}