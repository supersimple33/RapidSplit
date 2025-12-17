//
//  ChecksTable.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/6/25.
//

import SwiftUI
import SwiftData
import Tabler
import MaterialUIKit

@Observable
final class TableOptions {
    var selectedSorting: [SortDescriptor<Check>] = []

    var customFetchDescriptor: FetchDescriptor<Check> {
        FetchDescriptor(sortBy: selectedSorting)
    }
}


struct ChecksTable: View {
    @Query private var checks: [Check]
    let tableOptions: TableOptions

    let navigateToCheck: (Check) -> Void

    private typealias Context = TablerContext<Check>
    private typealias Sort = TablerSort<Check>

    init(_ tableOptions: TableOptions, navigateToCheck: @escaping (Check) -> Void) {
        self.tableOptions = tableOptions
        self.navigateToCheck = navigateToCheck

        _checks = Query(tableOptions.customFetchDescriptor)
    }

    private var gridItems: [GridItem] {
        [GridItem(.flexible(), alignment: .leading), GridItem(.flexible(), alignment: .trailing)]
    }

    private func row(check: Check) -> some View {
        Button {
            self.navigateToCheck(check)
        } label: {
            LazyVGrid(columns: gridItems) {
                Text(check.name)
                Text(check.createdAt.description).multilineTextAlignment(.trailing)
            }
        }
            .accessibilityIdentifier("checkRow.\(check.id)")
    }

    private func header(ctx: Binding<Context>) -> some View {
        LazyVGrid(columns: gridItems) {
            Sort.columnTitle("Name", ctx, \.name)
                .onTapGesture {
                    tableOptions.selectedSorting = [tablerSort(ctx, \.name)]
                }
            Sort.columnTitle("Date", ctx, \.createdAt)
                .onTapGesture {
                    tableOptions.selectedSorting = [tablerSort(ctx, \.createdAt)]
                }
        }
    }

    private var tablerConfig: TablerStackConfig<Check> {
        TablerStackConfig<Check>(
            tablePadding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        )
    }

    var body: some View {
        TablerStack(tablerConfig, header: header, row: row, results: checks)
    }
}

#if DEBUG
#Preview {
    return ChecksTable(TableOptions(), navigateToCheck: { _ in
        print()
    })
    .modelContainer(DataController.previewContainer)
}
#endif
