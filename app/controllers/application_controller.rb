class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    redirect_to login_path, alert: "ログインしてください" unless logged_in?
  end

  # VULN (Broken Access Control): this only checks a boolean on the user row,
  # and the role itself can be changed via mass assignment elsewhere in the app.
  def require_admin
    redirect_to root_path, alert: "権限がありません" unless current_user&.role == "admin"
  end
end
