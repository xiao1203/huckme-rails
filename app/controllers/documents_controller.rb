class DocumentsController < ApplicationController
  before_action :require_login

  UPLOAD_ROOT = Rails.root.join("storage", "uploads")

  def index
    @documents = current_user.documents
  end

  # VULN (Path Traversal): filename comes straight from the query string and is
  # joined onto the uploads directory with no basename/allowlist check, so
  # "../../../../etc/passwd" escapes the intended directory.
  def download
    path = File.join(UPLOAD_ROOT, params[:filename])
    send_file path, disposition: "attachment"
  end
end
