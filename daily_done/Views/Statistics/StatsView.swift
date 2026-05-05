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
                isPresented: Binding(
                    get: { vm.error != nil },
                    set: { if !$0 { vm.error = nil } }
                )
            ) {
                Button("Retry") { Task { await vm.loadStats() } }
                Button("Dismiss", role: .cancel) { vm.error = nil }
            } message: {
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

                    if !vm.habitStats.isEmpty {
                        Divider()
                            .padding(.horizontal, DesignSystem.Spacing.base)

                        Text("HABIT STREAKS")
                            .font(.caption)
                            .foregroundStyle(Color("textSecondary"))
                            .padding(.horizontal, DesignSystem.Spacing.base)

                        VStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(vm.habitStats) { habit in
                                HabitStreakRow(habit: habit)
                                    .padding(
                                        .horizontal,
                                        DesignSystem.Spacing.base
                                    )
                            }
                        }
                    }
                }
                .padding(.top, DesignSystem.Spacing.base)
            }
            .background(Color("backgroundPrimary"))
        }
    }
}

private struct HabitStreakRow: View {
    let habit: Habit

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.base) {
            Circle()
                .fill(Color(hex: habit.colorHex))
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: habit.iconName)
                        .foregroundStyle(.white)
                        .font(.system(size: 16, weight: .medium))
                )

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(habit.name)
                    .font(.headline)
                HStack(spacing: DesignSystem.Spacing.base) {
                    Label("\(habit.currentStreak)", systemImage: "flame.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                    Text("Best: \(habit.longestStreak)")
                        .font(.caption)
                        .foregroundStyle(Color("textSecondary"))
                    Text("Total: \(habit.totalCompletions)")
                        .font(.caption)
                        .foregroundStyle(Color("textSecondary"))
                }
            }

            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            Color("neutral-light").opacity(0.5),
            in: RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
        )
    }
}

#Preview {
    NavigationStack {
        StatsView()
    }
}
// Mock service that returns fake logs — no Firebase needed
private struct MockFirebaseService: FirebaseServiceProtocol {
    func fetchHabits(userId: String) async throws -> [Habit] {
        [
            Habit(
                id: "habit-1",
                userId: userId,
                name: "Morning Run",
                category: .fitness,
                colorHex: "#FF6B35",
                iconName: "figure.run",
                createdAt: Date(),
                currentStreak: 0,
                longestStreak: 0,
                totalCompletions: 0
            ),
            Habit(
                id: "habit-2",
                userId: userId,
                name: "Read 20 min",
                category: .learning,
                colorHex: "#7B61FF",
                iconName: "book.fill",
                createdAt: Date(),
                currentStreak: 0,
                longestStreak: 0,
                totalCompletions: 0
            ),
        ]
    }
    func createHabit(_ habit: Habit) async throws {}
    func habitLogComplition(habitId: String, userId: String) async throws {}
    func fetchTodayLogs(userId: String) async throws -> [HabitLog] { [] }
    func deleteHabit(habitId: String, userId: String) async throws {}

    func fetchAllLogs(userId: String) async throws -> [HabitLog] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Simulate 2-3 completions most days this month, gaps on a few days
        let pattern = [
            2, 3, 1, 0, 2, 3, 2, 1, 3, 0, 2, 2, 1, 3, 2,
            0, 1, 3, 2, 2, 1, 0, 3, 2, 1, 2, 3, 1, 2, 3,
        ]

        return pattern.enumerated().flatMap { offset, count in
            let date = calendar.date(
                byAdding: .day,
                value: -(29 - offset),
                to: today
            )!
            return (0..<count).map { _ in
                HabitLog(
                    id: UUID().uuidString,
                    habitId: "habit-1",
                    userId: "preview",
                    completedAt: date,
                    location: nil
                )
            }
        }
    }
}

#Preview("Stats — with data") {
    NavigationStack {
        StatsView(service: MockFirebaseService())
    }
}
