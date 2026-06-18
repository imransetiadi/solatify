"use client";

import Image from "next/image";
import { useEffect, useState } from "react";
import { LanguageToggle } from "@/components/language-toggle";
import { ThemeToggle } from "@/components/theme-toggle";
import { localizedContent, storeLinks, type Locale } from "@/lib/content";

function StoreButton({
  href,
  label,
  store,
  type
}: {
  href: string;
  label: string;
  store: string;
  type: "appstore" | "playstore";
}) {
  const icon = type === "appstore" ? "" : "▶";

  return (
    <a className="store-button" href={href} aria-label={`${label} ${store}`}>
      <span className="store-icon">{icon}</span>
      <span>
        <small>{label}</small>
        <strong>{store}</strong>
      </span>
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
          <a href="#notifications">{content.nav.notifications}</a>
          <a href="#why">{content.nav.why}</a>
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
              href={storeLinks.appStore}
              label={content.store.appStoreLabel}
              store={content.store.appStore}
            />
            <StoreButton
              type="playstore"
              href={storeLinks.playStore}
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
        </div>

        <div className="phone-card screenshot-hero" aria-label={content.preview.label}>
          <div className="phone-orbit" aria-hidden="true" />
          <div className="phone-shell real-screen-shell primary-screen">
            <div className="phone-top" />
            <Image
              src="/screenshots/ios-home-light.jpg"
              alt="Solatify iPhone home screen in light mode"
              width={1177}
              height={2560}
              priority
            />
          </div>
          <div className="phone-shell real-screen-shell secondary-screen" aria-hidden="true">
            <div className="phone-top" />
            <Image
              src="/screenshots/android-home-dark.jpg"
              alt=""
              width={1177}
              height={2560}
              priority
            />
          </div>
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section feature-showcase reveal" id="features">
        <div className="section-heading">
          <p className="eyebrow">{content.featuresSection.eyebrow}</p>
          <h2>{content.featuresSection.title}</h2>
          <p>{content.featuresSection.copy}</p>
        </div>
        <div className="feature-grid">
          {content.features.map((feature) => (
            <article className="feature-card" key={feature.title}>
              <span className="feature-icon">{feature.icon}</span>
              <h3>{feature.title}</h3>
              <p>{feature.description}</p>
            </article>
          ))}
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section screenshot-section reveal" id="screenshots">
        <div className="section-heading">
          <p className="eyebrow">{content.screenshotsSection.eyebrow}</p>
          <h2>{content.screenshotsSection.title}</h2>
          <p>{content.screenshotsSection.copy}</p>
        </div>
        <div className="screenshot-grid">
          {content.screenshots.map((screenshot) => (
            <article className="screenshot-card" key={screenshot.src}>
              <div className="screenshot-frame">
                <Image
                  src={screenshot.src}
                  alt={`${screenshot.title} preview`}
                  width={1177}
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

      <section className="notification-section glass-section reveal" id="notifications">
        <div className="ornament-card notification-copy">
          <p className="eyebrow">{content.notifications.eyebrow}</p>
          <h2>{content.notifications.title}</h2>
          <p>{content.notifications.copy}</p>
        </div>
        <div className="notification-stack" aria-label={content.notifications.examplesLabel}>
          <div className="alert-card alert-card-primary">
            <span>{content.notifications.primaryTime}</span>
            <strong>{content.notifications.primaryTitle}</strong>
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

      <section className="split-section reveal" id="why">
        <div>
          <p className="eyebrow">{content.why.eyebrow}</p>
          <h2>{content.why.title}</h2>
          <p>{content.why.copy}</p>
        </div>
        <div className="advantage-list">
          {content.advantages.map((item) => (
            <div className="advantage-item" key={item.title}>
              <span>{item.title}</span>
              <p>{item.description}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="section use-cases-section reveal" id="use-cases">
        <div className="section-heading">
          <p className="eyebrow">{content.useCasesSection.eyebrow}</p>
          <h2>{content.useCasesSection.title}</h2>
          <p>{content.useCasesSection.copy}</p>
        </div>
        <div className="use-case-grid">
          {content.useCases.map((item) => (
            <article className="use-case-card" key={item.title}>
              <span>{item.icon}</span>
              <h3>{item.title}</h3>
              <p>{item.description}</p>
            </article>
          ))}
        </div>
      </section>

      <div className="ornament-divider" aria-hidden="true" />

      <section className="section cta-section app-download-panel reveal">
        <div>
          <p className="eyebrow">{content.cta.eyebrow}</p>
          <h2>{content.cta.title}</h2>
          <p>{content.cta.copy}</p>
        </div>
        <div className="store-row centered">
          <StoreButton
            type="appstore"
            href={storeLinks.appStore}
            label={content.store.appStoreLabel}
            store={content.store.appStore}
          />
          <StoreButton
            type="playstore"
            href={storeLinks.playStore}
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
          {content.faqs.map((faq) => (
            <article className="faq" key={faq.question}>
              <h3>{faq.question}</h3>
              <p>{faq.answer}</p>
            </article>
          ))}
        </div>
      </section>
    </main>
  );
}
