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
    erb :home
  end
  
  get '/check' do
    @dras.check do
      redirect '/'
    end
  end
  
end
