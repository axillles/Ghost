import SwiftUI
import StoreKit
import UIKit

struct Screen6: View {
    @Binding var currentPage: Int
    var onComplete: () -> Void
    @State private var rotation: Double = 0
    @State private var text1 = ""
    @State private var text2 = ""
    @State private var text3 = ""
    @State private var text3Red = ""
    @State private var text4 = ""
    @State private var text4Green = ""
    @State private var progress: Double = 0
    @State private var hasRequestedReview = false
    
    let fullText1 = "Analyzing geolocation data..."
    let fullText2 = "Scanning local area for paranormal\nactivity..."
    let fullText3 = "Nearby anomalies "
    let fullText3Red = "DETECTED"
    let fullText4 = "Detector "
    let fullText4Green = "Ready"
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                ZStack {
                    ForEach(0..<4) { index in
                        Circle()
                            .trim(from: 0, to: 0.2)
                            .stroke(Color(hex: "7AFD91"), lineWidth: 12)
                            .frame(width: 280, height: 280)
                            .rotationEffect(Angle(degrees: rotation + Double(index * 90)))
                    }
                    
                    ForEach(0..<4) { index in
                        Circle()
                            .trim(from: 0, to: 0.2)
                            .stroke(Color(hex: "7AFD91"), lineWidth: 8)
                            .frame(width: 250, height: 250)
                            .rotationEffect(Angle(degrees: -rotation + Double(index * 90)))
                    }
                    
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "7AFD91").opacity(0.2), lineWidth: 6)
                            .frame(width: 200, height: 200)
                        
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color(hex: "7AFD91"), lineWidth: 6)
                            .frame(width: 200, height: 200)
                            .rotationEffect(Angle(degrees: -90))
                    }
                    
                    ZStack {
                        ForEach(0..<60, id: \.self) { index in
                            Rectangle()
                                .fill(Double(index) < progress * 60 ? Color.white : Color.white.opacity(0.15))
                                .frame(width: 2, height: 8)
                                .offset(y: -82)
                                .rotationEffect(Angle(degrees: Double(index) * 6))
                        }
                    }
                    .frame(width: 180, height: 180)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(Color(hex: "7AFD91"))
                }
                .frame(height: 300)
                
                VStack(spacing: 30) {
                    if !text1.isEmpty {
                        Text(text1)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    
                    if !text2.isEmpty {
                        Text(text2)
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    
                    if !text3.isEmpty || !text3Red.isEmpty {
                        HStack(spacing: 8) {
                            Text(text3)
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                            Text(text3Red)
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.red)
                        }
                    }
                    
                    if !text4.isEmpty || !text4Green.isEmpty {
                        HStack(spacing: 8) {
                            Text(text4)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            Text(text4Green)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "7AFD91"))
                        }
                    }
                }
                .frame(height: 250)
                
                Spacer()
                
                Button(action: {
                    OnboardingService.shared.completeOnboarding()
                    onComplete()
                }) {
                    Text("Continue")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(Color(hex: "7AFD91"))
                        .cornerRadius(35)
                }
                .padding(.horizontal, 60)
                .padding(.bottom, 40)
                .opacity(progress >= 1.0 && !text4Green.isEmpty && text4Green == fullText4Green ? 1 : 0)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    func startAnimation() {
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        animateProgress()
        
        typeWriter(text: fullText1, into: $text1, delay: 0.5) {
            typeWriter(text: fullText2, into: $text2, delay: 0.3) {
                typeWriter(text: fullText3, into: $text3, delay: 0.3) {
                    typeWriter(text: fullText3Red, into: $text3Red, delay: 0.3) {
                        typeWriter(text: fullText4, into: $text4, delay: 0.3) {
                            typeWriter(text: fullText4Green, into: $text4Green, delay: 0.3)
                        }
                    }
                }
            }
        }
    }
    
    func animateProgress() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if progress < 1.0 {
                progress += 0.01
            } else {
                progress = 1.0
                timer.invalidate()
                requestReviewIfNeeded()
            }
        }
    }
    
    func requestReviewIfNeeded() {
        guard !hasRequestedReview else { return }
        hasRequestedReview = true
        
        // Небольшая задержка перед показом запроса отзыва
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScene)
            }
        }
    }
    
    func typeWriter(text: String, into binding: Binding<String>, delay: Double, speed: Double = 0.05, completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            var currentIndex = 0
            Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { timer in
                if currentIndex < text.count {
                    let index = text.index(text.startIndex, offsetBy: currentIndex)
                    binding.wrappedValue += String(text[index])
                    currentIndex += 1
                } else {
                    timer.invalidate()
                    completion?()
                }
            }
        }
    }
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        Screen6(currentPage: .constant(0), onComplete: {})
    }
}
