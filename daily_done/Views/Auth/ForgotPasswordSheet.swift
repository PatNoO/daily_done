import SwiftUI

struct ForgotPasswordSheet: View {

    @ObservedObject var vm: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var email = ""
    @State private var isSubmitting = false
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
        VStack(spacing: DesignSystem.Spacing.lg) {
            Text("Enter the email address for your account and we'll send you a reset link.")
                .font(.body)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xl)

            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "envelope")
                    .foregroundStyle(Color("textSecondary"))
                    .frame(width: DesignSystem.Size.iconSmall)
                TextField("Email address", text: $email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($emailFocused)
                    .foregroundStyle(Color("textPrimary"))
                    .submitLabel(.send)
                    .onSubmit { Task { await submit() } }
            }
            .padding(.horizontal, DesignSystem.Spacing.base)
            .padding(.vertical, DesignSystem.Spacing.base)
            .background(Color("backgroundSecondary"))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.md))
            .padding(.horizontal, DesignSystem.Spacing.xl)

            Button {
                Task { await submit() }
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    if isSubmitting {
                        ProgressView().tint(.white)
                    } else {
                        Text("Send Reset Link").fontWeight(.semibold)
                        Image(systemName: "paperplane")
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
                .shadow(color: Color("brandPrimary").opacity(DesignSystem.Opacity.shadowBrand), radius: DesignSystem.Radius.md, x: 0, y: DesignSystem.Spacing.xs)
                .opacity(email.isEmpty ? DesignSystem.Opacity.disabled : 1.0)
            }
            .disabled(isSubmitting || email.isEmpty)
            .padding(.horizontal, DesignSystem.Spacing.xl)
        }
        .padding(.top, DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var successView: some View {
        VStack(spacing: DesignSystem.Spacing.basePlus) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: DesignSystem.Size.fab))
                .foregroundStyle(Color("brandPrimary"))

            Text("Check your inbox")
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(Color("textPrimary"))

            Text("A reset link has been sent to \(email). Check your inbox (and spam folder).")
                .font(.body)
                .foregroundStyle(Color("textSecondary"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xl)

            Button("Done") {
                dismiss()
            }
            .font(.body).fontWeight(.semibold)
            .foregroundStyle(Color("brandPrimary"))
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .padding(.top, DesignSystem.Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func submit() async {
        emailFocused = false
        isSubmitting = true
        defer { isSubmitting = false }
        await vm.sendPasswordReset(email: email)
    }
}

#Preview {
    ForgotPasswordSheet(vm: AuthViewModel())
        .preferredColorScheme(.dark)
}
