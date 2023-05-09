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
    
    @State private var selectedVehicle = ""
    
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
                                Picker("Auto", selection: $selectedVehicle) {
                                    ForEach(vehicleViewModel.vehicles, id: \.id) { vehicle in
                                        //                                        LOG.debug("\(vehicle.numberplate)")
                                        Text(vehicle.numberplate).tag(vehicle.numberplate)
                                        
                                    }
                                }
                            }
                            Toggle("Berufliche Fahrt", isOn: $beruflicheFahrt)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        
                        Section {
                            Button(action: {
                                mapViewModel.startRecording()
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
