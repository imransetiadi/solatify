"use client";

import { useEffect, useState } from "react";

export function ThemeToggle() {
  const [mounted, setMounted] = useState(false);
  const [isDark, setIsDark] = useState(false);

  useEffect(() => {
    setMounted(true);
    const stored = window.localStorage.getItem("theme");
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    const nextDark = stored ? stored === "dark" : prefersDark;
    setIsDark(nextDark);
  }, []);

  function toggleTheme() {
    const nextDark = !isDark;
    setIsDark(nextDark);
    document.documentElement.setAttribute("data-theme", nextDark ? "dark" : "light");
    window.localStorage.setItem("theme", nextDark ? "dark" : "light");
  }

  if (!mounted) {
    return (
      <button className="theme-toggle" type="button" aria-label="Toggle color theme" style={{ visibility: "hidden" }}>
        <span>☀</span> Light
      </button>
    );
  }

  return (
    <button className="theme-toggle" onClick={toggleTheme} type="button" aria-label="Toggle color theme">
      <span>{isDark ? "☾" : "☀"}</span>
      {isDark ? "Dark" : "Light"}
    </button>
  );
}
