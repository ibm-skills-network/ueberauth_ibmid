# Überauth IBMId

> IBMId OAuth2 strategy for Überauth.

## Installation

1. Setup your application with IBM Security Verify to get a Client ID and Secret. Ensure that a callback URL is specified in the OpenID Connect configuration (i.e. `https://localhost:PORT/auth/ibmid/callback`). [Learn more about IBM Security Verify & OpenID Connect](https://www.ibm.com/docs/en/security-verify?topic=sign-configuring-single-in-openid-connect-provider).

NOTE: IBMId only allows HTTPS callback URLs. [Learn how to serve a Phoenix App locally with HTTPS](https://til.hashrocket.com/posts/b8p5oalouz--serve-phoenix-app-locally-with-https-).

1. Add `:ueberauth_ibmid` to your list of dependencies in `mix.exs`:

   ```elixir
   def deps do
    [
      ...

      {:ueberauth_ibmid, "~> 0.1.0"}

      ...
    ]
   end
   ```

1. Add IBMId to your Überauth configuration:

   ```elixir
   config :ueberauth, Ueberauth,
     providers: [
       ibmid: {Ueberauth.Strategy.IBMId, []}
     ]
   ```

1. Update your provider configuration:

   ```elixir
   config :ueberauth, Ueberauth.Strategy.IBMId.OAuth,
     client_id: System.get_env("IBMID_OIDC_CLIENT_ID"),
     client_secret: System.get_env("IBMID_OIDC_CLIENT_SECRET")
   ```

   Or, to read the client credentials at runtime

   ```elixir
   config :ueberauth, Ueberauth.Strategy.IBMId.OAuth,
     client_id: {:system, "IBMID_OIDC_CLIENT_ID"},
     client_secret: {:system, "IBMID_OIDC_CLIENT_SECRET"}
   ```

1. Include the Überauth plug in your controller:

   ```elixir
   defmodule MyApp.Router do
     use MyApp.Web, :router


     pipeline :browser do
       plug Ueberauth
       ...
     end
   end
   ```

1. Create the request and callback routes if you haven't already:

   ```elixir
   scope "/auth", MyApp do
     pipe_through :browser

     get "/:provider", AuthController, :request
     get "/:provider/callback", AuthController, :callback
   end
   ```

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

## Calling

You can initialize the request through:

/auth/ibmid

By default the requested scope is "openid", which also happens to be the only required scope. Scope can be configured explicitly in your configuration (see below). [Learn more about OIDC scopes](https://auth0.com/docs/scopes/openid-connect-scopes).

```elixir
config :ueberauth, Ueberauth,
  providers: [
    ibmid: {Ueberauth.Strategy.IBMId, [default_scope: "openid profile"]}
  ]
```

## License

Please see [LICENSE](https://github.com/schwarz/ueberauth_ibmid/blob/master/LICENSE) for licensing details.
