//
//  Helpers.swift
//  Midterm4
//
//  Created by Mate Chachkhiani on 2026-02-10.
//

import Foundation

extension Loan {
    var isActive: Bool {
        returnedAt == nil
    }
    
    var isOverdue: Bool {
        returnedAt == nil && (dueAt ?? Date()) < Date()
    }
    
    var statusText: String {
        if returnedAt != nil {
            return "Returned"
        } else if isOverdue {
            return "Overdue"
        } else {
            return "Active"
        }
    }
}

extension Member {
    var activeLoans: [Loan] {
        (loan?.allObjects as? [Loan] ?? [])
            .filter { $0.isActive }
            .sorted { ($0.borrowedAt ?? Date()) > ($1.borrowedAt ?? Date()) }
    }
    
    var pastLoans: [Loan] {
        (loan?.allObjects as? [Loan] ?? [])
            .filter { !$0.isActive }
            .sorted { ($0.borrowedAt ?? Date()) > ($1.borrowedAt ?? Date()) }
    }
}
