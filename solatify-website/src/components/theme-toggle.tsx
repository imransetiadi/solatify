"use client";

import { useEffect, useState } from "react";

export function ThemeToggle() {
  const [isDark, setIsDark] = useState(false);

  useEffect(() => {
    const stored = window.localStorage.getItem("theme");
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
    const nextDark = stored ? stored === "dark" : prefersDark;
    setIsDark(nextDark);
    document.documentElement.dataset.theme = nextDark ? "dark" : "light";
  }, []);

  function toggleTheme() {
    const nextDark = !isDark;
    setIsDark(nextDark);
    document.documentElement.dataset.theme = nextDark ? "dark" : "light";
    window.localStorage.setItem("theme", nextDark ? "dark" : "light");
  }

  return (
    <button className="theme-toggle" onClick={toggleTheme} type="button" aria-label="Toggle color theme">
      <span>{isDark ? "☾" : "☀"}</span>
      {isDark ? "Dark" : "Light"}
    </button>
  );
}
