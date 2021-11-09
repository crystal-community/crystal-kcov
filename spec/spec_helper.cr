class Process
  class FakeProcess
    getter output : IO
    getter error : IO
    getter status_code : Int32

    def initialize(@output, @error, @status_code)
    end

    def wait
      terminate
      $?
    end

    def terminate
      $? = Process::Status.new(@status_code)
    end
  end

  @@cmd_to_process = {} of String => FakeProcess
  @@run_commands = [] of String
  class_property cmd_to_process, run_commands

  def self.expect_output(cmd, output, error, status_code)
    @@cmd_to_process[cmd] = FakeProcess.new(IO::Memory.new(output), IO::Memory.new(error), status_code)
  end

  def self.run(command : String, args = nil, env : Env = nil, clear_env : Bool = false, shell : Bool = false,
               input : Stdio = Redirect::Pipe, output : Stdio = Redirect::Pipe, error : Stdio = Redirect::Pipe, chdir : String? = nil)
    if process = @@cmd_to_process[command]?
      @@run_commands << "#{command} #{args ? args.join(" ") : ""}".strip
      begin
        value = yield process
        $? = process.wait
        return value
      rescue ex
        process.terminate
        raise ex
      end
    end
    raise "Command #{command} #{args} not properly set up for mocking"
  end
end

class File
  @@file_exists = Set(String).new
  class_property file_exists

  def self.exists?(path : Path | String) : Bool
    return true if @@file_exists.includes?(path)
    previous_def
  end
end

def set_argv_and_run(new_argv)
  old_argv = ARGV.clone
  ARGV.clear
  begin
    new_argv.each { |a| ARGV << a }
    yield
  ensure
    ARGV.clear
    old_argv.each { |a| ARGV << a }
  end
end

Spec.after_each do
  Process.cmd_to_process.clear
  Process.run_commands.clear
end

require "spec"
require "../src/runner"

class CrKcov::Runner
  def finish_with_exit
  end
end
