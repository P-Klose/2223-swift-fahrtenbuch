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
    
    @State private var privateTrip = false
    @State private var buttonStartIsPressed = false
    
    @State private var startTime: Date? = nil
    
    @State private var activity: Activity<DriveAttributes>? = nil
    
    @StateObject  var mapViewModel: MapViewModel
    @ObservedObject var vehicleViewModel: VehicleViewModel
    
    @State private var selectedVehicle = -1
    @State private var showAlert = false
    
    @State private var startButtonEnabled = true
    @State private var endButtonEnabled = false
    
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
                                Picker("Fahrzeug", selection: $selectedVehicle) {
                                    Text("bitte auswählen")
                                        .tag(-1)
                                    ForEach(vehicleViewModel.vehicles.indices, id: \.self) { index in
                                        Text(vehicleViewModel.vehicles[index].getName())
                                            .tag(vehicleViewModel.vehicles[index].id)
                                    }
                                }
                            }
                            Toggle("Private Fahrt", isOn: $privateTrip)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        
                        Section {
                            Button(action: {
                                buttonStartPressed()
                            }) {
                                Text("Fahrt starten")
                            }
                            .disabled(!startButtonEnabled)

                            
                            Button(action: {
                                buttonStopPressed()
                            }){
                                if(endButtonEnabled){
                                    Text("Fahrt beenden").foregroundColor(.red)
                                }else{
                                    Text("Fahrt beenden")
                                }
                            }
                            .disabled(!endButtonEnabled)
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
                vehicleViewModel.downloadAllVehicles(){}
            })
        }
    }
    
    func buttonStartPressed(){
        LOG.info("start pressed")
        startButtonEnabled = false
        endButtonEnabled = true
        LOG.info("SelectedvehicleId: \(selectedVehicle)")
        if selectedVehicle != -1 {
            startTime = .now
            let attributes = DriveAttributes(vehicleName: vehicleViewModel.vehicles[selectedVehicle].getName())
            let state = DriveAttributes.ContentState(startTime: .now, distance: 0)
            let selectedVehicleId = vehicleViewModel.vehicles[selectedVehicle].getId()
            activity = try? Activity<DriveAttributes>.request(attributes: attributes, contentState: state, pushType: nil)
            
            mapViewModel.startRecording(vehicle: selectedVehicleId, isPrivat: privateTrip)
        } else {
            showAlert = true
        }
        
    }
    
    func buttonStopPressed(){
        LOG.info("stop pressed")
        startButtonEnabled = true
        endButtonEnabled = false
        guard let startTime else { return }
        let state = DriveAttributes.ContentState(startTime: startTime, distance: 0)
        
        Task {
            await activity?.end(using: state, dismissalPolicy: .immediate)
        }
        
        mapViewModel.stopRecording()
        self.startTime = nil
    }
    
    
}

struct ViewRides_Previews: PreviewProvider {
    static let vehicleViewModel = VehicleViewModel()
    static let mapViewModel = MapViewModel()
    static var previews: some View {
        ViewRides(mapViewModel: mapViewModel, vehicleViewModel: vehicleViewModel)
    }
}
