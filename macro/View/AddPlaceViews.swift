//
//  AddPlaceViews.swift
//  macro
//
//  Created by ghala alismael on 01/12/1447 AH.
//

import SwiftUI

// MARK: - Add Place View

struct AddPlaceView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var addVM = AddPlaceViewModel()
    @State private var ocrVM = OCRViewModel()

    @State private var tab: Tab = .manual

    enum Tab {
        case manual
        case screenshot
    }

    var body: some View {

        NavigationStack {

            VStack(spacing: 0) {

                tabBar

                Divider()

                switch tab {

                case .manual:
                    ManualEntryView(viewModel: addVM)

                case .screenshot:
                    ScreenshotView(
                        addVM: addVM,
                        ocrVM: ocrVM
                    )
                }
            }
            .navigationTitle("Add a place")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(
                    placement: .cancellationAction
                ) {

                    Button {

                        dismiss()

                    } label: {

                        HStack(spacing: 4) {

                            Image("Back")

                            Text("Back")
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
        }
    }

    // MARK: - Tab Bar

    var tabBar: some View {

        HStack(spacing: 0) {

            tabButton(
                "Manual Entry",
                image: "pincel",
                for: .manual
            )

            tabButton(
                "From Screenshot",
                image: "camera",
                for: .screenshot
            )
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    // MARK: - Tab Button

    @ViewBuilder
    func tabButton(
        _ title: String,
        image: String,
        for target: Tab
    ) -> some View {

        Button {

            withAnimation {

                tab = target
            }

        } label: {

            HStack(spacing: 6) {

                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)

                Text(title)
            }
            .font(.subheadline)

            .fontWeight(
                tab == target
                ? .semibold
                : .regular
            )

            .frame(maxWidth: .infinity)

            .padding(.vertical, 10)

            .background(
                tab == target
                ? Color("OrangeBackground")
                : Color("BackgroundColor")
            )

            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Visited Toggle Row

struct VisitedToggleRow: View {

    @Binding var isVisited: Bool

    var body: some View {

        HStack {

            VStack(
                alignment: .leading,
                spacing: 2
            ) {

                Text("Already visited?")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text("Mark this place as visited.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isVisited)
                .labelsHidden()
        }
        .padding()

        .background(
            Color("OrangeBackground")
        )

        .clipShape(
            RoundedRectangle(cornerRadius: 12)
        )
    }
}

// MARK: - Preview

#Preview {

    AddPlaceView()
}
