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
            
            ZStack {
                
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("Add a Place")
                            .font(.custom("Shafarik-Regular", size: 38))
                            .foregroundColor(.black)
                        
                        Text("Save a spot you want to remember")
                            .font(.subheadline)
                            .foregroundColor(Color("AppBrown").opacity(0.75))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 22)
                    .padding(.bottom, 20)
                    
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
                
            }   .toolbar {
                
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    
                    Button {
                        
                        dismiss()
                        
                    } label: {
                        
                        HStack(spacing: 4) {
                            
                            Image(systemName: "arrow.backward")
                            Text("Back")
                        }
                        .foregroundStyle(.black)
                    }
                }
            }
        }

         
        }
    
    

    // MARK: - Tab Bar

    var tabBar: some View {

        HStack(spacing: 10) {

            tabButton(
                String(localized: "Manual Entry"),
                image: "pincel",
                for: .manual
            )

            tabButton(
                String(localized: "From Screenshot"),
                image: "camera",
                for: .screenshot
            )
        }
        .padding(6)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(
            color: .black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 5
        )
        .padding(.horizontal, 22)
        .padding(.bottom, 16)
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
                RoundedRectangle(cornerRadius: 16)
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

        .background(Color.white.opacity(0.95))

        .clipShape(
            RoundedRectangle(cornerRadius: 24)
        )

        .shadow(
            color: .black.opacity(0.05),
            radius: 10,
            x: 0,
            y: 5
        )
    }
}

// MARK: - Preview

#Preview {

    AddPlaceView()
}
