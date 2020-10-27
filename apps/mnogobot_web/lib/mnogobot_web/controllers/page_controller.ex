defmodule MnogobotWeb.PageController do
  use MnogobotWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
