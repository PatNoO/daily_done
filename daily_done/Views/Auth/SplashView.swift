import SwiftUI

struct SplashView: View {
    var onGetStarted: () -> Void

    var body: some View {
        ZStack {
            Color("backgroundPrimary")
                .ignoresSafeArea()

            RadialGradient(
                colors: [Color("brandPrimary").opacity(0.3), .clear],
                center: .center,
                startRadius: 0,
                endRadius: 280
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color("brandPrimary").opacity(0.9))
                        .frame(width: 96, height: 96)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(.white)
                }

                Spacer().frame(height: 32)

                VStack(spacing: 12) {
                    Text("Daily Done")
                        .font(.largeTitle).fontWeight(.bold)
                        .foregroundStyle(Color("textPrimary"))
                    Text("Build habits that stick")
                        .font(.body)
                        .foregroundStyle(Color("textSecondary"))
                }

                Spacer().frame(height: 48)

                Button(action: onGetStarted) {
                    HStack(spacing: 8) {
                        Text("Get Started").fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color("brandPrimary"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 32)

                Spacer()
            }

            VStack {
                Spacer()
                HStack {
                    Text("v1.0.0")
                        .font(.caption2)
                        .foregroundStyle(Color("textSecondary").opacity(0.5))
                        .padding(.leading, 16)
                        .padding(.bottom, 16)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    SplashView(onGetStarted: {})
        .preferredColorScheme(.dark)
}
