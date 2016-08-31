class Exporter
  def initialize(options = {})
    @output = options[:output]
    @data_source = options[:data_source]
  end

  def export!
    @output.open do |output|
      @data_source.write(output)
    end
  end
end
