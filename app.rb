require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models.rb'

enable :sessions 


before do
 Dotenv.load
 Cloudinary.config do |config|
     config.cloud_name=ENV["CLOUD_NAME"]
     config.api_key   =ENV["CLOUDINARY_API_KEY"]
     config.api_secret=ENV["CLOUDINARY_API_SECRET"]
  end
end

get "/" do
 redirect "/signin"
end

get "/signin" do
    erb :sign_in
end

get "/signup" do
    erb :sign_up
end

post "/signin" do
    user = User.find_by(username: params[:username])
    if user && user.authenticate(params[:password])
        session[:user] = user.id
    end
    redirect "/"
end

post "/signup" do
     img_url = ''
     if params[:file]
        img = params[:file]
        tempfile =img[:tempfile]
        upload =Cloudinary::Uploader.upload(tempfile.path)
        img_url =upload["url"]
     end
 
    user = User.create(
        username: params[:username],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        img: img_url,
        )
 
    if user.persisted?
        session[:user] = user.id
        redirect "/counters"
    else
        redirect "/"
    end
end
    
get "/counters" do
    erb :counters
end
    
get "/signout" do
    session[:user] = nil
    redirect "/"
end