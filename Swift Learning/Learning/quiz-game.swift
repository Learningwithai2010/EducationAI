// Simple Quiz Game - EducationAI prototype

// Need to shuffle questions randomly
let questions = [
    (question: "What is 5 + 3?", answer: "8", explanation: "5 + 3 = 8. When adding, combine the values together."),
    (question: "What is the capital of France?", answer: "paris", explanation: "Paris is the capital and largest city of France, located in the north-central part of the country."),
    (question: "How many sides does a triangle have?", answer: "3", explanation: "A triangle is a polygon with three sides and three angles. 'Tri' means three!")
].shuffled()

print("=== EducationAI Quiz Game ===")
print("Answer the following questions!\n")

var score = 0
let totalQuestions = questions.count

for (index, item) in questions.enumerated() {
    print("Question \(index + 1): \(item.question)")
    print("Your answer: ", terminator: "")
    
    if let answer = readLine() {
        if answer.lowercased() == item.answer.lowercased() {
            print("✅ Correct!\n")
            score = score + 1
        } else {
            print("❌ Wrong.")
            print("💡 Explanation: \(item.explanation)\n")
        }
    }
}

// Final Results
print("=== Quiz Complete! ===")
print("Your Score: \(score)/\(totalQuestions)")

let percentage = (Double(score) / Double(totalQuestions)) * 100

if percentage >= 80 {
    print("Amazing! You got \(percentage)%! 🔥")
} else if percentage >= 60 {
    print("Good effort! You got \(percentage)%. Keep studying! 📚")
} else {
    print("You got \(percentage)%. Let's review this material together! 🤝")
}