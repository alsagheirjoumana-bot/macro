import SwiftUI

struct CategoryPickerView: View {
    
    @Binding var selected: PlaceCategory
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(spacing: 2) {
                
                Label("Category", systemImage: "tag")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("*")
                    .foregroundStyle(.red)
                    .font(.subheadline)
            }
            
            HStack(spacing: 12) {
                
                ForEach([
                    PlaceCategory.cafe,
                    .restaurant,
                    .shopping
                ]) { cat in
                    
                    Button {
                        selected = cat
                    } label: {
                        categoryBox(
                            emoji: cat.emoji,
                            isSelected: selected == cat
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(accessibilityName(for: cat))
                    .accessibilityHint("Double tap to select this category")
                }
                
                // MARK: - Plus / Other Category
                
                Button {
                    selected = .other
                } label: {
                    categoryBox(
                        emoji: "+",
                        isSelected: selected == .other
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Custom category")
                .accessibilityHint("Double tap to select custom category")
            }
        }
    }
    
    // MARK: - Category Box
    
    @ViewBuilder
    func categoryBox(
        emoji: String,
        isSelected: Bool
    ) -> some View {
        
        Text(emoji)
            .font(.title2)
            .frame(width: 60, height: 60)
            .background(
                isSelected
                ? Color("OrangeBackground")
                : Color("BackgroundColor")
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected
                        ? Color("AppOrange")
                        : Color.clear,
                        lineWidth: 1.5
                    )
            )
    }
    
    // MARK: - Accessibility
    
    func accessibilityName(for category: PlaceCategory) -> String {
        
        switch category {
        case .cafe:
            return "Cafe"
            
        case .restaurant:
            return "Restaurant"
            
        case .shopping:
            return "Shopping"
            
        case .other:
            return "Custom category"
        }
    }
    
}
