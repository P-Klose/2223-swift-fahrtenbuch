//
//  ViewFahrten.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//
import SwiftUI
import MapKit
import OSLog
import Charts


struct ViewRides: View {
    
    @State private var oneTextField = ""
    @State private var twoTextField = ""
    @State private var threeTextField = ""
    
    @State private var beruflicheFahrt = true
    @State private var buttonStartIsPressed = false
    
    @StateObject  var mapViewModel: MapViewModel
    @ObservedObject var vehicleViewModel: VehicleViewModel
    
    @State private var selectedVehicleId = -1
    
    var data: [ToyShape] = [
        .init(type: "Cube", count: 5),
        .init(type: "Sphere", count: 4),
        .init(type: "Pyramid", count: 4)
    ]
    
    let LOG = Logger()
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                VStack (alignment: .leading) {
                    
                    Text("Verlauf").padding(15)
                    
                    Chart {
                        BarMark(
                                x: .value("Shape Type", data[0].type),
                                y: .value("Total Count", data[0].count)
                            )
                            BarMark(
                                 x: .value("Shape Type", data[1].type),
                                 y: .value("Total Count", data[1].count)
                            )
                            BarMark(
                                 x: .value("Shape Type", data[2].type),
                                 y: .value("Total Count", data[2].count)
                            )
                    }
                    .padding(15)
                    
                    Button(action: {
                        print("Details")
                    }) {
                        Text("Details")
                            .foregroundColor(.blue)
                            .padding(15)
                    }
                    
                    Text("Übersicht").padding(15)

                    MapView(mapViewModel: mapViewModel)
                        .frame(height: 220, alignment: .top)
                    Spacer()
                    
                    Form {
                        Section{
                            List {
                                Picker("Fahrzeug", selection: $selectedVehicleId) {
                                    Text("bitte auswählen")
                                    ForEach(vehicleViewModel.vehicles.indices) { index in
                                        Text(self.vehicleViewModel.vehicles[index].getName()).tag(index)
                                    }
                                }
                            }
                            /*Toggle("Berufliche Fahrt", isOn: $beruflicheFahrt)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))*/
                        }
                        /*
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
                        }*/
                    }
                    
                }
                
            }
            .navigationTitle("Aufzeichnen")
            .onAppear(perform: {
                vehicleViewModel.downloadAllVehicles()
            })
        }
    }
    
    func buttonStartPressed(){
        
    }
    
    func buttonStopPressed(){
        
    }
    
    
}

struct ToyShape: Identifiable {
    var type: String
    var count: Double
    var id = UUID()
}

struct ViewRides_Previews: PreviewProvider {
    static let vehicleViewModel = VehicleViewModel()
    static let mapViewModel = MapViewModel()
    static var previews: some View {
        ViewRides(mapViewModel: mapViewModel, vehicleViewModel: vehicleViewModel)
    }
}
