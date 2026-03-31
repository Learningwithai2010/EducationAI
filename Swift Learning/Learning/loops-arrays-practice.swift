// Arrays and Loops - Working with lists of data

// Create an array of quiz scores
let quizScores = [95.0, 82.0, 67.0, 88.0, 45.0]

print("=== All Quiz Scores ===")

// Loop through each score
for score in quizScores {
    print("Score: \(score)%")
}

// Now let's give feedback for each score
print("\n=== Smart Feedback System ===")

for score in quizScores {
    // Use your conditional logic from yesterday
    if score >= 90 {
        print("\(score)% - Outstanding! You've mastered this!")
    } else if score >= 80 {
        print("\(score)% - Great work! Keep it up!")
    } else if score >= 70 {
        print("\(score)% - Good effort! Almost there!")
    } else if score >= 60 {
        print("\(score)% - Keep studying! You're improving!")
    } else {
        print("\(score)% - Let's work through this together!")
    }
}

// Calculate average score
print("\n=== Grade Statistics ===")

var total = 0.0
for score in quizScores {
    total = total + score
}

let average = total / Double(quizScores.count)
print("Average score: \(average)%")

if average >= 80 {
    print("Overall performance: Strong! 💪")
} else if average >= 70 {
    print("Overall performance: Solid progress 📈")
} else {
    print("Overall performance: Needs improvement 📚")
}

// Student progress tracker
print("\n=== Student Progress Report ===")

let studentName = "Max"
var passingQuizzes = 0
var failingQuizzes = 0

for score in quizScores {
    if score >= 70 {
        passingQuizzes = passingQuizzes + 1
    } else {
        failingQuizzes = failingQuizzes + 1
    }
}

print("Student: \(studentName)")
print("Total quizzes: \(quizScores.count)")
print("Passing (70%+): \(passingQuizzes)")
print("Needs work (<70%): \(failingQuizzes)")

let passRate = (Double(passingQuizzes) / Double(quizScores.count)) * 100
print("Pass rate: \(passRate)%")

if passRate >= 80 {
    print("Status: On track! 🎯")
} else if passRate >= 60 {
    print("Status: Making progress 📈")
} else {
    print("Status: Needs intervention 🆘")
}