import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :live_blog_ex, LiveBlogExWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/Q8s8CjJYnWhLMJ+xeenp91t51BIaFcL8rzSF6qs0Cp5r9D196SetZpsdOeGCAmM",
  server: false

# In test we don't send emails.
config :live_blog_ex, LiveBlogEx.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
