import Image from "next/image";
import { ThemeToggle } from "@/components/theme-toggle";
import { advantages, faqs, features, storeLinks } from "@/lib/content";

function StoreButton({ type, href }: { type: "appstore" | "playstore"; href: string }) {
  const label = type === "appstore" ? "Download on the" : "Get it on";
  const store = type === "appstore" ? "App Store" : "Google Play";
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
          <a href="#features">Features</a>
          <a href="#notifications">Notifications</a>
          <a href="#why">Why Solatify</a>
          <a href="#faq">FAQ</a>
        </nav>
        <ThemeToggle />
      </header>

      <section className="hero" id="top">
        <div className="hero-glow" />
        <div className="hero-content">
          <div className="app-badge">
            <Image src="/brand/solatify-logo.png" alt="Solatify logo" width={42} height={42} priority />
            <span>Your calm Islamic companion</span>
          </div>
          <h1>Prayer times, adhan alerts, Qur’an, and daily worship in one beautiful app.</h1>
          <p className="hero-copy">
            Solatify helps Muslims stay connected to prayer and remembrance with accurate schedules,
            optional adhan notifications when prayer time arrives, Qur’an reading, Qibla direction,
            duas, Hijri calendar, and a clean worship tracker.
          </p>
          <div className="store-row" aria-label="Install Solatify">
            <StoreButton type="appstore" href={storeLinks.appStore} />
            <StoreButton type="playstore" href={storeLinks.playStore} />
          </div>
          <div className="hero-stats" aria-label="Solatify highlights">
            <span><strong>5</strong> daily prayers</span>
            <span><strong>Adhan</strong> arrival alerts</span>
            <span><strong>Light/Dark</strong> themes</span>
          </div>
        </div>

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
      </section>

      <section className="section feature-showcase" id="features">
        <div className="section-heading">
          <p className="eyebrow">Features</p>
          <h2>Designed for your daily Islamic routine.</h2>
          <p>
            From prayer reminders to Qur’an bookmarks and dhikr, Solatify brings essential Muslim
            routines into one focused experience.
          </p>
        </div>
        <div className="feature-grid">
          {features.map((feature) => (
            <article className="feature-card" key={feature.title}>
              <span className="feature-icon">{feature.icon}</span>
              <h3>{feature.title}</h3>
              <p>{feature.description}</p>
            </article>
          ))}
        </div>
      </section>

      <section className="notification-section glass-section" id="notifications">
        <div className="ornament-card notification-copy">
          <p className="eyebrow">Prayer Notifications</p>
          <h2>Know exactly when prayer time arrives.</h2>
          <p>
            Enable Solatify notifications to receive a status-bar alert as each prayer time begins.
            You can keep reminders subtle, open Solatify from the notification, or let the adhan play
            automatically when your device permission and app setting are enabled.
          </p>
        </div>
        <div className="notification-stack" aria-label="Prayer notification examples">
          <div className="alert-card alert-card-primary">
            <span>Now</span>
            <strong>It is time for Dhuhr</strong>
            <p>Tap to open Solatify and view today’s prayer schedule.</p>
          </div>
          <div className="alert-card">
            <span>Optional Adhan</span>
            <strong>Automatic adhan playback</strong>
            <p>Manual on/off control keeps notification permission in your hands.</p>
          </div>
        </div>
      </section>

      <section className="split-section" id="why">
        <div>
          <p className="eyebrow">Why Solatify</p>
          <h2>A worship app that feels calm, intentional, and practical.</h2>
          <p>
            Solatify is built with a warm Islamic visual language, practical controls, and a balanced
            interface that supports both daily use and focused worship moments.
          </p>
        </div>
        <div className="advantage-list">
          {advantages.map((item) => (
            <div className="advantage-item" key={item.title}>
              <span>{item.title}</span>
              <p>{item.description}</p>
            </div>
          ))}
        </div>
      </section>

      <section className="section cta-section app-download-panel">
        <div>
          <p className="eyebrow">Install Solatify</p>
          <h2>Bring prayer, Qur’an, and remembrance closer every day.</h2>
          <p>Download Solatify on iOS and Android when the public store listings are available.</p>
        </div>
        <div className="store-row centered">
          <StoreButton type="appstore" href={storeLinks.appStore} />
          <StoreButton type="playstore" href={storeLinks.playStore} />
        </div>
      </section>

      <section className="section faq-section" id="faq">
        <div className="section-heading">
          <p className="eyebrow">FAQ</p>
          <h2>Questions before installing?</h2>
        </div>
        <div className="faq-grid">
          {faqs.map((faq) => (
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
