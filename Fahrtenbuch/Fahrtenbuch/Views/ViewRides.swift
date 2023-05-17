//
//  ViewFahrten.swift
//  Fahrtenbuch
//
//  Created by Peter Klose on 29.03.23.
//
import SwiftUI
import MapKit
import OSLog
import ActivityKit


struct ViewRides: View {
    
    @State private var oneTextField = ""
    @State private var twoTextField = ""
    @State private var threeTextField = ""
    
    @State private var beruflicheFahrt = true
    @State private var buttonStartIsPressed = false
    
    @State private var startTime: Date? = nil
    
    @State private var activity: Activity<DriveAttributes>? = nil
    
    @StateObject  var mapViewModel: MapViewModel
    @ObservedObject var vehicleViewModel: VehicleViewModel
    
    @State private var selectedVehicleId = -1
    @State private var showAlert = false
    
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
                                    Text("bitte auswählen")
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
                                    startTime = .now
                                    let attributes = DriveAttributes(vehicleName: "\(selectedVehicleId)")
                                    let state = DriveAttributes.ContentState(startTime: .now, distance: 0)
                                    
                                    activity = try? Activity<DriveAttributes>.request(attributes: attributes, contentState: state, pushType: nil)
                                    
                                    mapViewModel.startRecording(vehicle:  selectedVehicleId)
                                } else {

                                    showAlert = true
                                    //LOG.error("🔴 Starten der Fahrt fehlgeschlagen - Kein Fahrzeug wurde ausgewählt")
                                    //display error
                                }
                            }) {
                                Text("Fahrt starten")
                            }
                            
                            Button(action: {
                                guard let startTime else { return }
                                let state = DriveAttributes.ContentState(startTime: startTime, distance: 0)
                                
                                Task {
                                    await activity?.end(using: state, dismissalPolicy: .immediate)
                                }
                                
                                mapViewModel.stopRecording()
                                self.startTime = nil
                                
                            }){
                                Text("Fahrt beenden").foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Fehler"),
                      message: Text("Bitte wählen Sie ein Fahrzeug aus!"),
                      dismissButton: .default(Text("OK")))}
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

struct ViewRides_Previews: PreviewProvider {
    static let vehicleViewModel = VehicleViewModel()
    static let mapViewModel = MapViewModel()
    static var previews: some View {
        ViewRides(mapViewModel: mapViewModel, vehicleViewModel: vehicleViewModel)
    }
}
