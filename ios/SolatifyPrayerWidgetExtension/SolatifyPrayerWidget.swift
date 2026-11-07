import SwiftUI
import WidgetKit

private let appGroupIdentifier = "group.com.solatify.app.solatify"

/// One prayer from the schedule synced by the app.
struct PrayerSlot {
    let name: String
    let date: Date
    /// Clock time in the prayer location's timezone, formatted by the app.
    let timeLabel: String

    /// Parses `name|epochMillis|HH:mm` entries joined by `;`.
    static func parse(_ raw: String?) -> [PrayerSlot] {
        guard let raw = raw, !raw.isEmpty else { return [] }
        return raw.split(separator: ";").compactMap { entry in
            let parts = entry.split(separator: "|", omittingEmptySubsequences: false)
            guard parts.count == 3, let millis = Double(parts[1]) else { return nil }
            return PrayerSlot(
                name: String(parts[0]),
                date: Date(timeIntervalSince1970: millis / 1000),
                timeLabel: String(parts[2])
            )
        }
        .sorted { $0.date < $1.date }
    }
}

struct PrayerWidgetData {
    let nextPrayerName: String
    let nextPrayerTimeLabel: String
    /// When set, the view shows a live system countdown to this date.
    let countdownTarget: Date?
    let fallbackCountdownLabel: String
    let locationLabel: String
    let hijriLabel: String

    static let placeholder = PrayerWidgetData(
        nextPrayerName: "Magrib",
        nextPrayerTimeLabel: "18:04",
        countdownTarget: Date().addingTimeInterval(45 * 60),
        fallbackCountdownLabel: "00:45:00",
        locationLabel: "Jakarta, Indonesia",
        hijriLabel: "Jadwal salat hari ini"
    )

    func showing(_ slot: PrayerSlot) -> PrayerWidgetData {
        PrayerWidgetData(
            nextPrayerName: slot.name,
            nextPrayerTimeLabel: slot.timeLabel,
            countdownTarget: slot.date,
            fallbackCountdownLabel: slot.timeLabel,
            locationLabel: locationLabel,
            hijriLabel: hijriLabel
        )
    }
}

struct StoredWidgetState {
    let base: PrayerWidgetData
    let slots: [PrayerSlot]

    static func load() -> StoredWidgetState {
        let defaults = UserDefaults(suiteName: appGroupIdentifier)
        let base = PrayerWidgetData(
            nextPrayerName: defaults?.string(forKey: "nextPrayerName") ?? "-",
            nextPrayerTimeLabel: defaults?.string(forKey: "nextPrayerTimeLabel") ?? "--:--",
            countdownTarget: nil,
            fallbackCountdownLabel: defaults?.string(forKey: "countdownLabel") ?? "--:--",
            locationLabel: defaults?.string(forKey: "locationLabel") ?? "Solatify",
            hijriLabel: defaults?.string(forKey: "hijriLabel") ?? "Jadwal salat"
        )
        return StoredWidgetState(
            base: base,
            slots: PrayerSlot.parse(defaults?.string(forKey: "schedule"))
        )
    }

    /// What the widget should show at [date]: the next prayer after it, or the
    /// stored labels (without a countdown) once the synced schedule ran out.
    func data(at date: Date) -> PrayerWidgetData {
        guard let next = slots.first(where: { $0.date > date }) else { return base }
        return base.showing(next)
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
        let now = Date()
        completion(PrayerWidgetEntry(date: now, data: StoredWidgetState.load().data(at: now)))
    }

    /// One entry now plus one at each upcoming prayer time, so the widget
    /// moves to the next prayer on its own while the app is closed.
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerWidgetEntry>) -> Void) {
        let now = Date()
        let state = StoredWidgetState.load()
        var entries = [PrayerWidgetEntry(date: now, data: state.data(at: now))]
        for slot in state.slots where slot.date > now {
            entries.append(PrayerWidgetEntry(date: slot.date, data: state.data(at: slot.date)))
        }
        // Once the synced schedule is used up, check again periodically until
        // the app syncs a new one.
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: entries.last?.date ?? now) ?? now
        completion(Timeline(entries: entries, policy: .after(refresh)))
    }
}

private let widgetGradient = LinearGradient(
    colors: [Color(red: 0.10, green: 0.22, blue: 0.19), Color(red: 0.06, green: 0.13, blue: 0.12)],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)

extension View {
    /// iOS 17+ requires `containerBackground`; without it the widget shows a
    /// "Please adopt containerBackground API" placeholder. iOS 17 also adds
    /// its own content margins, so the manual padding is only for older iOS.
    @ViewBuilder
    func solatifyWidgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.containerBackground(for: .widget) { widgetGradient }
        } else {
            self.padding(16).background(widgetGradient)
        }
    }
}

struct SolatifyPrayerWidgetView: View {
    let entry: PrayerWidgetEntry

    var body: some View {
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
            Group {
                if let target = entry.data.countdownTarget {
                    // Rendered and updated by the system every second.
                    Text(target, style: .timer)
                } else {
                    Text(entry.data.fallbackCountdownLabel)
                }
            }
            .font(.subheadline.weight(.semibold).monospacedDigit())
            .foregroundStyle(.white.opacity(0.92))
            .lineLimit(1)
            Text(entry.data.locationLabel)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.68))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .solatifyWidgetBackground()
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
