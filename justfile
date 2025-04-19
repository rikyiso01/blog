set dotenv-load

preview number:
    bash scripts/live.sh {{number}}

publish: (devto "push")

devto *args:
    pnpm exec dev {{args}}

