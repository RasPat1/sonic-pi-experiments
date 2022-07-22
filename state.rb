class State
  attr_accessor :recording, :playback, :settings, :is_stopped
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
