define :playback do |file_path|
  return if state.playback
  state.playback = true
  
  raise "Can't record and playback at the same time" if state.recording
  lines = []
  
  File.open(file_path).each do |the_line|
    lines = [*lines, *JSON.parse(the_line)]
  end
  
  notes_to_play = lines.map do |the_note|
    Note.from_json(the_note, state: state)
  end
  
  times = notes_to_play.map do |the_note|
    return if state.stop_playback

    first_time = state.quantise_amount ? quantise(notes_to_play.first.time, state.quantise_amount) : notes_to_play.first.time
    the_note_time = state.quantise_amount ? quantise(the_note.time, state.quantise_amount) : the_note.time
    the_note_time - first_time
  end
  
  use_bpm state.bpm
  
  at times, notes_to_play do |time, the_note|
    puts "playing #{the_note.to_json} at current_bpm: #{current_bpm}"
    
    the_note.play
  end
end
