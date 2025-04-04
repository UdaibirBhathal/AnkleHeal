//
//  HomeViewModel.swift
//  AnkleHeal
//
//  Created by Brahmjot Singh Tatla on 26/03/25.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var patient: Patient

    private var cancellables = Set<AnyCancellable>()
    private let dataModel = AnkleHealDataModel.shared

    init(patientID: Int) {
        self.patient = dataModel.getPatient(by: patientID) ?? Patient(
            id: patientID,
            name: "Unknown",
            dob: Date(),
            gender: .other,
            mobile: "",
            email: "",
            height: 0,
            weight: 0,
            injury: .other(description: ""),
            currentPhysiotherapistID: nil,
            location: Location(latitude: 0, longitude: 0)
        )

        // Observe changes in the data model
        dataModel.objectWillChange
            .sink { [weak self] _ in
                guard let self = self else { return }
                if let updated = self.dataModel.getPatient(by: patientID) {
                    DispatchQueue.main.async {
                        self.patient = updated
                    }
                }
            }
            .store(in: &cancellables)
    }
}
