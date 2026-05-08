import SwiftUI
struct LogoView: View {
    var size: CGFloat = 96

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color("brandPrimary"), Color("brandPrimary").opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            HStack(spacing: size * 0.01) {
                Text("D")
                    .font(.system(size: size * 0.44, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .offset(y: -(size * 0.06))

                Text("D")
                    .font(.system(size: size * 0.44, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .offset(y: size * 0.06)
            }
        }
    }
}
