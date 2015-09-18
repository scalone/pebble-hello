task :default => :mruby
task :mruby do
  ENV["MRUBY_CONFIG"] = File.join(File.dirname(File.expand_path(__FILE__)), "mruby_config.rb")
  FileUtils.cd File.join(File.dirname(File.expand_path(__FILE__)), "mruby")
  sh "rake"
end
