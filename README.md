# Überauth IBMId

> IBMId OAuth2 strategy for Überauth.

## Installation

1. Setup your application with [AppID](https://cloud.ibm.com/docs/appid).

1. Add `:ueberauth_ibmid` to your list of dependencies in `mix.exs`:

   ```elixir
   def deps do
     [{:ueberauth_ibmid, "~> 0.1"}]
   end
   ```

1. (Maybe) Add the strategy to your applications:

   ```elixir
   def application do
     [applications: [:ueberauth_ibmid]]
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

   And make sure to set the correct redirect URI(s) in your AppID application to wire up the callback.

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initialize the request through:

/auth/ibmid

Or with options:

/auth/ibmid?scope=identify%20email&prompt=none&permissions=452987952

By default the requested scope is "identify". Scope can be configured either explicitly as a `scope` query value on the request path or in your configuration:

```elixir
config :ueberauth, Ueberauth,
  providers: [
    ibmid: {Ueberauth.Strategy.IBMId, [default_scope: "identify email connections guilds"]}
  ]
```

## License

Please see [LICENSE](https://github.com/schwarz/ueberauth_ibmid/blob/master/LICENSE) for licensing details.
