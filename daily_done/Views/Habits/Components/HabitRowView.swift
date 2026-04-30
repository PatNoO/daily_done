import SwiftUI

struct HabitRowView: View {
    let habit: Habit

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
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    HabitRowView(habit: .preview)
        .padding()
}
