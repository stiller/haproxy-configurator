require 'erb'
require 'yaml'
require 'net/https'
require 'uri'
require 'json'
require 'fileutils'

CONFPATH = Dir.home
CONFFILE = 'proxyconf.yml'

class HAProxyConfig
  attr_reader :config

  def initialize
    if File.exists?(CONFPATH + "/" + CONFFILE)
      @config = YAML.load_file(CONFPATH + "/" + CONFFILE)
      @config.default_proc = proc{ |h,k| h.key?(k.to_s) ? h[k.to_s] : nil }
    else
      raise "Config file not found: #{CONFPATH}/#{CONFFILE}"
    end
    uri = URI.parse config[:url]
    @http = Net::HTTP.new(uri.host,uri.port)
    @http.use_ssl = true
    @request = Net::HTTP::Get.new(uri.request_uri)
    @request.basic_auth(config[:user],config[:password])
  end

  def fetch
    response = @http.request(@request)
    @domains = JSON.parse response.body
    self
  end

  def render template_file = "haproxy.cfg.erb"
    template = File.open(template_file, 'r').read
    erb = ERB.new(template)
    @result = erb.result(binding)
    self
  end
  
  def write config_path = "/etc/haproxy/haproxy.cfg"
    return unless File.exists?(config_path)
    FileUtils.cp(config_path, config_path.split(".")[0] + ".bk")
    File.open(config_path, 'w') { |file| file.write(@result) }
    puts "Done."
  end
end

if $stdout.tty? # execute if called from terminal
  if ENV["USER"] == "root"
    HAProxyConfig.new.fetch.render.write
  else
    puts "Please call using sudo."
  end
end
