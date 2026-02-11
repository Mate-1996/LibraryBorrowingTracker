//
//  LibraryHolder.swift
//  Midterm4
//
//  Created by Mate Chachkhiani on 2026-02-10.
//

import SwiftUI
import CoreData
import Combine

final class LibraryHolder: ObservableObject {
    
    @Published var categories: [Category] = []
    @Published var books: [Book] = []
    @Published var members: [Member] = []
    @Published var loans: [Loan] = []
    

    @Published var selectedCategory: Category? = nil
    @Published var searchText: String = ""
    
    init(_ context: NSManagedObjectContext) {
        seedIfNeeded(context)
        refreshAll(context)
    }
    
    func refreshAll(_ context: NSManagedObjectContext) {
        refreshCategories(context)
        refreshBooks(context)
        refreshMembers(context)
        refreshLoans(context)
    }
    
    func refreshCategories(_ context: NSManagedObjectContext) {
        categories = fetchCategories(context)
    }
    
    func refreshBooks(_ context: NSManagedObjectContext) {
        books = fetchBooks(context)
    }
    
    func refreshMembers(_ context: NSManagedObjectContext) {
        members = fetchMembers(context)
    }
    
    func refreshLoans(_ context: NSManagedObjectContext) {
        loans = fetchLoans(context)
    }
    
    func fetchCategories(_ context: NSManagedObjectContext) -> [Category] {
        do { return try context.fetch(categoriesFetch()) }
        catch { fatalError("Unresolved error \(error)") }
    }
    
    func fetchBooks(_ context: NSManagedObjectContext) -> [Book] {
        do { return try context.fetch(booksFetch()) }
        catch { fatalError("Unresolved error \(error)") }
    }
    
    func fetchMembers(_ context: NSManagedObjectContext) -> [Member] {
        do { return try context.fetch(membersFetch()) }
        catch { fatalError("Unresolved error \(error)") }
    }
    
    func fetchLoans(_ context: NSManagedObjectContext) -> [Loan] {
        do { return try context.fetch(loansFetch()) }
        catch { fatalError("Unresolved error \(error)") }
    }
    
    
    func categoriesFetch() -> NSFetchRequest<Category> {
        let request = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return request
    }
    
    func booksFetch() -> NSFetchRequest<Book> {
        let request = Book.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Book.title, ascending: true)]
        request.predicate = booksPredicate()
        return request
    }
    
    func membersFetch() -> NSFetchRequest<Member> {
        let request = Member.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Member.name, ascending: true)]
        return request
    }
    
    func loansFetch() -> NSFetchRequest<Loan> {
        let request = Loan.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Loan.borrowedAt, ascending: false)]
        return request
    }
    
    
    private func booksPredicate() -> NSPredicate? {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var parts: [NSPredicate] = []
        
        if let category = selectedCategory {
            parts.append(NSPredicate(format: "category == %@", category))
        }
        
        if !trimmed.isEmpty {
            parts.append(NSPredicate(format: "(title CONTAINS[cd] %@) OR (author CONTAINS[cd] %@)", trimmed, trimmed))
        }
        
        if parts.isEmpty { return nil }
        if parts.count == 1 { return parts[0] }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: parts)
    }
    

    func setCategory(_ category: Category?, _ context: NSManagedObjectContext) {
        selectedCategory = category
        refreshBooks(context)
    }
    
    func setSearch(_ text: String, _ context: NSManagedObjectContext) {
        searchText = text
        refreshBooks(context)
    }
    

    func createCategory(name: String, _ context: NSManagedObjectContext) {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty else { return }
        
        let c = Category(context: context)
        c.id = UUID()
        c.name = n
        
        saveContext(context)
    }
    
    func deleteCategory(_ category: Category, _ context: NSManagedObjectContext) {
        if selectedCategory == category {
            selectedCategory = nil
        }
        context.delete(category)
        saveContext(context)
    }
    

    func createBook(title: String, author: String, isbn: String?, category: Category?, _ context: NSManagedObjectContext) {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let a = author.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty, !a.isEmpty else { return }
        
        let b = Book(context: context)
        b.id = UUID()
        b.title = t
        b.author = a
        b.isbn = isbn?.trimmingCharacters(in: .whitespacesAndNewlines)
        b.addedAt = Date()
        b.isAvailable = true
        b.category = category
        
        saveContext(context)
    }
    
    func updateBook(_ book: Book, title: String, author: String, isbn: String?, category: Category?, _ context: NSManagedObjectContext) {
        book.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        book.author = author.trimmingCharacters(in: .whitespacesAndNewlines)
        book.isbn = isbn?.trimmingCharacters(in: .whitespacesAndNewlines)
        book.category = category
        
        saveContext(context)
    }
    
    func deleteBook(_ book: Book, _ context: NSManagedObjectContext) {
        context.delete(book)
        saveContext(context)
    }
    

    func createMember(name: String, email: String, _ context: NSManagedObjectContext) {
        let n = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let e = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty, !e.isEmpty else { return }
        
        let m = Member(context: context)
        m.id = UUID()
        m.name = n
        m.email = e
        m.joinedAt = Date()
        
        saveContext(context)
    }
    
    func deleteMember(_ member: Member, _ context: NSManagedObjectContext) {
        context.delete(member)
        saveContext(context)
    }
    

    func borrowBook(member: Member, book: Book, dueDays: Int = 14, _ context: NSManagedObjectContext) {
        guard book.isAvailable else { return }
        
        let loan = Loan(context: context)
        loan.id = UUID()
        loan.borrowedAt = Date()
        loan.dueAt = Calendar.current.date(byAdding: .day, value: dueDays, to: Date()) ?? Date()
        loan.returnedAt = nil
        loan.member = member
        loan.book = book
        
        book.isAvailable = false
        
        saveContext(context)
    }

    func returnLoan(_ loan: Loan, _ context: NSManagedObjectContext) {
        loan.returnedAt = Date()
        loan.book?.isAvailable = true
        
        saveContext(context)
    }
    

    private func seedIfNeeded(_ context: NSManagedObjectContext) {
        let req = Category.fetchRequest()
        req.fetchLimit = 1
        let count = (try? context.count(for: req)) ?? 0
        guard count == 0 else { return }
        
        let fiction = Category(context: context)
        fiction.id = UUID()
        fiction.name = "Fiction"
        
        let nonFiction = Category(context: context)
        nonFiction.id = UUID()
        nonFiction.name = "Non-Fiction"
        
        let b1 = Book(context: context)
        b1.id = UUID()
        b1.title = "The Great Gatsby"
        b1.author = "Scott Fitzgerald"
        b1.isbn = "42124421"
        b1.addedAt = Date()
        b1.isAvailable = true
        b1.category = fiction
        
        let b2 = Book(context: context)
        b2.id = UUID()
        b2.title = "Project Hail Mary"
        b2.author = "Andy Weir"
        b2.isbn = "42132452"
        b2.addedAt = Date()
        b2.isAvailable = true
        b2.category = nonFiction
        
        saveContext(context)
    }
    

    func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
            refreshAll(context)
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
