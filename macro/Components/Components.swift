
import SwiftUI

struct CategoryPickerView: View {

    @Binding var selected: PlaceCategory

    @State private var customEmoji: String = "+"

    @FocusState private var isEmojiFocused: Bool

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
                }

                // MARK: - Custom Emoji Button

                Button {

                    selected = .other

                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + 0.1
                    ) {

                        isEmojiFocused = true
                    }

                } label: {

                    categoryBox(
                        emoji:
                            selected == .other
                            ? customEmoji
                            : "+",

                        isSelected:
                            selected == .other
                    )
                }
                .buttonStyle(.plain)
            }

            // Hidden Emoji Input

            TextField(
                "",
                text: Binding(

                    get: {
                        customEmoji
                    },

                    set: { newValue in

                        let emoji = newValue
                            .filter { $0.isEmoji }

                        customEmoji = String(
                            emoji.prefix(1)
                        )

                        if !customEmoji.isEmpty {

                            selected = .other

                            isEmojiFocused = false
                        }
                    }
                )
            )
            .focused($isEmojiFocused)
            .opacity(0.01)
            .frame(width: 1, height: 1)
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

            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )

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
}

// MARK: - Emoji Extension

extension Character {

    var isEmoji: Bool {

        unicodeScalars.first?
            .properties.isEmojiPresentation ?? false
    }
}
