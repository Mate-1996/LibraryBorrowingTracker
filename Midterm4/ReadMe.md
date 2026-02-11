

# Library Tracker App

---

## Core Data Model

### Entities

**Member**
- `id`: UUID
- `name`: String
- `email`: String
- `joinedAt`: Date

**Book**
- `id`: UUID
- `title`: String
- `author`: String
- `isbn`: String (optional)
- `addedAt`: Date
- `isAvailable`: Boolean

**Category**
- `id`: UUID
- `name`: String

**Loan**
- `id`: UUID
- `borrowedAt`: Date
- `dueAt`: Date
- `returnedAt`: Date (optional)
- `status`: String (optional)

### Relationships

1. **Category ↔ Book** (1:N, Delete Rule: Nullify)
   - `Category.books` ↔ `Book.category`

2. **Member ↔ Loan** (1:N, Delete Rule: Cascade)
   - `Member.loans` ↔ `Loan.member`

3. **Book ↔ Loan** (1:N, Delete Rule: Cascade)
   - `Book.loans` ↔ `Loan.book`

![Core Data Diagram](ScreenShots/Diagram.png)

---

## Screenshots

### Books Screen
Browse, search, and filter books by category. Add new books or edit existing ones.

![Books Screen](ScreenShots/BookScreen.png)

---

### Members Screen
View all library members and their borrowing history.

![Members Screen](ScreenShots/MemberScreen.png)

---

### Borrow Screen
Select available books to borrow for a member.

![Borrow Screen](ScreenShots/BorrowScreen.png)

![Borrow Screen Detail](ScreenShots/BorrowScreen1.png)

---

### Loans Screen
Track all loans with status indicators (Active, Returned, Overdue).

![Loans Screen](ScreenShots/LoanScreen.png)



## Core Data Relationship Details

### Category → Book Relationship
![Category to Book](ScreenShots/Category.png)
![Book to Category](ScreenShots/Book1.png)

### Member → Loan Relationship
![Member to Loan](ScreenShots/Member.png)
![Loan to Member](ScreenShots/Loan2.png)

### Book → Loan Relationship
![Book to Loan](ScreenShots/Book2.png)
![Loan to Book](ScreenShots/Loan1.png)



## Author

[Mate Chachkhiani]  



