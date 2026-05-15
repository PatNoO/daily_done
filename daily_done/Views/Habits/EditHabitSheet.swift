import SwiftUI

struct EditHabitSheet: View {
    @ObservedObject var vm: HabitViewModel
    let habit: Habit

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var selectedCategory: HabitCategory
    @State private var selectedColorHex: String
    @State private var selectedIcon: String

    @State private var nameError: String?
    @State private var saveError: String?
    @State private var isSaving = false
    @State private var isDeleting = false
    @State private var showDeleteConfirmation = false

    init(vm: HabitViewModel, habit: Habit) {
        self.vm = vm
        self.habit = habit
        _name = State(initialValue: habit.name)
        _selectedCategory = State(initialValue: habit.category)
        _selectedColorHex = State(initialValue: habit.colorHex)
        _selectedIcon = State(initialValue: habit.iconName)
    }

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
                    deleteSection
                }
                .padding(DesignSystem.Spacing.base)
            }
            .background(Color("backgroundSheet"))
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color("textSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task { await save() }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color("brandPrimary"))
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .alert("Delete Habit", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) {
                    Task { await delete() }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("\"\(habit.name)\" will be permanently deleted.")
            }
        }
    }

    // MARK: - Name

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("HABIT NAME")
                .font(.caption)
                .foregroundStyle(Color("textSecondary"))
            TextField("Habit name", text: $name)
                .padding(DesignSystem.Spacing.md)
                .background(Color("backgroundSecondary"))
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.sm))
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
                        .accessibilityLabel("\(category.rawValue.capitalized)\(selectedCategory == category ? ", selected" : "")")
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
                        .accessibilityAddTraits(.isButton)
                        .accessibilityLabel("Color\(selectedColorHex == hex ? ", selected" : "")")
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
                    .accessibilityAddTraits(.isButton)
                    .accessibilityLabel("Icon: \(icon)\(selectedIcon == icon ? ", selected" : "")")
                }
            }
        }
    }

    // MARK: - Delete

    private var deleteSection: some View {
        Button {
            showDeleteConfirmation = true
        } label: {
            if isDeleting {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("Delete Habit")
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(Color("destructive"))
            }
        }
        .padding(DesignSystem.Spacing.base)
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
        .disabled(isDeleting || isSaving)
        .accessibilityLabel("Delete habit")
        .accessibilityHint("Asks for confirmation before deleting")
    }

    // MARK: - Actions

    private func save() async {
        nameError = nil
        saveError = nil
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            nameError = "Habit name can't be empty."
            return
        }
        isSaving = true
        defer { isSaving = false }

        var updated = habit
        updated.name = trimmed
        updated.category = selectedCategory
        updated.colorHex = selectedColorHex
        updated.iconName = selectedIcon

        await vm.updateHabit(updated)

        if vm.error == nil {
            dismiss()
        } else {
            saveError = vm.error?.errorDescription
            vm.error = nil
        }
    }

    private func delete() async {
        isDeleting = true
        defer { isDeleting = false }
        await vm.deleteHabit(habit)
        dismiss()
    }
}

#Preview {
    EditHabitSheet(vm: HabitViewModel(userId: "preview-user"), habit: .preview)
}
