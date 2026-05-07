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
        .opacity(isCompleted ? 0.65 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
    }

    private var iconView: some View {
        RoundedRectangle(cornerRadius: DesignSystem.Radius.sm)
            .fill(Color(hex: habit.colorHex))
            .frame(width: 44, height: 44)
            .overlay(
                Image(systemName: habit.iconName)
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .medium))
            )
    }

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

    private var streakView: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "flame.fill")
                .foregroundStyle(.orange)
                .font(.subheadline)
            Text("\(habit.currentStreak)")
                .font(.headline)
                .foregroundStyle(Color("textPrimary"))
        }
    }

    private var checkButton: some View {
        Button(action: onToggle) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(
                    isCompleted ? Color("success") : Color("textSecondary")
                )
                .animation(.easeInOut(duration: 0.15), value: isCompleted)
        }
        .disabled(isCompleted)
        .buttonStyle(.plain)
        .accessibilityLabel(isCompleted ? "Completed" : "Mark as done")
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
