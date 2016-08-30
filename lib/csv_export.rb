require 'csv'

class CsvExport
  def export(es_data)
    buffer << converted(es_data)

    if full_buffer
      flush!
    end
  end

  def full_buffer
    buffer.size > 10
  end

  def flush!
    CSV.open("output.csv", "a+") do |f|
      buffer.each { |l| f << l}
    end
  end

  def buffer
    @buffer ||= []
  end

  def converted(data)
    data["hits"]["hits"].map { |d| d["_source"].values }
  end
end
