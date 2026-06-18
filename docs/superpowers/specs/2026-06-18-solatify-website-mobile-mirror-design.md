# Solatify Website Mobile Mirror Design

Date: 2026-06-18
Branch: `feature/next-solatify-improvements`

## Goal

Refresh `solatify-website` so the website UI/UX feels like the Solatify mobile app: calm, premium, Islamic, glass-card based, and focused on prayer time, adhan notification, Qur'an, and daily worship.

## Approved Direction

Use **Premium Mobile Mirror**.

The website should feel like a larger landing-page version of the mobile app rather than a generic SaaS page.

## Copy Language

Keep the existing website direction in **English**.

This phase focuses on visual parity with the mobile app and avoids a broader content/positioning rewrite.

## Visual System

Use website CSS tokens that mirror the mobile app:

- Deep emerald/dark green surfaces for the premium app feel.
- Warm red accent for primary action, notification, and prayer highlight states.
- Cream/light background for light mode.
- Large border radius, soft shadows, and low-noise glass cards.
- Subtle Islamic geometric background/ornaments.
- Smooth, seamless transitions for hover and theme changes.

## Page Structure

Keep the existing landing page architecture, but restyle and rebalance it:

1. Sticky glass navigation
2. Hero section with app badge, large headline, store buttons, stats, and phone preview
3. Feature section for daily Islamic routine
4. Prayer notification/adhan section
5. Why Solatify section
6. Download CTA
7. FAQ section

## Hero Requirements

The hero should be the strongest mobile-app mirror:

- Phone preview should show a Solatify-like home screen.
- Include a prayer notification preview.
- Emphasize next prayer, location, Qur'an/last-read, Qibla, and prayer schedule snippets.
- Use the logo assets already present in `public/brand`.
- Keep store buttons prominent but not visually heavier than the phone preview.

## Component Requirements

- Cards should feel similar to `GlassContainer` from the Flutter app.
- Feature cards should use consistent icon, radius, spacing, and accent treatment.
- Notification section should feel trustworthy and practical, not overly technical.
- CTA section should feel like a calm app install moment.
- FAQ should remain readable and compact.

## Responsive Requirements

- Desktop: two-column hero with large phone preview.
- Tablet: balanced grid without horizontal overflow.
- Mobile: single-column flow, centered actions, compact sticky header, no cramped cards.
- Preserve accessibility: semantic sections, clear focus states, readable contrast.

## Out of Scope

- No backend changes.
- No store-link changes unless existing content already supports them.
- No new routes.
- No i18n implementation.
- No mobile app code changes.

## Success Criteria

- Website visually matches Solatify mobile identity more closely.
- Existing landing content remains available and readable.
- `npm run build` succeeds for `solatify-website`.
- Lint/build issues introduced by the redesign are fixed before handoff.
