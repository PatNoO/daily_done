import SwiftUI

struct ForgotPasswordSheet: View {

    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @FocusState private var emailFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color("backgroundPrimary").ignoresSafeArea()

                if vm.resetEmailSent {
                    successView
                } else {
                    formView
                }
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        vm.resetEmailSent = false
                        vm.error = nil
                        dismiss()
                    }
                }
            }
            .alert(
                "Reset Failed",
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
    }

    private var formView: some View {
        VStack(spacing: 24) {
            Text("Enter the email address for your account and we'll send you a reset link.")
                .font(.body)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .foregroundStyle(Color("textSecondary"))
                    .frame(width: 20)
                TextField("Email address", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($emailFocused)
                    .foregroundStyle(Color("textPrimary"))
                    .submitLabel(.send)
                    .onSubmit { Task { await submit() } }
            }
            .padding(.horizontal, 16).padding(.vertical, 16)
            .background(Color("backgroundSecondary"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 32)

            Button {
                Task { await submit() }
            } label: {
                HStack(spacing: 8) {
                    if vm.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text("Send Reset Link").fontWeight(.semibold)
                        Image(systemName: "paperplane")
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
                .shadow(color: Color("brandPrimary").opacity(0.45), radius: 12, x: 0, y: 4)
                .opacity(email.isEmpty ? 0.6 : 1.0)
            }
            .disabled(vm.isLoading || email.isEmpty)
            .padding(.horizontal, 32)
        }
        .padding(.top, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
    }

    private var successView: some View {
        VStack(spacing: 20) {
            Image(systemName: "envelope.badge.checkmark")
                .font(.system(size: 56))
                .foregroundStyle(Color("brandPrimary"))

            Text("Check your inbox")
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(Color("textPrimary"))

            Text("A reset link has been sent to \(email). Check your inbox (and spam folder).")
                .font(.body)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button("Done") {
                vm.resetEmailSent = false
                dismiss()
            }
            .font(.body).fontWeight(.semibold)
            .foregroundStyle(Color("brandPrimary"))
            .padding(.top, 8)
        }
        .padding(.top, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func submit() async {
        emailFocused = false
        await vm.sendPasswordReset(email: email)
    }
}

#Preview {
    ForgotPasswordSheet(vm: AuthViewModel())
        .preferredColorScheme(.dark)
}
