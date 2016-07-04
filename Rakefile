$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'bundler'
Bundler::GemHelper.install_tasks

require 'yard-doctest'
YARD::Doctest::RakeTask.new do |task|
  task.doctest_opts = %w[-v]
end

task default: 'yard:doctest'
