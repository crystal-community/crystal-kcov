require "./*"

module CrKcov
  class Runner
    def initialize
    end

    def run
      pwd = Dir.current
      base = File.basename(pwd)
      runner_file = File.tempname("crkcov", ".cr", dir: pwd)

      options = Options.parse

      create_spec_runner(runner_file)
      proc_runner = ProcessRunner.new(options)
      command = "crystal build -o #{base} --error-trace #{runner_file}"
      resp = proc_runner.run(command)
      resp.abort_if_failed
      File.delete(runner_file)

      include_path = options.kcov_include_override || "#{pwd}/src"
      command = "#{options.kcov_executable} --include-path=#{include_path} #{options.kcov_args} #{options.coverage_dir} #{base} #{options.executable_args}"
      resp = proc_runner.run(command)
      File.delete(base)

      # Output the results of the specs
      puts(resp.output)
      exit(resp.status)
    end

    def create_spec_runner(runner_file)
      File.open(runner_file, "w") do |file|
        # Colorize.enabled so we still get the terminal colors output
        file.puts("require \"./spec/**\"
          Colorize.enabled=true")
      end
    end
  end
end
