//
//  ContentView.swift
//  BetterRest
//
//  Created by valcasara-bryan on 20/05/2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var coffeIndex = 0
    @State private var bestTimeRecommanded: Date? = nil
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section("Desire amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                Section("Daily coffee intake") {
                    Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeIndex) {
                        ForEach(1..<21) { number in
                            Text("\(number)")
                        }
                    }
                    .onChange(of: coffeIndex) { oldValue, newValue in
                        coffeeAmount = newValue + 1
                    }
                    // Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                }
                Section() {
                    Text("Your ideal bedtime is \(bestTimeRecommanded?.formatted(date: .omitted, time: .shortened) ?? "calculating...")")
                        .font(.title)
                }
            }
            .onChange(of: wakeUp, { oldValue, newValue in
                bestTimeRecommanded = calculateBedTime()
            })
            .onChange(of: sleepAmount, { oldValue, newValue in
                bestTimeRecommanded = calculateBedTime()
            })
            .onChange(of: coffeeAmount, { oldValue, newValue in
                bestTimeRecommanded = calculateBedTime()
            })
            .onAppear {
                bestTimeRecommanded = calculateBedTime()
            }
            .navigationTitle("BetterRest")
            /*.toolbar {
                Button("Calculate", action: calculateBedTime)
                    .alert(alertTitle, isPresented: $showingAlert) {
                        Button("OK") { }
                    } message: {
                        Text(alertMessage)
                    }
            }*/
        }
        
    }
    
    func calculateBedTime() -> Date? {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            
            return wakeUp - prediction.actualSleep
        } catch {
            return nil
        }

    }
}

#Preview {
    ContentView()
}
