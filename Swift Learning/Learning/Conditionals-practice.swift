// Conditionals - Making code make decisions

// Simple grade feedback
func getGradeFeedback(score: Double) -> String {
    if score >= 90 {
        return "Outstanding! You've mastered this topic!"
    } else if score >= 80 {
        return "Great work! You're on the right track!"
    } else if score >= 70 {
        return "Good effort! A bit more practice will help!"
    } else if score >= 60 {
        return "Keep studying! You're making progress!"
    } else {
        return "Let's work through this together. You got this!"
    }
}

// Test it with different scores
print("Score: 95%")
print(getGradeFeedback(score: 95))

print("\nScore: 82%")
print(getGradeFeedback(score: 82))

print("\nScore: 67%")
print(getGradeFeedback(score: 67))

print("\nScore: 45%")
print(getGradeFeedback(score: 45))
// More advanced: Check if student needs help

func shouldOfferHelp(score: Double, attempts: Int) {
    if score < 50 && attempts > 2 {
        print("You've tried 3 times and scored below 50%. Let's schedule a tutoring session!")
    } else if score < 70 && attempts > 3 {
        print("This is taking a while. Want to try a different study method?")
    } else if score >= 90 {
        print("You're doing great! Ready for harder material?")
    } else {
        print("Keep practicing! You're making progress.")
    }
}

// Test it
print("\n--- Smart Feedback ---")
shouldOfferHelp(score: 45, attempts: 3)
shouldOfferHelp(score: 65, attempts: 4)
shouldOfferHelp(score: 95, attempts: 1)