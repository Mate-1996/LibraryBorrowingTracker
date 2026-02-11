

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

![Core Data Diagram](ScreenShot/Diagram.png)

---

## Screenshots

### Books Screen
Browse, search, and filter books by category. Add new books or edit existing ones.

![Books Screen](ScreenShot/BookScreen.png)

---

### Members Screen
View all library members and their borrowing history.

![Members Screen](ScreenShot/MemberScreen.png)

---

### Borrow Screen
Select available books to borrow for a member.

![Borrow Screen](ScreenShot/BorrowScreen.png)

![Borrow Screen Detail](ScreenShot/BorrowScreen1.png)

---

### Loans Screen
Track all loans with status indicators (Active, Returned, Overdue).

![Loans Screen](ScreenShot/LoanScreen.png)



## Core Data Relationship Details

### Category → Book Relationship
![Category to Book](ScreenShot/Category.png)
![Book to Category](ScreenShot/Book1.png)

### Member → Loan Relationship
![Member to Loan](ScreenShot/Member.png)
![Loan to Member](ScreenShot/Loan2.png)

### Book → Loan Relationship
![Book to Loan](ScreenShot/Book2.png)
![Loan to Book](ScreenShot/Loan1.png)



## Author

[Mate Chachkhiani]  



