//
//  Screen3.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import SwiftUI

struct Screen3: View {
    @Binding var currentPage: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("onboarding3")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
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
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                                .background(Color(hex: "7AFD91"))
                                .cornerRadius(35)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, max(geometry.safeAreaInsets.bottom + 45, 40))
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SpiritBoxView_Previews: PreviewProvider {
    static var previews: some View {
        Screen3(currentPage: .constant(0))
    }
}
