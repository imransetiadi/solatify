"use client";

import type { Locale } from "@/lib/content";
import { languages } from "@/lib/content";

type LanguageToggleProps = {
  locale: Locale;
  onChange: (locale: Locale) => void;
};

export function LanguageToggle({ locale, onChange }: LanguageToggleProps) {
  return (
    <div className="language-toggle" aria-label="Choose language" role="group">
      {Object.entries(languages).map(([code, label]) => {
        const nextLocale = code as Locale;
        const isActive = locale === nextLocale;

        return (
          <button
            aria-pressed={isActive}
            className={isActive ? "active" : undefined}
            key={code}
            onClick={() => onChange(nextLocale)}
            title={label}
            type="button"
          >
            {code.toUpperCase()}
          </button>
        );
      })}
    </div>
  );
}
