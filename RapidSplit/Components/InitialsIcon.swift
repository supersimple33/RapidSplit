//
//  InitialsIcon.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/27/25.
//

import SwiftUI
import SwiftData
import MaterialUIKit

struct InitialsIcon: View {
    let participant: Participant
    var size: CGFloat = 40

    // First letter of first name + second letter of last name (fallbacks applied)
    private var initials: String {
        let firstInitial = participant.firstName.first ?? " "
        let lastInitial = participant.lastName.first ?? " "
        return "\(firstInitial)\(lastInitial)".uppercased()
    }

    var body: some View {
        DropdownMenu {
            Text(participant.firstName + " " + participant.lastName)
        } label: {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                Text(initials)
                    .font(.system(size: size * 0.45, weight: .semibold, design: .rounded))
                    .foregroundStyle(.materialUIAccent)
            }
            .frame(width: size, height: size)
            .accessibilityLabel(Text("\(participant.firstName) \(participant.lastName)"))
        }
    }
}

#if DEBUG
#Preview {
    // Build a context from the preview container
    let container = DataController.previewContainer
    let context = container.mainContext

    // Try to fetch a single Participant (via a Check)
    var descriptor = FetchDescriptor<Check>()
    descriptor.fetchLimit = 1
    let fetchedCheck = try! context.fetch(descriptor).first!
    let participant = fetchedCheck.participants.first!

    return InitialsIcon(participant: participant, size: 48)
        .modelContainer(container)
}
#endif
