require "option_parser"

module CrKcov
  class State
    property pwd : String
    property base : String
    property runner_file : String
    property proc_runner : ProcessRunner
    property exit_code : Int32 = 0
    property coverage : Coverage?
    property report = [] of String

    property options : Options

    def initialize(@options, @pwd, @base, @runner_file, @proc_runner)
    end

    def coverage!
      coverage.not_nil!
    end
  end

  class Options
    property kcov_executable : String? = "kcov"
    property kcov_args : String? = nil
    property crystal_build_args : String? = nil
    property kcov_include_override : String? = nil
    property coverage_dir : String = "coverage"
    property executable_args : String? = nil
    property output : Bool = false
    property output_json : Bool = false
    property cleanup_coverage_after : Bool = false
    property cleanup_coverage_before : Bool = false
    property fail_under_low : Bool = false
    property fail_under_high : Bool = false
    property silent : Bool = false
    property build_only : Bool = false
    property run_only : Bool = false
    property verbose : Bool = false
    property name : String? = nil

    def self.parse
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

        parser.on "--build-args ARGS", "Arguments to be passed to crystal as it's compiling (i.e. compiler args could be here)" do |args|
          options.crystal_build_args = args
        end

        parser.on "--kcov-executable PATH", "Path to kcov executable to use, if not on PATH" do |path|
          options.kcov_executable = path
        end

        parser.on "--include-override SRC", "Path override for kcovs --include-path. Will implicitly be set to 'src/' already. Use this command to change that" do |override|
          options.kcov_include_override = override
        end

        parser.on "--output", "Outputs the basic results of the coverage tests to terminal" do
          options.output = true
        end

        parser.on "--output-json", "Outputs the generated coverage json file to stdout" do
          options.output_json = true
        end

        parser.on "--cleanup-coverage-after", "Delete the coverage directory at the end of running. Useful when paired with --output or --output-json to maintain a clean directory" do
          options.cleanup_coverage_after = true
        end

        parser.on "--cleanup-coverage-before", "Delete the coverage directory before running. Useful to make sure only latest report exists" do
          options.cleanup_coverage_before = true
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

        parser.on "--suppress", "Don't emit spec output (still exits with non-zero if specs fail)" do
          options.silent = true
        end

        parser.on "--build-only", "Only build the spec binary, skip running" do
          options.build_only = true
        end

        parser.on "--run-only", "Only run the spec binary (should only be run after --build-only has run)" do
          options.run_only = true
        end

        parser.on "--name NAME", "Optional name for the executable (will show up in coverage HTML)" do |name|
          options.name = name
        end

        parser.on "--verbose", "Output verbose logging" do
          options.verbose = true
        end

        parser.missing_option do |_|
          # do nothing
        end

        parser.invalid_option do |_|
          # do nothing
        end
      end.parse
      options
    end
  end
end
