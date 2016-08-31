#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('./lib')

require 'es'

options = {
  output: CsvOutput.new,
  data_source: ExportPropertyWithOutPrice.new
}

Exporter.new(options).export!
