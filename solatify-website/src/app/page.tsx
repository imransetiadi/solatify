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
  const icon = type === "appstore" ? "" : "▶";
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
              <span>{content.devicePreview.iosLabel}</span>
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
              <span>{content.devicePreview.androidLabel}</span>
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

      <section className="section feature-showcase reveal" id="features">
        <div className="section-heading">
          <p className="eyebrow">{content.featuresSection.eyebrow}</p>
          <h2>{content.featuresSection.title}</h2>
        </div>
        <div className="feature-grid">
          {content.features.slice(0, 6).map((feature) => (
            <article className="feature-card" key={feature.title}>
              <span className="feature-icon">{feature.icon}</span>
              <h3>{feature.title}</h3>
            </article>
          ))}
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section screenshot-section reveal" id="screenshots">
        <div className="section-heading">
          <p className="eyebrow">{content.screenshotsSection.eyebrow}</p>
          <h2>{content.screenshotsSection.title}</h2>
        </div>
        <div className="screenshot-grid">
          {content.screenshots.slice(0, 6).map((screenshot) => (
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

      <section className="section cta-section app-download-panel reveal" id="download">
        <div>
          <p className="eyebrow">{content.cta.eyebrow}</p>
          <h2>{content.cta.title}</h2>
          <p>{content.cta.copy}</p>
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

      <section className="section faq-section reveal" id="faq">
        <div className="section-heading">
          <p className="eyebrow">{content.faqSection.eyebrow}</p>
          <h2>{content.faqSection.title}</h2>
        </div>
        <div className="faq-grid">
          {content.faqs.slice(0, 3).map((faq) => (
            <article className="faq" key={faq.question}>
              <h3>{faq.question}</h3>
              <p>{faq.answer}</p>
            </article>
          ))}
        </div>
      </section>
      <div className="mobile-sticky-cta" aria-label={content.store.installLabel}>
        <a href={storeLinks.android}>{content.store.mobileCta}</a>
      </div>
    </main>
  );
}
