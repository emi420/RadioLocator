//
//  ContentView.swift
//  Radio Locator
//
//  Created by Emilio Mariscal on 25/12/2024.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    @State private var toneDuration: TimeInterval = 0.5
    @State private var pauseDuration: TimeInterval = 0.2
    @State private var dtmfPlayer = DTMFPlayer()
    @State private var geoDTMF = GeoDTMF()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Radio Locator")
                .font(.title)
            
            Button(action: {
                if let coordinates = locationManager.currentCoordinates {
                    let encodedMessage = geoDTMF.encodeDTMF(latitude: coordinates.latitude, longitude: coordinates.longitude)

                    DTMFPlayer.playMessage(message: encodedMessage)
                } else {
                    print("Coordinates not available")
                }
            }) {
                Text("Send")
                    .font(.title2)
                    .bold()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.white)
                    .background(Color.red)
                    .clipShape(Circle())
            }
        }
        .padding()
        .onAppear {
            locationManager.requestLocation()
        }
    }
    
}


#Preview {
    ContentView()
}
