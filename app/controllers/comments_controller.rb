class CommentsController < ApplicationController
  before_action :require_login
  skip_before_action :verify_authenticity_token, only: :create
  # VULN (CSRF): CSRF token verification is explicitly skipped on comment creation,
  # so a third-party page can submit a comment as the logged-in victim.

  def create
    @product = Product.find(params[:product_id])
    @product.comments.create(user: current_user, body: params[:body])
    redirect_to product_path(@product)
  end
end
