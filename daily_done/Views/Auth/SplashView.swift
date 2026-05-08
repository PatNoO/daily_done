import SwiftUI

struct SplashView: View {
    var onGetStarted: () -> Void

    var body: some View {
        ZStack {
            Color("backgroundPrimary")
                .ignoresSafeArea()

            RadialGradient(
                colors: [Color("brandPrimary").opacity(DesignSystem.Opacity.splashGradient), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 280
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                LogoView(size: DesignSystem.Size.logoCircle)

                Spacer().frame(height: DesignSystem.Spacing.xl)

                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("Daily Done")
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundStyle(Color("textPrimary"))
                    Text("Build habits that stick")
                        .font(.body)
                        .foregroundStyle(Color("textSecondary"))
                }

                Spacer().frame(height: DesignSystem.Spacing.xxl)

                Button(action: onGetStarted) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Text("Get Started").fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.base)
                    .background(Color("brandPrimary"))
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.button))
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)

                Spacer()
            }

            // MARK: - Version

            VStack {
                Spacer()
                HStack {
                    Text(appVersion)
                        .font(.caption2)
                        .foregroundStyle(Color("textSecondary").opacity(DesignSystem.Opacity.subtle))
                        .padding(.leading, DesignSystem.Spacing.base)
                        .padding(.bottom, DesignSystem.Spacing.base)
                    Spacer()
                }
            }
        }
    }

   
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return "v\(version)"
    }
}

#Preview {
    SplashView(onGetStarted: {})
        .preferredColorScheme(.dark)
}
