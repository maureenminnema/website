# Maureen Minnema's website: Hugo turns content/ (Markdown) into static pages, Caddy serves them.
#
# Stages:
#   build   runs Hugo
#   site    only the generated files; the GitHub Pages workflow exports it with
#             docker buildx build --target site --build-arg BASE_URL=... --output type=local,dest=public .
#   (last)  the Caddy image that serves the files (no state, no secrets)

FROM ghcr.io/gohugoio/hugo:v0.167.0 AS build
# Where the site will be reachable. Canonical links and the sitemap use it, and under a path
# (user.github.io/repo/) every internal link gets that prefix.
ARG BASE_URL=https://maureen.cowolff-shenanigans.com/
WORKDIR /project
COPY --chown=hugo:hugo . .
# --panicOnWarning: a template or content problem fails the build instead of shipping a broken page.
RUN hugo --gc --minify --panicOnWarning --baseURL "$BASE_URL" --destination /tmp/public --cacheDir /tmp/hugo-cache

FROM scratch AS site
COPY --from=build /tmp/public /

FROM caddy:2.11.7-alpine
COPY Caddyfile /etc/caddy/Caddyfile
RUN caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
COPY --from=build /tmp/public /srv
# Compressed copies next to the originals, served by file_server's "precompressed" option.
RUN find /srv -type f \( -name '*.html' -o -name '*.css' -o -name '*.svg' -o -name '*.xml' -o -name '*.txt' \) -exec gzip -k -9 {} +
