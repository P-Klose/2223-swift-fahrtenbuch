//
//  ViewFahrten.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//
import SwiftUI
import MapKit
import OSLog


struct ViewRides: View {
    
    @State private var oneTextField = ""
    @State private var twoTextField = ""
    @State private var threeTextField = ""
    
    @State private var beruflicheFahrt = true
    @State private var buttonStartIsPressed = false
    
    @StateObject  var mapViewModel: MapViewModel
    @ObservedObject var vehicleViewModel: VehicleViewModel
    
    @State private var selectedVehicleId = -1
    
    let LOG = Logger()
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack {
                    MapView(mapViewModel: mapViewModel)
                        .frame(height: 350, alignment: .top)
                    Spacer()
                    
                    Form {
                        Section{
                            List {
                                Picker("Fahrzeug", selection: $selectedVehicleId) {
                                    ForEach(vehicleViewModel.vehicles.indices) { index in
                                        Text(self.vehicleViewModel.vehicles[index].getName()).tag(index)
                                    }
                                }
                            }
                            Toggle("Berufliche Fahrt", isOn: $beruflicheFahrt)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        
                        Section {
                            Button(action: {
                                if selectedVehicleId != -1 {
                                    mapViewModel.startRecording(vehicle:  selectedVehicleId)
                                } else {
                                    LOG.error("🔴 Starten der Fahrt fehlgeschlagen - Kein Fahrzeug wurde ausgewählt")
                                    //display error
                                }
                            }) {
                                Text("Fahrt starten")
                            }
                            
                            Button(action: {
                
                                mapViewModel.stopRecording()
                                
                            }){
                                Text("Fahrt beenden").foregroundColor(.red)
                            }
                        }
                    }
                    
                }
                
            }
            .navigationTitle("Fahrten")
            .onAppear(perform: {
                vehicleViewModel.downloadAllVehicles()
                LOG.debug("\(vehicleViewModel.vehicles.count)")
            })
        }
    }
    
    func buttonStartPressed(){
        
    }
    
    func buttonStopPressed(){
        
    }
    
    
}

struct ViewRides_Previews: PreviewProvider {
    static let vehicleViewModel = VehicleViewModel()
    static let mapViewModel = MapViewModel()
    static var previews: some View {
        ViewRides(mapViewModel: mapViewModel, vehicleViewModel: vehicleViewModel)
    }
}
