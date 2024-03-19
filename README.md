`oof` is a self-hosted [Sentry](https://sentry.io) copycat.

Demo: https://oof.fly.dev

Key features:

- supports (almost) all Sentry clients
- simple deployment (single container, uses SQLite, optionally replicates to S3)
- (optional) ChatGPT-style error explainer
- (optional) Telegram integration
- email notifications
- performant (TODO: benchmarks) and memory efficient (can be hosted on free-tier [Fly.io](https://fly.io))
