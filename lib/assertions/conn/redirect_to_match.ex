defmodule ESpec.Phoenix.Assertions.Conn.RedirectToMatch do
  @moduledoc """
  Defines the `redirect_to_match` assertion that expects a connection to redirect to a location that
  matches a regular expression or substring.

  ## Examples

  Expect a connection to redirect to a location matching a regular expression:

      it do: expect(conn).to redirect_to_match(~r{^/foo/bar/})

  Expect a connection to redirect to a location matching a substring:

      it do: expect(conn).to redirect_to_match("/bar/")
  """
  use ESpec.Assertions.Interface

  defp match(conn, pattern) do
    if conn.status >= 300 && conn.status < 400 do
      {_, location} = conn.resp_headers
               |> Enum.find(fn({key, _val}) -> key == "location" end)

      {location =~ pattern, {:redirection, location}}
    else
      {false, {:not_redirection, conn.status}}
    end
  end

  defp success_message(_conn, pattern, {:redirection, location}, positive) do
    to = if positive, do: "matches", else: "does not match"

    "The connection's redirection location `#{location}` #{to} `#{Regex.source(pattern)}`"
  end

  defp error_message(_conn, pattern, {:not_redirection, status}, positive) do
    to = if positive, do: "matches", else: "does not match"

    "Expected the connection to redirect to a location that #{to} `#{Regex.source(pattern)}`, but the HTTP status was #{status}"
  end

  defp error_message(_conn, pattern, {:redirection, location}, positive) do
    to = if positive, do: "matches", else: "does not match"

    "Expected the connection to redirect to a location that #{to} `#{Regex.source(pattern)}`, but it redirects to `#{location}` instead"
  end
end
