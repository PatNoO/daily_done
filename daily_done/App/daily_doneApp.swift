import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}
@main
struct daily_doneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var auth = AuthViewModel()
    @State private var splashDissmised = false

    var body: some Scene {
        WindowGroup {
            if auth.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if auth.isSignedIn, let userId = auth.userId {
                ContentView(userId: userId, auth: auth)

            } else if !splashDissmised {
                SplashView(onGetStarted: { splashDissmised = true })
            } else {
                SignInView(vm: auth)
            }
        }
    }
}
