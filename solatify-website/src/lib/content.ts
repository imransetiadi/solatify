export type Locale = "en" | "id";

export const storeLinks = {
  android: "https://github.com/imransetiadi/solatify/releases/download/v1.0.0-rc3/solatify-1.0.0.apk"
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
      copy: "A calm Islamic app for prayer times, adhan, Qur’an recitation, Qibla, and worship tracking.",
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
        { number: "02", title: "Get prayer times", description: "Schedules follow your local time zone and update on their own each day, with offsets you can align to your local mosque." },
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
        { title: "Your data stays on your phone", description: "Prayer logs, bookmarks, and settings are stored on your device. Your location is only sent to OpenStreetMap when you search for nearby mosques." }
      ]
    },
    notifications: {
      eyebrow: "Prayer Notifications",
      title: "Know exactly when prayer time arrives.",
      copy:
        "Enable Solatify notifications to get an alert as each prayer time begins. Reminders are scheduled six days ahead, so they keep arriving even when you do not open the app. Keep them subtle, open Solatify from the notification, or let the adhan play when your device permission and app setting allow it.",
      examplesLabel: "Prayer notification examples",
      primaryTime: "Now",
      primaryTitle: "It is time for Dhuhr",
      primaryCopy: "Tap to open Solatify and view today’s prayer schedule.",
      adhanLabel: "Optional Adhan",
      adhanTitle: "Automatic adhan playback",
      adhanCopy: "Turn it on or off yourself. On Android, a Stop adhan button sits right in the notification."
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
      copy: "Android APK is available now as release candidate v1.0.0-rc3. iOS coming soon."
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
          "Read with adjustable Arabic text, transliteration, translation, bookmarks, and your last read position."
      },
      {
        icon: "🧭",
        title: "Qibla direction",
        description:
          "A compass that points to true north, with a calibration hint when the sensor needs it."
      },
      {
        icon: "📍",
        title: "Nearby mosques",
        description: "Find mosques around you with map directions. Your last results stay available when map servers are busy."
      },
      {
        icon: "🤲",
        title: "Duas and dhikr",
        description:
          "Full morning and evening dhikr including Ayat Kursi, plus daily duas, Asmaul Husna, and Islamic tips."
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
          "Track prayers with a 14 day heatmap and streak, and see the next prayer on a home screen widget."
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
          "Yes. Choose a reminder before prayer in Settings, and turn reminders on or off for each prayer. Notifications need your device’s notification permission."
      },
      {
        question: "Does adhan work on iOS and Android?",
        answer:
          "Adhan playback is optional and depends on each platform’s notification permission, sound mode, and app settings. Solatify keeps those controls clear for users."
      },
      {
        question: "Can I use Solatify offline?",
        answer:
          "Prayer times, notifications, dhikr, duas, the Hijri calendar, and the tracker work offline. Surahs you have opened stay available. Recitation audio, mosque search, and loading a surah for the first time need internet."
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
      },
      {
        question: "Can I keep listening to the Qur’an while using other apps?",
        answer:
          "Yes. Recitation keeps playing in the background and when the screen is locked. Control it from the mini player in the app or from the lock screen and notification."
      },
      {
        question: "Which prayer time calculation methods are available?",
        answer:
          "Kemenag RI (the default), Muslim World League, ISNA, Egyptian General Authority, Umm al Qura Makkah, and MUIS Singapore. You can also adjust each prayer by a few minutes to match your local mosque."
      },
      {
        question: "How do I install the Android APK?",
        answer:
          "Download the APK from the button on this page and allow installs from your browser when Android asks. This is release candidate v1.0.0-rc3, shared for testing ahead of the store release."
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
      copy: "Aplikasi Islami yang tenang untuk jadwal salat, adzan, murotal Qur’an, kiblat, dan tracker ibadah.",
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
        { number: "02", title: "Dapatkan jadwal", description: "Jadwal mengikuti zona waktu lokasimu dan diperbarui sendiri setiap hari, dengan offset yang bisa disesuaikan ke waktu masjid lokal." },
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
        { title: "Datamu tetap di HP", description: "Catatan ibadah, bookmark, dan pengaturan disimpan di perangkatmu. Lokasi hanya dikirim ke OpenStreetMap saat kamu mencari masjid terdekat." }
      ]
    },
    notifications: {
      eyebrow: "Notifikasi Salat",
      title: "Tahu tepat saat waktu salat tiba.",
      copy:
        "Aktifkan notifikasi Solatify untuk menerima pengingat saat setiap waktu salat dimulai. Pengingat dijadwalkan enam hari ke depan, jadi tetap datang walau aplikasi tidak dibuka. Kamu bisa membuat pengingat tetap ringan, membuka Solatify dari notifikasi, atau membiarkan adzan diputar saat izin perangkat dan pengaturan aplikasi mengizinkan.",
      examplesLabel: "Contoh notifikasi salat",
      primaryTime: "Sekarang",
      primaryTitle: "Waktu Dzuhur telah tiba",
      primaryCopy: "Ketuk untuk membuka Solatify dan melihat jadwal salat hari ini.",
      adhanLabel: "Adzan Opsional",
      adhanTitle: "Pemutaran adzan otomatis",
      adhanCopy: "Nyalakan atau matikan sendiri. Di Android, tombol Hentikan adzan ada langsung di notifikasi."
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
      copy: "APK Android sudah tersedia sebagai release candidate v1.0.0-rc3. iOS segera hadir."
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
          "Baca dengan ukuran teks Arab yang bisa diatur, transliterasi, terjemahan, bookmark, dan posisi terakhir dibaca."
      },
      {
        icon: "🧭",
        title: "Arah kiblat",
        description:
          "Kompas yang mengacu ke utara sejati, dengan petunjuk kalibrasi saat sensor membutuhkannya."
      },
      {
        icon: "📍",
        title: "Masjid terdekat",
        description:
          "Temukan masjid di sekitarmu lengkap dengan rute peta. Hasil terakhir tetap tampil saat server peta sedang sibuk."
      },
      {
        icon: "🤲",
        title: "Doa dan dzikir",
        description:
          "Dzikir pagi dan petang lengkap termasuk Ayat Kursi, ditambah doa harian, Asmaul Husna, dan tips Islami."
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
          "Pantau salat dengan heatmap 14 hari dan streak, serta lihat salat berikutnya lewat widget layar utama."
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
          "Bisa. Pilih pengingat sebelum salat di Pengaturan, dan nyalakan atau matikan pengingat untuk tiap waktu salat. Notifikasi membutuhkan izin notifikasi di perangkatmu."
      },
      {
        question: "Apakah adzan berjalan di iOS dan Android?",
        answer:
          "Adzan bersifat opsional dan bergantung pada izin notifikasi, mode suara perangkat, serta pengaturan aplikasi di masing-masing platform. Solatify membuat kontrolnya jelas."
      },
      {
        question: "Apakah Solatify bisa digunakan offline?",
        answer:
          "Jadwal salat, notifikasi, dzikir, doa, kalender Hijriah, dan tracker berjalan offline. Surah yang pernah dibuka tetap tersedia. Murotal, pencarian masjid, dan membuka surah pertama kali membutuhkan internet."
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
      },
      {
        question: "Apakah murotal tetap jalan saat memakai aplikasi lain?",
        answer:
          "Ya. Murotal tetap berjalan di latar belakang dan saat layar terkunci. Kendalikan lewat mini player di aplikasi atau dari layar kunci dan notifikasi."
      },
      {
        question: "Metode perhitungan jadwal salat apa saja yang tersedia?",
        answer:
          "Kemenag RI (bawaan), Muslim World League, ISNA, Egyptian General Authority, Umm al Qura Makkah, dan MUIS Singapura. Setiap waktu salat juga bisa digeser beberapa menit agar sama dengan masjid lokal."
      },
      {
        question: "Bagaimana cara memasang APK Android?",
        answer:
          "Unduh APK dari tombol di halaman ini, lalu izinkan pemasangan dari browser saat Android memintanya. Ini release candidate v1.0.0-rc3 yang dibagikan untuk uji coba sebelum rilis di store."
      }
    ]
  }
};
