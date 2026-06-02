//
//  OnboardingView.swift
//  macro
//
//  Created by Joumana Alsagheir on 31/05/2026.
//

import SwiftUI

struct OnboardingView: View {


@AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
@State private var page = 0

let screens = [
    OnboardingScreen(
        title: "Save places before\nthey disappear",
        subtitle: "Keep cafés, restaurants, and\nspots you want to visit in one\nsimple place.",
        image: "onboardingPlace"
    ),
    OnboardingScreen(
        title: "Add from\nscreenshots",
        subtitle: "Upload a screenshot and\nquickly turn it into a\nsaved place.",
        image: "onboardingScreenshot"
    ),
    OnboardingScreen(
        title: "Get reminded\nnearby",
        subtitle: "When you're close to a\nsaved place, we'll help\nyou rediscover it.",
        image: "onboardingCompass"
    )
]

var body: some View {
    VStack {
        
        TabView(selection: $page) {
            
            ForEach(screens.indices, id: \.self) { index in
                
                VStack(spacing: 18) {
                    
                    Text(screens[index].title)
                        .font(.system(size: 32, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(
                            Color(
                                red: 0.25,
                                green: 0.17,
                                blue: 0.13
                            )
                        )
                        .padding(.horizontal, 35)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(screens[index].subtitle)
                        .font(.system(size: 19, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundColor(
                            Color(
                                red: 0.87,
                                green: 0.52,
                                blue: 0.39
                            )
                        )
                        .lineSpacing(3)
                        .padding(.horizontal, 25)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    Image(screens[index].image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 400, height: 330)
                        .padding(.top, 35)
                    
                    Spacer()
                }
                .padding(.top, 50)
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        
        HStack(spacing: 8) {
            ForEach(screens.indices, id: \.self) { index in
                Capsule()
                    .fill(page == index ? Color.brown : Color.gray.opacity(0.3))
                    .frame(width: page == index ? 28 : 18, height: 6)
            }
        }
        .padding(.bottom, 25)
        
        Button {
            if page < screens.count - 1 {
                withAnimation {
                    page += 1
                }
            } else {
                hasSeenOnboarding = true
            }
        } label: {
            Text(page == screens.count - 1 ? "Get started" : "Next →")
                .fontWeight(.semibold)
                .foregroundColor(.brown)
                .padding(.horizontal, 22)
                .padding(.vertical, 10)
                .background(Color.brown.opacity(0.15))
                .cornerRadius(20)
        }
        .padding(.bottom, 35)
    }
    .background(Color.white)
}


}

struct OnboardingScreen {
let title: String
let subtitle: String
let image: String
}

#Preview {
OnboardingView()
}

