class InvoicesController < ApplicationController
  before_action :require_login

  def index
    @invoices = current_user.invoices
  end

  # VULN (IDOR - Broken Object Level Authorization): looks up ANY invoice by id
  # with no check that it belongs to current_user. Sequential integer ids make
  # enumeration trivial (/invoices/1, /invoices/2, ...).
  def show
    @invoice = Invoice.find(params[:id])
  end
end
