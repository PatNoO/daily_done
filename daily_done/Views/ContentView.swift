import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HabitListView()
            }
            .tabItem {
                Label("Habits", systemImage: "checkmark.circle")
            }
            
            NavigationStack{
                Text("Stats view Coming Soon")
                    .navigationTitle(Text("Stats"))
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
            
            NavigationStack {
                Text("Profile View Coming Soon")
                    .navigationTitle(Text("Settings"))
            }
            .tabItem {
                Label("Profile", systemImage: "person.circle")
            }
        }
    }
}

#Preview {
    ContentView()
}
