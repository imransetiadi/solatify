import SwiftUI
import WidgetKit

private let appGroupIdentifier = "group.com.solatify.app.solatify"

struct PrayerWidgetData {
    let nextPrayerName: String
    let nextPrayerTimeLabel: String
    let countdownLabel: String
    let locationLabel: String
    let hijriLabel: String

    static let placeholder = PrayerWidgetData(
        nextPrayerName: "Magrib",
        nextPrayerTimeLabel: "18:04",
        countdownLabel: "00:12:30",
        locationLabel: "Jakarta, Indonesia",
        hijriLabel: "Jadwal salat hari ini"
    )

    static func fromDefaults() -> PrayerWidgetData {
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        return PrayerWidgetData(
            nextPrayerName: defaults?.string(forKey: "nextPrayerName") ?? "-",
            nextPrayerTimeLabel: defaults?.string(forKey: "nextPrayerTimeLabel") ?? "--:--",
            countdownLabel: defaults?.string(forKey: "countdownLabel") ?? "--:--",
            locationLabel: defaults?.string(forKey: "locationLabel") ?? "Solatify",
            hijriLabel: defaults?.string(forKey: "hijriLabel") ?? "Jadwal salat"
        )
    }
}

struct PrayerWidgetEntry: TimelineEntry {
    let date: Date
    let data: PrayerWidgetData
}

struct PrayerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerWidgetEntry {
        PrayerWidgetEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrayerWidgetEntry) -> Void) {
        completion(PrayerWidgetEntry(date: Date(), data: .fromDefaults()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerWidgetEntry>) -> Void) {
        let entry = PrayerWidgetEntry(date: Date(), data: .fromDefaults())
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
}

struct SolatifyPrayerWidgetView: View {
    let entry: PrayerWidgetEntry

    var body: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [Color(red: 0.10, green: 0.22, blue: 0.19), Color(red: 0.06, green: 0.13, blue: 0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            VStack(alignment: .leading, spacing: 6) {
                Text("Solatify")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 0.97, green: 0.82, blue: 0.54))
                Text(entry.data.hijriLabel)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.78))
                    .lineLimit(1)
                Spacer(minLength: 4)
                Text(entry.data.nextPrayerName)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(entry.data.nextPrayerTimeLabel)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color(red: 0.97, green: 0.82, blue: 0.54))
                Text(entry.data.countdownLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))
                    .lineLimit(1)
                Text(entry.data.locationLabel)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.68))
                    .lineLimit(1)
            }
            .padding(16)
        }
    }
}

@main
struct SolatifyPrayerWidget: Widget {
    let kind = "SolatifyPrayerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerWidgetProvider()) { entry in
            SolatifyPrayerWidgetView(entry: entry)
        }
        .configurationDisplayName("Solatify Prayer")
        .description("Jadwal salat berikutnya dari Solatify.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
