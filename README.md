`oof` is a self-hosted [Sentry](https://sentry.io) copycat.

Demo: https://eren.fly.dev

Key features:

- supports (almost) all Sentry clients
- simple deployment (single container, SQLite, DuckDB, [Litestream](https://litestream.io))
- (optional) ChatGPT-style error explainer
- (optional) Telegram integration
- Email notifications
- Performant (TODO: benchmarks), memory efficient (can be hosted on free-tier [Fly.io](https://fly.io))
