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
