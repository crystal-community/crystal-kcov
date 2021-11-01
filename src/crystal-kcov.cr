require "./runner"
require "json"
require "colorize"

CrKcov::Runner.new.run

# # Run the executable with kcov
# include_path = options.kcov_include_override || "#{pwd}/src"
# command = "#{options.kcov_executable} --include-path=#{include_path} #{options.kcov_args} #{options.coverage_dir} #{base} #{options.executable_args}".strip.split(/\s+/)
# puts("Running kcov command to generate coverage reports:\n#{command.join(" ")}") if options.verbose
# Process.run(command[0], command[1..-1].compact)
# File.delete(base)

# exit_zero = true
# if options.output || options.output_json
#   coverage_file = "#{options.coverage_dir}/#{base}.*/coverage.json"
#   Dir.glob(coverage_file).each do |file_name|
#     File.open(file_name) do |file|
#       contents = file.gets_to_end
#       puts contents if options.output_json
#       if options.output
#         coverage = JSON.parse(contents)
#         low = coverage["percent_low"].as_i
#         high = coverage["percent_high"].as_i
#         total_covered = coverage["percent_covered"]

#         if total_covered.as_s.to_f32 < low
#           total_covered = total_covered.as_s.colorize.back(:red)
#           exit_zero = false if options.fail_under_low
#         elsif total_covered.as_s.to_f32 > high
#           total_covered = total_covered.as_s.colorize.back(:green)
#         else
#           total_covered = total_covered.as_s.colorize.back(:yellow)
#           exit_zero = false if options.fail_under_low
#         end
#         puts("Total code covered: #{total_covered}")
#         puts("Covered lines: #{coverage["covered_lines"]} / #{coverage["total_lines"]}")
#       end
#     end
#   end
# end

# Process.run("rm", ["-rf", options.coverage_dir]) if options.cleanup_coverage
# puts exit_zero
# exit(1) unless exit_zero
