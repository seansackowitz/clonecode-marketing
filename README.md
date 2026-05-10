# clonecode-marketing

Landing page for [clonecode](https://github.com/seansackowitz/clonecode).

## Stack
- Astro 5 (static output)
- Tailwind CSS 4 (via `@tailwindcss/vite`)
- Deployed to Railway, served by `serve`

## Develop

```bash
bun install        # or npm install / pnpm install
bun run dev        # http://localhost:4321
```

## Build

```bash
bun run build
bun run preview    # preview the built dist/
```

## Deploy (Railway)

The `start` script serves `dist/` on `$PORT`. Railway will:

1. Run `npm install` (or your detected package manager)
2. Run `npm run build` (Astro builds to `dist/`)
3. Run `npm start` (serves `dist/` on Railway's `$PORT`)

If Railway's auto-detection picks the wrong build, set custom commands in the service settings:
- Build: `npm run build`
- Start: `npm start`
