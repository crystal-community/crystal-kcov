require "./spec_helper"

describe CrKcov::Runner do
  it "creates an initial state" do
    state = CrKcov::Runner.new.state

    state.options.coverage_dir.should eq "coverage"
    state.base.should match /crystal-kcov-\d{8}-\d{6}/
    state.runner_file.should contain "crkcov-"
  end

  it "negates build_only and run_only" do
    set_argv_and_run(["--build-only"]) do
      state = CrKcov::Runner.new.state
      state.options.build_only.should eq true
      state.options.run_only.should eq false
    end

    set_argv_and_run(["--run-only"]) do
      state = CrKcov::Runner.new.state

      state.options.build_only.should eq false
      state.options.run_only.should eq true
    end

    set_argv_and_run(["--build-only", "--run-only"]) do
      state = CrKcov::Runner.new.state
      state.options.run_only.should eq false
      state.options.build_only.should eq false
    end
  end

  it "creates a spec runner file" do
    inst = CrKcov::Runner.new
    state = inst.state
    begin
      File.exists?(state.runner_file).should be_false

      inst.create_spec_runner

      File.exists?(state.runner_file).should be_true
    ensure
      File.delete(state.runner_file)
    end
  end

  it "generates spec runner binary" do
    Process.expect_output("crystal", "success!", "", 0)

    inst = CrKcov::Runner.new
    state = inst.state
    state.base = "generates_spec"
    File.exists?(state.runner_file).should be_false
    inst.generate_spec_runner
    File.exists?(state.runner_file).should be_false
  end

  it "runs specs" do
    Process.expect_output("not-really-kcov", "success!", "", 0)

    set_argv_and_run([
      "--run-only",
      "--kcov-executable",
      "not-really-kcov",
      "--kcov-args",
      "--runme",
      "--executable-args",
      "--metoo",
    ]) do
      inst = CrKcov::Runner.new
      state = inst.state
      state.base = "runs_specs"
      File.file_exists << "runs_specs"

      resp = inst.run_specs
      resp.command.should start_with "not-really-kcov --include-path"
      resp.command.should end_with " --runme coverage runs_specs --metoo"
    ensure
      File.file_exists.clear
    end
  end

  it "gets the latest coverage" do
    inst = CrKcov::Runner.new
    state = inst.state
    state.options.coverage_dir = "spec/test_coverage"
    state.base = "sample"

    state.coverage.should be_nil

    inst.get_latest_coverage

    state.coverage.should_not be_nil
  end

  it "colorizes output" do
    inst = CrKcov::Runner.new
    inst.colorize_by_threshold("59", "60", "60").should eq "\e[41m59\e[0m"
    inst.colorize_by_threshold("60", "60", "70").should eq "\e[30;103m60\e[0m"
    inst.colorize_by_threshold("69", "60", "70").should eq "\e[30;103m69\e[0m"
    inst.colorize_by_threshold("70", "60", "70").should eq "\e[30;102m70\e[0m"
    inst.colorize_by_threshold("71", "60", "70").should eq "\e[30;102m71\e[0m"
  end

  context "when processing coverage" do
    it "aborts with 2 when coverage is too low" do
      inst = CrKcov::Runner.new
      state = inst.state

      coverage = <<-END
      {
        "files": [],
        "percent_covered": "10",
        "covered_lines": 0,
        "total_lines": 0,
        "percent_low": 25,
        "percent_high": 75,
        "command": "some test",
        "date": "2021-11-04 00:00:00"
      }
      END
      state.coverage = CrKcov::Coverage.from_json(coverage)
      state.options.fail_under_low = true

      state.report.should be_empty
      state.exit_code.should eq 0

      inst.process_coverage

      state.report.should be_empty
      state.exit_code.should eq 2
    end

    it "aborts with 3 when coverage is below high" do
      inst = CrKcov::Runner.new
      state = inst.state

      coverage = <<-END
      {
        "files": [],
        "percent_covered": "50",
        "covered_lines": 0,
        "total_lines": 0,
        "percent_low": 25,
        "percent_high": 75,
        "command": "some test",
        "date": "2021-11-04 00:00:00"
      }
      END
      state.coverage = CrKcov::Coverage.from_json(coverage)
      state.options.fail_under_high = true

      state.report.should be_empty
      state.exit_code.should eq 0

      inst.process_coverage

      state.report.should be_empty
      state.exit_code.should eq 3
    end

    it "outputs json" do
      inst = CrKcov::Runner.new
      state = inst.state

      coverage = <<-END
      {
        "files": [],
        "percent_covered": "50",
        "covered_lines": 0,
        "total_lines": 0,
        "percent_low": 25,
        "percent_high": 75,
        "command": "some test",
        "date": "2021-11-04 00:00:00"
      }
      END
      state.coverage = CrKcov::Coverage.from_json(coverage)
      state.options.output_json = true

      state.report.should be_empty

      inst.process_coverage

      JSON.parse(state.report[0]).should eq JSON.parse(coverage)
    end

    it "outputs a report" do
      inst = CrKcov::Runner.new
      state = inst.state

      coverage = <<-END
      {
        "files": [
          {
            "file": "some_file",
            "percent_covered": "100.00",
            "covered_lines": "2",
            "total_lines": "5"
          }
        ],
        "percent_covered": "50",
        "covered_lines": 0,
        "total_lines": 0,
        "percent_low": 25,
        "percent_high": 75,
        "command": "some test",
        "date": "2021-11-04 00:00:00"
      }
      END
      state.coverage = CrKcov::Coverage.from_json(coverage)
      state.options.output = true

      state.report.should be_empty

      inst.process_coverage

      state.report.should eq ["", "some_file\t\e[30;102m100.00\e[0m\t(2 / 5)", "Covered 1 files\nTotal covored:\t\e[30;103m50\e[0m\t(0 / 0)"]
    end
  end

  context "when running" do
    it "builds only" do
      set_argv_and_run([
        "--build-only",
      ]) do
        inst = CrKcov::Runner.new
        Process.expect_output("crystal", "", "", 0)
        inst.run
      end
    end

    it "runs only" do
      set_argv_and_run([
        "--run-only",
        "--coverage-dir", "spec/test_coverage",
        "--suppress",
      ]) do
        inst = CrKcov::Runner.new
        inst.state.base = "sample"
        Process.expect_output("kcov", "", "", 0)
        File.write("sample", "fake binary file")
        inst.run
        inst.state.exit_code.should eq 0
      ensure
        File.delete("sample")
      end
    end
  end
end
