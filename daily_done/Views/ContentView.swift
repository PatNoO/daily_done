import SwiftUI

struct ContentView: View {

    @ObservedObject var authViewModel: AuthViewModel

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
                ProfileView(vm: authViewModel)
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
        }
    }
}

#Preview {
    ContentView(authViewModel: AuthViewModel())
}
