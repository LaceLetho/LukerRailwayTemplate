FROM node:lts-alpine3.23

ARG APP_HOME=/home/node/app
ARG LUKER_REPO=https://github.com/LaceLetho/Luker.git
ARG LUKER_REF=

ENV NODE_ENV=production
ENV USELESS_PLACETAKER=aabbcc

RUN apk add --no-cache gcompat tini git git-lfs su-exec shadow dos2unix

WORKDIR ${APP_HOME}

# Upstream Luker (since commit ecf4ae8, the current tip of main and release) evaluates
# getVersion() while webpack.config.js is loaded, which reads the 'disableUpdateCheck'
# config key. During the image build no config file path is set yet, so getConfig()
# aborts with "No config file path set" and the build fails. Setting the documented
# env override makes getConfigValue() return early, so the frontend libs can be compiled.
# The prefix applies to this single command only; update checks stay enabled at runtime.
RUN set -eux; \
  if [ -n "${LUKER_REF}" ]; then \
    git clone --depth 1 --branch "${LUKER_REF}" "${LUKER_REPO}" .; \
  else \
    git clone --depth 1 "${LUKER_REPO}" .; \
  fi; \
  npm ci --no-audit --no-fund --loglevel=error --no-progress --omit=dev --ignore-scripts; \
  npm cache clean --force; \
  rm -f config.yaml; \
  mkdir -p config data plugins public/scripts/extensions/third-party backups; \
  ln -s ./config/config.yaml config.yaml; \
  LUKER_DISABLEUPDATECHECK=true node ./docker/build-lib.js; \
  mv ./docker/docker-entrypoint.sh ./docker-entrypoint.sh; \
  chmod +x ./docker-entrypoint.sh; \
  dos2unix ./docker-entrypoint.sh; \
  rm -rf ./docker; \
  git config --global --add safe.directory "*"; \
  chown -R node:node ${APP_HOME}

USER root
WORKDIR ${APP_HOME}

COPY railway-entrypoint.sh ./railway-entrypoint.sh
RUN chmod +x ./railway-entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["tini", "--", "./railway-entrypoint.sh"]
