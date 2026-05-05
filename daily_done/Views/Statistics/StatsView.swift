import SwiftUI

struct StatsView: View {
//    @StateObject private var vm = StatsViewModel()
    init(service: FirebaseServiceProtocol? = nil) {
        _vm = StateObject(wrappedValue: StatsViewModel(service: service))
    }
    @StateObject private var vm: StatsViewModel

    var body: some View {
        contentView
            .navigationTitle("Statistics")
            .task {
                await vm.loadStats()
            }
            .alert(
                "Error",
                isPresented: Binding (
                    get: { vm.error != nil },
                    set: { if !$0 { vm.error = nil } }
                )
            ) {
                Button ("Retry") { Task { await vm.loadStats() } }
                Button ("Dismiss", role: .cancel) { vm.error = nil }
            } message : {
                Text(vm.error?.errorDescription ?? "")
            }
    }
    @ViewBuilder
    private var contentView: some View {
        if vm.isLoading {
            ProgressView("Loading stats...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if vm.weeklyStats.isEmpty {
            ContentUnavailableView(
                "No Data Yet",
                systemImage: "chart.bar",
                description: Text("Complete habits to see your weekly progress")
            )
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    Text("THIS WEEK")
                        .font(.caption)
                        .foregroundStyle(Color("textSecondary"))
                        .padding(.horizontal, DesignSystem.Spacing.base)
                    WeeklyChartView(stats: vm.weeklyStats)
                        .padding(.horizontal, DesignSystem.Spacing.base)
                    
                    Divider()
                         .padding(.horizontal, DesignSystem.Spacing.base)

                    
                     Text("THIS MONTH")
                         .font(.caption)
                         .foregroundStyle(Color("textSecondary"))
                         .padding(.horizontal, DesignSystem.Spacing.base)

                     MonthlyHeatmapView(stats: vm.monthlyStats)
                         .padding(.horizontal, DesignSystem.Spacing.base)
                }
                .padding(.top, DesignSystem.Spacing.base)
            }
            .background(Color("backgroundPrimary"))
        }
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
}
// Mock service that returns fake logs — no Firebase needed
private struct MockFirebaseService: FirebaseServiceProtocol {
    func fetchHabits(userId: String) async throws -> [Habit] { [] }
    func createHabit(_ habit: Habit) async throws {}
    func habitLogComplition(habitId: String, userId: String) async throws {}
    func fetchTodayLogs(userId: String) async throws -> [HabitLog] { [] }
    func deleteHabit(habitId: String, userId: String) async throws {}

    func fetchAllLogs(userId: String) async throws -> [HabitLog] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Simulate 2-3 completions most days this month, gaps on a few days
        let pattern = [2, 3, 1, 0, 2, 3, 2, 1, 3, 0, 2, 2, 1, 3, 2,
                       0, 1, 3, 2, 2, 1, 0, 3, 2, 1, 2, 3, 1, 2, 3]

        return pattern.enumerated().flatMap { offset, count in
            let date = calendar.date(byAdding: .day, value: -(29 - offset), to: today)!
            return (0..<count).map { _ in
                HabitLog(id: UUID().uuidString, habitId: "habit-1",
                         userId: "preview", completedAt: date, location: nil)
            }
        }
    }
}

#Preview("Stats — with data") {
    NavigationStack {
        StatsView(service: MockFirebaseService())
    }
}
