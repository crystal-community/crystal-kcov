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

    def run(cmd : String)
      # use CSV library to handle "things in quotes"
      command = CSV.parse(cmd.strip.gsub(/\s+/, ' '), ' ')[0]
      puts("Running command:\n#{command.join(" ")}") if @options.verbose
      resp = Process.run(command[0], command[1..-1], shell: true) do |proc|
        ProcessResponse.new(command.join(" "), error: proc.error.gets_to_end, output: proc.output.gets_to_end)
      end
      resp.status = $?.exit_code
      resp
    end
  end
end
