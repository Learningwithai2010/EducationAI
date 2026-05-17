import SwiftUI

@main
struct EducationAIApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var quizEngine = QuizEngine()
    @StateObject private var chatVM = ChatViewModel()

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(quizEngine)
                    .environmentObject(chatVM)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
    }
}
