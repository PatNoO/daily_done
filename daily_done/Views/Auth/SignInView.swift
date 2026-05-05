import SwiftUI

struct SignInView: View {

    @ObservedObject var vm: AuthViewModel

    @State private var email = ""
    @State private var password = ""

   
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }

    var body: some View {
        ZStack {
            Color("backgroundPrimary")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()
                logoSection
                Spacer().frame(height: 40)

                VStack(spacing: 12) {
                    emailField
                    passwordField
                    forgotPasswordLink
                }
                .padding(.horizontal, 32)

                Spacer().frame(height: 32)
                signInButton
                    .padding(.horizontal, 32)
                Spacer()
                signUpFooter
                    .padding(.bottom, 32)
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


    private var logoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color("brandPrimary").opacity(0.2))
                    .frame(width: 80, height: 80)
                Circle()
                    .fill(Color("brandPrimary").opacity(0.55))
                    .frame(width: 60, height: 60)
                Image(systemName: "timer")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(.white)
            }
            VStack(spacing: 8) {
                Text("Welcome back")
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(Color("textPrimary"))
                Text("Sign in to continue")
                    .font(.body)
                    .foregroundStyle(Color("textSecondary"))
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
                .onSubmit { Task { await signIn() } }
        }
        .padding(.horizontal, 16).padding(.vertical, 16)
        .background(Color("backgroundSecondary"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var forgotPasswordLink: some View {
        HStack {
            Spacer()
            Button("Forgot password?") { }
                // TODO: implement forgot password flow later ticket
                .font(.caption)
                .foregroundStyle(Color("brandPrimary"))
        }
    }

  
    private var signInButton: some View {
        Button {
           
            Task { await signIn() }
        } label: {
            HStack(spacing: 8) {
                if vm.isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text("Sign In").fontWeight(.semibold)
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

            .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
        }

        .disabled(vm.isLoading || email.isEmpty || password.isEmpty)
    }

    private var signUpFooter: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .font(.caption)
                .foregroundStyle(Color("textSecondary"))
            Button("Sign Up") { }
                // TODO: navigate to sign-up screen
                .font(.caption)
                .foregroundStyle(Color("brandPrimary"))
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
