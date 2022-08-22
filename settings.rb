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
