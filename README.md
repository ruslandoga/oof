`oof` is a self-hosted [Sentry](https://sentry.io) copycat.

TOBE:
- status page
- metrics sink / collector
- logs sink / collector
- dashboards?
- load testing tool?

Demo: https://oof.fly.dev

Key features:

- supports (almost) all Sentry clients
- simple deployment (single container, uses SQLite and embedded ClickHouse, optionally replicates to S3-compatible object storage)
- (optional) ChatGPT-style error explainer
- (optional) Telegram integration
- email notifications
- performant (TODO: benchmarks) and memory efficient (can be hosted on free-tier [Fly.io](https://fly.io))

Oof dreams of understanding applications and why they hurt.
