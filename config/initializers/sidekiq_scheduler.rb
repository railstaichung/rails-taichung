require 'sidekiq/scheduler'
Dir[File.expand_path('../lib/workers/*.rb',__FILE__)].each do |file| load file; end

Sidekiq.configure_server do |config|

  config.on(:startup) do
    Sidekiq.schedule = YAML.load_file(File.expand_path("../../../config/scheduler.yml",__FILE__))
  end
end
