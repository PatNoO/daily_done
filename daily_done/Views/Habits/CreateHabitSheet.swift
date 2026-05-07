import SwiftUI

struct CreateHabitSheet: View {
    @ObservedObject var vm: HabitViewModel
    @StateObject private var notificationVM = NotificationViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedCategory: HabitCategory = .health
    @State private var selectedColorHex = DesignSystem.HabitPalette.colors[0]
    @State private var selectedIcon = DesignSystem.HabitPalette.icons[0]
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var nameError: String?
    @State private var saveError: String?
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    if let saveError {
                        ErrorBannerView(message: saveError)
                    }
                    nameSection
                    categorySection
                    colorSection
                    iconSection
                    reminderSection
                }
                .padding(DesignSystem.Spacing.base)
            }
            .background(Color("backgroundSheet"))
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color("textSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await save() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color("brandPrimary"))
                    .disabled(isSaving)
                }
            }
        }
    }
    
    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("HABIT NAME")
                .font(.caption)
                .foregroundStyle(Color("textSecondary"))
            TextField("Morning run..", text: $name)
                .padding(DesignSystem.Spacing.md)
                .background(Color("backgroundSecondary"))
                .clipShape(
                    RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
                )
                .foregroundStyle(Color("textPrimary"))
            if let nameError {
                Text(nameError)
                    .font(.caption)
                    .foregroundStyle(Color("destructive"))
            }
        }
    }
    
    // MARK: - Category

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("CATEGORY")
                .font(.caption)
                .foregroundStyle(Color("textSecondary"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(HabitCategory.allCases) { category in
                        Button(category.rawValue.capitalized) {
                            selectedCategory = category
                        }
                        .padding(.horizontal, DesignSystem.Spacing.base)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(
                            selectedCategory == category
                                ? Color(hex: selectedColorHex)
                                : Color("backgroundSecondary")
                        )
                        .foregroundStyle(
                            selectedCategory == category
                                ? Color("textPrimary")
                                : Color("textSecondary")
                        )
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    // MARK: - Color

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("COLOR")
                .font(.caption)
                .foregroundStyle(Color("textSecondary"))
            HStack(spacing: DesignSystem.Spacing.md) {
                ForEach(DesignSystem.HabitPalette.colors, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: DesignSystem.Size.colorSwatch, height: DesignSystem.Size.colorSwatch)
                        .overlay {
                            if selectedColorHex == hex {
                                Circle().strokeBorder(
                                    Color("textPrimary"),
                                    lineWidth: DesignSystem.Stroke.selection
                                )
                            }
                        }
                        .onTapGesture { selectedColorHex = hex }
                }
            }
        }

    }
    
    // MARK: - Icon

    private var iconSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("ICON")
                .font(.caption)
                .foregroundStyle(Color("textSecondary"))
            HStack(spacing: DesignSystem.Spacing.md) {
                ForEach(DesignSystem.HabitPalette.icons, id: \.self) { icon in
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                            .fill(
                                selectedIcon == icon
                                    ? Color(hex: selectedColorHex)
                                    : Color("backgroundSecondary")
                            )
                            .frame(width: DesignSystem.Size.iconPickerTile, height: DesignSystem.Size.iconPickerTile)
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundStyle(
                                selectedIcon == icon
                                    ? Color("textPrimary")
                                    : Color("textSecondary")
                            )
                            .onTapGesture { selectedIcon = icon }
                    }
                }
            }
        }
    }
    
    // MARK: - Reminder

    private var reminderSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: DesignSystem.Spacing.base) {
                Image(systemName: "bell")
                    .foregroundStyle(Color("textSecondary"))
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                    Text("Reminder")
                        .font(.body)
                        .foregroundStyle(Color("textPrimary"))
                    Text("Set a daily reminder")
                        .font(.caption)
                        .foregroundStyle(Color("textSecondary"))
                }
                Spacer()
                Toggle("", isOn: $reminderEnabled)
                    .labelsHidden()
                    .tint(Color("brandPrimary"))
                    .onChange(of: reminderEnabled) { _, isOn in
                        guard isOn else { return }
                        Task {
                            let granted =
                                await notificationVM.requestPermission()
                            if !granted { reminderEnabled = false }
                        }
                    }
            }
            .padding(DesignSystem.Spacing.base)

            if reminderEnabled {
                Divider()
                DatePicker(
                    "Reminder time",
                    selection: $reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, DesignSystem.Spacing.base)
            }

            if notificationVM.permissionDenied {
                Text("Enable notifications in Settings to use reminders.")
                    .font(.caption)
                    .foregroundStyle(Color("destructive"))
                    .padding([.horizontal, .bottom], DesignSystem.Spacing.base)
            }
        }
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
    }
    
    // MARK: - Save

    private func save() async {
        nameError = nil
        isSaving = true
        saveError = nil
        defer { isSaving = false }
        do {
            let saved = try await vm.createHabit(
                name: name,
                category: selectedCategory,
                colorHex: selectedColorHex,
                iconName: selectedIcon,
                isReminderEnabled: reminderEnabled,
                reminderTime: reminderEnabled ? reminderTime : nil
            )
            await notificationVM.scheduleIfEnabled(for: saved)
            dismiss()

        } catch HabitViewModel.HabitError.nameMissing {
            nameError = "Name is required"
        } catch {
            saveError =
                "Could not save habit. Check your connection and try again."
        }
    }
}
#Preview {
    CreateHabitSheet(vm: HabitViewModel(userId: "preview-user"))
}
