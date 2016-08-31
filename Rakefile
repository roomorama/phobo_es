require "rake/testtask"

Rake::TestTask.new do |t|
  t.libs << "spec"
  t.test_files = Dir['spec/**/*_spec.rb']
  t.verbose = true
end

task default: :test
