import SwiftUI

@main
struct WorldClocksApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var timer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create status bar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clock.fill", accessibilityDescription: "World Clocks")
            button.action = #selector(togglePopover)
            button.target = self
        }

        // Create popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 450, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ClockView())

        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
    }

    @objc func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                popover?.performClose(nil)
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

struct TimeZone: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var identifier: String

    init(id: UUID = UUID(), name: String, identifier: String) {
        self.id = id
        self.name = name
        self.identifier = identifier
    }
}

class TimeZoneStore: ObservableObject {
    @Published var timeZones: [TimeZone] {
        didSet {
            saveTimeZones()
        }
    }

    private let key = "savedTimeZones"

    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([TimeZone].self, from: data) {
            self.timeZones = decoded
        } else {
            self.timeZones = [
                TimeZone(name: "CHILE", identifier: "America/Santiago"),
                TimeZone(name: "PACIFIC", identifier: "America/Los_Angeles"),
                TimeZone(name: "EAST COAST", identifier: "America/New_York")
            ]
        }
    }

    private func saveTimeZones() {
        if let encoded = try? JSONEncoder().encode(timeZones) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

struct ClockView: View {
    @StateObject private var store = TimeZoneStore()
    @State private var currentTime = Date()
    @State private var showConverter = false
    @State private var showAddTimezone = false
    @State private var selectedZone = "America/Santiago"
    @State private var inputHour = ""
    @State private var inputMinute = ""
    @State private var searchText = ""
    @State private var selectedTimezoneId = "America/Santiago"

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let popularTimezones: [(name: String, identifier: String)] = [
        ("Tokyo", "Asia/Tokyo"),
        ("Hong Kong", "Asia/Hong_Kong"),
        ("Singapore", "Asia/Singapore"),
        ("Dubai", "Asia/Dubai"),
        ("Moscow", "Europe/Moscow"),
        ("London", "Europe/London"),
        ("Paris", "Europe/Paris"),
        ("Berlin", "Europe/Berlin"),
        ("Madrid", "Europe/Madrid"),
        ("New York", "America/New_York"),
        ("Los Angeles", "America/Los_Angeles"),
        ("Chicago", "America/Chicago"),
        ("Mexico City", "America/Mexico_City"),
        ("São Paulo", "America/Sao_Paulo"),
        ("Buenos Aires", "America/Argentina/Buenos_Aires"),
        ("Santiago", "America/Santiago"),
        ("Sydney", "Australia/Sydney"),
        ("Melbourne", "Australia/Melbourne"),
        ("Auckland", "Pacific/Auckland")
    ]

    var filteredTimezones: [(name: String, identifier: String)] {
        if searchText.isEmpty {
            return popularTimezones
        }
        return popularTimezones.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.identifier.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    ForEach(store.timeZones) { tz in
                        VStack(spacing: 8) {
                            HStack(spacing: 4) {
                                Text(tz.name)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .tracking(2)

                                Button(action: {
                                    store.timeZones.removeAll { $0.id == tz.id }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                                .opacity(0.6)
                            }

                            Text(timeString(for: tz.identifier))
                                .font(.system(size: 32, weight: .light, design: .default))
                                .monospacedDigit()
                        }
                    }

                    Button(action: {
                        showAddTimezone.toggle()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)

                            Text("Add")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 10)
                }
                .padding(.horizontal, 30)
            }
            .padding(.vertical, 30)
            .onReceive(timer) { _ in
                currentTime = Date()
            }

            if showAddTimezone {
                VStack(spacing: 8) {
                    TextField("Search timezone...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 250)
                        .padding(.horizontal, 20)

                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(filteredTimezones, id: \.identifier) { tz in
                                Button(action: {
                                    store.timeZones.append(TimeZone(name: tz.name.uppercased(), identifier: tz.identifier))
                                    searchText = ""
                                    showAddTimezone = false
                                }) {
                                    HStack {
                                        Text(tz.name)
                                            .font(.system(size: 12))
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(tz.identifier)
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                }
                                .buttonStyle(.plain)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(4)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(height: 150)

                    Button("Cancel") {
                        showAddTimezone = false
                        searchText = ""
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom, 8)
                }
                .padding(.bottom, 10)
            }

            Divider()

            VStack(spacing: 12) {
                Button(action: {
                    showConverter.toggle()
                }) {
                    HStack {
                        Image(systemName: "clock.arrow.2.circlepath")
                        Text("Time Converter")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.primary)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)

                if showConverter {
                    VStack(spacing: 10) {
                        HStack(spacing: 8) {
                            Picker("", selection: $selectedZone) {
                                ForEach(store.timeZones) { tz in
                                    Text(tz.name).tag(tz.identifier)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 120)

                            TextField("HH", text: $inputHour)
                                .frame(width: 35)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.center)

                            Text(":")

                            TextField("MM", text: $inputMinute)
                                .frame(width: 35)
                                .textFieldStyle(.roundedBorder)
                                .multilineTextAlignment(.center)
                        }
                        .font(.system(size: 11))

                        if let convertedDate = getConvertedDate() {
                            VStack(spacing: 6) {
                                ForEach(store.timeZones) { tz in
                                    HStack {
                                        Text(tz.name)
                                            .font(.system(size: 10, weight: .medium))
                                            .foregroundColor(.secondary)
                                            .frame(width: 80, alignment: .leading)
                                        Text(timeString(for: tz.identifier, date: convertedDate))
                                            .font(.system(size: 14, weight: .medium))
                                            .monospacedDigit()
                                    }
                                }
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 12)
        }
    }

    func timeString(for identifier: String, date: Date? = nil) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = Foundation.TimeZone(identifier: identifier)
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date ?? currentTime)
    }

    func getConvertedDate() -> Date? {
        guard let hour = Int(inputHour), let minute = Int(inputMinute),
              hour >= 0, hour < 24, minute >= 0, minute < 60,
              let timeZone = Foundation.TimeZone(identifier: selectedZone) else {
            return nil
        }

        var calendar = Calendar.current
        calendar.timeZone = timeZone

        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute

        return calendar.date(from: components)
    }
}
