require "./spec_helper"

describe CrKcov::ProcessRunner do
  it "runs commands" do
    opts = CrKcov::Options.new
    proc_runner = CrKcov::ProcessRunner.new(opts)

    Process.expect_output("fake", "expected output", "", 256)

    resp = proc_runner.run("fake command is run")

    resp.command.should eq "fake command is run"
    resp.output.should eq "expected output"
    resp.error.should eq ""
    resp.status.should eq 1
  end
end
