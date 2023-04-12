//
//  ViewFahrzeuge.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//
import SwiftUI


struct ViewVehicle: View {
    @State var showingVehicleCreateForm = false
    @ObservedObject var vehicleViewModel: VehicleViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vehicleViewModel.vehicles, id: \.id) { vehicle in
                    NavigationLink(value: vehicle) {
                        Label(vehicle.numberplate, systemImage: "car.fill")
                        Text(vehicle.make)
                        Text(vehicle.model)
                        
                    }
                }
            }
            .navigationDestination(for: Vehicle.self) { vehicle in
                VehicleDetailView(vehicle: vehicle, vehicleViewModel: vehicleViewModel)
                
            }
            .navigationTitle("Fahrzeuge")
            .onAppear(perform: {
                vehicleViewModel.downloadAllVehicles()
            })
            .toolbar(){
                ToolbarItemGroup(placement:
                        .navigationBarTrailing){
                            Button(action: {
                                print("Search pressed")
                            },label: {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                            })
                            
                            Button(action: {
                                showingVehicleCreateForm.toggle()
                            },label: {
                                Image(systemName: "plus")
                            })
                        }
                ToolbarItemGroup(placement:
                        .navigationBarLeading){
                            Button(action: {
                                print("general Edit pressed")
                            }) {
                                Text("Edit")
                                    .foregroundColor(.gray)
                            }
                            
                        }
            }
        }
        .sheet(isPresented: $showingVehicleCreateForm) {
            VehicleFormView(vehicleViewModel: vehicleViewModel)
                .presentationDetents([.large])
        }
    }
}

struct VehicleDetailView: View {
    var vehicle: Vehicle
    var vehicleViewModel: VehicleViewModel
    @State var showingVehicleEditForm = false
    var body: some View {
        VStack (alignment: .leading){
            
            Text("\(vehicle.make) \(vehicle.model)")
                .font(.caption)
                .padding([.horizontal,.bottom], 20)
                .foregroundColor(.black.opacity(80))
            List {
                Section {
                    Text("Kilometerstand")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    Text("\(vehicle.milage) km")
                        .font(.headline)
                        .bold()
                        
                }
            }
            Spacer()
        }
        .navigationTitle(vehicle.numberplate)
        .toolbar {
            ToolbarItemGroup(placement:
                    .navigationBarTrailing){
                        Button(action: {
                            showingVehicleEditForm.toggle()
                        }) {
                            Text("Edit")
                        }
                        
                    }
        }
        .sheet(isPresented: $showingVehicleEditForm) {
            VehicleEditFormView(vehicle: vehicle, vehicleViewModel: vehicleViewModel)
                .presentationDetents([.large])
        }
    }
}

struct VehicleFormView: View {
    
    @ObservedObject var vehicleViewModel: VehicleViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    
    @State private var makeTextField = ""
    @State private var modelTextField = ""
    @State private var vinTextField = ""
    @State private var milageTextField = ""
    @State private var numberplateTextField = ""
    
    var body: some View {
        
        NavigationView{
            Form {
                Section("Bild") {
                    Button {
                        shouldShowImagePicker.toggle()
                    } label: {
                        VStack {
                            if let image = self.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .cornerRadius(15)
                            } else {
                                Image(systemName: "car.fill")
                                    .font(.system(size: 80))
                                    .padding()
                                    .foregroundColor(Color(.label))
                            }
                        }
                    }
                }
                
                Section {
                    TextField("Marke:", text: $makeTextField)
                    TextField("Modell:", text: $modelTextField)
                    TextField("Kennzeichen:",text: $numberplateTextField)
                }
                Section {
                    TextField("Kilometerstand:", text: $milageTextField)
                        .keyboardType(.numberPad)
                }
                Section {
                    TextField("Identifizierungsnummer:", text: $vinTextField)
                } header: {
                    Text("Zusätzliche Informationen:")
                }
                
                
                
            }
            .navigationTitle("Fahrzeug hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(){
                ToolbarItemGroup(placement:
                        .navigationBarLeading){
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Abbrechen")
                            }
                        }
                ToolbarItemGroup(placement:
                        .navigationBarTrailing){
                            Button(action: {
                                vehicleViewModel.saveButtonTapped(make: makeTextField, model: modelTextField, vin: vinTextField, milage: milageTextField, numberplate: numberplateTextField)
                                dismiss()
                            }) {
                                Text("Speichern")
                            }
                            
                        }
            }
            .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
                ImagePicker(image: $image)
                    .ignoresSafeArea()
            }
        }
    }
}

struct VehicleEditFormView: View {
    
    @ObservedObject var vehicleViewModel: VehicleViewModel
    @Environment(\.dismiss) var dismiss
    
    let vehicle: Vehicle
    @State private var makeTextField = ""
    @State private var modelTextField = ""
    @State private var vinTextField = ""
    @State private var milageTextField = ""
    @State private var numberplateTextField = ""
    
    
    init(vehicle: Vehicle, vehicleViewModel: VehicleViewModel) {
        self.vehicle = vehicle
        self.vehicleViewModel = vehicleViewModel
        _makeTextField = State(initialValue: vehicle.make)
        _modelTextField = State(initialValue: vehicle.model)
        _vinTextField = State(initialValue: vehicle.vin)
        _milageTextField = State(initialValue: vehicle.milage)
        _numberplateTextField = State(initialValue: vehicle.numberplate)
    }
    
    var body: some View {
        
        NavigationView{
            Form {
                Section {
                    TextField("Marke:", text: $makeTextField)
                    TextField("Modell:", text: $modelTextField)
                    TextField("Kennzeichen:",text: $numberplateTextField)
                }
                Section {
                    TextField("Kilometerstand:", text: $milageTextField)
                        .keyboardType(.numberPad)
                }
                Section {
                    TextField("Identifizierungsnummer:", text: $vinTextField)
                } header: {
                    Text("Zusätzliche Informationen:")
                }
                Button(action: {
                    vehicleViewModel.deleteVehicle(vehicle)
                    dismiss()
                },label: {
                    Text("Löschen")
                        .foregroundColor(.red)
                })
                
            }
            .navigationTitle("Fahrzeug bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(){
                ToolbarItemGroup(placement:
                        .navigationBarLeading){
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Abbrechen")
                            }
                        }
                ToolbarItemGroup(placement:
                        .navigationBarTrailing){
                            Button(action: {
                                vehicleViewModel.update(vehicle: vehicle, make: makeTextField, model: modelTextField, vin: vinTextField, milage: milageTextField, numberplate: numberplateTextField)
                                dismiss()
                            }) {
                                Text("Speichern")
                            }
                            
                        }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    private let controller = UIImagePickerController()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        let parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}


struct ViewVehicle_Previews: PreviewProvider {
    static let vehicleViewModel = VehicleViewModel()
    static var previews: some View {
        ViewVehicle(vehicleViewModel: vehicleViewModel)
    }
}



/**
 
 @State var shouldShowImagePicker = false
 @State var image: UIImage?
 
 
 
 VStack(spacing: 15) {
 VStack(spacing: 5) {
 Text("Cairocoders")
 .bold()
 .font(.title)
 Text("Coders")
 .font(.body)
 .foregroundColor(.secondary)
 }.padding()
 Text("SwiftUI Image Picker")
 .multilineTextAlignment(.center)
 .padding()
 Spacer()
 }
 Spacer()
 }
 }
 .navigationSplitViewStyle(StackNavigationViewStyle())
 .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
 ImagePicker(image: $image)
 }
 }
 
 
 */
