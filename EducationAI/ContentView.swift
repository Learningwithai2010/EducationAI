import SwiftUI
import Combine

// MARK: - Chat persistence model

struct ChatMessage: Identifiable, Equatable, Codable {
    let id: UUID
    let text: String
    let isUser: Bool

    init(text: String, isUser: Bool) {
        self.id = UUID()
        self.text = text
        self.isUser = isUser
    }
}

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isTyping = false

    private let storageKey = "chat_messages"
    private let welcomeMessage = ChatMessage(
        text: "Hi! I'm your AI tutor. I won't give you answers — but I'll help you think through any problem. What would you like to learn?",
        isUser: false
    )

    init() {
        loadMessages()
    }

    func sendMessage(_ text: String) async {
        messages.append(ChatMessage(text: text, isUser: true))
        isTyping = true
        saveMessages()

        // Claude requires the first message to be from the user, so skip any leading assistant messages
        var apiMessages: [(role: String, content: String)] = []
        var foundUser = false
        for msg in messages {
            if msg.isUser { foundUser = true }
            if foundUser {
                apiMessages.append((role: msg.isUser ? "user" : "assistant", content: msg.text))
            }
        }

        do {
            let response = try await ClaudeService.shared.sendMessage(messages: apiMessages)
            messages.append(ChatMessage(text: response, isUser: false))
        } catch {
            messages.append(ChatMessage(text: error.localizedDescription, isUser: false))
        }

        isTyping = false
        saveMessages()
    }

    func clearMessages() {
        messages = [welcomeMessage]
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func saveMessages() {
        let toSave = Array(messages.suffix(100))
        if let data = try? JSONEncoder().encode(toSave) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadMessages() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let saved = try? JSONDecoder().decode([ChatMessage].self, from: data),
              !saved.isEmpty else {
            messages = [welcomeMessage]
            return
        }
        messages = saved
    }
}

// MARK: - Assignment model

struct Assignment: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var dueDate: Date
    var type: String
    var isCompleted: Bool

    init(title: String, dueDate: Date, type: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.dueDate = dueDate
        self.type = type
        self.isCompleted = isCompleted
    }

    var displayDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: dueDate)
    }

    var isOverdue: Bool {
        !isCompleted && dueDate < Calendar.current.startOfDay(for: Date())
    }
}

// MARK: - Root

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            QuizView()
                .tabItem {
                    Image(systemName: "questionmark.circle.fill")
                    Text("Quiz")
                }
                .tag(1)

            ChatView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
                .tag(2)

            CalendarTabView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(4)
        }
        .tint(.blue)
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }
}

// MARK: - Home

struct HomeView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject private var quizEngine: QuizEngine

    private var todayDay: Int {
        Calendar.current.component(.day, from: Date())
    }

    private var currentMonthYear: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: Date())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 44))
                        .foregroundColor(.blue)
                    Text("EducationAI")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Learn smarter, not harder")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 45)

                // Calendar widget
                Button(action: { selectedTab = 3 }) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "calendar").foregroundColor(.blue)
                            Text("Calendar").font(.headline).foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray).font(.caption)
                        }
                        let days = ["S", "M", "T", "W", "T", "F", "S"]
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(days, id: \.self) { day in
                                Text(day).font(.caption2).foregroundColor(.gray)
                            }
                            ForEach(1...31, id: \.self) { day in
                                Text("\(day)")
                                    .font(.caption)
                                    .frame(width: 28, height: 28)
                                    .background(day == todayDay ? Color.blue : Color.clear)
                                    .foregroundColor(day == todayDay ? .white : .primary)
                                    .cornerRadius(14)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 25)

                // Recent quizzes widget
                Button(action: { selectedTab = 1 }) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill").foregroundColor(.blue)
                            Text("Recent Quizzes").font(.headline).foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right").foregroundColor(.gray).font(.caption)
                        }
                        if quizEngine.quizHistory.isEmpty {
                            Text("No quizzes taken yet. Start one!")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.vertical, 8)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(quizEngine.quizHistory.prefix(3)) { result in
                                    QuizRow(subject: result.topic, date: result.formattedDate, score: "\(result.percentage)%")
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 10)

                Button(action: { selectedTab = 2 }) {
                    Text("Start Learning")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
                .padding(.top, 5)
            }
        }
    }
}

struct QuizRow: View {
    let subject: String
    let date: String
    let score: String

    var scoreColor: Color {
        let number = Int(score.replacingOccurrences(of: "%", with: "")) ?? 0
        if number >= 80 { return .green }
        if number >= 50 { return .orange }
        return .red
    }

    var body: some View {
        HStack {
            Text(subject).font(.subheadline).foregroundColor(.primary)
            Spacer()
            Text(date).font(.caption).foregroundColor(.gray)
            Text(score).font(.subheadline).fontWeight(.semibold).foregroundColor(scoreColor)
        }
    }
}

// MARK: - Quiz

struct QuizView: View {
    @EnvironmentObject private var engine: QuizEngine
    @EnvironmentObject private var chatVM: ChatViewModel
    @State private var customTopic = ""
    @State private var showManualCreator = false
    @State private var pendingTopic: String? = nil

    private let presetTopics = ["Science", "Math", "History"]

    private var hasChatMessages: Bool {
        chatVM.messages.contains { $0.isUser }
    }

    var body: some View {
        NavigationView {
            Group {
                if engine.isGenerating {
                    generatingView
                } else if let errorMessage = engine.errorMessage {
                    errorView(message: errorMessage)
                } else if engine.quizComplete {
                    resultsView
                } else if engine.currentQuestion != nil {
                    questionView
                } else if let topic = pendingTopic {
                    confirmationView(topic: topic)
                } else {
                    topicSelectionView
                }
            }
            .navigationTitle("Quiz")
            .sheet(isPresented: $showManualCreator) {
                ManualQuizCreatorView()
                    .environmentObject(engine)
            }
        }
    }

    // MARK: Topic selection

    private var topicSelectionView: some View {
        ScrollView {
            VStack(spacing: 16) {
                Spacer().frame(height: 10)

                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 46))
                    .foregroundColor(.blue)

                Text("Start a Quiz")
                    .font(.title2)
                    .fontWeight(.bold)

                // From chat history
                VStack(alignment: .leading, spacing: 10) {
                    Label("From Your Chats", systemImage: "message.fill")
                        .font(.headline)
                    if hasChatMessages {
                        Button(action: {
                            let msgs = chatVM.messages.map {
                                (role: $0.isUser ? "user" : "assistant", content: $0.text)
                            }
                            Task { await engine.startQuizFromChatHistory(chatMessages: msgs) }
                        }) {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("Quiz Me on What I Studied")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                    } else {
                        Text("Chat with the AI tutor first — then come back to quiz yourself on what you covered.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 20)

                // AI quiz by topic
                VStack(alignment: .leading, spacing: 10) {
                    Label("AI Quiz by Topic", systemImage: "sparkles")
                        .font(.headline)

                    ForEach(presetTopics, id: \.self) { topic in
                        Button(action: {
                            pendingTopic = topic
                        }) {
                            Text(topic)
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }

                    HStack(spacing: 10) {
                        TextField("Custom topic (e.g. Algebra)...", text: $customTopic)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.words)
                            .disableAutocorrection(true)
                        Button(action: {
                            let topic = customTopic.trimmingCharacters(in: .whitespaces)
                            guard !topic.isEmpty else { return }
                            customTopic = ""
                            pendingTopic = topic
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(customTopic.trimmingCharacters(in: .whitespaces).isEmpty ? .gray : .blue)
                        }
                        .disabled(customTopic.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 20)

                // Create manually
                Button(action: { showManualCreator = true }) {
                    HStack {
                        Image(systemName: "pencil.circle")
                        Text("Create Quiz Manually")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)

                // Recent quizzes
                if !engine.quizHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent Quizzes")
                            .font(.headline)
                            .padding(.horizontal)
                        ForEach(engine.quizHistory.prefix(5)) { result in
                            HStack {
                                Text(result.topic).font(.subheadline)
                                Spacer()
                                Text(result.formattedDate).font(.caption).foregroundColor(.gray)
                                Text("\(result.percentage)%")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(result.percentage >= 80 ? .green : result.percentage >= 50 ? .orange : .red)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 4)
                }

                Spacer().frame(height: 20)
            }
        }
    }

    // MARK: Confirmation

    private func confirmationView(topic: String) -> some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            Text("Ready to Quiz?")
                .font(.title2)
                .fontWeight(.bold)
            Text("5 questions on \(topic)")
                .font(.subheadline)
                .foregroundColor(.gray)
            Button(action: {
                pendingTopic = nil
                Task { await engine.startAIQuiz(topic: topic) }
            }) {
                Text("Start Quiz")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 30)
            Button("Back") { pendingTopic = nil }
                .foregroundColor(.blue)
            Spacer()
        }
    }

    // MARK: Generating

    private var generatingView: some View {
        VStack(spacing: 20) {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Text("Generating quiz with Claude AI...")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
        }
    }

    // MARK: Error

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text("Could not generate quiz")
                .font(.title3)
                .fontWeight(.semibold)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            Button("Try Again") {
                engine.resetToTopicSelection()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
            .padding(.horizontal, 30)
            Spacer()
        }
    }

    // MARK: Question

    @ViewBuilder
    private var questionView: some View {
        if let question = engine.currentQuestion {
            VStack(spacing: 20) {
                ProgressView(value: Double(engine.currentIndex + 1), total: Double(engine.questions.count))
                    .tint(.blue)
                    .padding(.horizontal)
                    .padding(.top, 8)

                Text("Question \(engine.currentIndex + 1) of \(engine.questions.count)")
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(question.text)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    ForEach(0..<question.options.count, id: \.self) { index in
                        Button(action: {
                            if engine.selectedAnswer == nil {
                                engine.selectAnswer(index)
                            }
                        }) {
                            HStack {
                                Text(question.options[index])
                                    .foregroundColor(answerTextColor(index: index, question: question))
                                Spacer()
                                if engine.showExplanation {
                                    if index == question.correctIndex {
                                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                    } else if index == engine.selectedAnswer {
                                        Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                                    }
                                }
                            }
                            .padding()
                            .background(answerBackground(index: index, question: question))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(answerBorderColor(index: index, question: question), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal)

                if engine.showExplanation {
                    Text(question.explanation)
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)

                    Button("Next Question") { engine.nextQuestion() }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding(.horizontal, 30)
                }

                Spacer()
            }
        }
    }

    // MARK: Results

    private var resultsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 10)

                Image(systemName: engine.scorePercentage >= 80 ? "star.fill" : engine.scorePercentage >= 50 ? "hand.thumbsup.fill" : "book.fill")
                    .font(.system(size: 60))
                    .foregroundColor(engine.scorePercentage >= 80 ? .green : engine.scorePercentage >= 50 ? .orange : .red)

                Text("Quiz Complete!")
                    .font(.title)
                    .fontWeight(.bold)

                Text("\(engine.score)/\(engine.questions.count)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)

                Text("\(engine.scorePercentage)%")
                    .font(.title2)
                    .foregroundColor(engine.scorePercentage >= 80 ? .green : engine.scorePercentage >= 50 ? .orange : .red)

                if !engine.questionResults.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Question Summary")
                            .font(.headline)
                            .padding(.horizontal)
                        ForEach(engine.questionResults.indices, id: \.self) { i in
                            let r = engine.questionResults[i]
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: r.wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(r.wasCorrect ? .green : .red)
                                    .font(.system(size: 16))
                                Text(r.questionText)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }

                Button("Try Another Quiz") {
                    pendingTopic = nil
                    engine.resetToTopicSelection()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal, 30)

                Spacer().frame(height: 20)
            }
        }
    }

    private func answerTextColor(index: Int, question: Question) -> Color {
        guard engine.showExplanation else { return .primary }
        if index == question.correctIndex { return .green }
        if index == engine.selectedAnswer { return .red }
        return .gray
    }

    private func answerBackground(index: Int, question: Question) -> Color {
        guard engine.showExplanation else { return Color(.systemGray6) }
        if index == question.correctIndex { return Color.green.opacity(0.15) }
        if index == engine.selectedAnswer { return Color.red.opacity(0.15) }
        return Color(.systemGray6)
    }

    private func answerBorderColor(index: Int, question: Question) -> Color {
        guard engine.showExplanation else { return Color.gray.opacity(0.3) }
        if index == question.correctIndex { return Color.green.opacity(0.5) }
        if index == engine.selectedAnswer { return Color.red.opacity(0.5) }
        return Color.gray.opacity(0.2)
    }
}

// MARK: - Chat

struct ChatView: View {
    @EnvironmentObject private var chatVM: ChatViewModel
    @State private var messageText = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(chatVM.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            if chatVM.isTyping {
                                TypingIndicator()
                                    .id("typing")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatVM.messages.count) {
                        withAnimation {
                            if chatVM.isTyping {
                                proxy.scrollTo("typing", anchor: .bottom)
                            } else if let last = chatVM.messages.last {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: chatVM.isTyping) {
                        withAnimation {
                            if chatVM.isTyping {
                                proxy.scrollTo("typing", anchor: .bottom)
                            } else if let last = chatVM.messages.last {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }

                HStack(spacing: 10) {
                    TextField("Ask me anything...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(chatVM.isTyping)

                    Button(action: {
                        let text = messageText.trimmingCharacters(in: .whitespaces)
                        guard !text.isEmpty else { return }
                        messageText = ""
                        Task { await chatVM.sendMessage(text) }
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(messageText.trimmingCharacters(in: .whitespaces).isEmpty || chatVM.isTyping ? .gray : .blue)
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty || chatVM.isTyping)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.text)
                .padding(12)
                .background(message.isUser ? Color.blue : Color(.systemGray5))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(16)
                .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            if !message.isUser { Spacer() }
        }
    }
}

struct TypingIndicator: View {
    @State private var animate = false

    var body: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(.gray)
                        .opacity(animate ? 1.0 : 0.3)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(i) * 0.18),
                            value: animate
                        )
                }
            }
            .padding(12)
            .background(Color(.systemGray5))
            .cornerRadius(16)
            Spacer()
        }
        .onAppear { animate = true }
    }
}

// MARK: - Calendar

struct CalendarTabView: View {
    @State private var assignments: [Assignment] = []
    @State private var showAddSheet = false
    @State private var newTitle = ""
    @State private var newDate = Date()
    @State private var newType = "Homework"

    private let assignmentTypes = ["Homework", "Test", "Project", "Reading", "Other"]

    private var currentMonthYear: String {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f.string(from: Date())
    }

    private var sortedAssignments: [Assignment] {
        let active = assignments.filter { !$0.isCompleted }.sorted { $0.dueDate < $1.dueDate }
        let done = assignments.filter { $0.isCompleted }.sorted { $0.dueDate < $1.dueDate }
        return active + done
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text(currentMonthYear)
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)

                if assignments.isEmpty {
                    Spacer()
                    Text("No assignments yet. Tap + to add one.")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                    Spacer()
                } else {
                    List {
                        ForEach(sortedAssignments) { assignment in
                            HStack {
                                Button(action: {
                                    if let i = assignments.firstIndex(where: { $0.id == assignment.id }) {
                                        assignments[i].isCompleted.toggle()
                                        saveAssignments()
                                    }
                                }) {
                                    Image(systemName: assignment.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(assignment.isCompleted ? .green : .gray)
                                        .font(.system(size: 22))
                                }
                                .buttonStyle(.plain)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(assignment.title)
                                        .strikethrough(assignment.isCompleted)
                                        .foregroundColor(assignment.isCompleted ? .gray : .primary)

                                    HStack {
                                        Text(assignment.type)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(4)
                                        Text(assignment.displayDate)
                                            .font(.caption)
                                            .foregroundColor(assignment.isOverdue ? .red : .gray)
                                        if assignment.isOverdue {
                                            Text("Overdue")
                                                .font(.caption2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }

                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indexSet in
                            let toDelete = indexSet.map { sortedAssignments[$0].id }
                            assignments.removeAll { toDelete.contains($0.id) }
                            saveAssignments()
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                addAssignmentSheet
            }
            .onAppear { loadAssignments() }
        }
    }

    private var addAssignmentSheet: some View {
        NavigationView {
            Form {
                Section("Assignment Details") {
                    TextField("Title", text: $newTitle)
                    DatePicker("Due Date", selection: $newDate, displayedComponents: .date)
                    Picker("Type", selection: $newType) {
                        ForEach(assignmentTypes, id: \.self) { Text($0) }
                    }
                }
            }
            .navigationTitle("New Assignment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        resetForm()
                        showAddSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let assignment = Assignment(
                            title: newTitle.trimmingCharacters(in: .whitespaces),
                            dueDate: newDate,
                            type: newType
                        )
                        assignments.append(assignment)
                        saveAssignments()
                        resetForm()
                        showAddSheet = false
                    }
                    .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func resetForm() {
        newTitle = ""
        newDate = Date()
        newType = "Homework"
    }

    private func loadAssignments() {
        if let data = UserDefaults.standard.data(forKey: "assignments"),
           let saved = try? JSONDecoder().decode([Assignment].self, from: data) {
            assignments = saved
        } else {
            let today = Date()
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
            let threeDays = Calendar.current.date(byAdding: .day, value: 3, to: today)!
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
            assignments = [
                Assignment(title: "Chemistry Test", dueDate: tomorrow, type: "Test"),
                Assignment(title: "English Essay", dueDate: threeDays, type: "Project"),
                Assignment(title: "Math Homework Ch.7", dueDate: yesterday, type: "Homework")
            ]
            saveAssignments()
        }
    }

    private func saveAssignments() {
        if let data = try? JSONEncoder().encode(assignments) {
            UserDefaults.standard.set(data, forKey: "assignments")
        }
    }
}

// MARK: - Settings

struct SettingsView: View {
    @EnvironmentObject private var quizEngine: QuizEngine
    @EnvironmentObject private var chatVM: ChatViewModel
    @AppStorage("userName") private var userName = ""
    @AppStorage("userGrade") private var userGrade = "Freshman"
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var apiKey = APIConfig.claudeAPIKey
    @State private var keySaved = false
    @State private var showClearQuizAlert = false
    @State private var showClearChatAlert = false
    @State private var showResetOnboardingAlert = false

    private let grades = ["Freshman", "Sophomore", "Junior", "Senior"]

    var body: some View {
        NavigationView {
            Form {
                Section("Profile") {
                    TextField("Your Name", text: $userName)
                    Picker("Grade", selection: $userGrade) {
                        ForEach(grades, id: \.self) { Text($0) }
                    }
                }

                Section("Preferences") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                    Toggle("Notifications", isOn: $notificationsEnabled)
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        SecureField("sk-ant-...", text: $apiKey)
                            .font(.system(.body, design: .monospaced))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: apiKey) { keySaved = false }

                        Button("Save Key") {
                            APIConfig.claudeAPIKey = apiKey.trimmingCharacters(in: .whitespaces)
                            keySaved = true
                        }
                        .disabled(apiKey.trimmingCharacters(in: .whitespaces).isEmpty)

                        if keySaved {
                            Label("Saved!", systemImage: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                } header: {
                    Text("Claude API Key")
                } footer: {
                    Text("Get your key at console.anthropic.com. It starts with sk-ant-. Never share it.")
                }

                Section("Data") {
                    Button("Clear Quiz History", role: .destructive) {
                        showClearQuizAlert = true
                    }
                    .alert("Clear Quiz History?", isPresented: $showClearQuizAlert) {
                        Button("Clear", role: .destructive) { quizEngine.clearHistory() }
                        Button("Cancel", role: .cancel) {}
                    }

                    Button("Clear Chat History", role: .destructive) {
                        showClearChatAlert = true
                    }
                    .alert("Clear Chat History?", isPresented: $showClearChatAlert) {
                        Button("Clear", role: .destructive) { chatVM.clearMessages() }
                        Button("Cancel", role: .cancel) {}
                    }

                    Button("Reset Onboarding") {
                        showResetOnboardingAlert = true
                    }
                    .foregroundColor(.blue)
                    .alert("Reset Onboarding?", isPresented: $showResetOnboardingAlert) {
                        Button("Reset", role: .destructive) { hasCompletedOnboarding = false }
                        Button("Cancel", role: .cancel) {}
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Made by")
                        Spacer()
                        Text("Maxi Baumgart").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("View on GitHub")
                        Spacer()
                        Image(systemName: "safari").foregroundColor(.blue)
                    }
                    HStack {
                        Text("AI Model")
                        Spacer()
                        Text("Claude Sonnet 4.6").foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Manual Quiz Creator

struct ManualQuizCreatorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var engine: QuizEngine

    @State private var builtQuestions: [Question] = []
    @State private var showAddForm = false

    // Per-question form state
    @State private var qText = ""
    @State private var opts = ["", "", "", ""]
    @State private var correctIdx = 0
    @State private var explanationText = ""

    private var isFormValid: Bool {
        !qText.trimmingCharacters(in: .whitespaces).isEmpty &&
        opts.allSatisfy { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var body: some View {
        NavigationView {
            Group {
                if builtQuestions.isEmpty {
                    emptyState
                } else {
                    questionsList
                }
            }
            .navigationTitle("Create Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        engine.startManualQuiz(questions: builtQuestions)
                        dismiss()
                    }
                    .disabled(builtQuestions.isEmpty)
                }
            }
            .sheet(isPresented: $showAddForm) {
                addQuestionSheet
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "pencil.circle")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No questions yet")
                .font(.title3).fontWeight(.semibold)
            Text("Tap below to add your first question")
                .font(.subheadline).foregroundColor(.gray)
            Button(action: { resetForm(); showAddForm = true }) {
                Text("Add Question")
                    .font(.headline).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding()
                    .background(Color.blue).cornerRadius(12)
            }
            .padding(.horizontal, 30)
            Spacer()
        }
    }

    private var questionsList: some View {
        List {
            ForEach(builtQuestions.indices, id: \.self) { i in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Q\(i + 1): \(builtQuestions[i].text)")
                        .font(.subheadline).fontWeight(.medium)
                    Text("✓ \(builtQuestions[i].options[builtQuestions[i].correctIndex])")
                        .font(.caption).foregroundColor(.green)
                }
                .padding(.vertical, 4)
            }
            .onDelete { builtQuestions.remove(atOffsets: $0) }

            Button(action: { resetForm(); showAddForm = true }) {
                Label("Add Another Question", systemImage: "plus.circle")
                    .foregroundColor(.blue)
            }
        }
    }

    private var addQuestionSheet: some View {
        NavigationView {
            Form {
                Section("Question") {
                    TextField("Enter your question...", text: $qText, axis: .vertical)
                        .lineLimit(2...5)
                }
                Section {
                    ForEach(0..<4, id: \.self) { i in
                        HStack {
                            Button(action: { correctIdx = i }) {
                                Image(systemName: correctIdx == i ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(correctIdx == i ? .green : .gray)
                            }
                            .buttonStyle(.plain)
                            TextField("Option \(i + 1)", text: $opts[i])
                        }
                    }
                } header: {
                    Text("Answer Options")
                } footer: {
                    Text("Tap the circle next to the correct answer.")
                }
                Section("Explanation (optional)") {
                    TextField("Why is this the correct answer?", text: $explanationText, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("New Question")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showAddForm = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        builtQuestions.append(Question(
                            text: qText.trimmingCharacters(in: .whitespaces),
                            options: opts,
                            correctIndex: correctIdx,
                            explanation: explanationText.trimmingCharacters(in: .whitespaces)
                        ))
                        showAddForm = false
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    private func resetForm() {
        qText = ""
        opts = ["", "", "", ""]
        correctIdx = 0
        explanationText = ""
    }
}

#Preview {
    ContentView()
        .environmentObject(QuizEngine())
        .environmentObject(ChatViewModel())
}
