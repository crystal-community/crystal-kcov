require "./spec_helper"

describe "Something" do
  it "works" do
    false.should eq(true)
  end
end

describe CrKcov::Coverage do
  it "builds from new" do
    CrKcov::Coverage.new([] of CrKcov::FileCoverage, "nope", 0, 0, 0, 0, "spec", "nope")
  end

  it "Creates a process response" do
    CrKcov::ProcessResponse.new("command", "output", "error")
  end
end
