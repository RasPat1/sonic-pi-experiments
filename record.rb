FILE_PATH = 'C:\Users\Carlos\Desktop\recording.txt'
class State
  attr_accessor :recording, :playback
  
  def initialize
    @recording = false
    @playback = false
  end
end

state = State.new
notes = []

class Note
  class << self
    def from_json(json, context)
      hash = JSON.parse(json, symbolize_names: true)
      
      Note.new(**hash, context: context)
    end
  end
  
  attr_reader :pitch, :velocity, :time
  
  def initialize(pitch:, velocity:, time:, context: nil)
    @pitch = pitch
    @velocity = velocity
    @time = time
    @context = context
  end
  
  def to_json
    {
      pitch: pitch,
      velocity: velocity,
      time: time
    }.to_json
  end
  
  def print
    puts to_json
  end
  
  def play
    @context.send(:return_beep, pitch: pitch, velocity: velocity)
  end
end

def midi_note(synth_name:, velocity:, pitch:, **kwargs)
  synth synth_name, velocity: velocity / 127.0, note: pitch, **kwargs
end

def return_beep(pitch:, velocity:)
  with_fx :reverb, mix: 0.5   do
    midi_note synth_name: :beep, sustain: 0.1, pitch: pitch, velocity: velocity
  end
end

define :playback do |file_path|
  state.playback = true
  
  raise "Can't record and playback at the same time" if state.recording
  lines = []
  
  File.open(file_path).each do |the_line|
    lines = [*lines, *JSON.parse(the_line)]
  end
  
  notes_to_play = lines.map do |the_note|
    Note.from_json(the_note, self)
  end
  
  times = notes_to_play.map do |the_note|
    the_note.time - notes_to_play.first.time
  end
  
  at times, notes_to_play do |time, the_note|
    puts "playing: #{the_note.pitch}"
    the_note.play
  end
end

define :record do |file_path|
  state.recording = true
  
  raise "Can't record and playback at the same time" if state.playback
  live_loop :record do
    use_real_time
    
    note_tuple = sync "/midi:keystation_49_mk3_0:1/note_on"
    
    note, velocity = note_tuple
    
    return_beep pitch: note, velocity: velocity
    
    notes << Note.new(pitch: note, velocity: velocity, time: vt)
    set :notes, notes.map(&:to_json)
    
    require 'json'
    
    File.open(FILE_PATH, 'w') { |file| file.write get(:notes) }
  end
end

##########

# Control below this line
# API:
## RECORDING
##| record(FILE_PATH)
## PLAYBACK:
##| playback(FILE_PATH)