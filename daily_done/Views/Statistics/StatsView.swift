import SwiftUI

struct StatsView: View {
    @StateObject private var vm = StatsViewModel()

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
