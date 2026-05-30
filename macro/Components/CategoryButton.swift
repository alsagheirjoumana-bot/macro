//
//  CategoryButton.swift
//  macro
//
//  Created by May Alqunaytir on 19/05/2026.
//


import SwiftUI

struct CategoryButton: View {
    
    var emoji: String
    var number: Int
    var title: String
    
    private let cardWidth: CGFloat = 150
    private let cardHeight: CGFloat = 50
    
    var body: some View {
        
        Button {
            
        } label: {
            
            HStack(spacing: 15) {
                
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color("AppGray"))
                        .frame(width: 65, height: 65)
                    
                    Text(emoji)
                        .font(.system(size: 35))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text("\(number)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text(title)
                        .font(.body)
                        .foregroundColor(Color("AppBrown"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                
                Spacer(minLength: 0)
            }
            .frame(width: cardWidth, height: cardHeight)
            .padding()
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
        }
    }
}
