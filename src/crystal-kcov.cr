pwd = Dir.current
base = File.basename(pwd)
runner_file = File.tempname("crkcov-", ".cr", dir: pwd)

File.open(runner_file, "w") do |file|
  file.puts("require \"./spec/**\"")
end

# Generate the executable for running specs
`crystal build -o #{base} --error-trace #{runner_file}`
File.delete(runner_file)

# Run the executable with kcov
`kcov --clean --include-path=#{pwd}/src #{pwd}/coverage #{base}`
File.delete(base)
