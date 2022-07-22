define :stop_playback do
  state.is_stopped = true
end

define :stop_recording do
  state.is_stopped = true
end

define :start_playback do
  state.is_stopped = false

  playback(state.file_path)
end

define :start_recording do
  state.is_stopped = false

  record(state.file_path)
end