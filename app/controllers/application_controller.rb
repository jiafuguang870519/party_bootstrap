#coding: utf-8
class ApplicationController < ActionController::Base
  cache_sweeper :actor_sweeper
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  #SimpleCaptcha
  include SimpleCaptcha::ControllerHelpers
  #default layout
  layout :system_layout
  helper_method :current_user_session, :current_user, :current_org
  before_filter :require_user
  after_filter :logger_user_action

  ACTION_LOGGER = {
      :update => '更新',
      :create => '创建',
      :show => '查看',
      :pub => '更新',
      :quit => '退出系统'
  }

  #将params中的date型字符串改编为time型，加23：59：59
  def date_to_end_time(params, attributes=[])
    if !params.blank? && params.is_a?(Hash)
      attributes.each do |a|
        if params.has_key?(a) && params[a] =~ /^\d{4}-\d{1,2}-\d{1,2}$/
          params[a] += ' 23:59:59'
        end
      end
    end
  end

  private
  def system_layout
    if Settings.layout.form.include? action_name
      'form'
    else
      'main'
    end
  end

  #返回当前用户session
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = Fdn::UserSession.find
  end

  #设置多语言环境
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  #返回当前用户对象
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.user
  end

  def current_org
    return current_user.resource if current_user
  end

  #需要登录
  def require_user
    store_location
    if session[:return_to].include?('fdn/file_resources/ffxes')
      return session[:return_to]
    end
    if current_user
      session[:user_id] = current_user.id if session[:user_id].blank?
      session[:org_id] = current_user.resource_id if session[:org_id].blank?
      return true
    else
      redirect_to_log_in
      return false
    end

  end

  #用户操作日志
  def logger_user_action
    unless current_user.nil?
      #只记录特定类型的操作
      if ACTION_LOGGER.has_key?(params[:action].to_sym)
        logger = Fdn::Logger.new
        logger.user_id = current_user.id
        logger.ip = current_user.current_login_ip
        logger.controller = params[:controller].sub(/\//, '_')
        logger.action = params[:action]
        logger.act_at = Time.now
        logger.save
      end
    end
  end


  #存储请求位置
  def store_location
    #logger.info request.class.name
    session[:return_to] = request.url
  end

  #重定向到已存储的请求或默认请求
  def redirect_back_or_default(default)
    #logger.info session[:return_to]
    #logger.info default
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def redirect_to_log_in
    #flash[:notice] = I18n.t("e.base.must_log_in")
    redirect_to root_url
  end

  #判断是否有权利进行操作
  def authorize
    store_location
    if session[:return_to].include?('fdn/file_resources/ffxes')
      return session[:return_to]
    end
    if u = current_user
      actual_c_name = controller_path.sub(/\//, '_')
      actual_a_name = ACTION_MAPPINGS[action_name.to_sym] || action_name
      unless current_user.send("can_#{actual_a_name}_#{actual_c_name}?")
        logger.warn I18n.t("e.base.try_to_access", {:user => current_user.username})
        redirect_back_or_default root_url
        return false
      end
    else
      redirect_to_log_in
      return false
    end
  end

  def rjs(object_name, columns, var_name)
    collection = object_name.constantize.all
    rjs_by_collection(collection, columns, var_name)
  end

  def rjs_by_collection(collection, columns, var_name)
    values = []
    collection.each do |o|
      value = columns.map { |c| o.respond_to?(c) ? "#{change_column_name(columns, c)}: '#{o.send(c)}' " : "" }
      values << "{#{value.join(',')}}" unless value.blank?
    end
    "var #{var_name} = [#{values.join(',')}];"
  end

  def json_by_collection(collection, columns)
    values = []
    collection.each do |o|
      value = {}
      columns.each do |c|
        value = value.merge({change_column_name(columns, c) => o.send(c)}) if o.respond_to?(c)
      end
      values << value
    end
    values.to_json
  end

  def change_column_name(columns, c)
    return 'value' if columns.index(c) == 0
    return 'label' if columns.index(c) == 1
    return c
  end

end
