//
//  DoctorsHostingController.swift
//  HMS
//
//  Created by RITIK RANJAN on 28/03/25.
//

import SwiftUI

class DoctorsHostingController: UIHostingController<DoctorListView> {

    // MARK: Lifecycle

    required init?(coder: NSCoder) {
        let swiftUIView = DoctorListView()
        super.init(coder: coder, rootView: swiftUIView)
    }

    // MARK: Internal

    var specialization: String = ""
    var isSearchMode: Bool = false
    var searchQuery: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        if isSearchMode {
            navigationItem.title = "Search Results"
            loadDoctorsForSearch()
        } else {
            navigationItem.title = specialization
            loadDoctorsForSpecialization()
        }
        
        rootView.delegate = self
    }

    // MARK: Private
    
    private func loadDoctorsForSearch() {
        Task {
            if let doctors = await DataController.shared.searchDoctors(query: searchQuery) {
                DispatchQueue.main.async {
                    self.rootView.filteredDoctors = doctors
                }
            }
        }
    }
    
    private func loadDoctorsForSpecialization() {
        Task {
            if let doctors = await DataController.shared.fetchDoctor(bySpecialization: specialization) {
                DispatchQueue.main.async {
                    self.rootView.filteredDoctors = doctors
                }
            }
        }
    }

    func doctorsComplete() {
        performSegue(withIdentifier: "segueShowSignInViewController", sender: self)
    }

    func bookAppointment(_ appointment: Appointment) {
        Task {
            let booked = await DataController.shared.bookAppointment(appointment)
            DispatchQueue.main.async {
                if booked {
                    self.showAlert(message: "Appointment booked successfully")
                } else {
                    self.showAlert(message: "Failed to book appointment")
                }
            }
        }
    }

    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
