import Foundation

enum DesignSystem {

    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let base: CGFloat = 16
        static let basePlus: CGFloat = 20
        static let formGap: CGFloat = 40
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let button: CGFloat = 14
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }

    enum Size {
        static let iconSmall: CGFloat = 20
        static let authIconHeader: CGFloat = 26
        static let splashFlame: CGFloat = 40
        static let avatarInner: CGFloat = 60
        static let avatar: CGFloat = 80
        static let logoCircle: CGFloat = 96
        static let progressRing: CGFloat = 52
        static let habitIcon: CGFloat = 44
        static let fab: CGFloat = 56
        static let chartHeight: CGFloat = 200
    }

    enum Animation {
        static let fast: Double = 0.15
        static let standard: Double = 0.2
        static let slow: Double = 0.65
    }

    enum Opacity {
        static let avatarOuter: Double = 0.2
        static let headerGradient: Double = 0.25
        static let splashGradient: Double = 0.3
        static let subtle: Double = 0.5
        static let avatarInner: Double = 0.55
        static let completedRow: Double = 0.65
        static let errorStroke: Double = 0.7
        static let disabled: Double = 0.6
        static let shadowBrand: Double = 0.45
        static let logoFill: Double = 0.9
    }

    enum HabitPalette {
        static let violet = "#7B61FF"
        static let emerald = "#10B981"
        static let amber = "#F59E0B"
        static let coral = "#EF4444"
        static let sky = "#60A5FA"
        static let pink = "#EC4899"
        static let orange = "#F97316"
        static let lavender = "#A78BFA"

        static let colors: [String] = [
            violet, emerald, amber, coral, sky, pink, orange, lavender,
        ]

        static let icons: [String] = [
            "figure.mind.and.body",
            "dumbbell",
            "book.fill",
            "drop.fill",
            "moon.fill",
            "figure.run",
        ]
    }
}

// MARK: - UserDefaults Keys

enum UserDefaultsKey {
    static let notificationsEnabled = "notificationsEnabled"
    static let darkModeEnabled = "darkModeEnabled"
    static let locationEnabled = "locationEnabled"
}

// MARK: - Date Formats

enum DateFormat {
    static let fullWeekdayShortMonth = "EEEE, MMM d"
    static let shortWeekday = "EEE"
}

// MARK: - Greeting Hours

enum Greeting {
    static let morningStart = 5
    static let afternoonStart = 12
    static let eveningStart = 17
}
