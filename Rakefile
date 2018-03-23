$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'bundler'
Bundler::GemHelper.install_tasks

require 'yard-doctest'
YARD::Doctest::RakeTask.new do |task|
  task.doctest_opts = %w[-v]
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: %w[rubocop yard:doctest]
