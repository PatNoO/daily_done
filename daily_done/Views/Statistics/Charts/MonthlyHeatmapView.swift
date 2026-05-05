import SwiftUI

struct MonthlyHeatmapView: View {
    let stats: [DayStat]

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 4),
        count: 7
    )

    private var maxCount: Int {
        stats.map(\.count).max() ?? 1
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(paddedDays) { entry in
                RoundedRectangle(cornerRadius: 4)
                    .fill(cellColor(for: entry))
                    .aspectRatio(1, contentMode: .fit)
                    .accessibilityLabel(entry.label)
                    .accessibilityValue(entry.valueLabel)
            }
        }
    }

    private var paddedDays: [GridCell] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let components = calendar.dateComponents([.year, .month], from: today)
        guard let firstOfMonth = calendar.date(from: components) else {
            return []
        }

        let iOSWeekday = calendar.component(.weekday, from: firstOfMonth)
        let startOffset = (iOSWeekday + 5) % 7

        var cells: [GridCell] = []

        for _ in 0..<startOffset {
            cells.append(.init(date: nil, count: 0))
        }

        for stat in stats {
            if stat.id <= today {
                cells.append(GridCell(date: stat.id, count: stat.count))
            }
        }
        return cells
    }

    private func cellColor(for entry: GridCell) -> Color {
        guard entry.date != nil else {
            return Color.clear
        }
        if entry.count == 0 {
            return Color("neutral-light").opacity(0.5)
        }
        let intensity = Double(entry.count) / Double(max(maxCount, 1))
        return Color("brandPrimary").opacity(0.25 + intensity * 0.75)
    }
}

private struct GridCell: Identifiable {
    let id = UUID()
    let date: Date?
    let count: Int

    var label: String {
        guard let date else { return "Empty" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var valueLabel: String {
        count == 0
            ? "No completions" : "\(count) completion\(count == 1 ? "" : "s")"
    }
}

#Preview {
    MonthlyHeatmapView(
        stats: (0..<30).map { i in
            DayStat(
                id: Calendar.current.date(
                    byAdding: .day,
                    value: -(29 - i),
                    to: Date()
                )!,
                count: Int.random(in: 0...4)
            )
        }
    )
    .padding()
}
