import SwiftUI

struct ContentView: View {
    let userId: String
    @ObservedObject var auth: AuthViewModel
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
                ProfileView(vm: auth)
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
        }
    }
}

#Preview {
    ContentView(userId: "preview-user", auth: AuthViewModel())
}
