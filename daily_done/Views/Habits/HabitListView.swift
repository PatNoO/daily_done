import SwiftUI

struct HabitListView: View {
    @StateObject private var vm: HabitViewModel
      @State private var showCreateSheet = false

      init(userId: String) {
          _vm = StateObject(wrappedValue: HabitViewModel(userId: userId))
      }

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
        List {
            ForEach(vm.habits) { habit in
                HabitRowView(
                    habit: habit,
                    isCompleted: vm.completedHabitIds.contains(habit.id ?? ""),
                    onToggle: { Task { await vm.toggleCompletion(for: habit) } }
                )
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onDelete { indexSet in
                for i in indexSet {
                    let habit = vm.habits[i]
                    Task { await vm.deleteHabit(habit) }
                }
            }
            
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
        HabitListView(userId: "preview-user")

    }
}
