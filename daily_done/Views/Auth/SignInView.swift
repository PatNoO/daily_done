import SwiftUI

struct SignInView: View {

    @ObservedObject var vm: AuthViewModel

    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showForgotPassword = false

    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    var body: some View {
        ZStack {
            Color("backgroundPrimary")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                logoSection
                Spacer().frame(height: DesignSystem.Spacing.formGap)

                VStack(spacing: DesignSystem.Spacing.md) {
                    emailField
                    passwordField
                    forgotPasswordLink
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)

                Spacer().frame(height: DesignSystem.Spacing.xl)
                signInButton
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                Spacer()
                signUpFooter
                    .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }

        .alert(
            "Sign In Failed",
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

    // MARK: - Logo Section

    private var logoSection: some View {
        VStack(spacing: DesignSystem.Spacing.base) {
            ZStack {
                Circle()
                    .fill(Color("brandPrimary").opacity(DesignSystem.Opacity.avatarOuter))
                    .frame(width: DesignSystem.Size.avatar, height: DesignSystem.Size.avatar)
                Circle()
                    .fill(Color("brandPrimary").opacity(DesignSystem.Opacity.avatarInner))
                    .frame(width: DesignSystem.Size.avatarInner, height: DesignSystem.Size.avatarInner)
                Image(systemName: "timer")
                    .font(.system(size: DesignSystem.Size.authIconHeader, weight: .medium))
                    .foregroundStyle(.white)
            }
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Welcome back")
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(Color("textPrimary"))
                Text("Sign in to continue")
                    .font(.body)
                    .foregroundStyle(Color("textSecondary"))
            }
        }
    }

    // MARK: - Fields

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
                .onSubmit { Task { await signIn() } }
        }
        .padding(.horizontal, DesignSystem.Spacing.base).padding(.vertical, DesignSystem.Spacing.base)
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
    }

    private var forgotPasswordLink: some View {
        HStack {
            Spacer()
            Button("Forgot password?") { showForgotPassword = true }
                .font(.caption)
                .foregroundStyle(Color("brandPrimary"))
        }
        .sheet(isPresented: $showForgotPassword, onDismiss: {
            vm.resetEmailSent = false
            vm.error = nil
        }) {
            ForgotPasswordSheet(vm: vm)
        }
    }

    // MARK: - Sign In Button

    private var signInButton: some View {
        Button {
            Task { await signIn() }
        } label: {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if vm.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Sign In").fontWeight(.semibold)
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
            .opacity(email.isEmpty || password.isEmpty ? DesignSystem.Opacity.disabled : 1.0)
        }
        .disabled(vm.isLoading || email.isEmpty || password.isEmpty)
    }

    // MARK: - Footer

    private var signUpFooter: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text("Don't have an account?")
                .font(.caption)
                .foregroundStyle(Color("textSecondary"))
            Button("Sign Up") { showSignUp = true }
                .font(.caption)
                .foregroundStyle(Color("brandPrimary"))
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(vm: vm)
        }
    }

    private func signIn() async {
        focusedField = nil
        await vm.signIn(email: email, password: password)
    }
}

#Preview {
    SignInView(vm: AuthViewModel())
        .preferredColorScheme(.dark)
}
