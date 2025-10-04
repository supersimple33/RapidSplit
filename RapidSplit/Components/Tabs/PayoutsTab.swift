//
//  PayoutsTab.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 10/4/25.
//

import SwiftUI
import MaterialUIKit

struct PayoutsTab: View {
    @Environment(\.modelContext) private var modelContext

    let check: Check

    @State private var showDialogSheet: Bool = false
    @State private var selectedParticipant: Participant?

    @State private var showSnackbar: Bool = false
    @State private var snackbarMessage: String = ""

    var body: some View {
        Container {
            TotalsTable(check: check, handlePayout: { participant in
                self.selectedParticipant = participant
                self.showDialogSheet = true
            })
            .dialogSheet(isPresented: $showDialogSheet) {
                ParticipantOverview(participant: selectedParticipant) {
                    do {
                        try self.modelContext.save()
                    } catch let error {
                        self.snackbarMessage = error.localizedDescription
                        self.showSnackbar = true
                    }
                    self.showDialogSheet = false
                }
            }
            .snackbar(isPresented: $showSnackbar, message: snackbarMessage)
        }
    }
}
