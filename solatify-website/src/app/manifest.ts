import type { MetadataRoute } from "next";

export default function manifest(): MetadataRoute.Manifest {
  return {
    name: "Solatify",
    short_name: "Solatify",
    description:
      "Prayer times, adhan notifications, Qur’an reading, Qibla direction, dhikr, duas, Hijri calendar, and worship tracking.",
    start_url: "/",
    display: "standalone",
    background_color: "#fff7ed",
    theme_color: "#c94b3d",
    icons: [
      {
        src: "/apple-icon.png",
        sizes: "192x192",
        type: "image/png"
      },
      {
        src: "/icon.png",
        sizes: "512x512",
        type: "image/png"
      }
    ]
  };
}
