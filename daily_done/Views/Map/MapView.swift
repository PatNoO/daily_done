import MapKit
import SwiftUI

struct MapView: View {
    @StateObject private var vm: MapViewModel

    init(userId: String, service: FirebaseServiceProtocol = FirebaseService.shared) {
        _vm = StateObject(wrappedValue: MapViewModel(userId: userId, service: service))
    }

    @State private var selectedAnnotation: HabitLogAnnotation?

    var body: some View {
        ZStack(alignment: .top) {
            mapLayer
            filterChipBar
        }
        .navigationTitle("Habit Map")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.loadNearbyHabits() }
        .sheet(item: $selectedAnnotation) { annotation in
            annotationDetail(annotation)
                .presentationDetents([.fraction(0.3)])
        }
        .alert("Error", isPresented: Binding(
            get: { vm.error != nil },
            set: { if !$0 { vm.error = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.error ?? "")
        }
        .overlay {
            if vm.isLoading {
                ProgressView()
            } else if vm.filteredAnnotations.isEmpty && !vm.annotations.isEmpty {
                emptyFilterState
            } else if vm.annotations.isEmpty {
                emptyNoLogsState
            }
        }
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        Map {
            ForEach(vm.filteredAnnotations) { item in
                Annotation(item.habitName, coordinate: item.coordinate) {
                    Button { selectedAnnotation = item } label: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(Color("brandPrimary"))
                    }
                    .accessibilityLabel("Show details for \(item.habitName)")
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Filter Chips

    private var filterChipBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                habitChip(label: String(localized: "map.filter.all"), id: nil)
                ForEach(vm.habits) { habit in
                    habitChip(label: habit.name, id: habit.id)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.base)
            .padding(.vertical, DesignSystem.Spacing.sm)
        }
        .background(.ultraThinMaterial)
    }

    private func habitChip(label: String, id: String?) -> some View {
        let isSelected = vm.selectedHabitId == id
        return Button {
            vm.selectedHabitId = id
        } label: {
            Text(label)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(isSelected ? Color("brandPrimary") : Color(.systemGray5))
                .foregroundStyle(isSelected ? Color.white : Color("textPrimary"))
                .clipShape(Capsule())
        }
        .accessibilityLabel(label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Annotation Detail

    private func annotationDetail(_ item: HabitLogAnnotation) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(item.habitName)
                .font(.headline)
            Text(item.completedAt.formatted(date: .long, time: .shortened))
                .font(.body)
                .foregroundStyle(Color("textSecondary"))
            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Empty States

    private var emptyFilterState: some View {
        ContentUnavailableView(
            "No pins for this habit",
            systemImage: "mappin.slash",
            description: Text("This habit has no logged locations. Try completing it with location enabled.")
        )
    }

    private var emptyNoLogsState: some View {
        ContentUnavailableView(
            "No locations logged yet",
            systemImage: "map",
            description: Text("Complete habits to start seeing your locations on the map.")
        )
    }
}

#Preview {
    NavigationStack {
        MapView(userId: "preview-user", service: MockMapService())
    }
}

private struct MockMapService: FirebaseServiceProtocol {
    func fetchHabits(userId: String) async throws -> [Habit] {
        [
            Habit(
                id: "habit-1",
                userId: userId,
                name: "Morning Run",
                category: .fitness,
                colorHex: DesignSystem.HabitPalette.orange,
                iconName: "figure.run",
                createdAt: Date(),
                currentStreak: 5,
                longestStreak: 12,
                totalCompletions: 20,
                isReminderEnabled: false,
                reminderTime: nil
            ),
            Habit(
                id: "habit-2",
                userId: userId,
                name: "Read 20 min",
                category: .learning,
                colorHex: DesignSystem.HabitPalette.violet,
                iconName: "book.fill",
                createdAt: Date(),
                currentStreak: 3,
                longestStreak: 8,
                totalCompletions: 15,
                isReminderEnabled: false,
                reminderTime: nil
            ),
            Habit(
                id: "habit-3",
                userId: userId,
                name: "Meditate",
                category: .mindfulness,
                colorHex: DesignSystem.HabitPalette.emerald,
                iconName: "brain.head.profile",
                createdAt: Date(),
                currentStreak: 1,
                longestStreak: 5,
                totalCompletions: 10,
                isReminderEnabled: false,
                reminderTime: nil
            )
        ]
    }

    func fetchAllLogs(userId: String) async throws -> [HabitLog] {
        [
            // Morning Run — 4 pins around Stockholm
            HabitLog(id: "log-1", habitId: "habit-1", userId: userId, completedAt: Date(), location: HabitLocation(lat: 59.3293, lng: 18.0686)),
            HabitLog(id: "log-2", habitId: "habit-1", userId: userId, completedAt: Date(), location: HabitLocation(lat: 59.3340, lng: 18.0750)),
            HabitLog(id: "log-3", habitId: "habit-1", userId: userId, completedAt: Date(), location: HabitLocation(lat: 59.3250, lng: 18.0600)),
            HabitLog(id: "log-4", habitId: "habit-1", userId: userId, completedAt: Date(), location: HabitLocation(lat: 59.3310, lng: 18.0810)),

            // Read 20 min — 3 pins (closer together, indoor habit)
            HabitLog(id: "log-5", habitId: "habit-2", userId: userId, completedAt: Date(), location: HabitLocation(lat: 59.3320, lng: 18.0640)),
            HabitLog(id: "log-6", habitId: "habit-2", userId: userId, completedAt: Date(), location: HabitLocation(lat: 59.3280, lng: 18.0700)),
            HabitLog(id: "log-7", habitId: "habit-2", userId: userId, completedAt: Date(), location: HabitLocation(lat: 59.3300, lng: 18.0720)),

            // Meditate — 2 pins + 1 with no location (tests compactMap)
            HabitLog(id: "log-8", habitId: "habit-3", userId: userId, completedAt: Date(), location: HabitLocation(lat: 59.3270, lng: 18.0660)),
            HabitLog(id: "log-9", habitId: "habit-3", userId: userId, completedAt: Date(), location: HabitLocation(lat: 59.3350, lng: 18.0780)),
            HabitLog(id: "log-10", habitId: "habit-3", userId: userId, completedAt: Date(), location: nil)
        ]
    }

    // Required by protocol — not used in MapView
    func createHabit(_ habit: Habit) async throws -> String { "" }
    func habitLogCompletion(habitId: String, userId: String, location: HabitLocation?) async throws {}
    func fetchTodayLogs(userId: String) async throws -> [HabitLog] { [] }
    func deleteHabit(habitId: String, userId: String) async throws {}
}
