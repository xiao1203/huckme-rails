class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: "登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # VULN (Mass Assignment / Privilege Escalation): :role is permitted directly from
  # client params, so a signup request can set role=admin for itself.
  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation,
                                  :role, :bio, :ssn, :credit_card_number)
  end
end
