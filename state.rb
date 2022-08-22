class State
  attr_accessor :recording, :playback, :settings, :is_stopped
  attr_reader :notes, :context

  instance_eval(File.read("#{SONIC_PI_RECORD_PATH}/settings.rb"))

  
  def initialize(context)
    @recording = false
    @playback = false
    @notes = []
    @context = context
    @settings ||= Settings.new
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

  def puts(msg)
    default_log_path = "#{SONIC_PI_RECORD_PATH}/log.log"
    File.open(default_log_path, 'w') { |file| file.write msg.to_s }
  end
end
