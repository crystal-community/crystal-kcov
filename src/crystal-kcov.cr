require "option_parser"
require "json"
require "colorize"

class Options
  property kcov_executable : String? = "kcov"
  property kcov_args : String? = nil
  property kcov_include_override : String? = nil
  property coverage_dir : String = "coverage"
  property executable_args : String? = nil
  property output : Bool = false
  property output_json : Bool = false
  property cleanup_coverage : Bool = false
  property fail_under_low : Bool = false
  property fail_under_high : Bool = false
end

options = Options.new
OptionParser.new do |parser|
  parser.banner = "Usage: ./bin/crkcov [args]"

  parser.on "-h", "--help", "Show this message" do
    puts parser
    exit
  end

  parser.on "--kcov-args ARGS", "Arguments to be passed to kcov" do |args|
    options.kcov_args = args
  end

  parser.on "--executable-args ARGS", "Arguments to be passed to executable" do |args|
    options.executable_args = args
  end

  parser.on "--kcov-executable", "Path to kcov executable to use, if not on PATH" do |path|
    options.kcov_executable = path
  end

  parser.on "--include-override", "Path override for kcovs --include-path. Will implicitly be set to 'src/' already. Use this command to change that" do |override|
    options.kcov_include_override = override
  end

  parser.on "--output", "Outputs the basic results of the coverage tests to terminal" do
    options.output = true
  end

  parser.on "--output-json", "Outputs the generated coverage json file to stdout" do
    options.output_json = true
  end

  parser.on "--cleanup-coverage", "Delete the coverage directory at the end of running. Useful when paired with --output or --output-json to maintain a clean directory" do
    options.cleanup_coverage = true
  end

  parser.on "--coverage-dir DIRECTORY", "The name of the output coverage directory, defaults to 'coverage'" do |dir|
    options.coverage_dir = dir
  end

  parser.on "--fail-below-low", "Emits a non-zero exit status if coverage is below the 'low' threshold (default 25%)" do
    options.fail_under_low = true
  end

  parser.on "--fail-below-high", "Emits a non-zero exit status if coverage is below the 'high' threshold (default 75%)" do
    options.fail_under_high = true
  end

  parser.missing_option do |_|
    # do nothing
  end

  parser.invalid_option do |_|
    # do nothing
  end
end.parse

pwd = Dir.current
base = File.basename(pwd)
runner_file = File.tempname("crkcov", ".cr", dir: pwd)

File.open(runner_file, "w") do |file|
  file.puts("require \"./spec/**\"")
end

# Generate the executable for running specs
command = "crystal build -o #{base} --error-trace #{runner_file}".strip.split(/\s+/)
# puts("Generating spec executable:\n#{command.join(" ")}")
Process.run(command[0], command[1..-1])
unless $?.exit_status == 0
  abort("Unable to generate coverage reports, exit code from 'crystal build -o #{base} --error-trace #{runner_file}' returned with exit code #{$?.exit_code}")
end
File.delete(runner_file)

# Run the executable with kcov
include_path = options.kcov_include_override || "#{pwd}/src"
command = "#{options.kcov_executable} --include-path=#{include_path} #{options.kcov_args} #{options.coverage_dir} #{base} #{options.executable_args}".strip.split(/\s+/)
# puts("Running kcov command to generate coverage reports:\n#{command.join(" ")}")
Process.run(command[0], command[1..-1].compact)
File.delete(base)

exit_zero = true
if options.output || options.output_json
  coverage_file = "#{options.coverage_dir}/#{base}.*/coverage.json"
  Dir.glob(coverage_file).each do |file_name|
    File.open(file_name) do |file|
      contents = file.gets_to_end
      puts contents if options.output_json
      if options.output
        coverage = JSON.parse(contents)
        low = coverage["percent_low"].as_i
        high = coverage["percent_high"].as_i
        total_covered = coverage["percent_covered"]

        if total_covered.as_s.to_f32 < low
          total_covered = total_covered.as_s.colorize.back(:red)
          exit_zero = false if options.fail_under_low
        elsif total_covered.as_s.to_f32 > high
          total_covered = total_covered.as_s.colorize.back(:green)
        else
          total_covered = total_covered.as_s.colorize.back(:yellow)
          exit_zero = false if options.fail_under_low
        end
        puts("Total code covered: #{total_covered}")
        puts("Covered lines: #{coverage["covered_lines"]} / #{coverage["total_lines"]}")
      end
    end
  end
end

Process.run("rm", ["-rf", options.coverage_dir]) if options.cleanup_coverage
puts exit_zero
exit(1) unless exit_zero
