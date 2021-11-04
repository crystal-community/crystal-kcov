module CrKcov
  class Coverage
    include JSON::Serializable

    getter files : Array(FileCoverage)
    property percent_covered : String
    getter total_lines : Int32
    getter covered_lines : Int32
    getter percent_low : Int32
    getter percent_high : Int32
    getter command : String
    getter date : String
  end

  class FileCoverage
    include JSON::Serializable

    property file : String
    property percent_covered : String
    getter covered_lines : String
    getter total_lines : String
  end
end
