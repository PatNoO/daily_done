import SwiftUI

struct ContentView: View {
    @ObservedObject var auth: AuthViewModel
    @AppStorage(UserDefaultsKey.darkModeEnabled) private var darkModeEnabled = true

    var body: some View {
        TabView {
            NavigationStack {
                HabitListView()
            }
            .tabItem {
                Label("Habits", systemImage: "checkmark.circle")
            }

            NavigationStack {
                StatsView()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
            NavigationStack {
                MapView()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }

            NavigationStack {
                ProfileView(vm: auth)
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
        }
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }
}

#Preview {
    ContentView(auth: AuthViewModel())
        .environment(\.userId, "preview-user")
}
