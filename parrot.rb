# frozen_string_literal: true

class Parrot
  def initialize
    @frames = {}.tap do |frames|
      Dir[File.join(__dir__, "frames", "*.txt")].each_with_index do |path, idx|
        frames[idx] = File.read(path)
      end
    end
  end

  def clear_screen
    "\033[2J\033[3J\033[H"
  end

  def as_color(color:, string:)
    start, stop = colors.fetch(color)

    "\u001b[#{start}m#{string}\u001b[#{stop}m"
  end

  def colors
    {
      blue: [34, 39],
      cyan: [36, 39],
      green: [32, 39],
      magenta: [35, 39],
      red: [31, 39],
      white: [37, 39],
      yellow: [33, 39],
    }
  end

  def generate_frame(idx:, last_color:)
    color = colors.keys.keep_if { |color| color != last_color }.sample
    string = @frames[idx]
    frame = as_color(color:, string:)

    [frame, color]
  end

  def call(_env)
    stream_callback = proc do |stream|
      idx = 0
      last_color = nil
      loop do
        frame, last_color = generate_frame(idx:, last_color:)
        stream.write(clear_screen)
        stream.write(frame)
        sleep 0.07
        idx = (idx + 1) % @frames.size
      end
    ensure
      stream.close
    end

    [200, {}, stream_callback]
  end
end
