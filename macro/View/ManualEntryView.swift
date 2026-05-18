//
//  ManualEntryView.swift
//  macro
//
//  Created by ghala alismael on 27/11/1447 AH.
//

import SwiftUI

struct ManualEntryView: View {
    @Bindable var viewModel: AddPlaceViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CategoryPickerView(selected: $viewModel.selectedCategory)
                formField("Place Name *", text: $viewModel.name,
                          placeholder: "e.g. Café Bateel")
                formField("Neighborhood", text: $viewModel.neighborhood,
                          placeholder: "e.g. Al Olaya, Riyadh")
                notesField
                VisitedToggleRow(isVisited: $viewModel.isVisited)
                saveButton
            }
            .padding()
        }
    }

    @ViewBuilder
    private func formField(_ label: String,
                           text: Binding<String>,
                           placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.subheadline).fontWeight(.medium)
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var notesField: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Notes").font(.subheadline).fontWeight(.medium)
            TextField("What caught your eye? What to try?",
                      text: $viewModel.notes,
                      axis: .vertical)
                .lineLimit(4...6)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var saveButton: some View {
        Button {
            viewModel.save(context: modelContext)
            dismiss()
        } label: {
            Label("Save", systemImage: "square.and.arrow.down")
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.canSave ? Color("AppOrange") : Color("AppGray"))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!viewModel.canSave)
    }
}
