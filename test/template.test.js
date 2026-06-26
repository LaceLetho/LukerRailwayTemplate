const assert = require('node:assert/strict');
const fs = require('node:fs');

const dockerfile = fs.readFileSync('Dockerfile', 'utf8');
const entrypoint = fs.readFileSync('railway-entrypoint.sh', 'utf8');
const railwayToml = fs.readFileSync('railway.toml', 'utf8');
const readme = fs.readFileSync('README.md', 'utf8');

assert.match(dockerfile, /FROM node:lts-alpine3\.23/);
assert.match(dockerfile, /ARG LUKER_REPO=https:\/\/github\.com\/LaceLetho\/Luker\.git/);
assert.match(dockerfile, /ARG LUKER_REF=/);
assert.match(dockerfile, /git clone --depth 1 --branch "\$\{LUKER_REF\}" "\$\{LUKER_REPO\}"/);
assert.match(dockerfile, /node \.\/docker\/build-lib\.js/);
assert.match(dockerfile, /ENTRYPOINT \["tini", "--", "\.\/railway-entrypoint\.sh"\]/);

assert.match(entrypoint, /LUKER_PASSWORD is required/);
assert.match(entrypoint, /SILLYTAVERN_BASICAUTHMODE="true"/);
assert.match(entrypoint, /SILLYTAVERN_WHITELISTMODE="false"/);
assert.match(entrypoint, /--port="\$PORT_VALUE"/);
assert.match(entrypoint, /persist_dir "\$APP_HOME\/config" "\$PERSIST_DIR\/config"/);
assert.match(entrypoint, /persist_dir "\$APP_HOME\/public\/scripts\/extensions\/third-party" "\$PERSIST_DIR\/extensions"/);

assert.match(railwayToml, /builder = "dockerfile"/);
assert.match(railwayToml, /requiredMountPath = "\/data"/);

assert.match(readme, /LUKER_PASSWORD/);
assert.match(readme, /LUKER_REF/);
assert.match(readme, /Mount a persistent volume at `\/data`/);

console.log('Template checks passed.');
