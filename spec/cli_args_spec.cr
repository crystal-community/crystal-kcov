require "./spec_helper"

describe CrKcov::Options do
  it "parses from ARGV" do
    old_argv = ARGV.clone
    begin
      ARGV.clear
      [
        "--kcov-args", "arg1, arg2, arg3",
        "--executable-args", "arg4, arg5, arg6",
        "--kcov-executable", "RUNME",
        "--include-override", "notsrc",
        "--output",
        "--output-json",
        "--cleanup-coverage-before",
        "--cleanup-coverage-after",
        "--coverage-dir", "MYDIR",
        "--fail-below-low",
        "--fail-below-high",
        "--suppress",
        "--build-only",
        "--run-only",
        "--verbose",
        "notvalid",
        "--missing",
      ].each do |arg|
        ARGV << arg
      end

      options = CrKcov::Options.parse

      options.kcov_args.should eq "arg1, arg2, arg3"
      options.executable_args.should eq "arg4, arg5, arg6"
      options.kcov_executable.should eq "RUNME"
      options.kcov_include_override.should eq "notsrc"
      options.output.should eq true
      options.output_json.should eq true
      options.cleanup_coverage_before.should eq true
      options.cleanup_coverage_after.should eq true
      options.coverage_dir.should eq "MYDIR"
      options.fail_under_low.should eq true
      options.fail_under_high.should eq true
      options.silent.should eq true
      options.build_only.should eq true
      options.run_only.should eq true
      options.verbose.should eq true
    ensure
      ARGV.clear
      old_argv.each do |arg|
        ARGV << arg
      end
    end
  end
end
