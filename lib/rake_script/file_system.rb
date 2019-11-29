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
  end
end
