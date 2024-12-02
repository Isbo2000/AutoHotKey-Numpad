#Requires AutoHotkey v2
#SingleInstance
#Warn
Persistent()

#Include lib\Config.ahk
#Include lib\Gui.ahk

MaybeOpenMidiInput() {
	global appConfig, currentMidiInputDeviceIndex

	if (
		appConfig.midiInDevice >= 0
		; Open the MIDI input, if we don't have a "device name" stored, or if
		; the stored device name matches the actual device name
		and (
			StrLen(appConfig.midiInDeviceName) == 0
			or GetMidiInputDeviceName(appConfig.midiInDevice) == appConfig.midiInDeviceName
		)
	) {
		OpenMidiInput(appConfig.midiInDevice, OnMidiData)
		return true
	}
	return false
}

MaybeOpenMidiOutput() {
	global appConfig, currentMidiOutputDeviceIndex

	if (
		appConfig.midiOutDevice >= 0
		; Open the MIDI output, if we don't have a "device name" stored, or if
		; the stored device name matches the actual device name
		and (
			StrLen(appConfig.midiOutDeviceName) == 0
			or GetMidiOutputDeviceName(appConfig.midiOutDevice) == appConfig.midiOutDeviceName
		)
	) {
		OpenMidiOutput(appConfig.midiOutDevice)
		return true
	}
	return false
}

Main() {
	global appConfig, currentMidiInputDeviceIndex, currentMidiOutputDeviceIndex
	OnExit(CloseMidi)
	A_TrayMenu.Add() ; Add a menu separator line
	A_TrayMenu.Add("Show on Startup", ToggleShowOnStartup)
	A_TrayMenu.Add("MIDI Monitor", ShowMidiMonitor)
	ReadConfig()
	wasMidiInputOpened := MaybeOpenMidiInput()
	wasMidiOutputOpened := MaybeOpenMidiOutput()
	if (appConfig.showOnStartup) {
		A_TrayMenu.Check("Show on Startup")
	} else {
		A_TrayMenu.Uncheck("Show on Startup")
	}

	if (!wasMidiInputOpened || !wasMidiOutputOpened || appConfig.showOnStartup) {
		ShowMidiMonitor()
	}
}

Main()
