import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(hex: habit.colorHex))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: habit.iconName)
                        .foregroundStyle(.white)
                        .font(.system(size: 18, weight: .medium))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                    .strikethrough(isCompleted, color: .secondary)
                Text(habit.category.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                    Text("\(habit.currentStreak)")
                        .font(.headline)
                }
                Text("day streak")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Button(action: onToggle) {
                Image(
                    systemName: isCompleted ? "checkmark.circle.fill" : "circle"
                )
                .font(.title2)
                .foregroundStyle(
                    isCompleted ? Color("brandPrimary") : .secondary
                )
                .animation(.easeInOut(duration: 0.15), value: isCompleted)
            }
            .disabled(isCompleted)
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        HabitRowView(habit: .preview, isCompleted: false, onToggle: {})
            .padding()
        Divider()
        HabitRowView(habit: .preview, isCompleted: true, onToggle: {})
            .padding()
    }
}
