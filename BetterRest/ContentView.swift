//
//  ContentView.swift
//  BetterRest
//
//  Created by Gabriel Santos on 01/04/25.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUP = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading) {
                    Text("Que horas você deseja acordar?")
                        .font(.headline)
                    
                    DatePicker(
                        "Coloque a hora",
                        selection: $wakeUP,
                        displayedComponents: .hourAndMinute
                    ).labelsHidden()
                }
                
                VStack(alignment: .leading) {
                    Text("Tempo desejado de sono")
                    
                    Stepper(
                        "\(sleepAmount.formatted()) horas",
                        value: $sleepAmount,
                        in: 4...8,
                        step: 0.25
                    )
                }
                
                VStack(alignment: .leading) {
                    Text("Quantidade de café tomado diariamente")
                    
                    Picker(
                        coffeeAmount == 1 ? "1 copo" : "\(coffeeAmount) copos",
                        selection: $coffeeAmount,
                        content: {
                            ForEach(1...20, id: \.self) {
                                Text("\($0)")
                            }
                        }
                    )
                }
                
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calcular", action: calculateBedTime)
                    .font(.title2)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUP)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )
            
            let sleepTime = wakeUP - prediction.actualSleep
            alertTitle = "A hora ideal de dormir é..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Erro"
            alertMessage = "Desculpe, mas não foi possível calcular o horário de dormir."
        }
        
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
