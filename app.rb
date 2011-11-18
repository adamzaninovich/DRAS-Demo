require 'sinatra'
require File.dirname(__FILE__) + '/lib/dras'

class DrasDemo < Sinatra::Base
  
  def initialize(*args)
    super(*args)
    @dras = DRAS.new  "cdp.openadr.com",
                      "/RestClientWS/rest2",
                      "/RestClientWS/restConfirm",
                      ssl:true, auth: ['akua.client1','Test_1234']
  end
  
  get '/' do
    if @dras.last_check == "NEVER"
      redirect '/check'
    end
    "<!DOCTYPE html><html><head><meta charset='utf-8' /><title>DRAS Demo</title>" + 
    "<style>" + 
    "body{color: #181818;margin:40px 0 0 40px;font: 16px/24px helvetica;}" + 
    "a{color: #181818;text-decoration: underline;padding: 4px 4px 2px;}" +
    "a:hover{color: #eb0077;text-decoration: none;background: #181818;}" +
    "</style></head>" + 
    "<body><h1>DRAS Demo</h1>" + 
    "<p>End point: #{(@dras.ssl ? 'https://' : 'http://')}#{@dras.site}#{@dras.endpoint}</p>" +
    "<p>Last result: #{@dras.operation_mode_value} operation was #{@dras.event_status} at #{@dras.last_check}</p>" + 
    "<p><a href='/check'>check again</a></p></body></html>"
  end
  
  get '/check' do
    @dras.check do
      redirect '/'
    end
  end
  
end
