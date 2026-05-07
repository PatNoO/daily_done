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
                    Color("brandPrimary").opacity(0.25),
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
                Spacer().frame(height: 40)

                VStack(spacing: 12) {
                    nameField
                    emailField
                    passwordField
                }
                .padding(.horizontal, 32)

                Spacer().frame(height: 32)
                signUpButton
                    .padding(.horizontal, 32)
                Spacer()
                signInFooter
                    .padding(.bottom, 32)
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

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color("brandPrimary").opacity(0.2))
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color("brandPrimary").opacity(0.55))
                    .frame(width: 60, height: 60)
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(Color("textPrimary"))
            }
            VStack(spacing: 8) {
                Text("Create account")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color("textPrimary"))
                Text("Start tracking your habits")
                    .font(.system(size: 15))
                    .foregroundStyle(Color("textSecondary"))
            }
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: "person")
                    .foregroundStyle(Color("textSecondary"))
                    .frame(width: 20)
                TextField("Full name", text: $name)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .name)
                    .foregroundStyle(Color("textPrimary"))
                    .submitLabel(.next)
                    .onSubmit { focusedField = .email }
            }
            .padding(.horizontal, 16).padding(.vertical, 16)
            .background(Color("backgroundSecondary"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        nameError != nil
                            ? Color.red.opacity(0.7)
                            : Color("backgroundSecondary").opacity(0.6),
                        lineWidth: 1
                    )
            )

            if let nameError {
                Text(nameError)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
            }
        }
    }

    private var emailField: some View {
        HStack(spacing: 12) {
            Image(systemName: "envelope")
                .foregroundStyle(Color("textSecondary"))
                .frame(width: 20)
            TextField("Email address", text: $email)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: .email)
                .foregroundStyle(Color("textPrimary"))
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
        }
        .padding(.horizontal, 16).padding(.vertical, 16)
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var passwordField: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock")
                .foregroundStyle(Color("textSecondary"))
                .frame(width: 20)
            SecureField("Password", text: $password)
                .focused($focusedField, equals: .password)
                .foregroundStyle(Color("textPrimary"))
                .submitLabel(.done)
                .onSubmit { Task { await signUp() } }
        }
        .padding(.horizontal, 16).padding(.vertical, 16)
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var signUpButton: some View {
        Button {
            Task { await signUp() }
        } label: {
            HStack(spacing: 8) {
                if vm.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Sign Up").fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color("brandPrimary"), Color("brandAccent")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(
                color: Color("brandPrimary").opacity(0.45),
                radius: 12,
                x: 0,
                y: 4
            )
            .opacity(
                name.isEmpty || email.isEmpty || password.isEmpty ? 0.6 : 1.0
            )
        }
        .disabled(
            vm.isLoading || name.isEmpty || email.isEmpty || password.isEmpty
        )
    }

    private var signInFooter: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .font(.system(size: 14))
                .foregroundStyle(Color("textSecondary"))
            Button("Sign In") { dismiss() }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("brandPrimary"))
        }
    }

    private func signUp() async {
        focusedField = nil
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            nameError = "Please enter your name"
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
