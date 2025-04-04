//
//  SetReminderView.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 14/03/25.
//

import SwiftUI



struct SetReminderView: View {
    @State private var selectedTime: Date = Date()
    @State private var repeatOptions = ["Daily", "Weekly", "Monthly"]
    @State private var selectedRepeat = "Daily"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Time")
                        Spacer()
                        DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }

                    HStack {
                        Text("Repeat")
                        Spacer()
                        Picker("Repeat", selection: $selectedRepeat) {
                            ForEach(repeatOptions, id: \.self) { option in
                                Text(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
            }
            .navigationTitle("Set Reminders")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReminder()
                    }
                }
            }
        }
    }

    func saveReminder() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let timeString = dateFormatter.string(from: selectedTime)
        print("Reminder set for \(timeString), repeating \(selectedRepeat)")
    }
}

struct SetReminderView_Previews: PreviewProvider {
    static var previews: some View {
        SetReminderView()
    }
}
