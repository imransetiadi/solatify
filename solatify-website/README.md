# Solatify Website

Promotional landing page for Solatify, built with Next.js App Router.

## Highlights

- Islamic-inspired landing page with responsive light and dark mode.
- App Store and Google Play call-to-action buttons.
- Feature sections for prayer times, prayer-time notifications, optional adhan playback, Qur’an, Qibla, dhikr, duas, Hijri calendar, and worship tracking.
- FAQ section for install and notification behavior.
- SEO-ready metadata, favicon/app icons, web manifest, sitemap, and robots route.

## Development

```bash
npm install
npm run dev
```

Open `http://localhost:3000`.

## Build

```bash
npm run build
npm start
```

## Deploy

This project is ready for common Next.js hosts such as Vercel, Cloudflare Pages, or any Node-capable host.

### Vercel

1. Import the `solatify-website` folder as the project root.
2. Use the default Next.js build command: `npm run build`.
3. Set the production domain to the real Solatify website domain.

### Cloudflare Pages

1. Set project root to `solatify-website`.
2. Build command: `npm run build`.
3. Output directory for standard Next.js deployment depends on the Cloudflare Next.js adapter you choose.

## Notes

- App Store and Play Store buttons currently use placeholder URLs in `src/lib/content.ts`.
- SEO routes currently use `https://solatify.app`; update `metadataBase`, `robots.ts`, and `sitemap.ts` if the final domain is different.
- Replace or extend `public/brand` assets when final marketing logo/screenshots are available.
