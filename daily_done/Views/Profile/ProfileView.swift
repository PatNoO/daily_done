import SwiftUI

struct ProfileView: View {

    @ObservedObject var vm: AuthViewModel

    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = true
    @AppStorage("locationEnabled") private var locationEnabled = false

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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // TODO: open settings sheet (future ticket)
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


    private var avatarSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color("brandPrimary").opacity(0.6))
                    .frame(width: 80, height: 80)
                Text(initials)
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .accessibilityHidden(true)

            VStack(spacing: DesignSystem.Spacing.xxs) {
                Text(vm.displayName ?? "User")
                    .font(.title3).fontWeight(.bold)
                    .foregroundStyle(Color("textPrimary"))
                Text(vm.email ?? "")
                    .font(.subheadline)
                    .foregroundStyle(Color("textSecondary"))
                    .accessibilityLabel("Email: \(vm.email ?? "Unknown")")
            }
        }
    }


    private var statsSection: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // TODO: replace with real counts from HabitViewModel
            StatCard(value: "0", label: "Habits", color: Color("brandPrimary"))
            StatCard(value: "0", label: "Done", color: Color("brandPrimary"))
            StatCard(value: "0", label: "Best streak", color: Color("brandAccent"))
        }
        .padding(.horizontal, DesignSystem.Spacing.base)
    }


    private var settingsSection: some View {
        VStack(spacing: 0) {
            SettingsRow(icon: "bell", label: "Notifications", isOn: $notificationsEnabled)
            Divider().padding(.leading, 52)
            SettingsRow(icon: "moon", label: "Dark Mode", isOn: $darkModeEnabled)
            Divider().padding(.leading, 52)
            SettingsRow(icon: "location", label: "Location Tracking", isOn: $locationEnabled)
        }
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.lg))
        .padding(.horizontal, DesignSystem.Spacing.base)
    }


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
            .background(Color("brandAccent").opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(Color("brandAccent").opacity(0.4), lineWidth: 1)
            )
        }
        .accessibilityLabel("Sign out of your account")
    }


    private var initials: String {
        if let name = vm.displayName, !name.isEmpty {
            let parts = name.split(separator: " ")
            let first = parts.first?.prefix(1) ?? ""
            let last = parts.dropFirst().first?.prefix(1) ?? ""
            return "\(first)\(last)".uppercased()
        }
        let username = vm.email?.split(separator: "@").first ?? ""
        return String(username.prefix(2)).uppercased()
    }
}


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
                .frame(width: 20)
                .foregroundStyle(Color("brandPrimary"))
            Text(label)
                .foregroundStyle(Color("textPrimary"))
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color("brandPrimary"))
        }
        .padding(.horizontal, DesignSystem.Spacing.base)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        ProfileView(vm: AuthViewModel())
    }
    .preferredColorScheme(.dark)
}
