module RakeScript
  module Logging
    # RakeScript::Logging helper allows to print useful and colorized output.
    # @see https://misc.flogisoft.com/bash/tip_colors_and_formatting

    PROMPT_STYLES = {
        normal: 0,
        bold: 1,
        dim: 2,
        underlined: 4,
        blink: 5,
        inverted: 7,
        hidden: 8
    }

    PROMPT_COLORS = {
        default: 39,
        black: 30,
        red: 31,
        green: 32,
        yellow: 33,
        blue: 34,
        magenta: 35,
        cyan: 36,
        light_grey: 37,
        dark_grey: 90,
        light_red: 91,
        light_green: 92,
        light_yellow: 93,
        light_blue: 94,
        light_magenta: 95,
        light_cyan: 96,
        white: 97
    }

    RESET_PROMPT = "\e[0m".freeze

    def format_text(text, color: :default, background: :default, style: :normal)
      fg = PROMPT_COLORS.fetch(color)
      bg = PROMPT_COLORS.fetch(background) + 10
      fmt = PROMPT_STYLES.fetch(style)
      format = "\e[#{fmt};#{fg};#{bg}m"
      "#{format}#{text}#{RESET_PROMPT}"
    end

    def puts_colored(*lines)
      options = lines.pop
      raise ArgumentError, 'last argument must be options hash'.freeze unless options.is_a?(Hash)
      raise ArgumentError, 'provide at least one line'.freeze if lines.empty?

      formatted_lines = lines.map { |line| format_text(line, **options) }
      puts(*formatted_lines)
    end

    def puts_time(prefix: nil, color: :yellow, style: :bold)
      time = Time.now.utc.strftime('%F %T %Z'.freeze)
      puts_colored("#{prefix}[#{time}]", color: color, style: style)
    end

    def puts_info(text, color: :blue, style: :bold)
      puts_colored(">>> #{text}", color: color, style: style)
    end

    def with_puts_benchmark(title, show_time: true)
      puts_info title
      puts_time(prefix: "[#{title} begin]") if show_time
      time = Time.now.to_i
      begin
        yield
        took = Time.now.to_i - time
        puts_time(prefix: "[#{title} completed]") if show_time
        puts_colored("[#{title}] took #{took} seconds.", color: :yellow, style: :bold)
      rescue StandardError => e
        took = Time.now.to_i - time
        puts_time(prefix: "[#{title} failed]") if show_time
        puts_colored("[#{title}] failed after #{took} seconds.", color: :yellow, style: :bold)
        raise e
      end
    end
  end
end
