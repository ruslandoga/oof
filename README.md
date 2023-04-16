`eren` is a drop-in self-hosted [Sentry](https://sentry.io) clone.

Demo: https://eren.fly.dev

Key features:

- supports (almost) all Sentry clients
- simple deployment (single container, SQLite, DuckDB, [Litestream](https://litestream.io))
- (optional) ChatGPT-style error explainer
- (optional) Telegram integration
- Email notifications
- Performant (TODO: benchmarks), memory efficient (can be hosted on free-tier [Fly.io](https://fly.io))
