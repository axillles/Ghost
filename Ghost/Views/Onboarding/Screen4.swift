//
//  Screen4.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import SwiftUI

struct Screen4: View {
    @State private var selectedOption: Int? = nil
    @Binding var currentPage: Int
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                    .frame(height: 80)
                
                VStack(spacing: 8) {
                    HStack(spacing: 0) {
                        Text("What is your ")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        Text("ghost")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(hex: "7AFD91"))
                    }
                    
                    HStack(spacing: 0) {
                        Text("hunting")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color(hex: "7AFD91"))
                        Text(" experience?")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                        .frame(maxWidth: 400)
                        .padding(.top, 20)
                    
                    Text("Pick your path and start the hunt")
                        .font(.system(size: 20))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 20) {
                    OptionButton(
                        emoji: "🤓",
                        title: "BEGINNER",
                        subtitle: "(I'M JUST CURIOUS)",
                        isSelected: selectedOption == 0,
                        action: { selectedOption = 0 }
                    )
                    
                    OptionButton(
                        emoji: "🧐",
                        title: "BELIEVER",
                        subtitle: "(I BELIEVE IN THE PARANORMAL)",
                        isSelected: selectedOption == 1,
                        action: { selectedOption = 1 }
                    )
                    
                    OptionButton(
                        emoji: "😎",
                        title: "EXPERT",
                        subtitle: "(I'M HUNTING FOR EVIDENCE)",
                        isSelected: selectedOption == 2,
                        action: { selectedOption = 2 }
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                VStack {
                    Spacer()
                    ZStack{
                        Rectangle()
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 70)
                            .background(Color(hex: "7AFD91"))
                            .cornerRadius(35)
                        Button(action: {
                            currentPage += 1
                        }) {
                            Text("Continue")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(selectedOption != nil ? .black : .white.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                                .background(selectedOption != nil ? Color(hex: "7AFD91") : Color.gray.opacity(0.3))
                                .cornerRadius(35)
                        }
                        .disabled(selectedOption == nil)
                        .padding(.horizontal, 25)
                        .padding(.bottom, 40)
                    }
                }
            }
            .padding(.top, 60)
            .padding(.bottom, 130)
        }
    }
}




struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Screen4(currentPage: .constant(0))
    }
}
