import Foundation
import Combine

@MainActor
final class NotificationViewModel: ObservableObject {
    @Published var permissionDenied = false
    
    private let service: NotificationServiceProtocol

    init(service: NotificationServiceProtocol? = nil) {
        self.service = service ?? NotificationService.shared
    }
    
    func requestPermission() async -> Bool {
        let granted = await service.requestPermission()
        permissionDenied = !granted
        return granted
    }
    
    func scheduleIfEnabled(for habit: Habit) async {
          await service.scheduleReminder(for: habit)
      }

      func cancelReminder(habitId: String) {
          service.cancelReminder(habitId: habitId)
      }
}
