import SwiftUI

struct ErrorBannerView: View {
    let message: String

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: "exclamationmark.circle")
            Text(message)
                .font(.caption)
        }
        .foregroundStyle(Color("destructive"))
        .padding(DesignSystem.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("destructive").opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.Radius.sm))
    }
}

#Preview {
    ErrorBannerView(message: "Could not save habit. Check your connection and try again.")
        .padding()
}
