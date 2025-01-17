require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    #your code here
    user = User.new(user_params(params))

    if user.save
      redirect '/login'
    else
      redirect '/failure'
    end
  end

  get '/account' do
    if logged_in?
      @user = User.find(session[:user_id])
      erb :account
    else
      redirect '/login'
    end
  end


  get "/login" do
    erb :login
  end

  post "/login" do
    ##your code here
    user = User.find_by(username: params[:username])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect '/account'
    else
      redirect '/failure'
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  get '/deposit' do
    erb :deposit_form
  end

  post '/deposit' do
    current_user.make_deposit(params[:amount])
    redirect '/account'
  end

  get '/withdrawal' do
    erb :withdrawal_form
  end

  post '/withdrawal' do
    if current_user.balance < params[:amount].to_i
      erb :not_enough_funds
    else
      current_user.make_withdrawal(params[:amount])
      redirect '/account'
    end   
  end


  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

  private
  def user_params(params)
    {
      :username => params[:username],
      :password => params[:password]
    }
  end

end

