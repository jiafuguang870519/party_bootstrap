module Fdn
  class UserSessionsController < ApplicationController
    layout 'bootstrap'
    skip_before_filter :require_user, :only => ['new', 'create', 'js_render_captcha']
    skip_before_filter :authorize

    def new
      @user_session = Fdn::UserSession.new
      @user_session.org_code = cookies[:org_code]
    end

    def create
      #logger.info(user_session_params.inspect)
      params[:origin_name] = user_session_params[:username]
      session_params = user_session_params
      session_params[:username] = "#{user_session_params[:org_code]}_#{user_session_params[:username]}"
      @user_session = Fdn::UserSession.new(session_params)
      if simple_captcha_valid?
        if @user_session.save
          #logger.info("login successfully")
          session[:org_id] = current_user.resource_id #if current_user.primary_org
          session[:user_id] = current_user.id

          cookies[:org_code] = {value: user_session_params[:org_code], expires: 10.year.from_now}
          #session[:pos_id] = current_user.primary_pos.id if current_user.primary_pos
          #flash[:notice] = "Login successful!"
          redirect_to '/main/index'#root_url
        else
          @user_session.username = params[:origin_name]
          flash[:notice] = I18n.t('e.base.log_in')
          # redirect_to :action => :new
          redirect_to root_url#+'#contact'
        end
      else
        @user_session.username = params[:origin_name]
        flash[:notice] = I18n.t('simple_captcha.message.user')
        # render :action => :new
        redirect_to root_url#+'#contact'
      end
    end


    def quit
      cookies['fdn/user_credentials'] = nil
      cookies['_session_id'] = nil

      current_user_session.destroy
      #flash[:notice] = "Logout successful!"
      #respond_to do |format|
      #  format.html
      #end
      redirect_to root_url#new_fdn_user_session_url
    end

    def js_render_captcha

    end

    private
    def user_session_params
      params.require(:fdn_user_session).permit(:org_code, :username, :password, :value)
    end

  end
end