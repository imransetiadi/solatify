import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL("https://solatify.my.id"),
  title: "Solatify — Jadwal Salat, Qur’an, Adzan & Islamic Companion",
  description:
    "Solatify helps Muslims with accurate prayer times, notifikasi adzan, Qur’an reading, Qibla direction, nearby mosques, dzikir, doa, Hijri calendar, Islamic tips, and worship tracking.",
  keywords: [
    "Solatify",
    "prayer times",
    "adhan",
    "quran app",
    "qibla",
    "dhikr",
    "islamic app",
    "prayer notification",
    "waktu salat",
    "jadwal salat",
    "masjid terdekat",
    "aplikasi muslim indonesia"
  ],
  applicationName: "Solatify",
  manifest: "/manifest.webmanifest",
  icons: {
    icon: "/icon.png",
    apple: "/apple-icon.png"
  },
  openGraph: {
    title: "Solatify — Your Daily Islamic Companion",
    description:
      "Accurate prayer times, notifikasi adzan, Qur’an, Qibla, nearby mosques, dzikir, doa, Hijri calendar, and worship tracking in one calm Islamic app.",
    type: "website",
    url: "https://solatify.my.id",
    siteName: "Solatify",
    images: [
      {
        url: "/icon.png",
        width: 512,
        height: 512,
        alt: "Solatify app icon"
      }
    ]
  },
  twitter: {
    card: "summary",
    title: "Solatify — Your Daily Islamic Companion",
    description:
      "Prayer times, notifikasi adzan, Qur’an, Qibla, nearby mosques, dzikir, doa, and worship tracking.",
    images: ["/icon.png"]
  }
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#fff7ed" },
    { media: "(prefers-color-scheme: dark)", color: "#160f0a" }
  ]
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en" data-theme="light">
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `
              (function() {
                try {
                  const storedTheme = localStorage.getItem('theme');
                  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
                  const theme = storedTheme || (prefersDark ? 'dark' : 'light');
                  document.documentElement.setAttribute('data-theme', theme);
                  
                  const storedLocale = localStorage.getItem('locale');
                  if (storedLocale === 'en' || storedLocale === 'id') {
                    document.documentElement.setAttribute('lang', storedLocale);
                  }
                } catch (e) {}
              })();
            `
          }}
        />
      </head>
      <body>{children}</body>
    </html>
  );
}
