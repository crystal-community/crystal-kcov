require "./spec_helper"

describe CrKcov::Coverage do
  sample_json = <<-EOL
  {
  "files": [
    {"file": "/home/tsornson/programming/crystal-kcov/src/process_runner.cr", "percent_covered": "100.00", "covered_lines": "1", "total_lines": "1"},
    {"file": "/home/tsornson/programming/crystal-kcov/src/cli_args.cr", "percent_covered": "84.31", "covered_lines": "43", "total_lines": "51"},
    {"file": "/home/tsornson/programming/crystal-kcov/src/coverage.cr", "percent_covered": "100.00", "covered_lines": "1", "total_lines": "1"}
  ],
  "percent_covered": "84.91",
  "covered_lines": 45,
  "total_lines": 53,
  "percent_low": 25,
  "percent_high": 75,
  "command": "crystal-kcov",
  "date": "2021-11-04 08:56:21"
}
EOL

  it "parses json" do
    cov = CrKcov::Coverage.from_json(sample_json)

    cov.files.size.should eq 3
    cov.percent_covered.should eq "84.91"
    cov.percent_high.should eq 75
  end
end
