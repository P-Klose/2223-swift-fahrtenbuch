//
//  ViewFahrzeuge.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//

import SwiftUI

struct ViewVehicle: View {
    @State var showingVehicleCreateForm = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image(systemName: "car.2.fill")
                    .foregroundColor(.black)
                    .font(.system(size: 100.0))
            }
            .navigationTitle("Fahrzeuge")
            .toolbar(){
                ToolbarItemGroup(placement:
                        .navigationBarTrailing){
                            Button(action: {
                                print("Search pressed")
                            },label: {
                                Image(systemName: "magnifyingglass")
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
                                print("Edit pressed")
                            }) {
                                Text("Edit")
                            }
                            
                        }
            }
        }
        .sheet(isPresented: $showingVehicleCreateForm) {
            VehicleFormView()
                .presentationDetents([.large])
        }
    }
}

struct VehicleFormView: View {
    
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
                                //VehicleViewController().saveButtonTapped(makeTextField,modelTextField,vinTextField,milageTextField,numberplateTextField)
                            }) {
                                Text("Speichern")
                            }
                            
                        }
            }
        }
    }
}

struct ViewVehicle_Previews: PreviewProvider {
    static var previews: some View {
        ViewVehicle()
    }
}
