import Config

config :exfate_web, ExfateWeb.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: "exfate.juniet.net", port: 443],
  check_origin: ["https://exfate.juniet.net", "https://exfate.gigalixirapp.com"],
  force_ssl: [hsts: true, rewrite_on: [:x_forwarded_proto]]
