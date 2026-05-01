import SwiftUI

struct CreateHabitSheet: View {
    @ObservedObject var vm: HabitViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedCategory: HabitCategory = .health
    @State private var selectedColorHex = DesignSystem.HabitPalette.colors[0]
    @State private var selectedIcon = DesignSystem.HabitPalette.icons[0]
    @State private var reminderEnabled = false
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

    private var colorSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("COLOR")
                .font(.caption)
                .foregroundStyle(Color("textSecondary"))
            HStack(spacing: DesignSystem.Spacing.md) {
                ForEach(DesignSystem.HabitPalette.colors, id: \.self) { hex in
                    Circle()
                        .fill(Color(hex: hex))
                        .frame(width: 36, height: 36)
                        .overlay {
                            if selectedColorHex == hex {
                                Circle().strokeBorder(
                                    Color("textPrimary"),
                                    lineWidth: 3
                                )
                            }
                        }
                        .onTapGesture { selectedColorHex = hex }
                }
            }
        }

    }

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
                            .frame(width: 52, height: 52)
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

    private var reminderSection: some View {
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
            // TODO: Implementera NotificationService kommer i DD-009
            Toggle("", isOn: $reminderEnabled)
                .labelsHidden()
                .tint(Color("brandPrimary"))
        }
        .padding(DesignSystem.Spacing.base)
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
    }

    private func save() async {
        nameError = nil
        isSaving = true
        saveError = nil
        defer { isSaving = false }
        do {
            try await vm.createHabit(
                name: name,
                category: selectedCategory,
                colorHex: selectedColorHex,
                iconName: selectedIcon
            )
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
    CreateHabitSheet(vm: HabitViewModel())
}
