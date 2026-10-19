class ProductsController < ApplicationController
  def index
    @products = params[:q].present? ? Product.where("name LIKE ?", "%#{params[:q]}%") : Product.all
  end

  def show
    @product = Product.find(params[:id])
    @comments = @product.comments.includes(:user)
  end

  # VULN (Sensitive Data Exposure): returns every column, including internal_notes,
  # which is meant to be admin-only, through an unauthenticated JSON endpoint.
  def api_show
    product = Product.find(params[:id])
    render json: product.as_json
  end
end
