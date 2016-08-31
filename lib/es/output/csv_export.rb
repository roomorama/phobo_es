require 'csv'

class CsvOutput
  def initialize(options = {})
    @file_path = "output.csv"
  end

  def open
    CSV.open(@file_path, "a+") do |f|
      yield f
    end
  end
end
