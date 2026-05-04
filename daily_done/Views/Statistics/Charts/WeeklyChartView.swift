import Charts
import SwiftUI

struct WeeklyChartView: View {
    let stats: [DayStat]

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"  // Bra Att veta ! -> "EEE" is just a secret code telling DateFormatter: "give me the 3-letter abbreviation of the weekday".
        return formatter
    }()

    var body: some View {
        Chart(stats) { stat in
            BarMark(
                x: .value("Day", dayFormatter.string(from: stat.id)),
                y: .value("Completions", stat.count)
            )
            .foregroundStyle(Color("brandPrimary"))
            .accessibilityLabel(dayFormatter.string(from: stat.id))
            .accessibilityValue("\(stat.count) completions")
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .automatic) { value in
                AxisValueLabel()
                    .foregroundStyle(Color("textSecondary"))
            }
        }
        .frame(height: 200)
    }
}

#Preview {
    WeeklyChartView(
        stats: (0..<7).map { i in
            DayStat(
                id: Calendar.current.date(
                    byAdding: .day,
                    value: -i,
                    to: Date()
                )!,
                count: Int.random(in: 0...5)
            )
        }.reversed()
    )
    .padding()
}
