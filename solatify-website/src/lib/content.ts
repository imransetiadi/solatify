export type Locale = "en" | "id";

export const storeLinks = {
  appStore: "https://apps.apple.com/app/solatify",
  playStore: "https://play.google.com/store/apps/details?id=com.solatify.app"
};

export const languages: Record<Locale, string> = {
  en: "English",
  id: "Indonesia"
};

export const localizedContent = {
  en: {
    nav: {
      features: "Features",
      notifications: "Notifications",
      why: "Why Solatify",
      faq: "FAQ"
    },
    store: {
      installLabel: "Install Solatify",
      appStoreLabel: "Download on the",
      playStoreLabel: "Get it on",
      appStore: "App Store",
      playStore: "Google Play"
    },
    hero: {
      badge: "Your calm Islamic companion",
      title: "Prayer times, adhan alerts, Qur’an, and daily worship in one beautiful app.",
      copy:
        "Solatify helps Muslims stay connected to prayer and remembrance with accurate schedules, optional adhan notifications when prayer time arrives, Qur’an reading, Qibla direction, duas, Hijri calendar, and a clean worship tracker.",
      statsLabel: "Solatify highlights",
      stats: [
        { value: "5", label: "daily prayers" },
        { value: "Adhan", label: "arrival alerts" },
        { value: "Light/Dark", label: "themes" }
      ]
    },
    preview: {
      label: "Solatify app preview",
      notificationTitle: "Maghrib prayer time",
      notificationBody: "Adhan is ready to play • 18:08",
      nextPrayerLabel: "Next prayer",
      prayerName: "Maghrib",
      location: "18:08 • Jakarta",
      countdown: "00:42:12 remaining",
      qibla: "Qibla",
      quran: "Qur’an",
      quranValue: "Al-Fatihah",
      quickActions: ["Dhikr", "Mosques", "Daily Dua"],
      prayers: [
        ["Fajr", "04:32"],
        ["Dhuhr", "11:58"],
        ["Asr", "15:20"],
        ["Isha", "19:23"]
      ]
    },
    featuresSection: {
      eyebrow: "Features",
      title: "Designed for your daily Islamic routine.",
      copy:
        "From prayer reminders to Qur’an bookmarks and dhikr, Solatify brings essential Muslim routines into one focused experience."
    },
    screenshotsSection: {
      eyebrow: "App Preview",
      title: "Real screens from Solatify on iPhone and Android.",
      copy: "Light previews use iPhone screenshots, while dark previews use Android screenshots, so visitors can instantly feel both platform experiences."
    },
    screenshots: [
      { src: "/screenshots/ios-home-light.jpg", title: "iPhone Home", label: "Light mode" },
      { src: "/screenshots/ios-schedule-light.jpg", title: "Prayer Schedule", label: "iPhone" },
      { src: "/screenshots/ios-quran-light.jpg", title: "Qur’an Reader", label: "iPhone" },
      { src: "/screenshots/android-mosque-dark.jpg", title: "Nearby Mosques", label: "Android dark" },
      { src: "/screenshots/android-quran-dark.jpg", title: "Dark Qur’an", label: "Android" },
      { src: "/screenshots/android-tracker-dark.jpg", title: "Worship Tracker", label: "Android" }
    ],
    notifications: {
      eyebrow: "Prayer Notifications",
      title: "Know exactly when prayer time arrives.",
      copy:
        "Enable Solatify notifications to receive a status-bar alert as each prayer time begins. You can keep reminders subtle, open Solatify from the notification, or let the adhan play automatically when your device permission and app setting are enabled.",
      examplesLabel: "Prayer notification examples",
      primaryTime: "Now",
      primaryTitle: "It is time for Dhuhr",
      primaryCopy: "Tap to open Solatify and view today’s prayer schedule.",
      adhanLabel: "Optional Adhan",
      adhanTitle: "Automatic adhan playback",
      adhanCopy: "Manual on/off control keeps notification permission in your hands."
    },
    why: {
      eyebrow: "Why Solatify",
      title: "A worship app that feels calm, intentional, and practical.",
      copy:
        "Solatify is built with a warm Islamic visual language, practical controls, and a balanced interface that supports both daily use and focused worship moments."
    },
    cta: {
      eyebrow: "Install Solatify",
      title: "Bring your prayer routine into a calmer daily flow.",
      copy: "Download Solatify on iOS and Android when the public store listings are available."
    },
    faqSection: {
      eyebrow: "FAQ",
      title: "Questions before installing?"
    },
    features: [
      {
        icon: "🕌",
        title: "Accurate Prayer Times",
        description:
          "Daily prayer schedules with location-aware calculation and adjustable offsets for local mosque timing."
      },
      {
        icon: "🔔",
        title: "Prayer Time Notifications",
        description:
          "Get status-bar reminders when each prayer time arrives, with tap-to-open access back into Solatify."
      },
      {
        icon: "📢",
        title: "Optional Adhan Playback",
        description:
          "Turn adhan automation on or off manually, so notification permission and playback stay under your control."
      },
      {
        icon: "📖",
        title: "Qur’an Reading",
        description:
          "Read the Qur’an with a clean interface designed for focus, bookmarks, and comfortable light or dark mode."
      },
      {
        icon: "🧭",
        title: "Qibla Direction",
        description:
          "Find the Qibla direction quickly with a focused compass-style experience for travel and daily use."
      },
      {
        icon: "📍",
        title: "Nearby Mosques",
        description: "Find nearby mosques quickly with map-ready directions for prayer on the go."
      },
      {
        icon: "🤲",
        title: "Duas & Dhikr",
        description:
          "Keep daily duas, dhikr, Asmaul Husna, Islamic tips, and worship reminders close in one place."
      },
      {
        icon: "🌙",
        title: "Hijri Calendar",
        description:
          "Follow important Islamic dates with a practical Hijri calendar designed to complement your routine."
      },
      {
        icon: "✅",
        title: "Worship Tracker",
        description:
          "Track prayers and build consistency with a lightweight, distraction-free worship progress view."
      }
    ],
    advantages: [
      {
        title: "Permission-first controls",
        description: "Adhan and notification behavior can be controlled manually instead of feeling forced."
      },
      {
        title: "Beautiful in every theme",
        description: "Warm Islamic visuals, soft surfaces, and carefully tuned contrast for light and dark mode."
      },
      {
        title: "Built for daily flow",
        description:
          "Fast access to prayer times, Qur’an, Qibla, nearby mosques, dhikr, duas, Hijri calendar, and Islamic content."
      }
    ],
    useCasesSection: {
      eyebrow: "Use Cases",
      title: "Made for the moments Muslims open every day.",
      copy: "Solatify keeps each routine focused, whether you are at home, traveling, or building a stronger Qur’an habit."
    },
    useCases: [
      {
        icon: "🕌",
        title: "For daily prayer",
        description: "See the next prayer, review today’s schedule, and keep adhan reminders calm and intentional."
      },
      {
        icon: "🧳",
        title: "For travel",
        description: "Use Qibla direction and nearby mosques when your routine moves outside your usual city."
      },
      {
        icon: "📖",
        title: "For Qur’an routine",
        description: "Return to reading, remember last progress, and keep worship content close without clutter."
      }
    ],
    faqs: [
      {
        question: "What is Solatify?",
        answer:
          "Solatify is an Islamic companion app for prayer times, adhan reminders, Qur’an reading, Qibla direction, dhikr, duas, Hijri calendar, and worship tracking."
      },
      {
        question: "Can Solatify notify me when prayer time arrives?",
        answer:
          "Yes. Solatify can show a status-bar notification when each prayer time arrives, and tapping it can open the app to your prayer schedule."
      },
      {
        question: "Does adhan play automatically?",
        answer:
          "Adhan playback is optional. You can turn it on or off manually, and it only works when the required device notification permission is enabled."
      },
      {
        question: "Will Solatify work on iPhone and Android?",
        answer:
          "The landing page is prepared for both App Store and Google Play links, so users can install from the platform they use."
      },
      {
        question: "Does Solatify support dark mode?",
        answer:
          "Yes. Solatify is designed with comfortable light and dark visual modes for different environments."
      },
      {
        question: "Does Solatify include Qur’an and dhikr features?",
        answer:
          "Yes. Solatify brings Qur’an reading, dhikr, duas, Asmaul Husna, Islamic tips, and related worship features into one app."
      },
      {
        question: "Can Solatify help me find nearby mosques?",
        answer:
          "Yes. Solatify includes a nearby mosques feature so you can quickly find mosque locations and map-ready directions when you are away from home."
      }
    ]
  },
  id: {
    nav: {
      features: "Fitur",
      notifications: "Notifikasi",
      why: "Kenapa Solatify",
      faq: "FAQ"
    },
    store: {
      installLabel: "Install Solatify",
      appStoreLabel: "Unduh di",
      playStoreLabel: "Dapatkan di",
      appStore: "App Store",
      playStore: "Google Play"
    },
    hero: {
      badge: "Teman ibadah harian yang tenang",
      title: "Jadwal salat, adzan, Qur’an, dan ibadah harian dalam satu aplikasi indah.",
      copy:
        "Solatify membantu Muslim tetap terhubung dengan salat dan dzikir melalui jadwal akurat, notifikasi adzan saat waktu salat tiba, bacaan Qur’an, arah kiblat, doa, kalender Hijriah, dan tracker ibadah yang rapi.",
      statsLabel: "Keunggulan Solatify",
      stats: [
        { value: "5", label: "waktu salat" },
        { value: "Adzan", label: "saat waktu tiba" },
        { value: "Light/Dark", label: "tema nyaman" }
      ]
    },
    preview: {
      label: "Pratinjau aplikasi Solatify",
      notificationTitle: "Waktu salat Magrib",
      notificationBody: "Adzan siap diputar • 18:08",
      nextPrayerLabel: "Salat berikutnya",
      prayerName: "Magrib",
      location: "18:08 • Jakarta",
      countdown: "00:42:12 tersisa",
      qibla: "Kiblat",
      quran: "Qur’an",
      quranValue: "Al-Fatihah",
      quickActions: ["Dzikir", "Masjid", "Doa Harian"],
      prayers: [
        ["Subuh", "04:32"],
        ["Dzuhur", "11:58"],
        ["Ashar", "15:20"],
        ["Isya", "19:23"]
      ]
    },
    featuresSection: {
      eyebrow: "Fitur",
      title: "Dirancang untuk rutinitas Islami harianmu.",
      copy:
        "Dari pengingat salat hingga bookmark Qur’an dan dzikir, Solatify menyatukan rutinitas Muslim penting dalam satu pengalaman yang fokus."
    },
    screenshotsSection: {
      eyebrow: "Preview Aplikasi",
      title: "Tampilan asli Solatify di iPhone dan Android.",
      copy: "Preview mode terang memakai screenshot iPhone, sementara preview mode gelap memakai screenshot Android agar pengunjung langsung merasakan kedua pengalaman platform."
    },
    screenshots: [
      { src: "/screenshots/ios-home-light.jpg", title: "Home iPhone", label: "Mode terang" },
      { src: "/screenshots/ios-schedule-light.jpg", title: "Jadwal Salat", label: "iPhone" },
      { src: "/screenshots/ios-quran-light.jpg", title: "Baca Qur’an", label: "iPhone" },
      { src: "/screenshots/android-mosque-dark.jpg", title: "Masjid Terdekat", label: "Android gelap" },
      { src: "/screenshots/android-quran-dark.jpg", title: "Qur’an Gelap", label: "Android" },
      { src: "/screenshots/android-tracker-dark.jpg", title: "Tracker Ibadah", label: "Android" }
    ],
    notifications: {
      eyebrow: "Notifikasi Salat",
      title: "Tahu tepat saat waktu salat tiba.",
      copy:
        "Aktifkan notifikasi Solatify untuk menerima pengingat saat setiap waktu salat dimulai. Kamu bisa membuat pengingat tetap ringan, membuka Solatify dari notifikasi, atau membiarkan adzan diputar otomatis saat izin perangkat dan pengaturan aplikasi aktif.",
      examplesLabel: "Contoh notifikasi salat",
      primaryTime: "Sekarang",
      primaryTitle: "Waktu Dzuhur telah tiba",
      primaryCopy: "Ketuk untuk membuka Solatify dan melihat jadwal salat hari ini.",
      adhanLabel: "Adzan Opsional",
      adhanTitle: "Pemutaran adzan otomatis",
      adhanCopy: "Kontrol manual aktif/nonaktif membuat izin notifikasi tetap di tanganmu."
    },
    why: {
      eyebrow: "Kenapa Solatify",
      title: "Aplikasi ibadah yang terasa tenang, niat, dan praktis.",
      copy:
        "Solatify dibangun dengan bahasa visual Islami yang hangat, kontrol praktis, dan antarmuka seimbang untuk penggunaan harian maupun momen ibadah yang fokus."
    },
    cta: {
      eyebrow: "Install Solatify",
      title: "Bawa rutinitas salatmu ke alur harian yang lebih tenang.",
      copy: "Unduh Solatify di iOS dan Android saat listing publik tersedia."
    },
    faqSection: {
      eyebrow: "FAQ",
      title: "Pertanyaan sebelum install?"
    },
    features: [
      {
        icon: "🕌",
        title: "Jadwal Salat Akurat",
        description:
          "Jadwal salat harian berbasis lokasi dengan offset yang bisa disesuaikan mengikuti waktu masjid lokal."
      },
      {
        icon: "🔔",
        title: "Notifikasi Waktu Salat",
        description:
          "Dapatkan pengingat status-bar saat waktu salat tiba, dengan akses cepat kembali ke Solatify."
      },
      {
        icon: "📢",
        title: "Adzan Opsional",
        description:
          "Aktifkan atau matikan otomatisasi adzan secara manual agar izin notifikasi dan pemutaran tetap terkendali."
      },
      {
        icon: "📖",
        title: "Baca Qur’an",
        description:
          "Baca Qur’an dengan antarmuka bersih untuk fokus, bookmark, dan mode terang/gelap yang nyaman."
      },
      {
        icon: "🧭",
        title: "Arah Kiblat",
        description:
          "Temukan arah kiblat dengan pengalaman kompas yang fokus untuk perjalanan dan penggunaan harian."
      },
      {
        icon: "📍",
        title: "Masjid Terdekat",
        description:
          "Temukan masjid terdekat dengan cepat lengkap dengan arah berbasis peta saat salat di perjalanan."
      },
      {
        icon: "🤲",
        title: "Doa & Dzikir",
        description:
          "Simpan doa harian, dzikir, Asmaul Husna, tips Islami, dan pengingat ibadah dalam satu tempat."
      },
      {
        icon: "🌙",
        title: "Kalender Hijriah",
        description:
          "Ikuti tanggal penting Islam dengan kalender Hijriah praktis untuk melengkapi rutinitasmu."
      },
      {
        icon: "✅",
        title: "Tracker Ibadah",
        description:
          "Pantau salat dan bangun konsistensi dengan tampilan progress ibadah yang ringan dan bebas distraksi."
      }
    ],
    advantages: [
      {
        title: "Kontrol izin lebih jelas",
        description: "Adzan dan notifikasi bisa dikontrol manual tanpa terasa dipaksa."
      },
      {
        title: "Indah di setiap tema",
        description: "Visual Islami hangat, permukaan lembut, dan kontras yang nyaman untuk mode terang maupun gelap."
      },
      {
        title: "Siap untuk rutinitas harian",
        description:
          "Akses cepat ke jadwal salat, Qur’an, kiblat, masjid terdekat, dzikir, doa, kalender Hijriah, dan konten Islami."
      }
    ],
    useCasesSection: {
      eyebrow: "Kegunaan",
      title: "Dibuat untuk momen yang dibuka Muslim setiap hari.",
      copy: "Solatify menjaga setiap rutinitas tetap fokus, baik di rumah, saat bepergian, maupun saat membangun kebiasaan Qur’an."
    },
    useCases: [
      {
        icon: "🕌",
        title: "Untuk salat harian",
        description: "Lihat salat berikutnya, cek jadwal hari ini, dan gunakan pengingat adzan yang tenang serta niat."
      },
      {
        icon: "🧳",
        title: "Untuk perjalanan",
        description: "Gunakan arah kiblat dan masjid terdekat saat rutinitasmu berpindah dari kota biasanya."
      },
      {
        icon: "📖",
        title: "Untuk rutinitas Qur’an",
        description: "Kembali membaca, ingat progress terakhir, dan simpan konten ibadah dekat tanpa terasa ramai."
      }
    ],
    faqs: [
      {
        question: "Apa itu Solatify?",
        answer:
          "Solatify adalah aplikasi pendamping Islami untuk jadwal salat, pengingat adzan, bacaan Qur’an, arah kiblat, dzikir, doa, kalender Hijriah, dan tracker ibadah."
      },
      {
        question: "Apakah Solatify bisa mengingatkan saat waktu salat tiba?",
        answer:
          "Ya. Solatify bisa menampilkan notifikasi saat setiap waktu salat tiba, dan ketukan pada notifikasi dapat membuka jadwal salat di aplikasi."
      },
      {
        question: "Apakah adzan bisa diputar otomatis?",
        answer:
          "Pemutaran adzan bersifat opsional. Kamu bisa mengaktifkan atau mematikannya secara manual, dan fitur ini bekerja saat izin notifikasi perangkat sudah aktif."
      },
      {
        question: "Apakah Solatify tersedia untuk iPhone dan Android?",
        answer:
          "Landing page ini disiapkan untuk tautan App Store dan Google Play agar pengguna bisa install sesuai platform yang digunakan."
      },
      {
        question: "Apakah Solatify mendukung dark mode?",
        answer:
          "Ya. Solatify dirancang dengan mode terang dan gelap yang nyaman untuk berbagai kondisi."
      },
      {
        question: "Apakah Solatify punya fitur Qur’an dan dzikir?",
        answer:
          "Ya. Solatify menyatukan bacaan Qur’an, dzikir, doa, Asmaul Husna, tips Islami, dan fitur ibadah terkait dalam satu aplikasi."
      },
      {
        question: "Apakah Solatify bisa membantu mencari masjid terdekat?",
        answer:
          "Ya. Solatify memiliki fitur masjid terdekat agar kamu bisa cepat menemukan lokasi masjid dan arah berbasis peta saat jauh dari rumah."
      }
    ]
  }
};
