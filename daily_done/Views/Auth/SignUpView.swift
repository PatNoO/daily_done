import SwiftUI

struct SignUpView: View {

    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var nameError: String?

    @FocusState private var focusedField: Field?
    private enum Field { case name, email, password }

    var body: some View {
        ZStack {
            RadialGradient(
                gradient: Gradient(colors: [
                    Color("brandPrimary").opacity(DesignSystem.Opacity.headerGradient),
                    Color("backgroundPrimary"),
                ]),
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                headerSection
                Spacer().frame(height: DesignSystem.Spacing.formGap)

                VStack(spacing: DesignSystem.Spacing.md) {
                    nameField
                    emailField
                    passwordField
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)

                Spacer().frame(height: DesignSystem.Spacing.xl)
                signUpButton
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                Spacer()
                signInFooter
                    .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
        .alert(
            "Sign Up Failed",
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

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.base) {
            ZStack {
                Circle()
                    .fill(Color("brandPrimary").opacity(DesignSystem.Opacity.avatarOuter))
                    .frame(width: DesignSystem.Size.avatar, height: DesignSystem.Size.avatar)
                Circle()
                    .fill(Color("brandPrimary").opacity(DesignSystem.Opacity.avatarInner))
                    .frame(width: DesignSystem.Size.avatarInner, height: DesignSystem.Size.avatarInner)
                Image(systemName: "person.badge.plus")
                    .font(.system(size: DesignSystem.Size.authIconHeader, weight: .medium))
                    .foregroundStyle(Color("textPrimary"))
            }
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Create account")
                    .font(.title).fontWeight(.bold)
                    .foregroundStyle(Color("textPrimary"))
                Text("Start tracking your habits")
                    .font(.subheadline)
                    .foregroundStyle(Color("textSecondary"))
            }
        }
    }

    // MARK: - Fields

    private var nameField: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "person")
                    .foregroundStyle(Color("textSecondary"))
                    .frame(width: DesignSystem.Size.iconSmall)
                TextField("Full name", text: $name)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .name)
                    .foregroundStyle(Color("textPrimary"))
                    .submitLabel(.next)
                    .onSubmit { focusedField = .email }
            }
            .padding(.horizontal, DesignSystem.Spacing.base).padding(.vertical, DesignSystem.Spacing.base)
            .background(Color("backgroundSecondary"))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.Radius.md)
                    .stroke(
                        nameError != nil
                            ? Color.red.opacity(DesignSystem.Opacity.errorStroke)
                            : Color("backgroundSecondary").opacity(DesignSystem.Opacity.disabled),
                        lineWidth: 1
                    )
            )

            if let nameError {
                Text(nameError)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, DesignSystem.Spacing.xs)
            }
        }
    }

    private var emailField: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "envelope")
                .foregroundStyle(Color("textSecondary"))
                .frame(width: DesignSystem.Size.iconSmall)
            TextField("Email address", text: $email)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: .email)
                .foregroundStyle(Color("textPrimary"))
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
        }
        .padding(.horizontal, DesignSystem.Spacing.base).padding(.vertical, DesignSystem.Spacing.base)
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
    }

    private var passwordField: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "lock")
                .foregroundStyle(Color("textSecondary"))
                .frame(width: DesignSystem.Size.iconSmall)
            SecureField("Password", text: $password)
                .focused($focusedField, equals: .password)
                .foregroundStyle(Color("textPrimary"))
                .submitLabel(.done)
                .onSubmit { Task { await signUp() } }
        }
        .padding(.horizontal, DesignSystem.Spacing.base).padding(.vertical, DesignSystem.Spacing.base)
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
    }

    // MARK: - Sign Up Button

    private var signUpButton: some View {
        Button {
            Task { await signUp() }
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if vm.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Sign Up").fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.base)
            .background(
                LinearGradient(
                    colors: [Color("brandPrimary"), Color("brandAccent")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.button))
            .shadow(
                color: Color("brandPrimary").opacity(DesignSystem.Opacity.shadowBrand),
                radius: DesignSystem.Radius.md,
                x: 0,
                y: DesignSystem.Spacing.xs
            )
            .opacity(
                name.isEmpty || email.isEmpty || password.isEmpty ? DesignSystem.Opacity.disabled : 1.0
            )
        }
        .disabled(
            vm.isLoading || name.isEmpty || email.isEmpty || password.isEmpty
        )
    }

    // MARK: - Footer

    private var signInFooter: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text("Already have an account?")
                .font(.caption)
                .foregroundStyle(Color("textSecondary"))
            Button("Sign In") { dismiss() }
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(Color("brandPrimary"))
        }
    }

    private func signUp() async {
        focusedField = nil
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            nameError = String(localized: "sign_up.name_required")
            return
        }
        nameError = nil
        await vm.signUp(email: email, password: password, displayName: name)
    }
}

#Preview {
    SignUpView(vm: AuthViewModel())
        .preferredColorScheme(.dark)
}
