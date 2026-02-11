//
//  ContentView.swift
//  Midterm4
//
//  Created by Mate Chachkhiani on 2026-02-10.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BooksTab()
                .tabItem {
                    Label("Books", systemImage: "book")
                }
            
            MembersTab()
                .tabItem {
                    Label("Members", systemImage: "person.2")
                }
            
            LoansTab()
                .tabItem {
                    Label("Loans", systemImage: "calendar")
                }
            
        }
    }
}


