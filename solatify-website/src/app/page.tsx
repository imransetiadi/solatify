"use client";

import Image from "next/image";
import { useEffect, useState } from "react";
import { LanguageToggle } from "@/components/language-toggle";
import { ThemeToggle } from "@/components/theme-toggle";
import { localizedContent, storeLinks, type Locale } from "@/lib/content";

function getScreenshotWidth(src: string) {
  return src.includes("/ios") ? 1177 : 1182;
}

function StoreButton({
  href,
  label,
  store,
  type
}: {
  href?: string;
  label: string;
  store: string;
  type: "appstore" | "playstore";
}) {
  const icon = type === "appstore" ? (
    <svg viewBox="0 0 170 170" width="20" height="20" fill="currentColor" aria-hidden="true" style={{ display: 'block' }}>
      <path d="M150.37 130.25c-2.45 5.66-5.35 10.87-8.71 15.66-4.58 6.53-8.33 11.05-11.22 13.56-4.48 4.12-9.28 6.23-14.42 6.35-3.69 0-8.14-1.05-13.32-3.18-5.19-2.12-9.97-3.17-14.34-3.17-4.58 0-9.49 1.05-14.75 3.17-5.26 2.13-9.5 3.24-12.74 3.35-4.34.13-9.13-1.92-14.38-6.17-2.73-2.22-6.5-6.73-11.3-13.56-11.62-16.63-17.43-34.14-17.43-52.54 0-14.63 4.12-26.35 12.35-35.16 8.24-8.8 17.76-13.21 28.56-13.21 4.7 0 9.85 1.25 15.43 3.76 5.59 2.51 9.09 3.76 10.5 3.76 1.18 0 4.65-1.25 10.42-3.76 5.77-2.51 10.57-3.64 14.42-3.41 14.24.82 25.1 6.13 32.57 15.9-11.62 7.06-17.33 16.59-17.1 28.59.24 9.65 3.86 17.89 10.88 24.71 7.02 6.82 15.22 10.53 24.6 11.12-2.12 6.47-5.29 13.24-9.53 20.31zM119.22 19.01c0 8.12-2.94 15.65-8.83 22.59-5.88 6.94-13.06 10.88-21.53 11.82.12-7.65 3.12-15.18 9.01-22.59 5.88-7.41 13.12-11.41 21.71-12 .65 9.06-2.03 16.48-9.36 24.18z"/>
    </svg>
  ) : (
    <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor" aria-hidden="true" style={{ display: 'block' }}>
      <path d="M3.609 1.814L13.792 12 3.61 22.186a2.29 2.29 0 0 1-.61-1.572V3.386c0-.624.22-1.196.61-1.572zm11.29 9.176l3.528-2.036c.995-.574.995-1.506 0-2.08l-3.528-2.037L11.517 8.22 14.899 10.99zm-4.392-1.782L3.896 2.766C4.42 2.27 5.242 2.22 6.07 2.7l7.854 4.534-3.417 2.154zm0 3.564l3.417 2.154-7.854 4.534c-.828.48-1.65.43-2.174-.066l6.611-6.622z"/>
    </svg>
  );

  const content = (
    <>
      <span className="store-icon">{icon}</span>
      <span>
        <small>{label}</small>
        <strong>{store}</strong>
      </span>
    </>
  );

  if (!href) {
    return (
      <span className="store-button store-button-disabled" aria-label={`${label} ${store}`} aria-disabled="true">
        {content}
      </span>
    );
  }

  return (
    <a className="store-button" href={href} aria-label={`${label} ${store}`} rel="noreferrer">
      {content}
    </a>
  );
}

export default function Home() {
  const [locale, setLocale] = useState<Locale>("en");
  const content = localizedContent[locale];

  useEffect(() => {
    const storedLocale = window.localStorage.getItem("locale");
    if (storedLocale === "en" || storedLocale === "id") {
      setLocale(storedLocale);
      document.documentElement.lang = storedLocale;
    }
  }, []);

  function changeLocale(nextLocale: Locale) {
    setLocale(nextLocale);
    document.documentElement.lang = nextLocale;
    window.localStorage.setItem("locale", nextLocale);
  }

  const activeLabels = {
    en: { distance: "Distance", direction: "Direction", walking: "Walking time" },
    id: { distance: "Jarak", direction: "Arah", walking: "Waktu jalan kaki" }
  }[locale];

  return (
    <main>
      <header className="site-header">
        <a className="brand" href="#top" aria-label="Solatify home">
          <span className="brand-mark image-mark">
            <Image src="/brand/solatify-logo.png" alt="" width={30} height={30} priority />
          </span>
          <span>Solatify</span>
        </a>
        <nav className="nav-links" aria-label="Primary navigation">
          <a href="#how-it-works">{locale === "en" ? "How It Works" : "Cara Kerja"}</a>
          <a href="#features">{content.nav.features}</a>
          <a href="#screenshots">{content.nav.notifications}</a>
          <a href="#download">{content.nav.why}</a>
          <a href="#faq">{content.nav.faq}</a>
        </nav>
        <div className="header-actions">
          <LanguageToggle locale={locale} onChange={changeLocale} />
          <ThemeToggle />
        </div>
      </header>

      <section className="hero reveal" id="top">
        <div className="hero-glow" />
        <div className="hero-content">
          <div className="app-badge">
            <Image src="/brand/solatify-logo.png" alt="Solatify logo" width={42} height={42} priority />
            <span>{content.hero.badge}</span>
          </div>
          <h1>{content.hero.title}</h1>
          <p className="hero-copy">{content.hero.copy}</p>
          <div className="store-row" aria-label={content.store.installLabel}>
            <StoreButton
              type="appstore"
              label={content.store.appStoreLabel}
              store={content.store.appStore}
            />
            <StoreButton
              type="playstore"
              href={storeLinks.android}
              label={content.store.playStoreLabel}
              store={content.store.playStore}
            />
          </div>
          <div className="hero-stats" aria-label={content.hero.statsLabel}>
            {content.hero.stats.map((stat) => (
              <span key={`${stat.value}-${stat.label}`}>
                <strong>{stat.value}</strong> {stat.label}
              </span>
            ))}
          </div>
          <div className="prayer-countdown" aria-label={`${content.liveCountdown.label}: ${content.liveCountdown.prayer}`}>
            <span>{content.liveCountdown.label}</span>
            <strong>{content.liveCountdown.remaining}</strong>
            <small>{content.liveCountdown.time}</small>
          </div>
        </div>

        <div className="phone-card screenshot-hero" aria-label={content.preview.label}>
          <div className="device-pair">
            <article className="device-card iphone-device">
              <div className="phone-shell real-screen-shell iphone-shell">
                <div className="phone-top" />
                <Image
                  src="/screenshots/ios1.jpg"
                  alt={content.devicePreview.iosAlt}
                  width={1177}
                  height={2560}
                  priority
                />
              </div>
            </article>
            <article className="device-card pixel-device">
              <div className="phone-shell real-screen-shell pixel-shell">
                <div className="phone-top" />
                <Image
                  src="/screenshots/android-home-dark.jpg"
                  alt={content.devicePreview.androidAlt}
                  width={1182}
                  height={2560}
                  priority
                />
              </div>
            </article>
          </div>
          <div className="phone-preview-copy">
            <strong>{content.devicePreview.title}</strong>
            <p>{content.devicePreview.copy}</p>
          </div>
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section step-section reveal" id="how-it-works">
        <div className="section-heading">
          <p className="eyebrow">{content.howItWorks.eyebrow}</p>
          <h2>{content.howItWorks.title}</h2>
          <p className="section-copy" style={{ maxWidth: "700px", margin: "12px auto 0", color: "var(--muted)" }}>
            {content.howItWorks.copy}
          </p>
        </div>
        <div className="step-grid">
          {content.howItWorks.steps.map((step) => (
            <article className="step-card" key={step.number}>
              <span>{step.number}</span>
              <h3>{step.title}</h3>
              <p>{step.description}</p>
            </article>
          ))}
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section feature-showcase reveal" id="features">
        <div className="section-heading">
          <p className="eyebrow">{content.featuresSection.eyebrow}</p>
          <h2>{content.featuresSection.title}</h2>
        </div>
        <div className="feature-grid">
          {content.features.map((feature) => (
            <article className="feature-card" key={feature.title}>
              <span className="feature-icon">{feature.icon}</span>
              <h3>{feature.title}</h3>
              <p style={{ color: "var(--muted)", fontSize: "0.9rem", margin: "8px 0 0", lineHeight: "1.5" }}>
                {feature.description}
              </p>
            </article>
          ))}
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section notification-section reveal">
        <div className="notification-copy">
          <p className="eyebrow">{content.notifications.eyebrow}</p>
          <h2>{content.notifications.title}</h2>
          <p>{content.notifications.copy}</p>
          <ul className="check-list">
            <li>{content.notifications.primaryTitle}: {content.notifications.primaryCopy}</li>
            <li>{content.notifications.adhanTitle}: {content.notifications.adhanCopy}</li>
          </ul>
        </div>
        <div className="notification-stack">
          <div className="alert-card alert-card-primary">
            <span>{content.notifications.primaryTime}</span>
            <strong style={{ color: '#fff' }}>{content.notifications.primaryTitle}</strong>
            <p>{content.notifications.primaryCopy}</p>
          </div>
          <div className="alert-card">
            <span>{content.notifications.adhanLabel}</span>
            <strong>{content.notifications.adhanTitle}</strong>
            <p>{content.notifications.adhanCopy}</p>
          </div>
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section mosque-section reveal">
        <div>
          <p className="eyebrow">{content.mosqueSpotlight.eyebrow}</p>
          <h2>{content.mosqueSpotlight.title}</h2>
          <p style={{ margin: "12px 0 0" }}>{content.mosqueSpotlight.copy}</p>
          <ul className="check-list mosque-points">
            {content.mosqueSpotlight.points.map((point) => (
              <li key={point}>{point}</li>
            ))}
          </ul>
        </div>
        <div className="mosque-card">
          <span>{content.mosqueSpotlight.badge}</span>
          <strong>{content.mosqueSpotlight.mosqueName}</strong>
          <div className="mosque-meta">
            <div>
              <small>{activeLabels.distance}</small>
              <b>{content.mosqueSpotlight.distance}</b>
            </div>
            <div>
              <small>{activeLabels.direction}</small>
              <b>{content.mosqueSpotlight.direction}</b>
            </div>
            <div>
              <small>{activeLabels.walking}</small>
              <b>{content.mosqueSpotlight.walking}</b>
            </div>
          </div>
          <button type="button">{content.mosqueSpotlight.action}</button>
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section screenshot-section reveal" id="screenshots">
        <div className="section-heading">
          <p className="eyebrow">{content.screenshotsSection.eyebrow}</p>
          <h2>{content.screenshotsSection.title}</h2>
        </div>
        <div className="screenshot-grid">
          {content.screenshots.map((screenshot) => (
            <article className="screenshot-card" key={screenshot.src}>
              <div className="screenshot-frame">
                <Image
                  src={screenshot.src}
                  alt={`${screenshot.title} preview`}
                  width={getScreenshotWidth(screenshot.src)}
                  height={2560}
                />
              </div>
              <div>
                <span>{screenshot.label}</span>
                <strong>{screenshot.title}</strong>
              </div>
            </article>
          ))}
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section use-case-section reveal">
        <div className="section-heading">
          <p className="eyebrow">{content.useCasesSection.eyebrow}</p>
          <h2>{content.useCasesSection.title}</h2>
          <p className="section-copy" style={{ maxWidth: "700px", margin: "12px auto 0", color: "var(--muted)" }}>
            {content.useCasesSection.copy}
          </p>
        </div>
        <div className="use-case-grid">
          {content.useCases.map((useCase) => (
            <article className="use-case-card" key={useCase.title}>
              <span>{useCase.icon}</span>
              <h3>{useCase.title}</h3>
              <p>{useCase.description}</p>
            </article>
          ))}
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section split-section reveal">
        <div>
          <p className="eyebrow">{content.why.eyebrow}</p>
          <h2>{content.why.title}</h2>
          <p className="section-copy" style={{ color: "var(--muted)", margin: "12px 0 24px" }}>
            {content.why.copy}
          </p>
          <div className="advantage-list" style={{ display: "grid", gap: "16px" }}>
            {content.advantages.map((adv) => (
              <article className="advantage-item" key={adv.title}>
                <span>{adv.title}</span>
                <p>{adv.description}</p>
              </article>
            ))}
          </div>
        </div>
        <div className="ornament-card">
          <div className="arabic" dir="rtl">
            إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَوْقُوتًا
          </div>
          <p style={{ margin: 0, fontSize: "0.9rem", color: "var(--muted)", lineHeight: "1.6" }}>
            {locale === "en"
              ? "“Indeed, prayer has been decreed upon the believers a decree of specified times.” — Surah An-Nisa: 103"
              : "“Sesungguhnya salat itu adalah kewajiban yang ditentukan waktunya atas orang-orang yang beriman.” — QS. An-Nisa: 103"}
          </p>
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section trust-section reveal">
        <div className="section-heading">
          <p className="eyebrow">{content.trust.eyebrow}</p>
          <h2>{content.trust.title}</h2>
          <p className="section-copy" style={{ maxWidth: "700px", margin: "12px auto 0", color: "var(--muted)" }}>
            {content.trust.copy}
          </p>
        </div>
        <div className="trust-grid">
          {content.trust.items.map((item, idx) => (
            <article className="trust-card" key={item.title}>
              <span>{String(idx + 1).padStart(2, "0")}</span>
              <h3>{item.title}</h3>
              <p>{item.description}</p>
            </article>
          ))}
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section cta-section app-download-panel reveal" id="download">
        <div>
          <p className="eyebrow">{content.cta.eyebrow}</p>
          <h2>{content.cta.title}</h2>
          <p style={{ margin: "12px 0 24px" }}>{content.cta.copy}</p>
        </div>
        <div className="store-row centered">
          <StoreButton
            type="appstore"
            label={content.store.appStoreLabel}
            store={content.store.appStore}
          />
          <StoreButton
            type="playstore"
            href={storeLinks.android}
            label={content.store.playStoreLabel}
            store={content.store.playStore}
          />
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section faq-section reveal" id="faq">
        <div className="section-heading">
          <p className="eyebrow">{content.faqSection.eyebrow}</p>
          <h2>{content.faqSection.title}</h2>
        </div>
        <div className="faq-list">
          {content.faqs.map((faq) => (
            <details key={faq.question}>
              <summary>{faq.question}</summary>
              <p>{faq.answer}</p>
            </details>
          ))}
        </div>
      </section>

      <footer className="footer">
        <span>© 2026 Solatify</span>
      </footer>

      <div className="mobile-sticky-cta" aria-label={content.store.installLabel}>
        <a href={storeLinks.android}>{content.store.mobileCta}</a>
      </div>
    </main>
  );
}
