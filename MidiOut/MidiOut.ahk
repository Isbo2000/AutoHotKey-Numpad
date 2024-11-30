#Requires AutoHotkey v2.0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MIDI (Musical Instument Digital Interface)
;; Original Autor: Bentschi
;; -> https://github.com/Ixiko/AHK-libs-and-classes-collection/blob/master/classes/class_midiOut.ahk
;; AutoHotkey version: 2.0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Class MidiOut {
   Static NotesMap := Map("C", 0, "C#", 1, "D", 2, "D#", 3, "E", 4, "F", 5, "F#", 6, "G", 7, "G#", 8,"A", 9, "A#", 10, "B", 11)
   Static VolumeMultiplier := 100
   Static Winmm := DllCall("LoadLibrary", "Str", "Winmm.dll", "UPtr")
   Static Call(DevID := -1) {
      Handle := 0
      If DllCall("Winmm.dll\midiOutOpen", "Ptr*", &Handle, "UInt", DevID, "Ptr", 0, "Ptr", 0, "UInt", 0, "UInt")
         Return False
      This.Handle := Handle
      This.Channel := []
      Loop 16
         This.Channel.Push(MidiOut.MidiOutChannel(This, A_Index - 1))
      This.DefaultChannel := 1
      This.Base := MidiOut.Prototype
      Return This
   }
   Static GetDeviceList() { ;*
      Local Caps :=  Buffer(84, 0)
      Local List := []
      Loop DllCall("Winmm.dll\midiOutGetNumDevs", "UInt") {
         If DllCall("Winmm.dll\midiOutGetDevCapsW", "Ptr", A_Index - 1, "Ptr", Caps.Ptr, "UInt", 84, "UInt")
            Continue
         List.Push({Name: StrGet(Caps.Ptr + 8, 32, "UTF-16"), ID: A_Index - 1})
      }
      Return List.Length ? List : False
   }
   ; Destructor
   __Delete() {
      If This.HasProp("Handle")
         DllCall("Winmm.dll\midiOutClose", "Ptr", This.Handle, "UInt")
   }
   ; Properties --------------------------------------------------------------------------------------------------------
   DevID[*] => This.GetDeviceID()
   DeviceID[*] => This.DevID
   DevName[*] => This.GetDeviceName()
   DeviceName[*] => This.DevName
   VolumeL[*] {
      Get => This.GetVolumeLeft()
      Set => This.SetVolumeLeft(value)
   }
   VolumeR[*] {
      Get => This.GetVolumeRight()
      Set => This.SetVolumeRight(value)
   }
   Volume[*] {
      Get => This.GetVolume()
      Set => This.SetVolume(value)
   }
   Instrument[*] {
      Get => This.Channel[This.DefaultChannel].Instrument
      Set => This.Channel[This.DefaultChannel].Instrument := value
   }
   ; Methods -----------------------------------------------------------------------------------------------------------
   GetDeviceID() {
      Local DevID := 0
      If DllCall("Winmm.dll\midiOutGetID", "Ptr", This.Handle, "UInt*", &DevID, "UInt")
         Return ""
      Return DevID
   }
   GetDeviceName() {
      Local Caps := Buffer(84, 0)
      If DllCall("Winmm.dll\midiOutGetDevCapsW", "Ptr", This.GetDeviceID(), "Ptr", Caps.Ptr, "UInt", 84, "UInt")
         Return ""
      Return StrGet(Caps.Ptr + 8, 32, "UTF-16")
   }
   GetVolumeLeft() {
      Local Vol := 0
      If DllCall("Winmm.dll\midiOutGetVolume", "Ptr", This.Handle, "UInt*", &Vol, "UInt")
         Return ""
      Return (Vol & 0xFFFF) / 0xFFFF * MidiOut.VolumeMultiplier
   }
   GetVolumeRight() {
      Local Vol := 0
      If DllCall("Winmm.dll\midiOutGetVolume", "Ptr", This.Handle, "UInt*", &Vol, "UInt")
         Return
      Return (Vol >> 16) / 0xFFFF * MidiOut.VolumeMultiplier
   }
   GetVolume() {
      Local Vol := 0
      If DllCall("Winmm.dll\midiOutGetVolume", "Ptr", This.Handle, "UInt*", &Vol, "UInt")
         Return ""
      Return ((Vol >> 16) + (Vol & 0xFFFF)) / (2 * 0xFFFF) * MidiOut.VolumeMultiplier
   }
   SetVolumeLeft(Vol) {
      Local VolOld := VolNew := 0
      If DllCall("Winmm.dll\midiOutGetVolume", "Ptr", This.Handle, "UInt*", &VolOld, "UInt")
         Return ""
      VolNew := (VolOld & 0xFFFF0000) | Round(Vol / MidiOut.VolumeMultiplier * 0xFFFF)
      If DllCall("Winmm.dll\midiOutSetVolume", "Ptr", This.Handle, "UInt", VolNew, "UInt")
         Return ""
      Return 1
   }
   SetVolumeRight(Vol) {
      Local VolOld := VolNew := 0
      If DllCall("Winmm.dll\midiOutGetVolume", "Ptr", This.Handle, "UInt*", &VolOld, "UInt")
         Return ""
      VolNew :=  (VolOld & 0xFFFF) | (Round(Vol / MidiOut.VolumeMultiplier * 0xFFFF) << 16)
      If (DllCall("Winmm.dll\midiOutSetVolume", "Ptr", This.Handle, "UInt", VolNew, "UInt") != 0)
         Return ""
      Return 1
   }
   SetVolume(Vol) {
      Vol := Round(Vol / MidiOut.VolumeMultiplier * 0xFFFF)
      Return !DllCall("Winmm.dll\midiOutSetVolume", "Ptr", This.Handle, "UInt", (Vol << 16) | Vol, "UInt")
   }
   Reset() {
      Return !DllCall("Winmm.dll\midiOutReset", "Ptr", This.Handle, "UInt")
   }
   SetDefaultChannel(Channel) { ; Setter for default channel
      Local Result := False
      If IsInteger(Channel) && (Channel < 17) && (Channel > 0) {
         This.DefaultChannel := Channel
         Result := True
      }
      Return Result
   }
   ; There was no way to send CC messages so I made that for the MidiOut Class
   ControlChange(Control, Value, Channel := 0) {
      Channel := (Channel < 1 || Channel > 16) ? This.DefaultChannel : Channel
      This.Channel[Channel]._ChannelID := Channel
      This.Channel[Channel].ControlChange(Control, Value)
   }
   NoteOn(Note, Channel := 0, Velocity := 127) { ; since velocity is rarely used, I put it after channel
      Channel := (Channel < 1 || Channel > 16) ? This.DefaultChannel : Channel
      This.Channel[Channel]._ChannelID := Channel
      This.Channel[Channel].NoteOn(Note, Velocity)
   }
   NoteOff(Note := "all", Channel := 0, Velocity := 127) { ; since velocity is rarely used, I put it after channel
      Channel := (Channel < 1 || Channel > 16) ? This.DefaultChannel : Channel
      This.Channel[Channel]._ChannelID := Channel
      This.Channel[Channel].NoteOff(Note, Velocity)
   }
   SelectInstrument(Instrument := 0) {
      This.Channel[This.DefaultChannel].SelectInstrument(Instrument)
   }
   ShortMessage(Msg) {
      Return !DllCall("Winmm.dll\midiOutShortMsg", "Ptr", This.Handle, "UInt", Msg, "UInt")
   }
   ; ===================================================================================================================
   Class MidiOutChannel {
      Static Call(MidiObj, ChannelID) {
         This._MidiOut := MidiObj
         This._ChannelID := ChannelID
         This._Notes := Map()
         This._Instrument := 0
         This.Base := MidiOut.MidiOutChannel.Prototype
         Return This
      }
      Instrument[*] {
         Get => This._Instrument
         Set => This.SelectInstrument(Value)
      }
      ; There was no way to send CC messages so I made that for the MidiOutChannel Class
      ControlChange(Control, Value) {
         Msg := ((Value & 0xff) << 16) | ((Control & 0xff) << 8) | (This._ChannelID | 0xB0)
         Return This._MidiOut.ShortMessage(Msg)
      }
      NoteOn(Note, Velocity := 127)  {
         Note := This.GetNoteValue(Note)
         If This._Notes.Has(Note)
            This._Notes[Note][Velocity] := 1
         Else
            This._Notes[Note] := Map(Velocity, 1)
         Msg := ((Velocity & 0xFF) << 16) | ((Note & 0xFF) << 8) | ((This._ChannelID) | 0xF) | 0x90
         Return This._MidiOut.ShortMessage(Msg)
      }
      NoteOff(Note, Velocity := 127) {
         Note := This.GetNoteValue(Note)
         If This._Notes.Has(Note) && This._Notes[Note].Has(Velocity) {
            This._Notes[Note].Delete(Velocity)
            If !This._Notes[Note].Count
               This._Notes.Delete(Note)
            Msg := ((Velocity & 0xFF) << 16) | ((Note & 0xFF) << 8) | ((This._ChannelID) | 0xF) | 0x80
            Return This._MidiOut.ShortMessage(Msg)
         }
      }
      AllNotesOff() {
         For Note, Velocities In This._Notes {
            For Velocity, I In Velocities {
               Msg := ((Velocity & 0xFF) << 16) | ((Note & 0xFF) << 8) | ((This._ChannelID) | 0xF) | 0x80
               This._MidiOut.ShortMessage(Msg)
            }
         }
         This._Notes := Map()
         Return True
      }
      SelectInstrument(Instrument := 0) {
         This._Instrument := Instrument
         Msg := ((Instrument & 0xFF) << 8) | ((This._ChannelID) | 0xF) | 0xC0
         Return This._MidiOut.ShortMessage(Msg)
      }
      GetNoteValue(Note) {
         ; Extract note name and octave using RegEx:
         ; note_name = match[1], octave = match[2]
         RegexMatch(Note, "(\D+)(\d+)", &Match)
         Return (12 * Match[2]) + MidiOut.NotesMap[Match[1]]
      }
   }
}
