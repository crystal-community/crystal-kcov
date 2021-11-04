module CrKcov
  class Coverage
    include JSON::Serializable

    getter files : Array(FileCoverage)
    getter percent_covered : String
    getter total_lines : Int32
    getter covered_lines : Int32
    getter percent_low : Int32
    getter percent_high : Int32
    getter command : String
    getter date : String

    def initialize(@files, @percent_covered, @total_lines, @covered_lines, @percent_low, @percent_high, @command, @date)
    end

    setter percent_covered
  end

  class FileCoverage
    include JSON::Serializable

    getter file : String
    getter percent_covered : String
    getter covered_lines : String
    getter total_lines : String

    setter file, percent_covered
  end
end
