module RakeScript
  module FileSystem
    # RakeScript::FileSystem helper allows easy file system manipulations.

    # Check if folder exists.
    # @param path [String] folder path.
    # @return [TruClass,FalseClass] boolean
    def folder_exist?(path)
      File.directory?(path)
    end
  end
end
