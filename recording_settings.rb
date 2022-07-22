self.define :recording_settings do |&block|
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

  instance_eval(File.read("#{SONIC_PI_RECORD_PATH}/state.rb"))

  state = State.new(self)
  
  state.settings = settings

  instance_eval(File.read("#{SONIC_PI_RECORD_PATH}/note.rb"))
  instance_eval(File.read("#{SONIC_PI_RECORD_PATH}/record.rb"))
  instance_eval(File.read("#{SONIC_PI_RECORD_PATH}/playback.rb"))
  instance_eval(File.read("#{SONIC_PI_RECORD_PATH}/key_listener.rb"))
end
