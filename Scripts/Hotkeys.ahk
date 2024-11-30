#Requires AutoHotkey v2.0

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