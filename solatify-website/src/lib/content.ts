export type Locale = "en" | "id";

export const storeLinks = {
  android: "https://github.com/imransetiadi/solatify/releases/download/v1.0.0-rc5/solatify-1.0.0.apk"
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
      copy: "A calm Islamic app for prayer times, adhan, Qur’an recitation, Qibla, nearby mosques, and worship tracking, in Indonesian or English.",
      statsLabel: "Solatify highlights",
      stats: [
        { value: "5", label: "prayers" },
        { value: "Adhan", label: "alerts" },
        { value: "Light/Dark", label: "modes" }
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
      copy: "Supports light and dark mode across platforms.",
      iosLabel: "iPhone 16 Pro • Light",
      iosAlt: "Solatify light theme preview on iPhone 16 Pro",
      androidLabel: "Pixel 7 • Dark",
      androidAlt: "Solatify dark theme preview on Pixel 7"
    },
    phoneTabs: [
      {
        key: "home",
        label: "Android",
        src: "/screenshots/app-android-home.jpg",
        alt: "Solatify home screen with next prayer preview",
        title: "Android preview",
        copy: "Prayer time, countdown, and daily schedule."
      },
      {
        key: "ios-home",
        label: "iOS",
        src: "/screenshots/app-ios-home.jpg",
        alt: "Solatify iOS home screen with next prayer preview",
        title: "iOS preview",
        copy: "Clean layout for prayer routines."
      },
      {
        key: "quran",
        label: "Qur’an",
        src: "/screenshots/app-ios-quran.jpg",
        alt: "Solatify iOS Qur’an screen",
        title: "Qur’an",
        copy: "Browse and read comfortably."
      },
      {
        key: "mosque",
        label: "Mosque",
        src: "/screenshots/app-android-mosque.jpg",
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
        { number: "02", title: "Get prayer times", description: "Schedules follow your local time zone and update on their own each day, with offsets you can align to your local mosque." },
        { number: "03", title: "Enable reminders", description: "Get an alert at each prayer time, add a reminder 5, 10, or 15 minutes before, and choose adhan, a short beep, or a silent notification." }
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
      { src: "/screenshots/app-ios-home.jpg", title: "Prayer Home", label: "iOS", story: "" },
      { src: "/screenshots/app-ios-schedule.jpg", title: "Schedule", label: "iOS", story: "" },
      { src: "/screenshots/app-ios-quran.jpg", title: "Qur’an", label: "iOS", story: "" },
      { src: "/screenshots/app-ios-mosque.jpg", title: "Mosques", label: "iOS", story: "" },
      { src: "/screenshots/app-android-home.jpg", title: "Prayer Home", label: "Android", story: "" },
      { src: "/screenshots/app-android-quran.jpg", title: "Qur’an", label: "Android", story: "" },
      { src: "/screenshots/app-android-settings-adhan.jpg", title: "Settings", label: "Android", story: "" },
      { src: "/screenshots/app-android-tracker.jpg", title: "Tracker", label: "Android", story: "" }
    ],
    mosqueSpotlight: {
      eyebrow: "Nearby Mosques",
      title: "Find a mosque near you in about a second.",
      copy: "Solatify lists mosques within 5 km from OpenStreetMap, nearest first, with the address and a route button that opens your maps app.",
      badge: "Nearest",
      mosqueName: "Masjid Al-Ikhlas",
      distance: "650 m",
      address: "Jl. Cikini Raya, Menteng",
      source: "OpenStreetMap",
      action: "Route",
      points: ["Nearest first, within 5 km", "Address and a route in one tap", "Your last results stay when you are offline"]
    },
    trust: {
      eyebrow: "Privacy & Trust",
      title: "Helpful reminders without feeling invasive.",
      copy: "Solatify asks only for what a feature needs, schedules notifications on your phone, and lets you switch each one off.",
      items: [
        { title: "Location with purpose", description: "Location is used to calculate prayer times and find nearby mosques. Prefer not to share GPS? Pick your city by hand." },
        { title: "Local notification control", description: "Prayer alerts are scheduled on your phone. Turn each prayer, reminder, and the adhan on or off in Settings." },
        { title: "Your data stays on your phone", description: "Prayer logs, bookmarks, and settings are stored on your device. Your location is only sent to OpenStreetMap search services (Photon, with Overpass as a backup) when you search for nearby mosques." }
      ]
    },
    notifications: {
      eyebrow: "Prayer Notifications",
      title: "Know exactly when prayer time arrives.",
      copy:
        "Enable Solatify notifications to get an alert as each prayer time begins. Alerts are scheduled six days ahead, so they keep arriving even when you do not open the app. Add a reminder 5, 10, or 15 minutes before; it uses a short sound and says how long is left, so it never sounds like the adhan.",
      examplesLabel: "Prayer notification examples",
      primaryTime: "Now",
      primaryTitle: "It is time for Dhuhr",
      primaryCopy: "Tap to open Solatify and view today’s prayer schedule.",
      adhanLabel: "Optional Adhan",
      adhanTitle: "Automatic adhan playback",
      adhanCopy: "Turn it on or off yourself. On Android the full adhan plays once, with a Stop adhan button in the notification. On iPhone the notification plays the first 29 seconds, and the full adhan plays when Solatify is open or you tap the notification."
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
      copy: "Android APK is available now as release candidate v1.0.0-rc5. iOS coming soon."
    },
    faqSection: {
      eyebrow: "FAQ",
      title: "FAQ"
    },
    features: [
      {
        icon: "🕌",
        title: "Accurate prayer times",
        description:
          "Calculated for your location in the right WIB, WITA, or WIT zone, with six methods including Kemenag and offsets for your local mosque."
      },
      {
        icon: "🔔",
        title: "Prayer time notifications",
        description:
          "Alerts at each prayer time, scheduled six days ahead, with an optional adhan you switch on or off yourself."
      },
      {
        icon: "🎧",
        title: "Qur’an recitation in the background",
        description:
          "Listen verse by verse or a whole surah by Mishary Alafasy. It keeps playing with a mini player and lock screen controls."
      },
      {
        icon: "📖",
        title: "Qur’an reading",
        description:
          "Read with adjustable Arabic text, transliteration, Indonesian or English translation, bookmarks, and your last read position."
      },
      {
        icon: "🧭",
        title: "Qibla direction",
        description:
          "A true north compass on Android and iPhone, even on phones without a gyroscope, with a calibration hint when needed."
      },
      {
        icon: "📍",
        title: "Nearby mosques",
        description: "Find mosques within 5 km, usually in about a second, with addresses and map directions. Your last results stay available when map servers are busy."
      },
      {
        icon: "🤲",
        title: "Duas and dhikr",
        description:
          "Full morning and evening dhikr including Ayat Kursi, with counters kept for the day, plus daily duas, Asmaul Husna, and Islamic tips."
      },
      {
        icon: "🌙",
        title: "Hijri calendar",
        description:
          "Upcoming Islamic holidays based on the Umm al Qura calendar, always showing the next dates."
      },
      {
        icon: "✅",
        title: "Worship tracker and widget",
        description:
          "Track prayers with a 14 day heatmap and a streak that keeps counting, and see the next prayer on a home screen widget for Android and iPhone."
      }
    ],
    advantages: [
      {
        title: "You stay in control",
        description: "Turn the adhan, reminders, and each prayer notification on or off yourself. Nothing is forced."
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
          "Yes. Choose a reminder 5, 10, or 15 minutes before prayer in Settings, and turn it on or off for each prayer. The reminder uses a short sound and says how many minutes are left. Notifications need your device’s notification permission."
      },
      {
        question: "Does adhan work on iOS and Android?",
        answer:
          "Yes, if you turn it on. On Android the full adhan plays once at prayer time, with a Stop adhan button in the notification. iPhone limits notification sounds to 30 seconds, so the notification plays the first 29 seconds; the full adhan plays when Solatify is open or when you tap the notification within 15 minutes."
      },
      {
        question: "Can I use Solatify offline?",
        answer:
          "Prayer times, notifications, dhikr, duas, the Hijri calendar, and the tracker work offline. Surahs you have opened stay available. Recitation audio, mosque search, and loading a surah for the first time need internet."
      },
      {
        question: "Is Solatify available in Indonesian and English?",
        answer:
          "Yes. Choose Indonesian or English in Settings. Prayer times follow the WIB, WITA, and WIT zones and default to the Kemenag method. Some duas, tips, and dhikr notes are still only in Indonesian."
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
          "Yes. Solatify lists mosques within 5 km from OpenStreetMap, usually in about a second, nearest first, with the address and a route button for your maps app. Your last results stay available when you are offline."
      },
      {
        question: "Can I keep listening to the Qur’an while using other apps?",
        answer:
          "Yes. Recitation keeps playing in the background and when the screen is locked. Control it from the mini player in the app or from the lock screen and notification."
      },
      {
        question: "Which prayer time calculation methods are available?",
        answer:
          "Kemenag RI (the default), Muslim World League, ISNA, Egyptian General Authority, Umm al Qura Makkah, and MUIS Singapore. Kemenag times include the official ihtiyat and match Kemenag's published schedule to within a minute. You can also adjust each prayer by a few minutes to match your local mosque; the app shows the resulting time before you save."
      },
      {
        question: "How do I install the Android APK?",
        answer:
          "Download the APK from the button on this page and allow installs from your browser when Android asks. This is release candidate v1.0.0-rc5, shared for testing ahead of the store release. Already have rc3 or rc4? Install rc5 over it; your data stays."
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
      copy: "Aplikasi Islami yang tenang untuk jadwal salat, adzan, murotal Qur’an, kiblat, masjid terdekat, dan tracker ibadah, dalam bahasa Indonesia atau Inggris.",
      statsLabel: "Keunggulan Solatify",
      stats: [
        { value: "5", label: "salat" },
        { value: "Adzan", label: "pengingat" },
        { value: "Light/Dark", label: "mode" }
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
      copy: "Mendukung mode terang dan gelap di dua platform.",
      iosLabel: "iPhone 16 Pro • Light",
      iosAlt: "Preview tema light Solatify di iPhone 16 Pro",
      androidLabel: "Pixel 7 • Dark",
      androidAlt: "Preview tema dark Solatify di Pixel 7"
    },
    phoneTabs: [
      {
        key: "home",
        label: "Android",
        src: "/screenshots/app-android-home.jpg",
        alt: "Tampilan home Solatify dengan salat berikutnya",
        title: "Preview Android",
        copy: "Jadwal, countdown, dan salat harian."
      },
      {
        key: "ios-home",
        label: "iOS",
        src: "/screenshots/app-ios-home.jpg",
        alt: "Tampilan home iOS Solatify dengan salat berikutnya",
        title: "Preview iOS",
        copy: "Tampilan bersih untuk rutinitas salat."
      },
      {
        key: "quran",
        label: "Qur’an",
        src: "/screenshots/app-ios-quran.jpg",
        alt: "Tampilan Qur’an iOS Solatify",
        title: "Qur’an",
        copy: "Baca dan jelajahi dengan nyaman."
      },
      {
        key: "mosque",
        label: "Masjid",
        src: "/screenshots/app-android-mosque.jpg",
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
        { number: "02", title: "Dapatkan jadwal", description: "Jadwal mengikuti zona waktu lokasimu dan diperbarui sendiri setiap hari, dengan offset yang bisa disesuaikan ke waktu masjid lokal." },
        { number: "03", title: "Aktifkan pengingat", description: "Dapatkan notifikasi di setiap waktu salat, tambah pengingat 5, 10, atau 15 menit sebelumnya, dan pilih adzan, bunyi beep singkat, atau notifikasi senyap." }
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
      { src: "/screenshots/app-ios-home.jpg", title: "Home Salat", label: "iOS", story: "" },
      { src: "/screenshots/app-ios-schedule.jpg", title: "Jadwal", label: "iOS", story: "" },
      { src: "/screenshots/app-ios-quran.jpg", title: "Qur’an", label: "iOS", story: "" },
      { src: "/screenshots/app-ios-mosque.jpg", title: "Masjid", label: "iOS", story: "" },
      { src: "/screenshots/app-android-home.jpg", title: "Home Salat", label: "Android", story: "" },
      { src: "/screenshots/app-android-quran.jpg", title: "Qur’an", label: "Android", story: "" },
      { src: "/screenshots/app-android-settings-adhan.jpg", title: "Pengaturan", label: "Android", story: "" },
      { src: "/screenshots/app-android-tracker.jpg", title: "Tracker", label: "Android", story: "" }
    ],
    mosqueSpotlight: {
      eyebrow: "Masjid Terdekat",
      title: "Temukan masjid terdekat dalam sekitar 1 detik.",
      copy: "Solatify menampilkan masjid dalam radius 5 km dari OpenStreetMap, urut dari yang terdekat, lengkap dengan alamat dan tombol rute ke aplikasi peta.",
      badge: "Terdekat",
      mosqueName: "Masjid Al-Ikhlas",
      distance: "650 m",
      address: "Jl. Cikini Raya, Menteng",
      source: "OpenStreetMap",
      action: "Rute",
      points: ["Urut dari yang terdekat, radius 5 km", "Alamat dan rute sekali ketuk", "Hasil terakhir tetap tampil saat offline"]
    },
    trust: {
      eyebrow: "Privasi & Trust",
      title: "Pengingat yang membantu tanpa terasa mengganggu.",
      copy: "Solatify hanya meminta izin yang dibutuhkan fitur, menjadwalkan notifikasi di HP-mu, dan setiap notifikasi bisa kamu matikan.",
      items: [
        { title: "Lokasi sesuai kebutuhan", description: "Lokasi dipakai untuk menghitung jadwal salat dan mencari masjid terdekat. Tidak ingin berbagi GPS? Pilih kotamu secara manual." },
        { title: "Kontrol notifikasi lokal", description: "Notifikasi salat dijadwalkan di HP-mu. Nyalakan atau matikan tiap waktu salat, pengingat, dan adzan di Pengaturan." },
        { title: "Datamu tetap di HP", description: "Catatan ibadah, bookmark, dan pengaturan disimpan di perangkatmu. Lokasi hanya dikirim ke layanan pencarian OpenStreetMap (Photon, dengan Overpass sebagai cadangan) saat kamu mencari masjid terdekat." }
      ]
    },
    notifications: {
      eyebrow: "Notifikasi Salat",
      title: "Tahu tepat saat waktu salat tiba.",
      copy:
        "Aktifkan notifikasi Solatify untuk menerima pemberitahuan saat setiap waktu salat dimulai. Notifikasi dijadwalkan enam hari ke depan, jadi tetap datang walau aplikasi tidak dibuka. Tambahkan pengingat 5, 10, atau 15 menit sebelumnya; pengingat memakai bunyi singkat dan menyebut sisa waktunya, jadi tidak terdengar seperti adzan.",
      examplesLabel: "Contoh notifikasi salat",
      primaryTime: "Sekarang",
      primaryTitle: "Waktu Dzuhur telah tiba",
      primaryCopy: "Ketuk untuk membuka Solatify dan melihat jadwal salat hari ini.",
      adhanLabel: "Adzan Opsional",
      adhanTitle: "Pemutaran adzan otomatis",
      adhanCopy: "Nyalakan atau matikan sendiri. Di Android adzan diputar penuh satu kali, dengan tombol Hentikan adzan di notifikasi. Di iPhone notifikasi memutar 29 detik pertama, dan adzan penuh diputar saat Solatify terbuka atau notifikasinya diketuk."
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
      copy: "APK Android sudah tersedia sebagai release candidate v1.0.0-rc5. iOS segera hadir."
    },
    faqSection: {
      eyebrow: "FAQ",
      title: "FAQ"
    },
    features: [
      {
        icon: "🕌",
        title: "Jadwal salat akurat",
        description:
          "Dihitung sesuai lokasimu dengan zona WIB, WITA, atau WIT yang tepat, enam metode termasuk Kemenag, dan offset untuk masjid lokal."
      },
      {
        icon: "🔔",
        title: "Notifikasi waktu salat",
        description:
          "Pengingat di setiap waktu salat, dijadwalkan enam hari ke depan, dengan adzan opsional yang bisa kamu nyalakan atau matikan sendiri."
      },
      {
        icon: "🎧",
        title: "Murotal di latar belakang",
        description:
          "Dengarkan per ayat atau satu surah penuh oleh Mishary Alafasy. Tetap berjalan dengan mini player dan kontrol di layar kunci."
      },
      {
        icon: "📖",
        title: "Baca Qur’an",
        description:
          "Baca dengan ukuran teks Arab yang bisa diatur, transliterasi, terjemahan bahasa Indonesia atau Inggris, bookmark, dan posisi terakhir dibaca."
      },
      {
        icon: "🧭",
        title: "Arah kiblat",
        description:
          "Kompas utara sejati di Android dan iPhone, tetap jalan di HP tanpa giroskop, dengan petunjuk kalibrasi saat dibutuhkan."
      },
      {
        icon: "📍",
        title: "Masjid terdekat",
        description:
          "Temukan masjid dalam radius 5 km, biasanya dalam sekitar 1 detik, lengkap dengan alamat dan rute peta. Hasil terakhir tetap tampil saat server peta sedang sibuk."
      },
      {
        icon: "🤲",
        title: "Doa dan dzikir",
        description:
          "Dzikir pagi dan petang lengkap termasuk Ayat Kursi, dengan hitungan yang tersimpan sepanjang hari, ditambah doa harian, Asmaul Husna, dan tips Islami."
      },
      {
        icon: "🌙",
        title: "Kalender Hijriah",
        description:
          "Hari besar Islam berdasarkan kalender Umm al Qura, selalu menampilkan tanggal berikutnya."
      },
      {
        icon: "✅",
        title: "Tracker ibadah dan widget",
        description:
          "Pantau salat dengan heatmap 14 hari dan streak yang terus terhitung, serta lihat salat berikutnya lewat widget layar utama di Android dan iPhone."
      }
    ],
    advantages: [
      {
        title: "Kamu yang memegang kendali",
        description: "Nyalakan atau matikan adzan, pengingat, dan notifikasi tiap waktu salat sendiri. Tidak ada yang dipaksakan."
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
          "Bisa. Pilih pengingat 5, 10, atau 15 menit sebelum salat di Pengaturan, lalu nyalakan atau matikan untuk tiap waktu salat. Pengingat memakai bunyi singkat dan menyebut sisa menitnya. Notifikasi membutuhkan izin notifikasi di perangkatmu."
      },
      {
        question: "Apakah adzan berjalan di iOS dan Android?",
        answer:
          "Ya, kalau kamu menyalakannya. Di Android adzan diputar penuh satu kali saat waktu salat, dengan tombol Hentikan adzan di notifikasi. iPhone membatasi suara notifikasi 30 detik, jadi notifikasi memutar 29 detik pertama; adzan penuh diputar saat Solatify terbuka atau saat notifikasinya diketuk dalam 15 menit."
      },
      {
        question: "Apakah Solatify bisa digunakan offline?",
        answer:
          "Jadwal salat, notifikasi, dzikir, doa, kalender Hijriah, dan tracker berjalan offline. Surah yang pernah dibuka tetap tersedia. Murotal, pencarian masjid, dan membuka surah pertama kali membutuhkan internet."
      },
      {
        question: "Apakah Solatify tersedia dalam bahasa Indonesia dan Inggris?",
        answer:
          "Ya. Pilih bahasa Indonesia atau Inggris di Pengaturan. Jadwal salat mengikuti zona WIB, WITA, dan WIT dengan metode Kemenag sebagai bawaan. Sebagian doa, tips, dan catatan dzikir masih hanya dalam bahasa Indonesia."
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
          "Ya. Solatify menampilkan masjid dalam radius 5 km dari OpenStreetMap, biasanya dalam sekitar 1 detik, urut dari yang terdekat, lengkap dengan alamat dan tombol rute ke aplikasi peta. Hasil terakhir tetap tampil saat kamu offline."
      },
      {
        question: "Apakah murotal tetap jalan saat memakai aplikasi lain?",
        answer:
          "Ya. Murotal tetap berjalan di latar belakang dan saat layar terkunci. Kendalikan lewat mini player di aplikasi atau dari layar kunci dan notifikasi."
      },
      {
        question: "Metode perhitungan jadwal salat apa saja yang tersedia?",
        answer:
          "Kemenag RI (bawaan), Muslim World League, ISNA, Egyptian General Authority, Umm al Qura Makkah, dan MUIS Singapura. Jadwal Kemenag sudah termasuk ihtiyat resmi dan sama dengan jadwal terbitan Kemenag dengan selisih paling banyak 1 menit. Setiap waktu salat juga bisa digeser beberapa menit agar sama dengan masjid lokal; aplikasi menampilkan jam hasilnya sebelum kamu menyimpan."
      },
      {
        question: "Bagaimana cara memasang APK Android?",
        answer:
          "Unduh APK dari tombol di halaman ini, lalu izinkan pemasangan dari browser saat Android memintanya. Ini release candidate v1.0.0-rc5 yang dibagikan untuk uji coba sebelum rilis di store. Sudah pasang rc3 atau rc4? Pasang rc5 langsung di atasnya, datamu tetap aman."
      }
    ]
  }
};
