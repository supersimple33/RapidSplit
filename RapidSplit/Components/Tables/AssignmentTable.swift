//
//  AssignmentTable.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/27/25.
//

import SwiftUI
import Tabler
import MaterialUIKit

struct AssignmentTable: View {
    private typealias Context = TablerContext<Item>
    private typealias Sort = TablerSort<Item>

    @Bindable var check: Check
    let linkParticipantAndItem: (Item, Participant) -> Void

    private var tablerConfig: TablerStackConfig<Item> {
        TablerStackConfig<Item>(
            rowPadding: EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4),
            headerSpacing: 0,
            tablePadding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        )
    }

    private let descriptionGridItems: [GridItem] = [
        GridItem(.flexible(), alignment: .leading),
        GridItem(.flexible(), alignment: .trailing)
    ]

    private func participantGridItems() -> [GridItem] {
        return Array(repeating:  GridItem(.flexible(), alignment: .center), count: self.check.participants.count)
    }

    private func header(ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: participantGridItems()) {
            ForEach(self.check.participants) { participant in
                InitialsIcon(participant: participant)
            }
        }
        .padding(8)
        .background(Rectangle()
            .fill(
                LinearGradient(gradient: .init(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)]),
                               startPoint: .top,
                               endPoint: .bottom)
            )
            .clipShape(
                .rect(
                    topLeadingRadius: 5,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 5
                )
            )
        ).border(width: 0.5, edges: [.bottom], color: .black)
    }

    private func footer(ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: participantGridItems()) {
            ForEach(self.check.participants) { participant in
                Text(self.check.items.reduce(0) { total, item in
                    if item.orderers.contains(participant) {
                        return total + 1
                    } else {
                        return total
                    }
                }, format: .number)
            }
        }
        .padding(8)
        .background(Rectangle()
            .fill(
                LinearGradient(gradient: .init(colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.3)]),
                               startPoint: .top,
                               endPoint: .bottom)
            )
                .clipShape(
                    .rect(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 5,
                        bottomTrailingRadius: 5,
                        topTrailingRadius: 0
                    )
                )
        ).border(width: 0.5, edges: [.top], color: .black)
    }

    private func row(item: Item) -> some View {
        VStack {
            LazyVGrid(columns: descriptionGridItems, alignment: .leading) {
                Text(item.name).lineLimit(1)
                Text(item.price, format: .currency(code: getCurrencyCode()))
                    .lineLimit(1)
            }
            LazyVGrid(columns: participantGridItems(), alignment: .center) {
                ForEach(self.check.participants) { participant in
                    Toggle("", isOn: Binding(get: {
                        item.orderers.contains(participant)
                    }, set: { on in
                        if on {
                            linkParticipantAndItem(item, participant)
                        } else {
                            item.removeOrderer(participant)
                        }
                    })).toggleStyle(CheckboxStyle())
                }
            }
        }
    }

    private func rowOverlay(item: Item) -> some View {
        Rectangle()
            .fill(.clear)
            .border(width: 0.5, edges: [.top, .bottom], color: .black)
            .border(width: 1, edges: [.leading, .trailing], color: .black)
    }

    var body: some View {
        TablerStack(
            tablerConfig,
            header: header,
            footer: footer,
            row: row,
            rowOverlay: rowOverlay,
            results: check.items
        )
    }
}

