module RakeScript
  module FileSystem
    # RakeScript::FileSystem helper allows easy file system manipulations.

    # Check if folder exists.
    # @param path [String] folder path.
    # @return [TruClass,FalseClass] boolean
    def folder_exist?(path)
      File.directory?(path)
    end

    def posix_flags(*flags)
      result = []
      flags.each do |flag|
        if flag.is_a?(Hash)
          result.concat(
              flag.reject { |_, v| !v }.map { |k, v| v.is_a?(TrueClass) ? k.to_s : "#{k}=#{v}" }
          )
        else
          result.push(flag.to_s)
        end
      end
      result
    end

    def remove_rf(*paths)
      options = paths.last.is_a?(Hash) ? paths.pop : {}
      flags = posix_flags('-rf', '-v': !!options[:verbose])
      cmd('rm', *flags, *paths)
    end

    def create_dir_p(*paths)
      options = paths.last.is_a?(Hash) ? paths.pop : {}
      # FileUtils.mkdir_p(paths, options)
      flags = posix_flags('-p', '-v': !!options[:verbose])
      cmd('mkdir', *flags, *paths)
    end

    def copy(from, to, options = {})
      # from = from.include?('*') ? Dir.glob(from) : [from]
      # from.each { |f| FileUtils.cp(f, to, options) }
      flags = posix_flags('-v': !!options[:verbose])
      cmd('cp', *flags, from, to)
    end

    def copy_r(from, to, options = {})
      # from = from.include?('*') ? Dir.glob(from) : [from]
      # from.each { |f| FileUtils.cp_r(f, to, options) }
      flags = posix_flags('-r', '-v': !!options[:verbose])
      cmd('cp', *flags, from, to)
    end

    def chdir(path)
      Dir.chdir(path) { yield }
    end

    def append_file(filepath, string, verbose: false, before: nil, after: nil, safe: false)
      raise ArgumentError, "can't use :before and :after in same time" if before && after

      unless File.exist?(filepath)
        return failure!(safe, verbose) { "can't find file at #{filepath}" }
      end

      after_index = nil
      if after || before
        content = File.read(filepath)
        after_index = content.index(after || before)
        return if after_index.nil?
      end
      after_index -= before.size if after_index && before

      File.open(filepath, 'a+') do |f|
        f.seek(after_index, IO::SEEK_SET) if after_index
        f.write(string)
      end
      puts_verbose("Append #{string.inspect} to #{filepath}") if verbose
    end

    # @param safe [Boolean]
    # @param verbose [Boolean]
    # @raise [ArgumentError]
    # @return [nil]
    # @example
    #   unless File.exist?(filepath)
    #     return failure!(true, true) { "can't find file at #{filepath}" }
    #   end
    def failure!(safe = false, verbose = false, &block)
      raise ArgumentError, block.call unless safe
      puts_verbose("[Error] #{block.call}") if verbose
      nil
    end

    def puts_verbose(msg, color: :red, style: :normal)
      if respond_to?(:puts_colored)
        puts_colored(msg, color: color, style: style)
      else
        puts(msg)
      end
    end

    def replace_file(filepath, new_string, old:, verbose: false, safe: false)
      unless File.exist?(filepath)
        return failure!(safe, verbose) { "can't find file at #{filepath}" }
      end

      content = File.read(filepath)
      index_start = content.index(old)
      if index_start.nil?
        return failure!(safe, verbose) { "can't find #{old.inspect} in #{filepath}" }
      end

      if old.is_a?(Regexp)
        old_string = old.match(content[index_start..-1]).to_a.first
      else
        old_string = old
      end
      index_end = index_start + old_string.size
      new_content = content[0..(index_start - 1)] + new_string + content[index_end..-1]
      # File.write(filepath, new_content, mode: 'w')
      File.open(filepath, 'w') do |f|
        f.sync = true
        f.write(new_content)
      end

      puts_verbose("Replace #{old.inspect} with #{new_string.inspect} in #{filepath}") if verbose
    end
  end
end
