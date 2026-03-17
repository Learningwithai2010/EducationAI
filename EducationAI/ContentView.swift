import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            ChatView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chat")
                }
            
           QuizView()
                .tabItem {
                    Image(systemName: "questionmark.circle.fill")
                    Text("Quiz")
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
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("EducationAI")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("Learn smarter, not harder")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Spacer()
            
            Button(action: {
                // Will navigate to quiz later
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
            
            Spacer()
        }
    }
}

struct ChatView: View {
    @State private var messageText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Image(systemName: "message.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .padding(.bottom, 10)
                
                Text("AI Tutor")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Ask me anything — I'll guide you\nto the answer, not give it to you.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                HStack {
                    TextField("What do you want to learn?", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        // Will send message later
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            .navigationTitle("Chat")
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

#Preview {
    ContentView()
}
