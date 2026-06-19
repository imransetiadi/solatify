export type Locale = "en" | "id";

export const storeLinks = {
  android: "https://github.com/imransetiadi/solatify/releases/download/v1.0.0-rc2/solatify-1.0.0.apk"
};

export const languages: Record<Locale, string> = {
  en: "English",
  id: "Indonesia"
};

export const localizedContent = {
  en: {
    nav: {
      features: "Features",
      notifications: "Preview",
      why: "Download",
      faq: "FAQ"
    },
    store: {
      installLabel: "Install Solatify",
      appStoreLabel: "iOS",
      playStoreLabel: "Download for",
      appStore: "Coming Soon",
      playStore: "Android APK",
      mobileCta: "Download Solatify"
    },
    hero: {
      badge: "Prayer companion",
      title: "Prayer, Qur’an, and daily worship — simple.",
      copy: "A calm Islamic app for prayer times, adhan, Qur’an, Qibla, and worship tracking.",
      statsLabel: "Solatify highlights",
      stats: [
        { value: "5", label: "prayers" },
        { value: "Adhan", label: "alerts" },
        { value: "iOS/Android", label: "preview" }
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
    liveCountdown: {
      label: "Next prayer",
      prayer: "Maghrib",
      time: "18:08",
      remaining: "Maghrib in 12m"
    },
    devicePreview: {
      title: "Light on iPhone. Dark on Pixel.",
      copy: "A clean preview for both platforms.",
      iosLabel: "iPhone 17 Pro • Light",
      iosAlt: "Solatify light theme preview on iPhone 17 Pro",
      androidLabel: "Pixel 10 Pro • Dark",
      androidAlt: "Solatify dark theme preview on Pixel 10 Pro"
    },
    phoneTabs: [
      {
        key: "home",
        label: "Android",
        src: "/screenshots/android-home-dark.jpg",
        alt: "Solatify home screen with next prayer preview",
        title: "Android preview",
        copy: "Prayer time, countdown, and daily schedule."
      },
      {
        key: "ios-home",
        label: "iOS",
        src: "/screenshots/ios1.jpg",
        alt: "Solatify iOS home screen with next prayer preview",
        title: "iOS preview",
        copy: "Clean layout for prayer routines."
      },
      {
        key: "quran",
        label: "Qur’an",
        src: "/screenshots/ios3.jpg",
        alt: "Solatify iOS Qur’an screen",
        title: "Qur’an",
        copy: "Browse and read comfortably."
      },
      {
        key: "mosque",
        label: "Mosque",
        src: "/screenshots/android-mosque-dark.jpg",
        alt: "Solatify nearby mosques screen",
        title: "Nearby mosques",
        copy: "Find a prayer place quickly."
      }
    ],
    howItWorks: {
      eyebrow: "How it works",
      title: "From permission to prayer reminder in three calm steps.",
      copy: "Solatify keeps the setup familiar: allow location, let schedules calculate, then choose how prayer reminders should appear.",
      steps: [
        { number: "01", title: "Allow location", description: "Use your city or device location so Solatify can calculate accurate local prayer times." },
        { number: "02", title: "Get prayer times", description: "Daily schedules update automatically with offsets you can align to your local mosque." },
        { number: "03", title: "Enable reminders", description: "Choose notification, reminder, and optional adhan behavior that matches your device settings." }
      ]
    },
    featuresSection: {
      eyebrow: "Features",
      title: "Everything essential. Nothing noisy.",
      copy: ""
    },
    screenshotsSection: {
      eyebrow: "App Preview",
      title: "Real screens. iOS and Android.",
      copy: ""
    },
    screenshots: [
      { src: "/screenshots/ios1.jpg", title: "Prayer Home", label: "iOS", story: "" },
      { src: "/screenshots/ios2.jpg", title: "Schedule", label: "iOS", story: "" },
      { src: "/screenshots/ios3.jpg", title: "Qur’an", label: "iOS", story: "" },
      { src: "/screenshots/ios6.jpg", title: "Mosques", label: "iOS", story: "" },
      { src: "/screenshots/android-home-dark.jpg", title: "Prayer Home", label: "Android", story: "" },
      { src: "/screenshots/android-quran-dark.jpg", title: "Qur’an", label: "Android", story: "" },
      { src: "/screenshots/pengaturan.jpg", title: "Settings", label: "Android", story: "" },
      { src: "/screenshots/tracker-2.jpg", title: "Tracker", label: "Android", story: "" }
    ],
    mosqueSpotlight: {
      eyebrow: "Nearby Mosques",
      title: "A travel-ready way to find a mosque near you.",
      copy: "Show distance, direction, and estimated walking time so users quickly understand where to pray next.",
      badge: "Nearby now",
      mosqueName: "Masjid Al-Ikhlas",
      distance: "650 m away",
      direction: "North-east",
      walking: "8 min walk",
      action: "Open directions",
      points: ["Distance and direction at a glance", "Map-ready mosque detail", "Useful when traveling or commuting"]
    },
    trust: {
      eyebrow: "Privacy & Trust",
      title: "Helpful reminders without feeling invasive.",
      copy: "Solatify is designed around permission-first behavior, local notification control, and clear user choices.",
      items: [
        { title: "Location with purpose", description: "Location is used to calculate prayer times and nearby mosque context, not to make the app feel noisy." },
        { title: "Local notification control", description: "Prayer reminders and optional adhan behavior stay tied to your device permission and app settings." },
        { title: "No excessive tracking copy", description: "The product story focuses on worship utility, privacy clarity, and trust before conversion." }
      ]
    },
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
      title: "Download Solatify.",
      copy: "Android is available now. iOS coming soon."
    },
    faqSection: {
      eyebrow: "FAQ",
      title: "FAQ"
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
        question: "Can Solatify remind me 10 minutes before prayer?",
        answer:
          "Solatify is designed around flexible prayer reminders, including pre-prayer reminders and arrival notifications when device permissions allow them."
      },
      {
        question: "Does adhan work on iOS and Android?",
        answer:
          "Adhan playback is optional and depends on each platform’s notification permission, sound mode, and app settings. Solatify keeps those controls clear for users."
      },
      {
        question: "Can I use Solatify offline?",
        answer:
          "Core saved content can be designed for quick access, while location updates, mosque discovery, and store downloads may need internet access."
      },
      {
        question: "Does Solatify support Indonesia?",
        answer:
          "Yes. Solatify is especially relevant for Indonesian users with Indonesian copy, daily prayer flow, nearby mosques, Qibla, Qur’an, dhikr, and Hijri calendar features."
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
      notifications: "Preview",
      why: "Download",
      faq: "FAQ"
    },
    store: {
      installLabel: "Install Solatify",
      appStoreLabel: "iOS",
      playStoreLabel: "Unduh untuk",
      appStore: "Coming Soon",
      playStore: "Android APK",
      mobileCta: "Download Solatify"
    },
    hero: {
      badge: "Teman ibadah harian",
      title: "Salat, Qur’an, dan ibadah harian — simpel.",
      copy: "Aplikasi Islami yang tenang untuk jadwal salat, adzan, Qur’an, kiblat, dan tracker ibadah.",
      statsLabel: "Keunggulan Solatify",
      stats: [
        { value: "5", label: "salat" },
        { value: "Adzan", label: "pengingat" },
        { value: "iOS/Android", label: "preview" }
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
    liveCountdown: {
      label: "Salat berikutnya",
      prayer: "Magrib",
      time: "18:08",
      remaining: "Magrib dalam 12m"
    },
    devicePreview: {
      title: "Light di iPhone. Dark di Pixel.",
      copy: "Preview bersih untuk dua platform.",
      iosLabel: "iPhone 17 Pro • Light",
      iosAlt: "Preview tema light Solatify di iPhone 17 Pro",
      androidLabel: "Pixel 10 Pro • Dark",
      androidAlt: "Preview tema dark Solatify di Pixel 10 Pro"
    },
    phoneTabs: [
      {
        key: "home",
        label: "Android",
        src: "/screenshots/android-home-dark.jpg",
        alt: "Tampilan home Solatify dengan salat berikutnya",
        title: "Preview Android",
        copy: "Jadwal, countdown, dan salat harian."
      },
      {
        key: "ios-home",
        label: "iOS",
        src: "/screenshots/ios1.jpg",
        alt: "Tampilan home iOS Solatify dengan salat berikutnya",
        title: "Preview iOS",
        copy: "Tampilan bersih untuk rutinitas salat."
      },
      {
        key: "quran",
        label: "Qur’an",
        src: "/screenshots/ios3.jpg",
        alt: "Tampilan Qur’an iOS Solatify",
        title: "Qur’an",
        copy: "Baca dan jelajahi dengan nyaman."
      },
      {
        key: "mosque",
        label: "Masjid",
        src: "/screenshots/android-mosque-dark.jpg",
        alt: "Tampilan masjid terdekat Solatify",
        title: "Masjid terdekat",
        copy: "Cari tempat salat dengan cepat."
      }
    ],
    howItWorks: {
      eyebrow: "Cara kerja",
      title: "Dari izin lokasi ke pengingat salat dalam tiga langkah tenang.",
      copy: "Solatify menjaga setup tetap familiar: izinkan lokasi, jadwal dihitung otomatis, lalu pilih cara pengingat salat muncul.",
      steps: [
        { number: "01", title: "Izinkan lokasi", description: "Gunakan kota atau lokasi perangkat agar Solatify menghitung waktu salat lokal dengan akurat." },
        { number: "02", title: "Dapatkan jadwal", description: "Jadwal harian diperbarui otomatis dengan offset yang bisa disesuaikan ke waktu masjid lokal." },
        { number: "03", title: "Aktifkan pengingat", description: "Pilih notifikasi, reminder, dan adzan opsional sesuai izin serta pengaturan perangkatmu." }
      ]
    },
    featuresSection: {
      eyebrow: "Fitur",
      title: "Yang penting saja. Tanpa ramai.",
      copy: ""
    },
    screenshotsSection: {
      eyebrow: "Preview Aplikasi",
      title: "Tampilan asli. iOS dan Android.",
      copy: ""
    },
    screenshots: [
      { src: "/screenshots/ios1.jpg", title: "Home Salat", label: "iOS", story: "" },
      { src: "/screenshots/ios2.jpg", title: "Jadwal", label: "iOS", story: "" },
      { src: "/screenshots/ios3.jpg", title: "Qur’an", label: "iOS", story: "" },
      { src: "/screenshots/ios6.jpg", title: "Masjid", label: "iOS", story: "" },
      { src: "/screenshots/android-home-dark.jpg", title: "Home Salat", label: "Android", story: "" },
      { src: "/screenshots/android-quran-dark.jpg", title: "Qur’an", label: "Android", story: "" },
      { src: "/screenshots/pengaturan.jpg", title: "Pengaturan", label: "Android", story: "" },
      { src: "/screenshots/tracker-2.jpg", title: "Tracker", label: "Android", story: "" }
    ],
    mosqueSpotlight: {
      eyebrow: "Masjid Terdekat",
      title: "Cara praktis menemukan masjid saat bepergian.",
      copy: "Tampilkan jarak, arah, dan estimasi jalan kaki agar pengguna cepat paham tempat salat berikutnya.",
      badge: "Terdekat sekarang",
      mosqueName: "Masjid Al-Ikhlas",
      distance: "650 m dari sini",
      direction: "Timur laut",
      walking: "8 menit jalan kaki",
      action: "Buka arah",
      points: ["Jarak dan arah sekali lihat", "Detail masjid siap peta", "Berguna saat traveling atau commute"]
    },
    trust: {
      eyebrow: "Privasi & Trust",
      title: "Pengingat yang membantu tanpa terasa mengganggu.",
      copy: "Solatify dirancang dengan perilaku permission-first, kontrol notifikasi lokal, dan pilihan pengguna yang jelas.",
      items: [
        { title: "Lokasi sesuai kebutuhan", description: "Lokasi digunakan untuk menghitung jadwal salat dan konteks masjid terdekat, bukan membuat aplikasi terasa berisik." },
        { title: "Kontrol notifikasi lokal", description: "Pengingat salat dan adzan opsional tetap mengikuti izin perangkat serta pengaturan aplikasi." },
        { title: "Tanpa narasi tracking berlebihan", description: "Cerita produk fokus pada manfaat ibadah, kejelasan privasi, dan rasa percaya sebelum konversi." }
      ]
    },
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
      title: "Download Solatify.",
      copy: "Android sudah tersedia. iOS segera hadir."
    },
    faqSection: {
      eyebrow: "FAQ",
      title: "FAQ"
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
        question: "Apakah Solatify bisa mengingatkan 10 menit sebelum salat?",
        answer:
          "Solatify dirancang untuk pengingat salat yang fleksibel, termasuk reminder sebelum salat dan notifikasi saat waktu tiba jika izin perangkat mendukung."
      },
      {
        question: "Apakah adzan berjalan di iOS dan Android?",
        answer:
          "Adzan bersifat opsional dan bergantung pada izin notifikasi, mode suara perangkat, serta pengaturan aplikasi di masing-masing platform. Solatify membuat kontrolnya jelas."
      },
      {
        question: "Apakah Solatify bisa digunakan offline?",
        answer:
          "Konten inti bisa dirancang untuk akses cepat, sementara update lokasi, pencarian masjid, dan tautan store tetap membutuhkan internet."
      },
      {
        question: "Apakah Solatify mendukung Indonesia?",
        answer:
          "Ya. Solatify sangat relevan untuk pengguna Indonesia dengan bahasa Indonesia, jadwal salat harian, masjid terdekat, kiblat, Qur’an, dzikir, dan kalender Hijriah."
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
