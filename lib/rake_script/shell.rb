require 'open3'

module RakeScript
  module Shell
    # RakeScript::Shell helper allows easy shell commands execution.

    # Wrapper around #execute which raise RuntimeError when command was exited unsuccessfully.
    # Prefer to use this method unless you allow some command to fail.
    # @param command [String] shell command.
    # @param arguments [Array<String, Hash>] command arguments with optional last hash.
    def cmd(command, *arguments)
      result = execute(command, *arguments)
      if result[:code] != 0
        raise RuntimeError, "command #{result[:command].inspect} failed with code: #{result[:code]}"
      end
    end

    # Executes shell command and stream it's output.
    # @param command [String] shell command.
    # @param arguments [Array<String, Hash>] command arguments with optional last hash,
    #   last arguments hash keys:
    #   :stdout [Proc<String>] each command output line will be passed to this proc (print to STDOUT by default),
    #   :stderr [Proc<String>] each command error output line will be passed to this proc (print to STDERR by default),
    #   :env [Hash] optional environment hash,
    #   :debug [TruClass,FalseClass] prints command before execution (true by default),
    #   :debug_color [Symbol] color of debug print (@see RakeScript::Formatting::PROMPT_COLORS),
    #   :debug_style [Symbol] style of debug print (@see RakeScript::Formatting::PROMPT_STYLES).
    # @return [Hash] hash with keys:
    #   :code [Integer] exit code status of command,
    #   :command [String] command line without environment.
    def execute(command, *arguments)
      # extracting options
      options = arguments.last.is_a?(Hash) ? arguments.pop : {}

      # extract option keys
      stdout = options.fetch(:stdout) { proc { |raw_line| STDOUT.puts(raw_line) } }
      stderr = options.fetch(:stderr) { proc { |raw_line| STDERR.puts(raw_line) } }
      env = options.fetch(:env, {})
      debug = options.fetch(:debug, true)
      debug_color = options.fetch(:debug_color, :light_cyan)
      debug_style = options.fetch(:debug_style, :underlined)

      # calculating command line
      env_str = env.map { |k, v| "#{k}=#{v}" }.join(' ')
      command_line = ([env_str, command] + arguments).reject(&:empty?).join(' ')

      # debugging
      if debug
        if respond_to?(:puts_colored, true)
          puts_colored(command_line, color: debug_color, style: debug_style)
        else
          puts command_line
        end
      end

      # execution
      status = raw_execute(command_line, stdout: stdout, stderr: stderr)

      # response
      { code: status.exitstatus, command: command_line }
    end

    # Executes shell command and stream it's output.
    # @param command_line [String] command line to execute.
    # @param stdout [Proc] each command output line will be passed to this proc.
    # @param stderr [Proc] each command error output line will be passed to this proc.
    # @return [Process::Status] status object for command.
    def raw_execute(command_line, stdout:, stderr:)
      Open3.popen3(command_line) do |_stdin_io, stdout_io, stderr_io, wait_thread|
        Thread.new do
          begin
            until (raw_line = stdout_io.gets).nil? do
              stdout.call(raw_line)
            end
          rescue IOError => _
            # command process was closed and it's ok
          end

        end
        Thread.new do
          begin
            until (raw_line = stderr_io.gets).nil? do
              stderr.call(raw_line)
            end
          rescue IOError => _
            # command process was closed and it's ok
          end
        end
        wait_thread.value
      end
    end
  end
end
