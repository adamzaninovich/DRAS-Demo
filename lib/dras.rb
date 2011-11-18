require 'net/http'
require 'net/https'
require 'nokogiri'

# Example usage
# dras = DRAS.new "cdp.openadr.com",
#                 "/RestClientWS/rest2",
#                 "/RestClientWS/restConfirm",
#                 ssl:true, auth: ['akua.client1','Test_1234']
# dras.check
# puts "#{dras.operation_mode_value} operation was #{dras.event_status} at #{dras.last_check}"

# TODO: add confirmation

class DRAS
  
  attr_accessor :site, :endpoint, :confirmation_endpoint
  attr_reader :event_status, :operation_mode_value, :last_check, :ssl
    
  def initialize(site, endpoint, confirmation_endpoint, opts={})
    @last_check           = "NEVER"
    @event_status         = "NOT_SET"
    @operation_mode_value = "NOT_SET"
    
    @site = site
    @endpoint = endpoint
    @confirmation_endpoint = confirmation_endpoint
    
    @auth = opts[:auth]
    @ssl  = !!opts[:ssl]
    port  = opts[:port].nil? ? (@ssl ? 443 : 80) : opts[:port]
    
    @http = Net::HTTP.new(@site, port)
    @http.use_ssl = @ssl
  end
  
  def check
    @http.start do |http|
      req = Net::HTTP::Get.new(@endpoint)
      req.basic_auth(*@auth) if @auth.is_a? Array
      response = http.request(req)
      doc = Nokogiri::XML(response.body)
      
      @last_check = Time.new
      @event_status          = doc.xpath("//p:EventStatus").first.text
      @operation_mode_value  = doc.xpath("//p:OperationModeValue").first.text
    end
    yield if block_given?
  end
  
end
