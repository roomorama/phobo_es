require 'elasticsearch'

class ExportPropertyWithOutPrice
  HOST = "localhost:14000"
  INDEX = "phobo_reading"

  def initialize(options = {})
  end

  def write(output)
    scroll_all do |slice_data|
      slice_data["hits"]["hits"].each do |d|
        output << d["_source"].values
      end
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

  def query_hash
    {
      query: {
        bool: {
          must: [
            { missing: { field: :daily_price } },
            { term: { date: Date.today }}
          ]
        }
      },
      _source: [ :room_id, :unit_id ]
    }
  end
end
