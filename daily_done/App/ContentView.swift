import SwiftUI

struct ContentView: View {
    let userId: String
    @ObservedObject var auth: AuthViewModel
    @AppStorage(UserDefaultsKey.darkModeEnabled) private var darkModeEnabled = true

    var body: some View {
        TabView {
            NavigationStack {
                HabitListView(userId: userId)
            }
            .tabItem {
                Label("Habits", systemImage: "checkmark.circle")
            }

            NavigationStack {
                StatsView(userId: userId)
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
            NavigationStack {
                MapView(userId: userId)
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }

            NavigationStack {
                ProfileView(userId: userId, vm: auth)
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
        }
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }
}

#Preview {
    ContentView(userId: "preview-user", auth: AuthViewModel())
}
