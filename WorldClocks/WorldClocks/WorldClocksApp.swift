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
        popover?.contentSize = NSSize(width: 400, height: 250)
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

struct ClockView: View {
    @State private var currentTime = Date()
    @State private var showConverter = false
    @State private var selectedZone = "America/Santiago"
    @State private var inputHour = ""
    @State private var inputMinute = ""

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    let timeZones: [(name: String, identifier: String)] = [
        ("CHILE", "America/Santiago"),
        ("PACIFIC", "America/Los_Angeles"),
        ("EAST COAST", "America/New_York")
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 30) {
                ForEach(timeZones, id: \.identifier) { tz in
                    VStack(spacing: 8) {
                        Text(tz.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                            .tracking(2)

                        Text(timeString(for: tz.identifier))
                            .font(.system(size: 32, weight: .light, design: .default))
                            .monospacedDigit()

                        Text(dateString(for: tz.identifier))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(30)
            .onReceive(timer) { _ in
                currentTime = Date()
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
                                ForEach(timeZones, id: \.identifier) { tz in
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
                                ForEach(timeZones, id: \.identifier) { tz in
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
        formatter.timeZone = TimeZone(identifier: identifier)
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date ?? currentTime)
    }

    func dateString(for identifier: String) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: identifier)
        formatter.locale = Locale(identifier: "es_CL")
        formatter.dateFormat = "EEE, d MMM"
        return formatter.string(from: currentTime).lowercased()
    }

    func getConvertedDate() -> Date? {
        guard let hour = Int(inputHour), let minute = Int(inputMinute),
              hour >= 0, hour < 24, minute >= 0, minute < 60,
              let timeZone = TimeZone(identifier: selectedZone) else {
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
