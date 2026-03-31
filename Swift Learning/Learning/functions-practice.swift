func greetStudent(name: String){
    print("Welcome to Education AI, \(name)!")
}

greetStudent (name: "Max")
greetStudent (name: "Skibidi")
greetStudent (name: "Bean Boi")

func calculateGradeWhole(points: Int, total: Int) -> Int {
    return (points * 100) / total
}

func calculateGradeDecimal(points: Double, total: Double) -> Double { 
    return (points / total) * 100
}

let wholeGrade = calculateGradeWhole(points: 87, total : 100)
let decimalGrade = calculateGradeDecimal(points: 87.0, total: 100.0)

print("\nWith Int: \(wholeGrade)")
print("With Double: \(decimalGrade)")

// Now try with a tricky score:
let wholeGrade2 = calculateGradeWhole(points: 43, total: 50)
let decimalGrade2 = calculateGradeDecimal(points: 43, total: 50)

print("\nWith Int: \(wholeGrade2)")
print("With Double: \(decimalGrade2)")

let wholeGrade3 = calculateGradeWhole(points: 87, total:90)
let decimalGrade3 = calculateGradeDecimal(points: 87.0, total:90.0)

print("\nScore = 87 out of 90")
print ("With Int: \(wholeGrade3)")
print ("With Double: \(decimalGrade3)")