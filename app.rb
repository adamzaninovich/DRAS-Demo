require 'sinatra'
require 'yaml'
require File.dirname(__FILE__) + '/lib/dras'

class DrasDemo < Sinatra::Base
  
  def initialize(*args)
    super(*args)
    
    @config = YAML.load(File.read(File.dirname(__FILE__) + '/config/config.yml'))['dras']
    
    @dras = DRAS.new @config
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
    "<p>Account: #{@config['auth']['user']}" +
    "<p>End point: #{(@dras.ssl ? 'https://' : 'http://')}#{@dras.site}:#{@dras.port}#{@dras.endpoint}</p>" +
    "<p>Last result: #{@dras.operation_mode_value} operation was #{@dras.event_status} (#{@dras.last_check})" + 
    "<a href='/check'>udpate</a></p>" +
    "<p><a href='https://github.com/adamzaninovich/DRAS-Demo'>see the code at github</a></p></body></html>"
  end
  
  get '/check' do
    @dras.check do
      redirect '/'
    end
  end
  
end
