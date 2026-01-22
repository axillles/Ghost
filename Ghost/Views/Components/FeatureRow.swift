//
//  FeatureRow.swift
//  Ghost
//
//  Created by Артем Гаврилов on 21.01.26.
//

import SwiftUI

struct FeatureRow: View {
    let icon: String
    let text: String
    var iconColor: Color = Color(hex: "7AFD91")
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 30)
                .font(.system(size: 20))
            Text(text)
                .foregroundColor(.white)
                .font(.system(size: 16))
            Spacer()
        }
    }
}

#Preview {
    FeatureRow(icon: "sparkles", text: "All features unlocked")
        .background(Color.black)
}
