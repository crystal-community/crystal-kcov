module CrKcov
  class ProcessResponse
    property command : String
    property output : String
    property error : String
    property status : Int32 = 0

    def initialize(@command, @output, @error)
    end

    def abort_if_failed
      return if @status == 0

      abort("Command '#{@command}' failed with status #{@status}. Error and Output were:\nERROR:\n#{@error}\n\nOUTPUT:\n#{@output}")
    end
  end

  class ProcessRunner
    def initialize(@options : CrKcov::Options)
    end

    def run(cmd : String, specs : Bool = false)
      # use CSV library to handle "things in quotes"
      command = CSV.parse(cmd.strip.gsub(/\s+/, ' '), ' ')[0]
      puts("Running command:\n#{command.join(" ")}") if @options.verbose
      # If we're running the specs directly and NOT running in silent mode, send the normal spec output
      # to STDOUT and STDERR directly instead of having us manage it in the runner class.
      send_to_std = specs && !@options.silent
      resp = Process.run(command[0], command[1..-1], shell: true,
        output: (send_to_std ? STDOUT : Process::Redirect::Pipe),
        error: (send_to_std ? STDERR : Process::Redirect::Pipe)) do |proc|
        ProcessResponse.new(
          command.join(" "),
          error: (send_to_std ? "" : proc.error.gets_to_end),
          output: (send_to_std ? "" : proc.output.gets_to_end))
      end
      resp.status = $?.exit_code
      resp
    end
  end
end
