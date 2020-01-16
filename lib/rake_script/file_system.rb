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

    def append_file(filepath, string, verbose: false, before: nil, after: nil)
      raise ArgumentError, "can't use :before and :after in same time" if before && after

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
      puts("Append #{string.inspect} to #{filepath}") if verbose
    end
  end
end
