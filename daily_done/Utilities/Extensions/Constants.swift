import SwiftUI

enum DesignSystem {
    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let base: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    enum HabitPalette {
        static let colors: [String] = [
            "#7B61FF",  // violet
            "#10B981",  // emerald
            "#F59E0B",  // amber
            "#EF4444",  // coral
            "#60A5FA",  // sky
            "#EC4899",  // pink
            "#F97316",  // orange
            "#A78BFA"   // lavender
        ]

        static let icons: [String] = [
            "figure.mind.and.body",
            "dumbbell",
            "book.fill",
            "drop.fill",
            "moon.fill",
            "figure.run"
        ]
    }
}
