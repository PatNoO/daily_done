import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            iconView
            infoView
            Spacer()
            streakView
            checkButton
        }
        .padding(DesignSystem.Spacing.base)
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
        .opacity(isCompleted ? DesignSystem.Opacity.completedRow : 1.0)
        .animation(.easeInOut(duration: DesignSystem.Animation.standard), value: isCompleted)
    }

    // MARK: - Icon

    private var iconView: some View {
        RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
            .fill(Color(hex: habit.colorHex))
            .frame(width: DesignSystem.Size.habitIcon, height: DesignSystem.Size.habitIcon)
            .overlay(
                Image(systemName: habit.iconName)
                    .foregroundStyle(.white)
                    .font(.system(size: DesignSystem.Size.habitRowIcon, weight: .medium))
            )
            .accessibilityHidden(true)
    }

    // MARK: - Info

    private var infoView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(habit.name)
                .font(.headline)
                .foregroundStyle(Color("textPrimary"))
            categoryBadge
        }
    }

    private var categoryBadge: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Text(habit.category.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(Color("textSecondary"))
            if isCompleted {
                Text("· Done ✓")
                    .font(.caption)
                    .foregroundStyle(Color("success"))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xxs)
        .background(Color("backgroundPrimary"))
        .clipShape(Capsule())
    }

    // MARK: - Streak

    private var streakView: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
                .font(.subheadline)
            Text("\(habit.currentStreak)")
                .font(.headline)
                .foregroundStyle(Color("textPrimary"))
        }
        .accessibilityLabel("\(habit.currentStreak) day streak")
    }

    // MARK: - Check Button

    private var checkButton: some View {
        Button(action: onToggle) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(
                    isCompleted ? Color("success") : Color("textSecondary")
                )
                .animation(.easeInOut(duration: DesignSystem.Animation.fast), value: isCompleted)
        }
        .disabled(isCompleted)
        .buttonStyle(.plain)
        .accessibilityLabel(isCompleted ? Text("Completed") : Text("Mark as done"))
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.sm) {
        HabitRowView(habit: .preview, isCompleted: false, onToggle: {})
        HabitRowView(habit: .preview, isCompleted: true, onToggle: {})
    }
    .padding()
    .background(Color("backgroundPrimary"))
    .preferredColorScheme(.dark)
}
