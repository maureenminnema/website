# Maureen Minnema – website

Personal academic website, modelled on the structure of [emma-peters.com](https://www.emma-peters.com/):
a home page with a large statement, and one page per section (Research, Media, Events, Publications, About).

- **Content** is plain Markdown in `content/`. Add a file and it appears on the site.
- **Build:** [Hugo](https://gohugo.io/) turns it into static HTML. No JavaScript, no database.
- **Hosting:** a small Caddy container (`Dockerfile`, `compose.yml`), or GitHub Pages (`.github/workflows/pages.yml`).

Live preview: <https://maureen.cowolff-shenanigans.com> (not indexed by search engines while `noindex = true` in `hugo.toml`).

## Editing content

```
content/
├── _index.md            home page: headline, intro, focus areas, portrait, footer links
├── research/            display: cards      full entries, ordered by "weight"
├── media/               display: list       newest first, grouped by year
├── events/              display: list
├── publications/        display: citations  grouped by "status" (hidden until the first entry, see below)
└── about/_index.md      display: profile    bio, facts, contact links, CV
```

Each folder's `_index.md` holds the page title, the intro text, and the menu position (`weight`).
Every other `.md` file in the folder is one entry on that page.

### Add an entry

Copy an existing file in the same folder and change it, e.g. `content/media/2026-11-podcast.md`:

```markdown
---
title: "Why we dream"
date: 2026-11-04
subtitle: Podcast name · Episode 12          # small line under the title (outlet, venue, role)
link: https://example.org/episode-12          # optional: title and "Read more" point here
linkLabel: Listen to the episode              # optional: text of that link
image: images/podcast.jpg                     # optional: see "Images"
imageAlt: Recording the episode
---

One or two sentences about it. **Markdown** works here, including [links](https://example.org).
```

Research entries take the same fields and are ordered by `weight: 10`, `20`, … (lower comes first).
The newest three entries from Media, Events and Publications also appear under "Latest" on the home page.

### Publications

The section is hidden while `content/publications/_index.md` contains `draft: true`. To start it, delete that
line and turn `publications/example.md` into the first entry (delete its `draft: true` as well). The citation
is the body of the file; `status` picks the heading (Published, Preprints, Submitted, In preparation),
and `doi:` adds the DOI link.

### Images

- Portrait: put a photo in `assets/images/` (e.g. `portrait.jpg`) and set `portrait: images/portrait.jpg` in
  `content/_index.md`. It is used on the home page and the About page; until then a network illustration fills that space.
- For an entry, either put the image in `assets/images/` and write `image: images/name.jpg`, or make the entry a
  folder (`content/events/2026-11-talk/index.md` with `photo.jpg` next to it) and write `image: photo.jpg`.
- Images inside the text: `![Description](photo.jpg)` works the same way.

Large photos straight from a phone are fine: they are resized and converted to WebP at build time.
Images must live in the repository; the site does not load pictures from other websites.
If a file name is misspelt, the build stops with `image "…" not found`, and the live site keeps the previous version.

### Links, email, CV

The links in the footer (and under "Reach me" on About) are the `links:` list in `content/_index.md`.
The email, ORCID and Google Scholar lines are there, commented out. For a CV, put the PDF in `static/files/`
and set `cv: files/cv.pdf` in `content/about/_index.md`.

### A new section

Create a folder with an `_index.md`, e.g. `content/teaching/_index.md`:

```markdown
---
title: Teaching
weight: 35            # position in the menu
display: list         # cards | list | citations
groupByYear: true
---
Intro text.
```

It appears in the menu automatically. Markdown cannot contain raw HTML (it is dropped), so embeds such as
YouTube players are not possible; link to them instead.

## Preview while editing

```sh
docker compose --profile dev up maureen-dev     # http://localhost:1313, reloads on every save, shows drafts
docker compose up -d --build                    # the production container at http://localhost:8080
```

## Publishing

**cowolff-shenanigans.com (current).** The stack lives in `~/docker/maureen/` on the server; after changing
content run there:

```sh
cd ~/docker/maureen && docker compose up -d --build
```

**GitHub Pages.** Push the repository to GitHub, then:

1. Settings → Pages → Build and deployment → Source: **GitHub Actions**
2. Settings → Secrets and variables → Actions → Variables: add `PAGES_ENABLED` = `true`

Every push to `main` then publishes to `https://<owner>.github.io/<repo>/` (the workflow builds the same
Dockerfile stage, so both sites are identical). A custom domain can be set under Settings → Pages.
Before using the site as Maureen's real home page, set `noindex = false` in `hugo.toml`.

**Anywhere else with Docker.** The image serves plain HTTP on port 80. For HTTPS with an automatic
certificate, run it with `SITE_ADDRESS=maureen.example.org` and publish ports 80 and 443. Build with
`--build-arg BASE_URL=https://maureen.example.org/`.

## Layout of the code

| Path | Purpose |
|---|---|
| `hugo.toml` | Technical settings: base URL, `noindex`, image quality |
| `layouts/` | HTML templates. `section.html` serves every section; `_partials/entries/` holds the three list styles |
| `assets/css/main.css` | All styling. Colours are variables at the top, with a dark-mode set below them |
| `static/fonts/` | Barlow, self-hosted (SIL Open Font License, `OFL.txt`) |
| `archetypes/` | Templates for `hugo new content media/name.md` |
| `Dockerfile`, `Caddyfile` | Build with Hugo, serve with Caddy (security headers, caching, 404 page) |
