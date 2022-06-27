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
        redirect "/counters"
    else
        redirect "/"
    end
end

post "/signup" do
     img_url = '/images/bird.jpg'
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
   @counters = Counter.all.order("id desc")
   if session[:user].present?
    erb :counters
   else
     redirect "/"
   end
end

post "/counters" do
   
    redirect "/newcounter"
end    

get "/signout" do
    session[:user] = nil
    redirect "/"
end

get "/newcounter" do
   if session[:user].present?
    erb :create_counter
   else
     redirect "/"
   end
end

post "/newcounter" do
     img_url = '/images/bird.jpg'
     if params[:counter_file]
        img = params[:counter_file]
        tempfile =img[:tempfile]
        upload =Cloudinary::Uploader.upload(tempfile.path)
        img_url =upload["url"]
     end
 
    counter = Counter.create(
        countername: params[:counter_name],
        counter_number: 0,
        img: img_url,
        user_id: session[:user]
        )
        
    redirect  "/counters"
end

post '/plus/:id' do
  counter = Counter.find(params[:id])
  counter.counter_number = counter.counter_number + 1
  counter.save
  redirect '/counters'
end

post "/delete/:id" do
  Counter.find(params[:id]).destroy
  redirect '/counters'
end

get "/user/:id" do
   if User.find(params[:id]).present?
    @usercounters = User.find(params[:id]).counters
    erb :user
   else
     redirect "/"
   end
    erb :user
end

post '/user_plus/:id' do
  counter = Counter.find(params[:id])
  counter.counter_number = counter.counter_number + 1
  counter.save
  redirect '/user/:id'
end

post "/user_delete/:id" do
  Counter.find(params[:id]).destroy
  redirect '/user/:id'
end