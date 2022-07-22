instance_eval(File.read("#{SONIC_PI_RECORD_PATH}/recording_settings.rb"))

self.recording_settings do
  file_path 'C:\Users\Carlos\Desktop\return\intro.txt'
  synth_name :blade
  quantise_amount 0.25
  bpm 60
end
