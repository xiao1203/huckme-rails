class DiagnosticsController < ApplicationController
  before_action :require_login

  def new
  end

  # VULN (OS Command Injection): host is interpolated into a shell command with no
  # validation or escaping. A payload like "example.com; cat /etc/passwd" or
  # "example.com `id`" runs arbitrary commands as the app's user.
  def ping
    host = params[:host]
    @output = `ping -c 2 #{host} 2>&1`
    render :new
  end

  # VULN (SSRF): fetches an arbitrary attacker-supplied URL server-side, including
  # internal/cloud-metadata hosts, with no allowlist on scheme or destination.
  def fetch_url
    uri = URI.parse(params[:url])
    @preview = Net::HTTP.get(uri)
    render :new
  rescue StandardError => e
    @preview = "error: #{e.message}"
    render :new
  end
end
