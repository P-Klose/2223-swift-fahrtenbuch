//
//  ViewFahrzeuge.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//

import SwiftUI


struct ViewVehicle: View {
    @State var showingVehicleCreateForm = false
    @State var showingVehicleEditForm = false
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
                VStack {
                    Text("Automarke: \(vehicle.make)")
                    Text("Modell: \(vehicle.model)")
                    Divider()
                    Text("Kennzeichen: \(vehicle.numberplate)")
                    Divider()
                    Text("Kilometerleistung: \(vehicle.milage)")
                    
                }.toolbar {
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


struct VehicleFormView: View {
    
    @ObservedObject var vehicleViewModel: VehicleViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var makeTextField = ""
    @State private var modelTextField = ""
    @State private var vinTextField = ""
    @State private var milageTextField = ""
    @State private var numberplateTextField = ""
    
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

                
                
            }
            .navigationTitle("Fahrzeug hinzufügen")
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

struct ViewVehicle_Previews: PreviewProvider {
    static let vehicleViewModel = VehicleViewModel()
    static var previews: some View {
        ViewVehicle(vehicleViewModel: vehicleViewModel)
    }
}
