require "json"
require "colorize"
require "csv"
require "./cli_args"
require "./coverage"
require "./process_runner"

module CrKcov
  class Runner
    @state : State?

    def initialize
    end

    def run
      unless state.options.run_only
        generate_spec_runner

        return if state.options.build_only
      end

      state.proc_runner.run("rm -rf #{state.options.coverage_dir}") if state.options.cleanup_coverage_before
      resp = run_specs
      state.exit_code = resp.status

      get_latest_coverage

      process_coverage

      # Only output the report if there were no failed tests (otherwise coverage report pushes failures off the screen)
      puts(state.report.join("\n")) if (state.options.output || state.options.output_json) && resp.status == 0
      state.proc_runner.run("rm -rf #{state.options.coverage_dir}") if state.options.cleanup_coverage_after

      finish_with_exit
    end

    def finish_with_exit
      exit(state.exit_code)
    end

    def state
      (@state ||= init_state).not_nil!
    end

    def init_state
      options = Options.parse

      # If both "only" params are specified, negate them out
      if options.run_only && options.build_only
        options.run_only = false
        options.build_only = false
      end

      pwd = Dir.current
      base = options.name || "#{File.basename(pwd)}-#{Time.local.to_s("%Y%m%d")}-#{Time.local.to_s("%H%M%S")}"
      runner_file = File.tempname("crkcov", ".cr", dir: pwd)

      proc_runner = ProcessRunner.new(options)

      state = State.new(options, pwd, base, runner_file, proc_runner)
      state
    end

    def process_coverage
      # output 2 if tests pass and test coverage is below the low threshold
      state.exit_code = 2 if state.exit_code == 0 &&
                             state.options.fail_under_low &&
                             state.coverage!.percent_covered.to_f < state.coverage!.percent_low
      # output 3 if tests pass and test coverage is below the high threshold
      state.exit_code = 3 if state.exit_code == 0 &&
                             state.options.fail_under_high &&
                             state.coverage!.percent_covered.to_f < state.coverage!.percent_high

      state.report << state.coverage!.to_json if state.options.output_json
      if state.options.output
        state.report << ""
        cov = state.coverage!
        if cov.files.size > 0
          cov.files.each do |file|
            file.file = file.file.gsub(state.pwd, "")
            file.percent_covered = colorize_by_threshold(file.percent_covered, cov.percent_low, cov.percent_high)
          end
          max_file_length = cov.files.map { |f| f.file.size }.max
          cov.files.sort_by(&.file).each do |file|
            file.file = file.file.ljust(max_file_length)
            state.report << "#{file.file}\t#{file.percent_covered}\t(#{file.covered_lines} / #{file.total_lines})"
          end
        end
        cov.percent_covered = colorize_by_threshold(cov.percent_covered, cov.percent_low, cov.percent_high)
        state.report << "Covered #{cov.files.size} files\nTotal covored:\t#{cov.percent_covered}\t(#{cov.covered_lines} / #{cov.total_lines})"
      end
    end

    def colorize_by_threshold(total, low, high)
      return total.colorize.back(:red).to_s if total.to_f < low.to_f
      return total.colorize.back(:light_yellow).fore(:black).to_s if total.to_f >= low.to_f && total.to_f < high.to_f
      return total.colorize.back(:light_green).fore(:black).to_s if total.to_f >= high.to_f
      total
    end

    def get_latest_coverage
      latest_name = "#{state.options.coverage_dir}/#{state.base}"
      latest_time = Time.unix(0)
      Dir.children(state.options.coverage_dir).each do |child|
        if child.starts_with?(state.base) && child.size > state.base.size
          info = File.info("#{state.options.coverage_dir}/#{child}")
          if info.modification_time > latest_time
            latest_time = info.modification_time
            latest_name = child
          end
        end
      end
      puts "Reading coverage from #{state.options.coverage_dir}/#{latest_name}/coverage.json" if state.options.verbose
      state.coverage = Coverage.from_json(File.open("#{state.options.coverage_dir}/#{latest_name}/coverage.json"))
      puts "Coverage:\n#{state.coverage.to_json}" if state.options.verbose
    end

    def generate_spec_runner
      create_spec_runner
      command = "crystal build #{state.options.crystal_build_args} -o #{state.base} --error-trace #{state.runner_file}"
      resp = state.proc_runner.run(command)
      File.delete(state.runner_file)
      resp.abort_if_failed
    end

    def run_specs : ProcessResponse
      include_path = state.options.kcov_include_override || "#{state.pwd}/src"
      abort("Could not find any executable named #{state.base}, was it built using a previous run of --build-only?") if state.options.run_only && !File.exists?(state.base)
      command = "#{state.options.kcov_executable} --include-path=#{include_path} #{state.options.kcov_args} #{state.options.coverage_dir} #{state.base} #{state.options.executable_args}"
      resp = state.proc_runner.run(command, specs: true)
      File.delete(state.base) unless state.options.run_only
      resp
    end

    def create_spec_runner
      File.open(state.runner_file, "w") do |file|
        # Colorize.enabled so we still get the terminal colors output
        file.puts("require \"./spec/**\"
          Colorize.enabled=true")
      end
    end
  end
end
