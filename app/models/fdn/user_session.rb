module Fdn
  class UserSession < Authlogic::Session::Base
    attr_accessor :org_code, :username, :password

    # configuration here, see documentation for sub modules of Authlogic::Session
    find_by_login_method :find_by_org_and_username
  end
end