live_loop :key_listener do
  instance_eval(File.read("#{SONIC_PI_RECORD_PATH}/stop_tools.rb"))

  note_tuple = sync "/midi:midiin2_(keystation_49_mk3)_1:1/note_on"
  
  note = note_tuple[0]
  
  case note
  when 95
    start_recording
  when 93
    if state.playback
      stop_playback
    elsif state.recording
      stop_recording
    end
  when 94
    start_playback
  end
end
