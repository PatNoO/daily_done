import SwiftUI

struct ProfileView: View {

    @ObservedObject var vm: AuthViewModel
    @StateObject private var statsVM: StatsViewModel
    
    init(userId: String, vm: AuthViewModel) {
        self.vm = vm
        _statsVM = StateObject(wrappedValue: StatsViewModel(userId: userId))
    }

    @AppStorage(UserDefaultsKey.notificationsEnabled) private var notificationsEnabled = true
    @AppStorage(UserDefaultsKey.darkModeEnabled) private var darkModeEnabled = true
    @AppStorage(UserDefaultsKey.locationEnabled) private var locationEnabled = false

    var body: some View {
        ZStack {
            Color("backgroundPrimary")
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    avatarSection
                        .padding(.top, DesignSystem.Spacing.xl)
                    statsSection
                    settingsSection
                    signOutButton
                        .padding(.horizontal, DesignSystem.Spacing.base)
                        .padding(.bottom, DesignSystem.Spacing.xxl)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .task {
            await statsVM.loadStats()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // settings sheet — tracked in a separate ticket
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(Color("textSecondary"))
                }
                .accessibilityLabel("Settings")
            }
        }
        .alert(
            "Sign Out Failed",
            isPresented: Binding(
                get: { vm.error != nil },
                set: { if !$0 { vm.error = nil } }
            )
        ) {
            Button("OK") { vm.error = nil }
        } message: {
            Text(vm.error?.localizedDescription ?? "")
        }
    }

    // MARK: - Avatar Section

    private var avatarSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color("brandPrimary").opacity(DesignSystem.Opacity.avatarFill))
                    .frame(width: DesignSystem.Size.avatar, height: DesignSystem.Size.avatar)
                Text(initials)
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text(vm.displayName ?? String(localized: "profile.fallback_name"))
                    .font(.title3).fontWeight(.bold)
                    .foregroundStyle(Color("textPrimary"))
                Text(vm.email ?? "")
                    .font(.subheadline)
                    .foregroundStyle(Color("textSecondary"))
                    .accessibilityLabel("Email: \(vm.email ?? String(localized: "profile.email_unknown"))")
            }
        }
    }

    // MARK: - Stats Section

    private var statsSection: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            StatCard(value: "\(statsVM.habitStats.count)", label: "Habits", color: Color("brandPrimary"))
            StatCard(value: "\(statsVM.habitStats.reduce(0) { $0 + $1.totalCompletions })", label: "Done", color: Color("brandPrimary"))
            StatCard(value: "\(statsVM.habitStats.map(\.longestStreak).max() ?? 0)", label: "Best streak", color: Color("brandAccent"))
        }
        .padding(.horizontal, DesignSystem.Spacing.base)
    }

    // MARK: - Settings Section

    private var settingsSection: some View {
        VStack(spacing: 0) {
            SettingsRow(icon: "bell", label: "Notifications", isOn: $notificationsEnabled)
            Divider().padding(.leading, DesignSystem.Size.settingsRowInset)
            SettingsRow(icon: "moon", label: "Dark Mode", isOn: $darkModeEnabled)
            Divider().padding(.leading, DesignSystem.Size.settingsRowInset)
            SettingsRow(icon: "location", label: "Location Tracking", isOn: $locationEnabled)
        }
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
        .padding(.horizontal, DesignSystem.Spacing.base)
    }

    // MARK: - Sign Out Button

    private var signOutButton: some View {
        Button {
            vm.signOut()
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out").fontWeight(.semibold)
            }
            .foregroundStyle(Color("brandAccent"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.base)
            .background(Color("brandAccent").opacity(DesignSystem.Opacity.tintedBackground))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(Color("brandAccent").opacity(DesignSystem.Opacity.tintedBorder), lineWidth: DesignSystem.Stroke.thin)
            )
        }
        .accessibilityLabel("Sign out of your account")
    }

    // MARK: - Helpers

    private var initials: String {
        if let name = vm.displayName, !name.isEmpty {
            let nameParts = name.split(separator: " ")
            let firstName = nameParts.first?.prefix(1) ?? ""
            let lastName = nameParts.dropFirst().first?.prefix(1) ?? ""
            return "\(firstName)\(lastName)".uppercased()
        }
        let username = vm.email?.split(separator: "@").first ?? ""
        return String(username.prefix(2)).uppercased()
    }
}

// MARK: - Subviews

private struct StatCard: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            Text(value)
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("textSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.base)
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
    }
}

private struct SettingsRow: View {
    let icon: String
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: icon)
                .frame(width: DesignSystem.Size.iconSmall)
                .foregroundStyle(Color("brandPrimary"))
            Text(label)
                .foregroundStyle(Color("textPrimary"))
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color("brandPrimary"))
        }
        .padding(.horizontal, DesignSystem.Spacing.base)
        .padding(.vertical, DesignSystem.Spacing.base)
    }
}

#Preview {
    NavigationStack {
        ProfileView(userId: "preview-user" ,vm: AuthViewModel())
    }
    .preferredColorScheme(.dark)
}
