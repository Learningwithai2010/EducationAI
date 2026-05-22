import SwiftUI

// MARK: - Flow layout for chip tags (iOS 16+)

struct WrappingHStack: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var height: CGFloat = 0
        for (i, row) in rows.enumerated() {
            height += (row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0)
            if i < rows.count - 1 { height += spacing }
        }
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in computeRows(proposal: proposal, subviews: subviews) {
            var x = bounds.minX
            let rowH = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            for sv in row {
                let size = sv.sizeThatFits(.unspecified)
                sv.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowH + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubview]] {
        var rows: [[LayoutSubview]] = [[]]
        var rowWidth: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for sv in subviews {
            let w = sv.sizeThatFits(.unspecified).width
            if !rows[rows.count - 1].isEmpty && rowWidth + spacing + w > maxWidth {
                rows.append([])
                rowWidth = 0
            }
            rows[rows.count - 1].append(sv)
            rowWidth += (rows[rows.count - 1].count > 1 ? spacing : 0) + w
        }
        return rows.filter { !$0.isEmpty }
    }
}

// MARK: - Reusable chip view

struct TagChip: View {
    let text: String
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 4) {
            Text(text).font(.subheadline)
            if let remove = onRemove {
                Button(action: remove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.12))
        .cornerRadius(20)
    }
}

// MARK: - Onboarding profile setup flow

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool

    @State private var step = 0
    @State private var studentName = ""
    @State private var schoolName = ""
    @State private var gradeLevel = "Freshman"
    @State private var courses: [String] = []
    @State private var activities: [String] = []
    @State private var newCourse = ""
    @State private var newActivity = ""

    private let grades = ["Freshman", "Sophomore", "Junior", "Senior"]
    private let totalSteps = 6

    var body: some View {
        VStack(spacing: 0) {
            progressHeader
            Group {
                switch step {
                case 0: nameStep
                case 1: schoolStep
                case 2: gradeStep
                case 3: coursesStep
                case 4: activitiesStep
                default: confirmationStep
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            navButtons
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    // MARK: - Progress header

    private var progressHeader: some View {
        VStack(spacing: 6) {
            HStack(spacing: 5) {
                ForEach(0..<totalSteps, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i <= step ? Color.blue : Color.gray.opacity(0.25))
                        .frame(height: 4)
                        .animation(.easeInOut, value: step)
                }
            }
            .padding(.horizontal, 24)
            Text("Step \(step + 1) of \(totalSteps)")
                .font(.caption).foregroundColor(.gray)
        }
        .padding(.top, 60)
        .padding(.bottom, 10)
    }

    // MARK: - Navigation buttons

    private var navButtons: some View {
        HStack(spacing: 12) {
            if step > 0 {
                Button("Back") { withAnimation { step -= 1 } }
                    .font(.headline).foregroundColor(.blue)
                    .frame(maxWidth: .infinity).padding()
                    .background(Color(.systemGray6)).cornerRadius(12)
            }
            if step < totalSteps - 1 {
                Button("Continue") { withAnimation { step += 1 } }
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding()
                    .background(canContinue ? Color.blue : Color.gray).cornerRadius(12)
                    .disabled(!canContinue)
            } else {
                Button("Start Learning") { saveAndFinish() }
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.blue).cornerRadius(12)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 40)
        .padding(.top, 12)
    }

    private var canContinue: Bool {
        switch step {
        case 0: return !studentName.trimmingCharacters(in: .whitespaces).isEmpty
        case 1: return !schoolName.trimmingCharacters(in: .whitespaces).isEmpty
        default: return true
        }
    }

    private func saveAndFinish() {
        let ud = UserDefaults.standard
        ud.set(studentName.trimmingCharacters(in: .whitespaces), forKey: "userName")
        ud.set(schoolName.trimmingCharacters(in: .whitespaces), forKey: "userSchool")
        ud.set(gradeLevel, forKey: "userGrade")
        if let d = try? JSONEncoder().encode(courses) { ud.set(d, forKey: "userCourses") }
        if let d = try? JSONEncoder().encode(activities) { ud.set(d, forKey: "userActivities") }
        hasCompletedOnboarding = true
    }

    // MARK: - Step 1: Name

    private var nameStep: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: "person.circle.fill")
                .font(.system(size: 72)).foregroundColor(.blue)
            VStack(spacing: 8) {
                Text("What's your name?").font(.title).fontWeight(.bold)
                Text("We'll personalize your learning experience")
                    .font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center)
            }
            TextField("Your name", text: $studentName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title3).padding(.horizontal, 32)
                .autocapitalization(.words)
                .submitLabel(.continue)
                .onSubmit { if canContinue { withAnimation { step += 1 } } }
            Spacer()
            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Step 2: School

    private var schoolStep: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: "building.columns.fill")
                .font(.system(size: 72)).foregroundColor(.blue)
            VStack(spacing: 8) {
                Text("Your School").font(.title).fontWeight(.bold)
                Text("Tell us where you study")
                    .font(.subheadline).foregroundColor(.gray)
            }
            TextField("Enter your school", text: $schoolName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title3).padding(.horizontal, 32)
                .autocapitalization(.words)
                .submitLabel(.continue)
                .onSubmit { if canContinue { withAnimation { step += 1 } } }
            Spacer()
            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Step 3: Grade

    private var gradeStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "graduationcap.fill")
                .font(.system(size: 72)).foregroundColor(.blue)
            VStack(spacing: 8) {
                Text("What grade are you in?").font(.title).fontWeight(.bold)
                Text("We'll tailor content to your level")
                    .font(.subheadline).foregroundColor(.gray)
            }
            VStack(spacing: 10) {
                ForEach(grades, id: \.self) { grade in
                    Button(action: { gradeLevel = grade }) {
                        HStack {
                            Text(grade).font(.headline)
                                .foregroundColor(gradeLevel == grade ? .white : .primary)
                            Spacer()
                            if gradeLevel == grade {
                                Image(systemName: "checkmark").foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(gradeLevel == grade ? Color.blue : Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 32)
            Spacer()
            Spacer()
        }
        .padding(.horizontal)
    }

    // MARK: - Step 4: Courses

    private var coursesStep: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "book.fill")
                .font(.system(size: 60)).foregroundColor(.blue)
            VStack(spacing: 8) {
                Text("Your Courses").font(.title).fontWeight(.bold)
                Text("Add your current classes")
                    .font(.subheadline).foregroundColor(.gray)
            }
            HStack(spacing: 10) {
                TextField("Add a course (e.g. AP Biology)", text: $newCourse)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .submitLabel(.done)
                    .onSubmit { addCourse() }
                Button(action: addCourse) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(newCourse.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                }
                .disabled(newCourse.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 24)
            if courses.isEmpty {
                Text("No courses added yet").font(.caption).foregroundColor(.gray)
            } else {
                ScrollView {
                    WrappingHStack(spacing: 8) {
                        ForEach(courses, id: \.self) { c in
                            TagChip(text: c) { courses.removeAll { $0 == c } }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxHeight: 140)
            }
            Spacer()
        }
    }

    // MARK: - Step 5: Activities

    private var activitiesStep: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "sportscourt.fill")
                .font(.system(size: 60)).foregroundColor(.blue)
            VStack(spacing: 8) {
                Text("Sports & Activities").font(.title).fontWeight(.bold)
                Text("Add your extracurriculars (optional)")
                    .font(.subheadline).foregroundColor(.gray)
            }
            HStack(spacing: 10) {
                TextField("Add an activity (e.g. Soccer)", text: $newActivity)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .submitLabel(.done)
                    .onSubmit { addActivity() }
                Button(action: addActivity) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(newActivity.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                }
                .disabled(newActivity.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 24)
            if activities.isEmpty {
                Text("No activities added yet").font(.caption).foregroundColor(.gray)
            } else {
                ScrollView {
                    WrappingHStack(spacing: 8) {
                        ForEach(activities, id: \.self) { a in
                            TagChip(text: a) { activities.removeAll { $0 == a } }
                        }
                    }
                    .padding(.horizontal, 24)
                }
                .frame(maxHeight: 140)
            }
            Spacer()
        }
    }

    // MARK: - Step 6: Confirmation

    private var confirmationStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 10)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72)).foregroundColor(.green)
                VStack(spacing: 6) {
                    Text("You're all set, \(studentName)!").font(.title2).fontWeight(.bold)
                    Text("Here's your profile").font(.subheadline).foregroundColor(.gray)
                }
                VStack(spacing: 10) {
                    confirmRow("person.fill", "Name", studentName)
                    confirmRow("building.columns.fill", "School", schoolName)
                    confirmRow("graduationcap.fill", "Grade", gradeLevel)
                    if !courses.isEmpty { confirmTagSection("book.fill", "Courses", courses) }
                    if !activities.isEmpty { confirmTagSection("sportscourt.fill", "Activities", activities) }
                }
                .padding(.horizontal, 24)
                Spacer().frame(height: 20)
            }
        }
    }

    private func confirmRow(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(.blue).frame(width: 24)
            Text(label).fontWeight(.semibold)
            Spacer()
            Text(value).foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func confirmTagSection(_ icon: String, _ label: String, _ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(label, systemImage: icon)
                .fontWeight(.semibold).font(.subheadline)
            WrappingHStack(spacing: 6) {
                ForEach(items, id: \.self) { item in
                    Text(item).font(.caption)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.blue.opacity(0.1)).cornerRadius(20)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func addCourse() {
        let t = newCourse.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty, !courses.contains(t) else { return }
        courses.append(t); newCourse = ""
    }

    private func addActivity() {
        let t = newActivity.trimmingCharacters(in: .whitespaces)
        guard !t.isEmpty, !activities.contains(t) else { return }
        activities.append(t); newActivity = ""
    }
}
