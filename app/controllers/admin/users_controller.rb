module Admin
  class UsersController < ApplicationController
    before_action :require_login
    before_action :require_admin

    def index
      if params[:q].present?
        # VULN (SQL Injection): search query interpolated directly into a raw SQL string.
        @users = User.where("username LIKE '%#{params[:q]}%' OR email LIKE '%#{params[:q]}%'")
      else
        @users = User.all
      end
    end

    def show
      @user = User.find(params[:id])
    end

    def update
      @user = User.find(params[:id])
      # VULN (Mass Assignment): admin screen permits :role, which is fine for an admin
      # to edit here — but combined with the signup mass-assignment bug, any user can
      # reach this screen by first granting themselves the admin role at signup.
      @user.update(params.require(:user).permit(:role, :username, :email))
      redirect_to admin_users_path, notice: "更新しました"
    end
  end
end
