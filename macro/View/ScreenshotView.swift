//
//  ScreenshotView.swift
//  macro
//
//  Created by ghala alismael on 27/11/1447 AH.
//

import SwiftUI
import MapKit

struct ScreenshotView: View {
    @Bindable var addVM: AddPlaceViewModel
    @Bindable var ocrVM: OCRViewModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                imageZone
                if ocrVM.selectedImage != nil && !ocrVM.ocrDidRun {
                    extractButton
                }
                if ocrVM.ocrDidRun {
                    extractedFields
                }
                VisitedToggleRow(isVisited: $addVM.isVisited)
                saveButton
            }
            .padding()
        }
        .sheet(isPresented: $ocrVM.showImagePicker) {
            ImagePicker(selectedImage: $ocrVM.selectedImage)
                .ignoresSafeArea()
        }
        .onChange(of: ocrVM.result) { _, result in
            addVM.apply(ocrResult: result)
        }
    }

    @ViewBuilder
    private var imageZone: some View {
        if let image = ocrVM.selectedImage {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable().scaledToFit()
                    .frame(maxHeight: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Button {
                    ocrVM.reset()
                    addVM.reset()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3).foregroundStyle(.white).padding(6)
                }
            }
        } else {
            uploadPlaceholder
        }
    }

    private var uploadPlaceholder: some View {
        Button { ocrVM.showImagePicker = true } label: {
            VStack(spacing: 12) {
                Image(systemName: "camera").font(.largeTitle)
                    .foregroundStyle(Color("AppOrange"))
                Text("Upload a screenshot").font(.headline)
                Text("From Google Maps, Instagram, TikTok or any app")
                    .font(.caption).foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                Label("Choose file", systemImage: "arrow.up.square")
                    .padding(.horizontal, 20).padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity).padding(30)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                    .foregroundStyle(Color.secondary.opacity(0.4))
            )
        }
        .buttonStyle(.plain)
    }

    private var extractButton: some View {
        Button { ocrVM.runOCR() } label: {
            Label(
                ocrVM.isProcessing ? "Extracting…" : "Extract Text",
                systemImage: "text.viewfinder"
            )
            .frame(maxWidth: .infinity).padding()
            .background(Color("AppOrange"))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(ocrVM.isProcessing)
        .overlay {
            if ocrVM.isProcessing { ProgressView() }
        }
    }

    private var extractedFields: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Review & edit", systemImage: "pencil")
                .font(.subheadline).fontWeight(.semibold)

            fieldRow("Place Name *", text: $addVM.name)
            fieldRow("Neighborhood", text: $addVM.neighborhood)
            VStack(alignment: .leading, spacing: 4) {
                Text("Notes").font(.subheadline).fontWeight(.medium)
                TextField("Notes", text: $addVM.notes, axis: .vertical)
                    .lineLimit(3...5).textFieldStyle(.roundedBorder)
            }
        }
    }

    @ViewBuilder
    private func fieldRow(_ label: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.subheadline).fontWeight(.medium)
            TextField(label, text: text).textFieldStyle(.roundedBorder)
        }
    }

    private var saveButton: some View {
        Button {
            let imageData = ocrVM.selectedImage?
                .jpegData(compressionQuality: 0.6)
            
            saveScreenshotPlace(imageData: imageData)
            
        } label: {
            Label("Save place", systemImage: "square.and.arrow.down")
                .frame(maxWidth: .infinity).padding()
                .background(addVM.canSave ? Color.accentColor : .gray)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!addVM.canSave)
    }
    private func saveScreenshotPlace(imageData: Data?) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(addVM.name) \(addVM.neighborhood)"
        request.resultTypes = [.pointOfInterest, .address]
        
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 24.7136,
                longitude: 46.6753
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.15,
                longitudeDelta: 0.15
            )
        )
        
        MKLocalSearch(request: request).start { response, _ in
            
            if let item = response?.mapItems.first {
                DispatchQueue.main.async {
                    addVM.latitude = item.placemark.coordinate.latitude
                    addVM.longitude = item.placemark.coordinate.longitude
                    addVM.address = item.placemark.title ?? addVM.neighborhood
                    
                    addVM.save(context: modelContext, imageData: imageData)
                    dismiss()
                }
            } else {
                DispatchQueue.main.async {
                    addVM.save(context: modelContext, imageData: imageData)
                    dismiss()
                }
            }
        }
    }
}
