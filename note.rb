require 'bundler'

Bundler.require

class Note
  STANDARD_FREQUENCY = 440
  NOTE_NAMES = %w[A A# B C C# D D# E F F# G G#]
  STOP_NAME = "S"
  TWELTH_ROOT_OF_TWO = 1.0594630943592953 # 2 ** (1.0/12)

  def initialize(name, octave=nil, opts={})
    @duration = opts.delete(:duration)
    @sample_rate = opts.delete(:sample_rate)
    @frequency = calc_frecquency(name)
  end

  def samples
    _total_frames = ( @duration * @sample_rate ).to_i
    _cycles_per_frame = @frequency / @sample_rate
    _increment = 2 * Math::PI * _cycles_per_frame

    _phase = 0
    _total_frames.times.map do
      _sample = Math.sin _phase
      _phase += _increment
      _sample
    end
  end

  def calc_frecquency(name)
    raise "Unknown note name" unless NOTE_NAMES.include? name

    index_offset = NOTE_NAMES.index name
    freq_offset = TWELTH_ROOT_OF_TWO ** index_offset

    STANDARD_FREQUENCY * freq_offset
  end

end

class Wav
  SAMPLE_RATE= 22050
  DURATION = 1

  def initialize(notes)
    @samples = notes.map do |note|
      Note.new(note, nil, sample_rate: SAMPLE_RATE, duration: DURATION).samples
    end.flatten
    makefile
  end

  def play
    `afplay #{filename}`
  end

  def makefile
    _format = WaveFile::Format.new :stereo, :pcm_16, SAMPLE_RATE
    _buffer_format = WaveFile::Format.new :stereo, :float, SAMPLE_RATE
    WaveFile::Writer.new filename, _format do |writer|
      _buffer = WaveFile::Buffer.new @samples, _buffer_format
      writer.write _buffer
    end
  end

  def filename
    'a.wav'
  end
end

#note_names = %w[A A# B C C# D D# E F F# G G#]
notes = %w[A B C D E F G]

#notes = 100.times.map{ note_names.sample }

Wav.new(notes).play
