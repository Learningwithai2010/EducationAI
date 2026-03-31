import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
                    HomeView()
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }
                    
                    QuizView()
                .tabItem {
                    Image(systemName: "questionmark.circle.fill")
                    Text("Quiz")
                }
            
                    ChatView()
                        .tabItem {
                            Image(systemName: "message.fill")
                            Text("Chat")
                        }
                    
                CalendarTabView()
                        .tabItem {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Calendar")
                        }
                    
                    SettingsView()
                        .tabItem {
                            Image(systemName: "gearshape.fill")
                            Text("Settings")
                        }
                }
                .tint(.blue)
            }
        }

struct HomeView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
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
                   
                    // Calendar Widget
                    Button(action: {
                        // We'll wire this up to switch tabs
                    }) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                Text("Calendar")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            
                            // Mini calendar grid
                            let days = ["S", "M", "T", "W", "T", "F", "S"]
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                                ForEach(days, id: \.self) { day in
                                    Text(day)
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                                ForEach(1...31, id: \.self) { day in
                                    Text("\(day)")
                                        .font(.caption)
                                        .frame(width: 28, height: 28)
                                        .background(
                                            day == 17 ? Color.blue : Color.clear
                                        )
                                        .foregroundColor(day == 17 ? .white : .primary)
                                        .cornerRadius(14)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 25)
                    
                    // Recent Quizzes Widget
                    Button(action: {
                        // We'll wire this up to switch tabs
                    }) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Recent Quizzes")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            
                            VStack(spacing: 8) {
                                QuizRow(subject: "Chemistry", date: "Mar 15", score: "92%")
                                QuizRow(subject: "Math", date: "Mar 12", score: "78%")
                                QuizRow(subject: "History", date: "Mar 10", score: "43%")
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 10)
                    
                    // Start Learning Button
                    Button(action: {
                        // Navigate to chat
                    }) {
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
            .navigationTitle("Home")
        }
    }


struct QuizRow: View {
    let subject: String
    let date: String
    let score: String
    
    var scoreColor: Color {
        let number = Int(score.replacingOccurrences(of: "%", with: "")) ?? 0
        if number >= 80 {
            return .green
        } else if number >= 50 {
            return .orange
        } else {
            return .red
        }
    }
    
    var body: some View {
        HStack {
            Text(subject)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            Text(date)
                .font(.caption)
                .foregroundColor(.gray)
            Text(score)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(scoreColor)
        }
    }
}

struct QuizView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .padding(.bottom, 10)
                
                Text("Quiz Mode")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Test your knowledge with\nadaptive quizzes that learn from you.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: {
                    // Will start quiz later
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
                
                Spacer()
            }
            .navigationTitle("Quiz")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .padding(.bottom, 10)
                
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Customize your learning experience.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
            }
            .navigationTitle("Settings")
        }
    }
}

struct CalendarTabView: View {
    @State private var assignments: [Assignment] = [
        Assignment(title: "Chemistry Test", date: "March 20", type: "Test"),
        Assignment(title: "English Essay", date: "March 22", type: "Project"),
        Assignment(title: "Math Homework Ch.7", date: "March 18", type: "Homework")
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                // Month Header
                HStack {
                    Text("March 2026")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Assignment List
                List {
                    ForEach(assignments.indices, id: \.self) { index in
                        HStack {
                            Button(action: {
                                assignments[index].isCompleted.toggle()
                            }) {
                                Image(systemName: assignments[index].isCompleted ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(assignments[index].isCompleted ? .green : .gray)
                                    .font(.system(size: 22))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(assignments[index].title)
                                    .strikethrough(assignments[index].isCompleted)
                                    .foregroundColor(assignments[index].isCompleted ? .gray : .primary)
                                
                                HStack {
                                    Text(assignments[index].type)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(4)
                                    
                                    Text(assignments[index].date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Calendar")
        }
    }
}

struct Assignment: Identifiable {
    let id = UUID()
    var title: String
    var date: String
    var type: String
    var isCompleted: Bool = false
}
    
struct ChatView: View {
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hi! I'm your AI tutor. I won't give you answers — but I'll help you think through any problem. What would you like to learn?", isUser: false)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { message in
                                MessageBubble(message: message)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) {
                        if let last = messages.last {
                            withAnimation {
                                proxy.scrollTo(last.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input bar
                HStack(spacing: 10) {
                    TextField("Ask me anything...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(messageText.isEmpty ? .gray : .blue)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func sendMessage() {
            let userMessage = ChatMessage(text: messageText, isUser: true)
            messages.append(userMessage)
            let userText = messageText
            messageText = ""
            
            // Build message history for API
            var apiMessages: [(role: String, content: String)] = []
            for msg in messages {
                apiMessages.append((role: msg.isUser ? "user" : "assistant", content: msg.text))
            }
            
            // Call real Claude API
            Task {
                do {
                    let response = try await ClaudeService.shared.sendMessage(messages: apiMessages)
                    let aiMessage = ChatMessage(text: response, isUser: false)
                    messages.append(aiMessage)
                } catch {
                    let errorMessage = ChatMessage(text: "Something went wrong. Check your connection and try again.", isUser: false)
                    messages.append(errorMessage)
                }
            }
        }
    
  
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
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

#Preview {
    ContentView()
}
