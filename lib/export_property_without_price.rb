require 'elasticsearch'
require 'byebug'

class ExportPropertyWithOutPrice
  HOST = "localhost:14000"
  INDEX = "phobo_reading"

  def initialize(options = {})
    @exporter = options[:exporter]
  end

  def execute!
    scroll_all do |slice_data|
      export(slice_data)
    end
  end

  def scroll_all(&block)
    data = init_scroll
    block.call(data)

    while data && data["hits"]["hits"].any? do
      data = scroll do |result|
        block.call(result)
      end
    end

    @exporter.flush!
  end

  def scroll(&block)
    return nil unless scroll_id

    result = client.scroll(scroll_id: scroll_id, scroll: '1m')
    block.call result

    result
  end

  def scroll_id
    @scroll_id
  end

  def init_scroll
    result = client.search(index: INDEX, size: 100, body: query_hash, scroll: '1m')
    @scroll_id = result['_scroll_id']

    result
  end

  def client
    @client ||= Elasticsearch::Client.new(host: HOST)
  end

  def export(data)
    @exporter.export(data)
  end

  def query_hash
    {
      query: {
        bool: {
          must: [
            { missing: { field: :daily_price } },
            { term: { date: Date.today }}
          ]
        }
      }
    }
  end
end

require_relative 'csv_export'

options = {
  exporter: CsvExport.new
}

ExportPropertyWithOutPrice.new(options).execute!
