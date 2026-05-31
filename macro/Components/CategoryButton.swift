import SwiftUI

struct CategoryButton: View {
    
    var emoji: String
    var number: Int
    var title: String
    var isSelected: Bool = false
    var action: () -> Void = {}
    
    var body: some View {
        
        Button {
            action()
        } label: {
            
            HStack(spacing: 12) {
                
                Text(emoji)
                    .font(.title2)
                    .frame(width: 46, height: 46)
                    .background(Color("AppGray"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    Text("\(number)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text(title)
                        .font(.caption)
                        .foregroundColor(Color("AppBrown"))
                }
                
                Spacer()
            }
            .padding(12)
            .frame(height: 74)
            .background(isSelected ? Color("OrangeBackground") : Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(isSelected ? Color("AppOrange") : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
