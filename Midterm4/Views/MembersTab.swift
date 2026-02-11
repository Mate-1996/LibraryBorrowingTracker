//
//  MembersView.swift
//  Midterm4
//
//  Created by Mate Chachkhiani on 2026-02-10.
//

import SwiftUI

struct MembersTab: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    
    @State private var showAddMember = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if holder.members.isEmpty {
                    ContentUnavailableView("No members", systemImage: "person.2")
                        .padding(.top, 40)
                } else {
                    List {
                        ForEach(holder.members) { member in
                            NavigationLink {
                                MemberDetailView(member: member)
                            } label: {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(member.name ?? "")
                                        .font(.headline)
                                    Text(member.email ?? "")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Members")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddMember = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddMember) {
                MemberAddView()
            }
            .onAppear {
                holder.refreshMembers(context)
            }
        }
    }
}

struct MemberAddView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var email = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            }
            .navigationTitle("Add Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        holder.createMember(name: name, email: email, context)
                        dismiss()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
        }
    }
}

struct MemberDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    @Environment(\.dismiss) private var dismiss
    
    let member: Member
    
    @State private var showBorrowBook = false
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Email")
                    Spacer()
                    Text(member.email ?? "")
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Joined")
                    Spacer()
                    Text(member.joinedAt ?? Date(), style: .date)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Active Loans") {
                if member.activeLoans.isEmpty {
                    Text("No active loans")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(member.activeLoans) { loan in
                        LoanRow(loan: loan)
                    }
                }
            }
            
            Section("Past Loans") {
                if member.pastLoans.isEmpty {
                    Text("No past loans")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(member.pastLoans) { loan in
                        LoanRow(loan: loan)
                    }
                }
            }
            
            Section {
                Button {
                    showBorrowBook = true
                } label: {
                    Label("Borrow a Book", systemImage: "book")
                }
                
                Button("Delete Member", role: .destructive) {
                    holder.deleteMember(member, context)
                    dismiss()
                }
            }
        }
        .navigationTitle(member.name ?? "")
        .sheet(isPresented: $showBorrowBook) {
            BorrowBookView(member: member)
        }
    }
}

struct BorrowBookView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    @Environment(\.dismiss) private var dismiss
    
    let member: Member
    
    @State private var selectedBook: Book?
    
    var availableBooks: [Book] {
        holder.books.filter { $0.isAvailable }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if availableBooks.isEmpty {
                    Text("No available books")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Book", selection: $selectedBook) {
                        Text("Select a book").tag(nil as Book?)
                        ForEach(availableBooks) { book in
                            Text(book.title ?? "").tag(book as Book?)
                        }
                    }
                }
            }
            .navigationTitle("Borrow Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Borrow") {
                        if let book = selectedBook {
                            holder.borrowBook(member: member, book: book, context)
                            dismiss()
                        }
                    }
                    .disabled(selectedBook == nil)
                }
            }
        }
    }
}
