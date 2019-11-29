require 'rake_script/logging'
require 'rake_script/shell'
require 'rake_script/file_system'

module RakeScript
  module RakeMethods
    # RakeScript::RakeMethods aggregate al helper modules from this gem to single mixin.

    include RakeScript::Logging
    include RakeScript::Shell
    include RakeScript::FileSystem
  end
end
