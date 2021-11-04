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

  def self.expect_output(cmd, output, error)
    @@cmd_to_process[cmd] = FakeProcess.new(IO::Memory.new(output), IO::Memory.new(error))
  end

  def self.run(command : String, args = nil, env : Env = nil, clear_env : Bool = false, shell : Bool = false,
               input : Stdio = Redirect::Pipe, output : Stdio = Redirect::Pipe, error : Stdio = Redirect::Pipe, chdir : String? = nil)
    if process = @@cmd_to_process[command]?
      begin
        value = yield process
        $? = process.wait
        value
      rescue ex
        process.terminate
        raise ex
      end
    end
    raise "Command #{command} #{args} not properly set up for mocking"
  end
end

require "spec"
require "../src/runner"
