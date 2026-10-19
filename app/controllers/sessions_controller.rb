class SessionsController < ApplicationController
  def new
  end

  def create
    # VULN (SQL Injection): user-controlled string interpolated directly into SQL.
    # Intentionally bypasses ActiveRecord's parameter binding for lab purposes.
    user = User.find_by("email = '#{params[:email]}'")

    # VULN (Broken Authentication): no rate limiting / lockout on repeated attempts,
    # enabling credential stuffing and brute force.
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "ログインしました"
    else
      flash.now[:alert] = "メールアドレスまたはパスワードが違います"
      render :new, status: :unauthorized
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path, notice: "ログアウトしました"
  end
end
