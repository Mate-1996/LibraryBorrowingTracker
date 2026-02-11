//
//  LoansView.swift
//  Midterm4
//
//  Created by Mate Chachkhiani on 2026-02-10.
//

import SwiftUI

struct LoansTab: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    
    var body: some View {
        NavigationStack {
            VStack {
                if holder.loans.isEmpty {
                    ContentUnavailableView("No loans yet", systemImage: "calendar")
                        .padding(.top, 40)
                } else {
                    List {
                        ForEach(holder.loans) { loan in
                            LoanRow(loan: loan)
                        }
                    }
                }
            }
            .navigationTitle("Loans")
            .onAppear {
                holder.refreshLoans(context)
            }
        }
    }
}

struct LoanRow: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    
    let loan: Loan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(loan.book?.title ?? "Unknown Book")
                .font(.headline)
            Text(loan.member?.name ?? "Unknown Member")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Text("Due: \(loan.dueAt ?? Date(), style: .date)")
                    .font(.caption)
                Spacer()
                Text(loan.statusText)
                    .font(.caption)
                    .foregroundStyle(loan.isOverdue ? .red : (loan.isActive ? .orange : .green))
            }
            
            if loan.isActive {
                Button {
                    holder.returnLoan(loan, context)
                } label: {
                    Text("Return Book")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 4)
    }
}
