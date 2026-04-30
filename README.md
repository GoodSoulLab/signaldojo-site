# Signal Dojo Site

One repository with two DreamHost deploy targets:
- Production deploys from repository root
- Staging deploys from `staging/`

## Files added for deploys
- `deploy.sh`: deploy command for staging/production
- `deploy.config.example`: template for DreamHost SSH and remote paths
- `staging/robots.txt`: blocks staging from indexing

## Setup
1. Copy the config template:
   cp deploy.config.example deploy.config
2. Edit `deploy.config` with your DreamHost values.
3. Make the script executable:
   chmod +x deploy.sh

## Dry-run first
- Staging:
  ./deploy.sh staging --dry-run
- Production:
  ./deploy.sh production --dry-run

## Deploy
- Staging:
  ./deploy.sh staging
- Production:
  ./deploy.sh production

## Notes
- Production excludes: `.git/`, `staging/`, `archive/`, `design/`, and local deploy config/script files.
- Keep DreamHost web root paths ending with `/`.
