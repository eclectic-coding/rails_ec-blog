class WwwRedirect
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["HTTP_HOST"]&.start_with?("www.")
      host = env["HTTP_HOST"].delete_prefix("www.")
      location = "https://#{host}#{env['REQUEST_URI']}"
      [301, { "Location" => location, "Content-Type" => "text/html", "Content-Length" => "0" }, []]
    else
      @app.call(env)
    end
  end
end

Rails.application.config.middleware.insert_before(ActionDispatch::SSL, WwwRedirect) if Rails.env.production?
