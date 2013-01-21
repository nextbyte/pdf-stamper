$:.unshift File.join(File.dirname(__FILE__), "lib")
require 'pdf/stamper'
require 'spec/rake/spectask'

%w[rubygems rake rake/clean fileutils rubigen].each { |f| require f }

Dir['tasks/**/*.rake'].each { |t| load t }

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/*_spec.rb']
  t.warning = true
  t.rcov = false
end
