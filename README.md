# Luker Railway Template

[中文](./README.zh-CN.md)

Deploy Luker on Railway with a single Docker-based service. This template builds Luker from `https://github.com/LaceLetho/Luker.git` and adds Railway-specific defaults for public access, persistent storage, and Basic Auth.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/templates)

Replace the button URL with your published Railway template URL after publishing this repository as a template.

## What This Template Does

1. Clones and builds Luker from `LaceLetho/Luker`.
2. Listens on Railway's injected `PORT`.
3. Requires HTTP Basic Auth before exposing Luker publicly.
4. Uses one persistent Railway volume mounted at `/data`.
5. Maps Luker's mutable directories into `/data`: `config`, `data`, `plugins`, `extensions`, and `backups`.

## Required Railway Setup

1. Create a Railway service from this repository.
2. Mount a persistent volume at `/data`.
3. Set `LUKER_PASSWORD` in service variables.
4. Generate a public domain for the service.

## Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `LUKER_PASSWORD` | Yes | - | Password for HTTP Basic Auth. |
| `LUKER_USERNAME` | No | `luker` | Username for HTTP Basic Auth. |
| `LUKER_PERSIST_DIR` | No | `/data` | Persistent root directory. |
| `LUKER_REF` | No | repository default branch | Branch or tag to clone and build. This is read during Docker build, so redeploy after changing it. |

Luker also supports `SILLYTAVERN_*` environment overrides from its own config system. This template sets safe deployment defaults at startup.

## Persistent Files

The `/data` volume contains:

| Path | Purpose |
| --- | --- |
| `/data/config` | `config.yaml` and runtime config. |
| `/data/data` | User data, chats, assets, cache, and secrets. |
| `/data/plugins` | Server plugins. |
| `/data/extensions` | Third-party web extensions. |
| `/data/backups` | Generated backups. |

## Local Smoke Test

```bash
npm test
```

## Local Docker Run

```bash
docker build -t luker-railway-template .
docker run --rm -p 8000:8000 \
  -e PORT=8000 \
  -e LUKER_PASSWORD=change-me \
  -v luker-data:/data \
  luker-railway-template
```

Then open `http://localhost:8000` and log in with username `luker` and the password you set.

To build a specific branch or tag locally, pass `LUKER_REF` as a build arg:

```bash
docker build --build-arg LUKER_REF=release -t luker-railway-template .
```
