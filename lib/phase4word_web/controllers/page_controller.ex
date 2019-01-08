defmodule Phase4wordWeb.PageController do
  use Phase4wordWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
