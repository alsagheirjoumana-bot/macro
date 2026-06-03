import SwiftUI

struct SplashView: View {
    
    @State private var backgroundColor = Color(red: 0.08, green: 0.04, blue: 0.025)
    @State private var logoScale: CGFloat = 0.55
    @State private var logoOffsetX: CGFloat = 0
    @State private var displayedText = ""
    
    private let appName = "MAKAN"
    
    var body: some View {
        
        ZStack {
            
            backgroundColor
                .ignoresSafeArea()
            
            HStack(spacing: 6) {
                
                Image("SplashLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 92, height: 92)
                    .scaleEffect(logoScale)
                    .offset(x: logoOffsetX)
                
                HStack(spacing: 1) {
                    
                    ForEach(Array(displayedText.enumerated()), id: \.offset) { _, letter in
                        
                        Text(String(letter))
                            .font(.system(size: 44, weight: .medium))
                            .foregroundColor(Color("AppOrange"))
                            .transition(
                                .opacity.combined(
                                    with: .move(edge: .trailing)
                                )
                            )
                    }
                }
                .animation(.easeOut(duration: 0.25), value: displayedText)
            }
        }
        .onAppear {
            
            logoScale = 0.55
            logoOffsetX = 0
            displayedText = ""
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    backgroundColor = Color("BackgroundColor")
                    logoScale = 1.35
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.7)) {
                    logoScale = 0.75
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                withAnimation(.easeInOut(duration: 0.45)) {
                    logoOffsetX = -18
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                
                displayedText = ""
                let letters = Array(appName)
                
                for index in letters.indices {
                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + Double(index) * 0.22
                    ) {
                        withAnimation(.easeOut(duration: 0.25)) {
                            displayedText.append(letters[index])
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
