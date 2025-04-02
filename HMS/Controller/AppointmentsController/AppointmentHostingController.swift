//
//  AppointmentHostingController.swift
//  HMS
//
//  Created by RITIK RANJAN on 28/03/25.
//

import SwiftUI

let calendar: Calendar = .current
let currentDate: Date = .init()

let sampleAppointments: [Appointment] = []

class AppointmentHostingController: UIHostingController<AppointmentView>, UISearchBarDelegate, UISearchResultsUpdating, AppointmentDetailDelegate {

    // MARK: Lifecycle

    required init?(coder: NSCoder) {
        super.init(coder: coder, rootView: AppointmentView())
    }

    // MARK: Internal

    var searchController: UISearchController = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        rootView.delegate = self
        navigationItem.title = "My Appointments"

        prepareSearchController()
        loadAppointments()

        // Add observer for showing appointment details from home view
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleShowAppointmentDetail(_:)),
            name: NSNotification.Name("ShowAppointmentDetail"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleShowAppointmentDetail(_ notification: Notification) {
        if let appointment = notification.object as? Appointment {
            showAppointmentDetails(appointment)
        }
    }

    private func loadAppointments() {
        Task {
            let appointments = await DataController.shared.fetchAppointments()
            DispatchQueue.main.async {
            self.rootView.appointments = appointments
            }
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        // Handle search
    }

    func showAppointmentDetails(_ appointment: Appointment) {
        let detailView = AppointmentDetailView(appointment: appointment, delegate: self)
        let detailVC = UIHostingController(rootView: detailView)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // MARK: - AppointmentDetailDelegate

    func refreshAppointments() {
        loadAppointments()
    }

    // MARK: Private

    private func prepareSearchController() {
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Appointments"

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

}
