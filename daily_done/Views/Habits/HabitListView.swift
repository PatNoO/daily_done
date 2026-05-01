import SwiftUI

struct HabitListView: View {
    @StateObject private var vm = HabitViewModel()
    @State private var showCreateSheet = false

    var body: some View {
        contentView
            .navigationTitle("Daily Done")
            .toolbar { toolbarContent }
            .sheet(isPresented: $showCreateSheet) {
                CreateHabitSheet(vm: vm)
            }
            .task {
                await vm.loadHabits()

            }
            .alert(
                "Error",
                isPresented: Binding(
                    get: { vm.error != nil },
                    set: { if !$0 { vm.error = nil } }
                )
            ) {
                Button("Retry") { Task { await vm.loadHabits() } }
                Button("Dismiss", role: .cancel) { vm.error = nil }
            } message: {
                Text(vm.error?.errorDescription ?? "")
            }

    }

    @ViewBuilder
    private var contentView: some View {
        if vm.isLoading {
            ProgressView("Loading habits..")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if vm.habits.isEmpty {
            ContentUnavailableView(
                "No Habits Yet",
                systemImage: "checkmark.circle",
                description: Text("Tap + to add your first habit")
            )
        } else {
            habitList
        }
    }

    private var habitList: some View {
        List(vm.habits) { habit in
            HabitRowView(habit: habit)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                showCreateSheet = true
            } label: {
                Label("Add Habit", systemImage: "plus")
            }
        }
    }
}

#Preview {
    NavigationStack {
        HabitListView()

    }
}
