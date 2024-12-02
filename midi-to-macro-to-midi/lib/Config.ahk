#Requires AutoHotkey v2

global appConfig

configFileName := "./midi-to-macro-to-midi/MidiToMacro.ini"

Class MidiToMacroConfig {
	__New() {
		this.maxLogLines := 10
		this.midiInDevice := -1
		this.midiInDeviceName := ""
		this.midiOutDevice := -1
		this.midiOutDeviceName := ""
		this.showOnStartup := true
	}
}

appConfig := MidiToMacroConfig()

ReadConfig() {
	if (FileExist(configFileName)) {
		appConfig.maxLogLines := IniRead(configFileName, "Settings", "MaxLogLines", 10)
		appConfig.midiInDevice := IniRead(configFileName, "Settings", "MidiInDevice", -1)
		appConfig.midiInDeviceName := IniRead(configFileName, "Settings", "MidiInDeviceName", "")
		appConfig.midiOutDevice := IniRead(configFileName, "Settings", "MidiOutDevice", -1)
		appConfig.midiOutDeviceName := IniRead(configFileName, "Settings", "MidiOutDeviceName", "")
		appConfig.showOnStartup := IniRead(configFileName, "Settings", "ShowOnStartup", true)
	}
}

WriteConfigMidiInputDevice(midiInDevice, midiInDeviceName) {
	IniWrite(midiInDevice, configFileName, "Settings", "MidiInDevice")
	IniWrite(midiInDeviceName, configFileName, "Settings", "MidiInDeviceName")
	appConfig.midiInDevice := midiInDevice
	appConfig.midiInDeviceName := midiInDeviceName
}

WriteConfigMidiOutputDevice(midiOutDevice, midiOutDeviceName) {
	IniWrite(midiOutDevice, configFileName, "Settings", "MidiOutDevice")
	IniWrite(midiOutDeviceName, configFileName, "Settings", "MidiOutDeviceName")
	appConfig.midiOutDevice := midiOutDevice
	appConfig.midiOutDeviceName := midiOutDeviceName
}

WriteConfigShowOnStartup(showOnStartup) {
	IniWrite(showOnStartup, configFileName, "Settings", "ShowOnStartup")
	appConfig.showOnStartup := showOnStartup
}
