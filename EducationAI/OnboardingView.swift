import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                // Page 1
                OnboardingPage(
                    icon: "brain.head.profile",
                    title: "Think, don't copy",
                    description: "EducationAI helps you learn by guiding your thinking — not doing the work for you.",
                    color: .blue
                )
                .tag(0)
                
                // Page 2
                OnboardingPage(
                    icon: "questionmark.circle.fill",
                    title: "Quiz yourself",
                    description: "Test your knowledge with adaptive quizzes that learn what you need to practice.",
                    color: .blue
                )
                .tag(1)
                
                // Page 3
                OnboardingPage(
                    icon: "calendar",
                    title: "Stay organized",
                    description: "Track assignments, deadlines, and your progress all in one place.",
                    color: .blue
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            // Get Started button on last page
            if currentPage == 2 {
                Button(action: {
                    hasCompletedOnboarding = true
                }) {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            } else {
                Button(action: {
                    withAnimation {
                        currentPage += 1
                    }
                }) {
                    Text("Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button("Skip") {
                hasCompletedOnboarding = true
            }
            .foregroundColor(.blue)
            .fontWeight(.medium)
            .padding(.top, 55)
            .padding(.trailing, 20)
        }
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(color)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(description)
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}
//  OnboardingView.swift
//  EducationAI
//
//  Created by Maxi Baumgart on 3/26/26.
//

