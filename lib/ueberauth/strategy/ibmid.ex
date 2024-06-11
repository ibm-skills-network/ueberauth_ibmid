defmodule Ueberauth.Strategy.IBMId do
  @moduledoc """
  IBMId Strategy for Überauth.
  """

  use Ueberauth.Strategy,
    uid_field: :uniqueSecurityName,
    default_scope: "openid",
    oauth2_module: Ueberauth.Strategy.IBMId.OAuth

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra
  alias Ueberauth.Strategy.Helpers

  @doc """
  Handles initial request for IBMId authentication.
  """
  def handle_request!(conn) do
    scopes = conn.params["scope"] || option(conn, :default_scope)

    opts = [redirect_uri: callback_url(conn), scope: scopes] |> Helpers.with_state_param(conn)

    module = option(conn, :oauth2_module)
    redirect!(conn, apply(module, :authorize_url!, [opts]))
  end

  @doc false
  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    module = option(conn, :oauth2_module)
    token = apply(module, :get_token!, [[code: code, redirect_uri: callback_url(conn)]])

    if token.access_token == nil do
      err = token.other_params["error"]
      desc = token.other_params["error_description"]
      set_errors!(conn, [error(err, desc)])
    else
      conn
      |> store_token(token)
      |> fetch_user(token)
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:ibmid_token, nil)
    |> put_private(:ibmid_user, nil)
  end

  # Store the token for later use.
  @doc false
  defp store_token(conn, token) do
    put_private(conn, :ibmid_token, token)
  end

  defp fetch_user(conn, token) do
    resp =
      Ueberauth.Strategy.IBMId.OAuth.get(
        token,
        "https://login.ibm.com/oidc/endpoint/default/userinfo"
      )

    case resp do
      {:ok, %OAuth2.Response{status_code: 401, body: _body}} ->
        set_errors!(conn, [error("token", "unauthorized")])

      {:ok, %OAuth2.Response{status_code: status_code, body: user}}
      when status_code in 200..399 ->
        put_private(conn, :ibmid_user, user)

      {:error, %OAuth2.Error{reason: reason}} ->
        set_errors!(conn, [error("OAuth2", reason)])
    end
  end

  defp split_scopes(token) do
    (token.other_params["scope"] || "")
    |> String.split(" ")
  end

  @doc """
  Includes the credentials from the IBMId response.
  """
  def credentials(conn) do
    token = conn.private.ibmid_token
    scopes = split_scopes(token)

    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      scopes: scopes,
      refresh_token: token.refresh_token,
      token: token.access_token,
      token_type: token.token_type
    }
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.ibmid_user

    %Info{
      name: "#{user["given_name"]} #{user["family_name"]}",
      first_name: user["given_name"],
      last_name: user["family_name"],
      email: user["email"]
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from the IBMId callback.
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.ibmid_token,
        user: conn.private.ibmid_user
      }
    }
  end

  @doc """
  Fetches the uid field from the response.
  """
  def uid(conn) do
    conn |> option(:uid_field) |> to_string() |> fetch_uid(conn)
  end

  defp fetch_uid(field, conn) do
    conn.private.ibmid_user[field]
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end
end
