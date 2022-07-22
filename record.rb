class State
  attr_accessor :recording, :playback, :settings
  attr_reader :notes, :context
  
  def initialize(context)
    @recording = false
    @playback = false
    @notes = []
    @context = context
  end
  
  def quantise_amount
    settings.quantise_amount
  end
  
  def file_path
    settings.file_path
  end
  
  def bpm
    settings.bpm
  end
  
  def synth_name
    settings.synth_name
  end
end

state = State.new(self)

class Note
  class << self
    def from_json(json, state:)
      hash = JSON.parse(json, symbolize_names: true)
      
      Note.new(**hash, state: state)
    end
  end
  
  attr_reader :pitch, :velocity, :time, :current_bpm
  
  def initialize(pitch:, velocity:, time:, current_bpm:, state:)
    @pitch = pitch
    @velocity = velocity
    @time = time
    @current_bpm = current_bpm
    @state = state
  end
  
  def to_json
    {
      pitch: pitch,
      velocity: velocity,
      time: time,
      current_bpm: current_bpm
    }.to_json
  end
  
  def print
    puts to_json
  end
  
  
  def play(synth_name = nil, **kwargs)
    @state.context.send(:synth, synth_name || @state.synth_name, velocity: velocity / 127.0, note: pitch, **kwargs)
  end
end

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

define :record do |file_path|
  state.recording = true
  
  raise "Can't record and playback at the same time" if state.playback
  
  use_bpm state.bpm
  
  live_loop :metronome do
    sample :drum_cymbal_closed
    
    sleep 1
  end
  
  live_loop :record do
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

live_loop :key_listener do
  note_tuple = sync "/midi:midiin2_(keystation_49_mk3)_1:1/note_on"
  
  note = note_tuple[0]
  
  case note
  when 95
    record(state.file_path)
  when 93
    stop
  when 94
    playback(state.file_path)
  end
end

define :recording_settings do |&block|
  class Settings
    attr_accessor :quantise_amount, :file_path
    
    def quantise_amount(amount = nil)
      @quantise_amount ||= amount
    end
    
    def file_path(path = nil)
      @file_path ||= path
    end
    
    def bpm(bpm = 120)
      @bpm ||= bpm
    end
    
    def synth_name(the_synth = :beep)
      @synth_name ||= the_synth
    end
  end
  
  
  settings = Settings.new
  settings.instance_exec(&block)
  
  state.settings = settings
end

# don't edit anything above this line

recording_settings do
  file_path 'C:\Users\Carlos\Desktop\return\intro.txt'
  synth_name :beep
  quantise_amount 0.25
  bpm 60
end
