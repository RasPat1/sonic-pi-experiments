instance_eval(File.read("#{SONIC_PI_RECORD_PATH}/settings.rb"))

self.define :recording_settings do |&block|
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
