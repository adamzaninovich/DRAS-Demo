require 'net/http'
require 'net/https'
require 'nokogiri'

# TODO: add confirmation

class DRAS
  
  attr_reader :site,:endpoint, :confirmation_endpoint, :port,
              :event_status, :operation_mode_value, :last_check, :ssl
    
  def initialize(opts)
    @last_check           = "NEVER"
    @event_status         = "NOT_SET"
    @operation_mode_value = "NOT_SET"
    
    @site = opts['site']
    @endpoint = opts['endpoint']
    @confirmation_endpoint = opts['confirm_ep']
    
    @cache_file = "#{File.dirname(__FILE__)}/../cache/#{opts['cache']}.xml" if opts['cache']
    
    @auth = [opts['auth']['user'],opts['auth']['pass']]
    @ssl  = !!opts['use_ssl']
    @port  = opts['port'].nil? ? (@ssl ? 443 : 80) : opts['port']
    
    @http = Net::HTTP.new(@site, @port)
    @http.use_ssl = @ssl
    
    update_from_cache if @cache_file
  end
  
  def update_from_cache
    if @cache_file and FileTest.file?(@cache_file)
      file = File.open(@cache_file)
      doc = Nokogiri::XML(file)
      file.close
      @event_status          = doc.xpath("//p:EventStatus").first.text
      @operation_mode_value  = doc.xpath("//p:OperationModeValue").first.text
      @last_check = 'from cache file'
    else
      puts "WARNING: No cache file."
    end
  end
  
  def check
    @http.start do |http|
      req = Net::HTTP::Get.new(@endpoint)
      req.basic_auth(*@auth) if @auth.is_a? Array
      response = http.request(req)
      doc = Nokogiri::XML(response.body)
      
      @last_check = Time.new
      
      if @cache_file
        file = File.new(@cache_file, "w")
        file.write(response.body)
        file.close
      end
      
      @event_status          = doc.xpath("//p:EventStatus").first.text
      @operation_mode_value  = doc.xpath("//p:OperationModeValue").first.text
    end
    yield if block_given?
  end
  
end
