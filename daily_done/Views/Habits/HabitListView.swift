import SwiftUI

struct HabitListView: View {
    @StateObject private var vm: HabitViewModel
    @State private var showCreateSheet = false

    init(userId: String) {
        _vm = StateObject(wrappedValue: HabitViewModel(userId: userId))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color("backgroundPrimary")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection
                    .padding(.horizontal, DesignSystem.Spacing.base)
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.md)

                todayHeader
                    .padding(.horizontal, DesignSystem.Spacing.base)
                    .padding(.bottom, DesignSystem.Spacing.sm)

                contentView
            }

            fabButton
                .padding(DesignSystem.Spacing.lg)
        }
        
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


    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text(greeting)
                    .font(.title).fontWeight(.bold)
                    .foregroundStyle(Color("textPrimary"))
                Text(todayDateString)
                    .font(.subheadline)
                    .foregroundStyle(Color("textSecondary"))
            }
            Spacer()
            progressRing
        }
    }

    private var progressRing: some View {
        let total = vm.habits.count
        let done = vm.completedHabitIds.count
        let progress = total > 0 ? Double(done) / Double(total) : 0

        return ZStack {
            Circle()
                .stroke(Color("brandPrimary").opacity(0.2), lineWidth: 5)
                .frame(width: 52, height: 52)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color("brandPrimary"),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 52, height: 52)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            VStack(spacing: 0) {
                Text("\(done)/\(total)")
                    .font(.caption).fontWeight(.bold)
                    .foregroundStyle(Color("textPrimary"))
                Text("done")
                    .font(.system(size: 8))
                    .foregroundStyle(Color("textSecondary"))
            }
        }
        .accessibilityLabel("\(done) of \(total) habits done today")
    }

    private var todayHeader: some View {
        HStack {
            Text("TODAY")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(Color("textSecondary"))
            Spacer()
            Button("See all") {}
                // TODO: navigate to full log history (future ticket)
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(Color("brandPrimary"))
        }
    }


    @ViewBuilder
    private var contentView: some View {
        if vm.isLoading {
            Spacer()
            ProgressView()
                .tint(Color("brandPrimary"))
            Spacer()
        } else if vm.habits.isEmpty {
            Spacer()
            ContentUnavailableView(
                "No Habits Yet",
                systemImage: "checkmark.circle",
                description: Text("Tap + to add your first habit")
            )
            Spacer()
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
                    onToggle: {
                        Task { await vm.toggleCompletion(for: habit) }
                    }
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(
                    top: DesignSystem.Spacing.xs,
                    leading: DesignSystem.Spacing.base,
                    bottom: DesignSystem.Spacing.xs,
                    trailing: DesignSystem.Spacing.base
                ))
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        Task { await vm.deleteHabit(habit) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }


    private var fabButton: some View {
        Button {
            showCreateSheet = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color("brandPrimary"))
                .clipShape(Circle())
                .shadow(
                    color: Color("brandPrimary").opacity(0.4),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
        .accessibilityLabel("Add new habit")
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning 👋"
        case 12..<17: return "Good afternoon 👋"
        default: return "Good evening 🌙"
        }
    }

    private var todayDateString: String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f.string(from: Date())
    }
}

#Preview {
    HabitListView(userId: "preview-user")
        .preferredColorScheme(.dark)
}
