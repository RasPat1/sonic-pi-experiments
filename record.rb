define :record do |file_path|
  state.recording = true
  
  raise "Can't record and playback at the same time" if state.playback

  puts "Now Recording at #{state.bpm} bpm"
  
  use_bpm state.bpm
  
  live_loop :metronome do
    sample :drum_cymbal_closed unless state.is_stopped

    sleep 1
  end
  
  live_loop :record do
    unless state.is_stopped
      use_real_time
    
      note_tuple = sync "/midi:keystation_49_mk3_0:1/note_on"
    
      note, velocity = note_tuple
    
      the_note = Note.new(pitch: note, velocity: velocity, time: vt, current_bpm: state.bpm, state: state)
    
      the_note.play
    
      state.notes << the_note
      set :notes, state.notes.map(&:to_json)
    
      require 'json'
    
      File.open(state.file_path, 'w') { |file| file.write get(:notes) }
    end
  end
end
