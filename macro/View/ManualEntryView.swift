import SwiftUI
import WidgetKit

struct ManualEntryView: View {
    
    @Bindable var viewModel: AddPlaceViewModel
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchTask: Task<Void, Never>?
    @State private var showMapPicker = false
    
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 20) {
                
                CategoryPickerView(selected: $viewModel.selectedCategory)
                
                placeNameField
                
                formField(
                    "Neighborhood",
                    text: $viewModel.neighborhood,
                    placeholder: "e.g. Al Olaya, Riyadh"
                )
                
                notesField
                
                VisitedToggleRow(isVisited: $viewModel.isVisited)
                
                saveButton
            }
            .padding()
        }
    }
    
    private var placeNameField: some View {
        
        VStack(alignment: .leading, spacing: 6) {
            
            Text("Place Name *")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Button {
                showMapPicker = true
            } label: {
                
                HStack {
                    
                    Text(
                        viewModel.name.isEmpty
                        ? String(localized: "Choose place from map...")
                        : viewModel.name
                    )
                    .foregroundColor(
                        viewModel.name.isEmpty
                        ? .secondary
                        : .primary
                    )

                    Spacer()

                    Image(systemName: "map.fill")
                        .foregroundColor(Color("AppOrange"))
                }
                .padding(10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showMapPicker) {
                
                MapPickerView { selectedPlace in
                    fillFromMapPlace(selectedPlace)
                    showMapPicker = false
                }
            }
        }
    }
    
    private func formField(
        _ label: LocalizedStringKey,
        text: Binding<String>,
        placeholder: LocalizedStringKey
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    private var notesField: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text("Notes")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField(
                "What caught your eye? What to try?",
                text: $viewModel.notes,
                axis: .vertical
            )
            .lineLimit(4...6)
            .textFieldStyle(.roundedBorder)
        }
    }
    
    private var saveButton: some View {
        
        Button {
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            
            viewModel.save(context: modelContext)
            
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 0.5
            ) {
                WidgetCenter.shared.reloadAllTimelines()
            }
            
            dismiss()
            
        } label: {
            
            Label("Save", systemImage: "square.and.arrow.down")
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    viewModel.canSave
                    ? Color("AppOrange")
                    : Color("AppGray")
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!viewModel.canSave)
    }
    
    private func fillFromMapPlace(_ place: MapPlace) {
        
        viewModel.name = place.name
        viewModel.neighborhood = place.address
        viewModel.notes = place.note
        viewModel.latitude = place.latitude
        viewModel.longitude = place.longitude
        viewModel.address = place.address
        viewModel.selectedCategory = place.category
    }
}
