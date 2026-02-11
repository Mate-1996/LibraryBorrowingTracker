//
//  BooksTabView.swift
//  Midterm4
//
//  Created by Mate Chachkhiani on 2026-02-10.
//

import SwiftUI

struct BooksTab: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    
    
    @State private var showManageCategories = false
    @State private var showAddBook = false
    @State private var showAddCategory = false
    @State private var searchDraft = ""
    
    private let cols = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search books", text: $searchDraft)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(12)
                .background(.secondary.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
                .onChange(of: searchDraft) { _, newValue in
                    holder.setSearch(newValue, context)
                }
                
                categoryBar
                
                if holder.books.isEmpty {
                    ContentUnavailableView("No books", systemImage: "book")
                        .padding(.top, 40)
                } else {
                    ScrollView {
                        LazyVGrid(columns: cols, spacing: 12) {
                            ForEach(holder.books) { book in
                                NavigationLink {
                                    BookEditView(book: book)
                                } label: {
                                    BookCard(book: book)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                }
            }
            .navigationTitle("Books")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showAddBook = true
                        } label: {
                            Label("Add Book", systemImage: "book")
                        }
                        
                        Button {
                            showAddCategory = true
                        } label: {
                            Label("Add Category", systemImage: "folder")
                        }
                        
                        Button {
                            showManageCategories = true
                        } label: {
                            Label("Manage Categories", systemImage: "folder.badge.gearshape")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddBook) {
                BookAddView()
            }
            .sheet(isPresented: $showAddCategory) {
                CategoryAddView()
            }
            .sheet(isPresented: $showManageCategories) {
                CategoryManageView()
            }
            .onAppear {
                holder.refreshAll(context)
                searchDraft = holder.searchText
            }
        }
    }
    
    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                
                Button {
                    holder.setCategory(nil, context)
                } label: {
                    Text("All")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            holder.selectedCategory == nil
                            ? Color.primary.opacity(0.12)
                            : Color.clear
                        )
                        .clipShape(Capsule())
                }
                
                ForEach(holder.categories) { c in
                    Button {
                        holder.setCategory(c, context)
                    } label: {
                        Text(c.name ?? "Category")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                holder.selectedCategory == c
                                ? Color.primary.opacity(0.12)
                                : Color.clear
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct BookCard: View {
    @ObservedObject var book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.secondary.opacity(0.12))
                    .frame(height: 110)
                
                Image(systemName: "book.closed")
                    .font(.system(size: 34, weight: .semibold))
            }
            
            Text(book.title ?? "Untitled")
                .font(.headline)
                .lineLimit(2)
                .foregroundStyle(.primary)
            
            Text(book.author ?? "Unknown")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Text(book.category?.name ?? "No category")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(book.isAvailable ? "Available" : "Borrowed")
                    .font(.caption)
                    .foregroundStyle(book.isAvailable ? .green : .red)
            }
        }
        .padding(12)
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.secondary.opacity(0.15), lineWidth: 1)
        )
    }
}

struct BookAddView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var selectedCategory: Category?
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Author", text: $author)
                TextField("ISBN optional", text: $isbn)
                
                Picker("Category", selection: $selectedCategory) {
                    Text("None").tag(nil as Category?)
                    ForEach(holder.categories) { c in
                        Text(c.name ?? "").tag(c as Category?)
                    }
                }
            }
            .navigationTitle("Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        holder.createBook(title: title, author: author, isbn: isbn.isEmpty ? nil : isbn, category: selectedCategory, context)
                        dismiss()
                    }
                    .disabled(title.isEmpty || author.isEmpty)
                }
            }
        }
    }
}

struct BookEditView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    @Environment(\.dismiss) private var dismiss
    
    let book: Book
    
    @State private var title = ""
    @State private var author = ""
    @State private var isbn = ""
    @State private var selectedCategory: Category?
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextField("Author", text: $author)
            TextField("ISBN optional", text: $isbn)
            
            Picker("Category", selection: $selectedCategory) {
                Text("None").tag(nil as Category?)
                ForEach(holder.categories) { c in
                    Text(c.name ?? "").tag(c as Category?)
                }
            }
            
            Section {
                Button("Delete Book", role: .destructive) {
                    holder.deleteBook(book, context)
                    dismiss()
                }
            }
        }
        .navigationTitle("Edit Book")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    holder.updateBook(book, title: title, author: author, isbn: isbn.isEmpty ? nil : isbn, category: selectedCategory, context)
                    dismiss()
                }
                .disabled(title.isEmpty || author.isEmpty)
            }
        }
        .onAppear {
            title = book.title ?? ""
            author = book.author ?? ""
            isbn = book.isbn ?? ""
            selectedCategory = book.category
        }
    }
}

struct CategoryAddView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Category Name", text: $name)
            }
            .navigationTitle("Add Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        holder.createCategory(name: name, context)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// I wasn't sure if you wanted this feature but since you mentioned "If category gets deleted, book stays intact"
// I added it anyways, just in case.
struct CategoryManageView: View {
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject private var holder: LibraryHolder
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(holder.categories) { category in
                    HStack {
                        Text(category.name ?? "")
                        Spacer()
                        Button(role: .destructive) {
                            holder.deleteCategory(category, context)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .navigationTitle("Manage Categories")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
