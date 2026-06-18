# Solatify Website Mobile Mirror Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refresh `solatify-website` so its landing page visually mirrors the Solatify mobile app while keeping the current English content and Next.js structure.

**Architecture:** This is a focused presentation-layer redesign of the existing single-page Next.js app. Keep content in `src/lib/content.ts`, page structure in `src/app/page.tsx`, and the visual system/responsive behavior in `src/app/globals.css`.

**Tech Stack:** Next.js 14, React 18, TypeScript, CSS custom properties, existing public brand images.

---

## File Structure

- Modify: `solatify-website/src/app/page.tsx`
  - Keep the existing sections and data imports.
  - Improve semantic structure and add mobile-app mirror elements for the hero phone preview.
  - Add small presentational wrappers/classes where CSS needs stronger visual hierarchy.
- Modify: `solatify-website/src/app/globals.css`
  - Replace the current generic warm landing styling with mobile-app-aligned tokens.
  - Add glass-card utilities, emerald/red themes, phone mockup polish, responsive layouts, and seamless transitions.
- Optional modify: `solatify-website/src/lib/content.ts`
  - Only adjust existing English labels if the current wording conflicts with the mobile-app visual direction.
  - Do not add new content systems, routes, or store-link logic.
- Verify: `solatify-website/package.json`
  - Use existing scripts: `npm run build` and `npm run lint` if available.

---

### Task 1: Baseline Website Build and Visual Inventory

**Files:**
- Read: `solatify-website/src/app/page.tsx`
- Read: `solatify-website/src/app/globals.css`
- Read: `solatify-website/src/lib/content.ts`
- Verify: `solatify-website/package.json`

- [ ] **Step 1: Confirm website scripts**

Run:

```bash
cd solatify-website
cat package.json
```

Expected: scripts include `build` and `lint`.

- [ ] **Step 2: Run current build baseline**

Run:

```bash
cd solatify-website
npm run build
```

Expected: build succeeds before edits, or any pre-existing failure is captured before changing UI.

- [ ] **Step 3: Capture current file responsibilities**

Read these files:

```bash
cd solatify-website
sed -n '1,260p' src/app/page.tsx
sed -n '1,360p' src/app/globals.css
sed -n '1,220p' src/lib/content.ts
```

Expected: confirm the landing page is a single `Home` page using `features`, `advantages`, `faqs`, and `storeLinks`.

- [ ] **Step 4: Commit baseline note only if needed**

If the baseline build fails before edits, do not modify UI yet. Report the failure and stop for debugging.

---

### Task 2: Update Page Markup for Mobile-App Mirror Hero

**Files:**
- Modify: `solatify-website/src/app/page.tsx`

- [ ] **Step 1: Refactor hero preview markup**

In `solatify-website/src/app/page.tsx`, keep imports unchanged and update the hero preview area so the phone mockup contains a clearer Solatify home preview. Replace the current `<div className="phone-card" ...>` block with this structure:

```tsx
        <div className="phone-card" aria-label="Solatify app preview">
          <div className="phone-orbit" aria-hidden="true" />
          <div className="phone-shell">
            <div className="phone-top" />
            <div className="phone-status">
              <span>09:41</span>
              <span>● ● ●</span>
            </div>
            <div className="notification-preview">
              <Image src="/brand/solatify-logo.png" alt="" width={28} height={28} />
              <div>
                <strong>Maghrib prayer time</strong>
                <span>Adhan is ready to play • 18:08</span>
              </div>
            </div>
            <div className="app-preview-card active">
              <span>Next prayer</span>
              <strong>Maghrib</strong>
              <p>18:08 • Jakarta</p>
              <div className="countdown-pill">00:42:12 remaining</div>
            </div>
            <div className="app-preview-grid">
              <div>
                <span>Qibla</span>
                <strong>295°</strong>
              </div>
              <div>
                <span>Qur’an</span>
                <strong>Al-Fatihah</strong>
              </div>
            </div>
            <div className="quick-actions-preview">
              <span>Dhikr</span>
              <span>Daily Dua</span>
              <span>Hijri</span>
            </div>
            <div className="mini-list">
              <div><span>Fajr</span><strong>04:32</strong></div>
              <div><span>Dhuhr</span><strong>11:58</strong></div>
              <div><span>Asr</span><strong>15:20</strong></div>
              <div><span>Isha</span><strong>19:23</strong></div>
            </div>
          </div>
        </div>
```

- [ ] **Step 2: Add mobile-app mirror classes to section cards**

In `src/app/page.tsx`, keep the section order unchanged, but add these class names where applicable:

```tsx
<section className="section feature-showcase" id="features">
```

```tsx
<section className="notification-section glass-section" id="notifications">
```

```tsx
<section className="section cta-section app-download-panel" id="download">
```

Expected: existing content remains rendered, but CSS gets stronger hooks for app-like styling.

- [ ] **Step 3: Run TypeScript/Next build check for JSX syntax**

Run:

```bash
cd solatify-website
npm run build
```

Expected: build succeeds or fails only on CSS/Next lint warnings unrelated to JSX syntax. Fix syntax immediately if TypeScript reports an invalid JSX structure.

- [ ] **Step 4: Commit page markup**

Run:

```bash
git add solatify-website/src/app/page.tsx
git commit -m "Refine website mobile app preview markup"
```

---

### Task 3: Rebuild Visual Tokens and Global Atmosphere

**Files:**
- Modify: `solatify-website/src/app/globals.css`

- [ ] **Step 1: Replace root theme tokens**

Update the top `:root` and `:root[data-theme="dark"]` blocks in `src/app/globals.css` to use mobile-aligned tokens:

```css
:root {
  color-scheme: light;
  --bg: #fff8ef;
  --bg-soft: #f3e7d5;
  --bg-deep: #0c281d;
  --surface: rgba(255, 255, 255, 0.76);
  --surface-strong: #ffffff;
  --surface-deep: #123724;
  --text: #1e2119;
  --muted: #6d7568;
  --line: rgba(55, 87, 67, 0.14);
  --accent: #c0392b;
  --accent-strong: #a93226;
  --accent-soft: rgba(192, 57, 43, 0.1);
  --gold: #c59b57;
  --green: #1f7a59;
  --green-soft: rgba(31, 122, 89, 0.12);
  --shadow: 0 24px 70px rgba(20, 48, 33, 0.16);
  --shadow-strong: 0 34px 100px rgba(8, 31, 21, 0.28);
  --radius: 28px;
  --radius-lg: 36px;
}

:root[data-theme="dark"] {
  color-scheme: dark;
  --bg: #071a14;
  --bg-soft: #0e2a20;
  --bg-deep: #061711;
  --surface: rgba(18, 55, 36, 0.74);
  --surface-strong: #123724;
  --surface-deep: #0d2a1f;
  --text: #fff8ef;
  --muted: #b9c8bb;
  --line: rgba(232, 93, 79, 0.16);
  --accent: #e85d4f;
  --accent-strong: #ff8a78;
  --accent-soft: rgba(232, 93, 79, 0.14);
  --gold: #e0b86f;
  --green: #68c7a6;
  --green-soft: rgba(104, 199, 166, 0.14);
  --shadow: 0 28px 90px rgba(0, 0, 0, 0.42);
  --shadow-strong: 0 38px 120px rgba(0, 0, 0, 0.54);
}
```

- [ ] **Step 2: Update body background and transitions**

Replace the current `body` and `body::before` background rules with a calmer Islamic app background:

```css
body {
  margin: 0;
  min-height: 100vh;
  background:
    radial-gradient(circle at 12% 8%, color-mix(in srgb, var(--accent) 18%, transparent), transparent 32rem),
    radial-gradient(circle at 88% 12%, color-mix(in srgb, var(--green) 20%, transparent), transparent 30rem),
    linear-gradient(135deg, var(--bg), var(--bg-soft));
  color: var(--text);
  font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  transition: background 240ms ease, color 240ms ease;
}

body::before {
  content: "";
  position: fixed;
  inset: 0;
  pointer-events: none;
  opacity: 0.16;
  background-image:
    linear-gradient(30deg, transparent 48%, var(--line) 49%, transparent 51%),
    linear-gradient(150deg, transparent 48%, var(--line) 49%, transparent 51%);
  background-size: 78px 78px;
  mask-image: linear-gradient(to bottom, black, transparent 76%);
}
```

- [ ] **Step 3: Add shared interaction transitions**

Add or update these rules near base element styles:

```css
button,
a,
.feature-card,
.faq,
.ornament-card,
.phone-shell,
.store-button {
  transition: transform 180ms ease, border-color 180ms ease, background 180ms ease, box-shadow 180ms ease, color 180ms ease;
}

:focus-visible {
  outline: 3px solid color-mix(in srgb, var(--accent) 70%, white);
  outline-offset: 4px;
}
```

- [ ] **Step 4: Verify CSS parsing**

Run:

```bash
cd solatify-website
npm run build
```

Expected: build succeeds. If CSS parsing fails, fix the exact selector or syntax reported by Next.

- [ ] **Step 5: Commit token update**

Run:

```bash
git add solatify-website/src/app/globals.css
git commit -m "Align website visual tokens with mobile app"
```

---

### Task 4: Polish Hero, Header, Store Buttons, and Phone Mockup

**Files:**
- Modify: `solatify-website/src/app/globals.css`

- [ ] **Step 1: Update sticky header and navigation**

Adjust `.site-header`, `.brand-mark`, `.theme-toggle`, and `.nav-links` to feel like mobile glass UI:

```css
.site-header {
  position: sticky;
  top: 16px;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  margin: 16px 0 34px;
  padding: 12px 14px;
  border: 1px solid var(--line);
  border-radius: 999px;
  background: color-mix(in srgb, var(--surface) 88%, transparent);
  box-shadow: var(--shadow);
  backdrop-filter: blur(20px);
}

.brand-mark {
  display: grid;
  width: 40px;
  height: 40px;
  place-items: center;
  border-radius: 16px;
  color: white;
  background: linear-gradient(135deg, var(--accent), var(--gold));
  box-shadow: 0 14px 30px color-mix(in srgb, var(--accent) 28%, transparent);
}

.theme-toggle {
  gap: 8px;
  border: 1px solid var(--line);
  border-radius: 999px;
  padding: 10px 14px;
  color: var(--text);
  background: color-mix(in srgb, var(--surface-strong) 88%, transparent);
  cursor: pointer;
  font-weight: 800;
}

.nav-links a:hover,
.theme-toggle:hover {
  color: var(--accent);
  transform: translateY(-1px);
}
```

- [ ] **Step 2: Update hero layout and typography**

Refine `.hero`, `.hero-glow`, `.app-badge`, `h1`, and `.hero-copy`:

```css
.hero {
  position: relative;
  display: grid;
  grid-template-columns: minmax(0, 1.02fr) minmax(330px, 0.78fr);
  gap: 48px;
  align-items: center;
  min-height: 700px;
  padding: 18px 0 54px;
}

.hero-glow {
  position: absolute;
  inset: 6% 38% auto auto;
  width: 280px;
  height: 280px;
  border-radius: 999px;
  background: color-mix(in srgb, var(--accent) 24%, transparent);
  filter: blur(90px);
}

.app-badge {
  display: inline-flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 18px;
  padding: 8px 14px 8px 8px;
  border: 1px solid var(--line);
  border-radius: 999px;
  color: var(--muted);
  background: color-mix(in srgb, var(--surface) 86%, transparent);
  font-weight: 900;
  backdrop-filter: blur(14px);
}

h1 {
  max-width: 780px;
  margin-bottom: 22px;
  font-size: clamp(3.1rem, 7vw, 6.6rem);
  line-height: 0.92;
  letter-spacing: -0.075em;
}

.hero-copy {
  max-width: 700px;
  font-size: 1.13rem;
}
```

- [ ] **Step 3: Update store buttons**

Use app-like primary buttons with clear hover state:

```css
.store-button {
  gap: 12px;
  min-width: 184px;
  padding: 12px 16px;
  border: 1px solid color-mix(in srgb, var(--accent) 18%, var(--line));
  border-radius: 20px;
  background: linear-gradient(135deg, var(--surface-deep), color-mix(in srgb, var(--surface-deep) 82%, var(--accent)));
  color: #fff8ef;
  box-shadow: var(--shadow);
}

.store-button:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-strong);
}
```

- [ ] **Step 4: Replace phone mockup CSS**

Update the existing phone-related rules to support the new markup:

```css
.phone-card {
  position: relative;
  display: grid;
  place-items: center;
  min-height: 620px;
}

.phone-orbit {
  position: absolute;
  width: min(460px, 88vw);
  aspect-ratio: 1;
  border-radius: 999px;
  background:
    radial-gradient(circle, color-mix(in srgb, var(--green) 18%, transparent), transparent 62%),
    conic-gradient(from 120deg, transparent, color-mix(in srgb, var(--accent) 28%, transparent), transparent 46%);
  filter: blur(2px);
  opacity: 0.8;
}

.phone-shell {
  position: relative;
  width: min(356px, 100%);
  min-height: 610px;
  padding: 18px;
  border: 1px solid color-mix(in srgb, var(--accent) 18%, var(--line));
  border-radius: 46px;
  background:
    linear-gradient(180deg, color-mix(in srgb, var(--surface-deep) 94%, black), var(--bg-deep));
  box-shadow: var(--shadow-strong);
  overflow: hidden;
}

.phone-shell::before {
  content: "";
  position: absolute;
  inset: 0;
  background:
    radial-gradient(circle at 20% 8%, rgba(232, 93, 79, 0.22), transparent 34%),
    linear-gradient(135deg, transparent 54%, rgba(255, 255, 255, 0.04));
  pointer-events: none;
}

.phone-top {
  position: relative;
  width: 96px;
  height: 6px;
  margin: 0 auto 14px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.22);
}

.phone-status,
.notification-preview,
.app-preview-card,
.app-preview-grid,
.quick-actions-preview,
.mini-list {
  position: relative;
}

.phone-status {
  display: flex;
  justify-content: space-between;
  color: rgba(255, 248, 239, 0.74);
  font-size: 0.78rem;
  font-weight: 800;
  margin-bottom: 14px;
}

.notification-preview {
  display: flex;
  gap: 10px;
  align-items: center;
  margin-bottom: 14px;
  padding: 12px;
  border: 1px solid rgba(255, 255, 255, 0.11);
  border-radius: 20px;
  background: rgba(255, 255, 255, 0.1);
  color: #fff8ef;
  backdrop-filter: blur(12px);
}

.notification-preview span {
  display: block;
  margin-top: 2px;
  color: rgba(255, 248, 239, 0.68);
  font-size: 0.78rem;
}

.app-preview-card {
  padding: 20px;
  border-radius: 28px;
  color: #fff8ef;
  background: linear-gradient(135deg, var(--accent), color-mix(in srgb, var(--accent) 76%, var(--gold)));
  box-shadow: 0 24px 50px rgba(192, 57, 43, 0.28);
}

.app-preview-card span,
.app-preview-card p {
  color: rgba(255, 248, 239, 0.78);
}

.app-preview-card strong {
  display: block;
  margin: 4px 0;
  font-size: 2.2rem;
}

.countdown-pill {
  display: inline-flex;
  margin-top: 8px;
  padding: 7px 10px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.16);
  font-size: 0.78rem;
  font-weight: 900;
}

.app-preview-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
  margin-top: 12px;
}

.app-preview-grid div,
.quick-actions-preview,
.mini-list div {
  border: 1px solid rgba(255, 255, 255, 0.1);
  background: rgba(255, 255, 255, 0.08);
  color: #fff8ef;
  backdrop-filter: blur(10px);
}

.app-preview-grid div {
  padding: 14px;
  border-radius: 18px;
}

.app-preview-grid span,
.mini-list span {
  display: block;
  color: rgba(255, 248, 239, 0.62);
  font-size: 0.78rem;
}

.quick-actions-preview {
  display: flex;
  justify-content: space-between;
  gap: 8px;
  margin-top: 12px;
  padding: 10px;
  border-radius: 18px;
}

.quick-actions-preview span {
  flex: 1;
  border-radius: 999px;
  padding: 8px 6px;
  background: rgba(255, 255, 255, 0.08);
  color: rgba(255, 248, 239, 0.78);
  font-size: 0.75rem;
  font-weight: 900;
  text-align: center;
}

.mini-list {
  display: grid;
  gap: 8px;
  margin-top: 12px;
}

.mini-list div {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 12px;
  border-radius: 16px;
}
```

- [ ] **Step 5: Build after hero polish**

Run:

```bash
cd solatify-website
npm run build
```

Expected: build succeeds.

- [ ] **Step 6: Commit hero polish**

Run:

```bash
git add solatify-website/src/app/globals.css
git commit -m "Polish website hero to mirror mobile app"
```

---

### Task 5: Polish Sections, Cards, CTA, FAQ, and Responsive Layout

**Files:**
- Modify: `solatify-website/src/app/globals.css`

- [ ] **Step 1: Update generic section and glass card styling**

Add/update section card rules:

```css
.section {
  padding: 88px 0;
}

.section-heading {
  max-width: 760px;
  margin: 0 auto 34px;
  text-align: center;
}

.feature-grid,
.advantage-grid,
.faq-grid {
  display: grid;
  gap: 18px;
}

.feature-grid {
  grid-template-columns: repeat(4, minmax(0, 1fr));
}

.feature-card,
.faq,
.ornament-card {
  border: 1px solid var(--line);
  border-radius: var(--radius);
  background: color-mix(in srgb, var(--surface) 88%, transparent);
  box-shadow: var(--shadow);
  backdrop-filter: blur(14px);
}

.feature-card {
  padding: 24px;
}

.feature-card:hover,
.faq:hover,
.ornament-card:hover {
  transform: translateY(-3px);
  border-color: color-mix(in srgb, var(--accent) 32%, var(--line));
  box-shadow: var(--shadow-strong);
}

.feature-icon {
  display: grid;
  width: 48px;
  height: 48px;
  place-items: center;
  margin-bottom: 18px;
  border-radius: 18px;
  background: var(--accent-soft);
  color: var(--accent);
  font-size: 1.4rem;
}
```

- [ ] **Step 2: Update notification section styling**

Make the notification block match the app's trust/reliability tone:

```css
.notification-section {
  display: grid;
  grid-template-columns: minmax(0, 0.9fr) minmax(280px, 0.7fr);
  gap: 22px;
  align-items: stretch;
  padding: 34px;
  border: 1px solid var(--line);
  border-radius: var(--radius-lg);
  background:
    radial-gradient(circle at 8% 10%, color-mix(in srgb, var(--accent) 16%, transparent), transparent 30rem),
    color-mix(in srgb, var(--surface) 82%, transparent);
  box-shadow: var(--shadow);
  backdrop-filter: blur(18px);
}

.notification-copy,
.notification-points {
  box-shadow: none;
}

.notification-points {
  display: grid;
  gap: 12px;
}

.notification-points li,
.notification-list li {
  border: 1px solid var(--line);
  border-radius: 18px;
  background: color-mix(in srgb, var(--surface-strong) 72%, transparent);
}
```

- [ ] **Step 3: Update CTA and FAQ styling**

Keep download CTA calm and premium:

```css
.cta-section {
  margin: 52px 0;
  padding: 56px;
  border: 1px solid var(--line);
  border-radius: var(--radius-lg);
  background:
    linear-gradient(135deg, color-mix(in srgb, var(--surface-deep) 92%, var(--accent)), var(--bg-deep));
  color: #fff8ef;
  box-shadow: var(--shadow-strong);
  text-align: center;
}

.cta-section p,
.cta-section .eyebrow {
  color: rgba(255, 248, 239, 0.76);
}

.faq-grid {
  grid-template-columns: repeat(2, minmax(0, 1fr));
}

.faq {
  padding: 22px;
}
```

- [ ] **Step 4: Update responsive breakpoints**

Ensure desktop, tablet, and mobile are safe:

```css
@media (max-width: 980px) {
  main {
    width: min(100% - 24px, 760px);
  }

  .site-header {
    align-items: flex-start;
    border-radius: 28px;
    flex-wrap: wrap;
  }

  .nav-links {
    order: 3;
    width: 100%;
    justify-content: center;
    gap: 14px;
    flex-wrap: wrap;
  }

  .hero,
  .notification-section,
  .split-section {
    grid-template-columns: 1fr;
  }

  .hero {
    min-height: auto;
    text-align: center;
  }

  .hero-copy,
  .store-row,
  .hero-stats {
    justify-content: center;
    margin-left: auto;
    margin-right: auto;
  }

  .feature-grid,
  .faq-grid,
  .advantage-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }
}

@media (max-width: 640px) {
  main {
    width: min(100% - 18px, 100%);
  }

  .site-header {
    top: 8px;
    margin-top: 8px;
    padding: 10px;
  }

  .nav-links {
    display: none;
  }

  h1 {
    font-size: clamp(2.55rem, 16vw, 4.2rem);
  }

  h2 {
    font-size: clamp(2rem, 11vw, 3.1rem);
  }

  .store-row,
  .hero-stats {
    width: 100%;
  }

  .store-button,
  .hero-stats span {
    width: 100%;
    justify-content: center;
  }

  .phone-card {
    min-height: auto;
  }

  .phone-shell {
    min-height: 560px;
    border-radius: 38px;
  }

  .feature-grid,
  .faq-grid,
  .advantage-grid {
    grid-template-columns: 1fr;
  }

  .notification-section,
  .cta-section {
    padding: 24px;
    border-radius: 28px;
  }
}
```

- [ ] **Step 5: Build after section polish**

Run:

```bash
cd solatify-website
npm run build
```

Expected: build succeeds.

- [ ] **Step 6: Commit section polish**

Run:

```bash
git add solatify-website/src/app/globals.css
git commit -m "Polish website sections and responsive layout"
```

---

### Task 6: Final QA, Screenshot Review, and PR Prep

**Files:**
- Verify: `solatify-website/src/app/page.tsx`
- Verify: `solatify-website/src/app/globals.css`
- Optional modify: `solatify-website/README.md` only if run instructions become outdated

- [ ] **Step 1: Run lint**

Run:

```bash
cd solatify-website
npm run lint
```

Expected: no lint errors. If Next reports `next lint` is deprecated but still exits successfully, record the warning but continue.

- [ ] **Step 2: Run production build**

Run:

```bash
cd solatify-website
npm run build
```

Expected: production build succeeds.

- [ ] **Step 3: Run local dev server for visual check**

Run:

```bash
cd solatify-website
npm run dev
```

Expected: server starts at `http://127.0.0.1:3000` or the next available port. Review desktop width, tablet-ish width, and mobile width in the browser.

- [ ] **Step 4: Manual visual checklist**

Verify these points in the browser:

- Header remains sticky and readable.
- Hero phone preview does not overflow.
- Store buttons are visible and clickable.
- Feature cards align in desktop grid and collapse on mobile.
- Notification section remains readable.
- CTA text has enough contrast.
- FAQ cards are compact and readable.
- Light and dark theme toggle both look polished.

- [ ] **Step 5: Stop dev server**

Stop the process started by `npm run dev` with `Ctrl+C` in its terminal session.

- [ ] **Step 6: Check git diff**

Run:

```bash
git status --short
git diff --stat
git diff --check
```

Expected: only intended website files changed and no whitespace errors.

- [ ] **Step 7: Commit final fixes if any**

If QA required small fixes, commit them:

```bash
git add solatify-website/src/app/page.tsx solatify-website/src/app/globals.css solatify-website/src/lib/content.ts solatify-website/README.md
git commit -m "Finalize website mobile mirror QA fixes"
```

- [ ] **Step 8: Push branch**

Run:

```bash
git push
```

Expected: `feature/next-solatify-improvements` updates on GitHub.

---

## Self-Review

- Spec coverage: The plan covers visual system, hero, existing page structure, component styling, responsive behavior, and build/lint success criteria.
- Placeholder scan: No task contains TBD/TODO/fill-in placeholders; code snippets and commands are explicit.
- Scope check: The plan stays within the website presentation layer and avoids backend, routing, i18n, store-link, or mobile app changes.
- Type consistency: The only JSX additions use existing `Image` import and CSS class names defined in later tasks.
