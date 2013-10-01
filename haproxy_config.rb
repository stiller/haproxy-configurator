require 'erb'
require 'yaml'
require 'net/https'
require 'uri'
require 'json'
require 'pry'

CONFPATH = Dir.home
CONFFILE = 'proxyconf.yml'

class HAProxyConfig
  attr_accessor :config, :domains, :request, :http

  def initialize
    if File.exists?(CONFPATH + "/" + CONFFILE)
      config = YAML.load_file(CONFPATH + "/" + CONFFILE)
      config.default_proc = proc{ |h,k| h.key?(k.to_s) ? h[k.to_s] : nil }
    else
      raise "Config file not found: #{CONFPATH}/#{CONFFILE}"
    end
    uri = URI.parse config[:url]
    @http = Net::HTTP.new(uri.host,uri.port)
    @http.use_ssl = true
    @request = Net::HTTP::Get.new(uri.request_uri)
    @request.basic_auth(config[:user],config[:password])
  end

  def get
    response = @http.request(@request)
    JSON.parse response.body
  end

  def create
    template_file = File.open("haproxy.cfg.erb", 'r').read
    erb = ERB.new(template_file)
    File.open("/etc/haproxy/haproxy.cfg", 'w') { |file| file.write(erb.result(binding)) }
  end

end
puts HAProxyConfig.new.get
