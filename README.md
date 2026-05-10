# clonecode-marketing

Landing page for [clonecode](https://github.com/seansackowitz/clonecode), served at <https://clonecode.io>.

## Stack
- Astro 5 (static output)
- Tailwind CSS 4 (via `@tailwindcss/vite`)
- Hosted on GitHub Pages, deployed via `.github/workflows/deploy.yml` on every push to `main`

## Develop

```bash
bun install
bun run dev        # http://localhost:4321
```

## Build

```bash
bun run build
bun run preview    # preview the built dist/
```

## Deploy

Pushes to `main` trigger the Pages workflow:

1. `bun install --frozen-lockfile`
2. `bun run build` → `dist/`
3. `actions/upload-pages-artifact` + `actions/deploy-pages`

The custom domain is configured both ways:
- `public/CNAME` (`clonecode.io`) gets copied into `dist/` and tells Pages the domain on each deploy
- The repo's Pages settings have `clonecode.io` set as the custom domain (one-time `gh api -X PUT` on initial setup)

`public/.nojekyll` keeps Pages from running Jekyll on the Astro output.
