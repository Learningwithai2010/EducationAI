import SwiftUI
import Combine
struct Question: Identifiable {
    let id = UUID()
    let text: String
    let options: [String]
    let correctIndex: Int
    let explanation: String
}

class QuizEngine: ObservableObject {
    @Published var questions: [Question] = []
    @Published var currentIndex = 0
    @Published var score = 0
    @Published var selectedAnswer: Int? = nil
    @Published var showExplanation = false
    @Published var quizComplete = false
    
    let sampleQuestions: [String: [Question]] = [
        "Science": [
            Question(text: "What is the powerhouse of the cell?", options: ["Nucleus", "Mitochondria", "Ribosome", "Cell Wall"], correctIndex: 1, explanation: "Mitochondria produce ATP, which is the energy currency of the cell."),
            Question(text: "What gas do plants absorb from the atmosphere?", options: ["Oxygen", "Nitrogen", "Carbon Dioxide", "Hydrogen"], correctIndex: 2, explanation: "Plants absorb CO2 and use it in photosynthesis to make glucose."),
            Question(text: "What is the chemical symbol for water?", options: ["H2O", "CO2", "NaCl", "O2"], correctIndex: 0, explanation: "Water is made of 2 hydrogen atoms and 1 oxygen atom: H2O."),
            Question(text: "Which planet is closest to the Sun?", options: ["Venus", "Earth", "Mercury", "Mars"], correctIndex: 2, explanation: "Mercury is the closest planet to the Sun at about 36 million miles away."),
            Question(text: "What force keeps us on the ground?", options: ["Magnetism", "Friction", "Gravity", "Inertia"], correctIndex: 2, explanation: "Gravity is the force that attracts objects with mass toward each other.")
        ],
        "Math": [
            Question(text: "What is 15% of 200?", options: ["15", "20", "25", "30"], correctIndex: 3, explanation: "15% of 200 = 0.15 × 200 = 30."),
            Question(text: "What is the square root of 144?", options: ["10", "11", "12", "14"], correctIndex: 2, explanation: "12 × 12 = 144, so the square root of 144 is 12."),
            Question(text: "What is the value of pi (approximately)?", options: ["2.14", "3.14", "4.14", "3.41"], correctIndex: 1, explanation: "Pi is approximately 3.14159, commonly rounded to 3.14."),
            Question(text: "What is 7 × 8?", options: ["54", "56", "58", "64"], correctIndex: 1, explanation: "7 × 8 = 56. A common multiplication fact to memorize."),
            Question(text: "What type of angle is exactly 90°?", options: ["Acute", "Obtuse", "Right", "Straight"], correctIndex: 2, explanation: "A right angle measures exactly 90 degrees.")
        ],
        "History": [
            Question(text: "In what year did World War II end?", options: ["1943", "1944", "1945", "1946"], correctIndex: 2, explanation: "WWII ended in 1945 with the surrender of Germany in May and Japan in August."),
            Question(text: "Who was the first President of the United States?", options: ["John Adams", "Thomas Jefferson", "Benjamin Franklin", "George Washington"], correctIndex: 3, explanation: "George Washington served as the first President from 1789 to 1797."),
            Question(text: "What ancient civilization built the pyramids?", options: ["Romans", "Greeks", "Egyptians", "Persians"], correctIndex: 2, explanation: "The ancient Egyptians built the pyramids as tombs for their pharaohs."),
            Question(text: "What document declared American independence?", options: ["The Constitution", "Bill of Rights", "Declaration of Independence", "Magna Carta"], correctIndex: 2, explanation: "The Declaration of Independence was adopted on July 4, 1776."),
            Question(text: "Which explorer is credited with discovering America?", options: ["Magellan", "Columbus", "Cortez", "Vespucci"], correctIndex: 1, explanation: "Christopher Columbus reached the Americas in 1492, though Indigenous peoples were already there.")
        ]
    ]
    
    func startQuiz(topic: String) {
        questions = sampleQuestions[topic] ?? []
        questions.shuffle()
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        showExplanation = false
        quizComplete = false
    }
    
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    func selectAnswer(_ index: Int) {
        selectedAnswer = index
        showExplanation = true
        if index == currentQuestion?.correctIndex {
            score += 1
        }
    }
    
    func nextQuestion() {
        selectedAnswer = nil
        showExplanation = false
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            quizComplete = true
        }
    }
    
    var scorePercentage: Int {
        guard questions.count > 0 else { return 0 }
        return Int((Double(score) / Double(questions.count)) * 100)
    }
}
