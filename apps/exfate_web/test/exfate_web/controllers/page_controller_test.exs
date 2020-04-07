defmodule ExfateWeb.PageControllerTest do
  use ExfateWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "ExFate"
  end
end
