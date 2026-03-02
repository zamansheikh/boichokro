# 📚 **FULL LIBRARY MODULE — COMPLETE WIREFRAME SET**

# ----------------------------------------------------------

# 🟦 1️⃣ LIBRARY PAGE (Main Structure)

# ----------------------------------------------------------

```
 ---------------------------------------------------------
 |  My Books  |  My Requests  |  Requests to Me  | History |
 ---------------------------------------------------------
```

Four tabs. Each tab’s UI is below.

---

# ----------------------------------------------------------

# 🟩 2️⃣ **MY BOOKS TAB**

# ----------------------------------------------------------

### **List of My Uploaded Books**

```
 ---------------------------------------------------------
 | [Cover]  Book Title                              (⋮)   |
 | Author: John Doe                                   Edit |
 | Condition: Good                                    Del  |
 ---------------------------------------------------------
 | [Cover]  Another Book                           (⋮)    |
 | Author: Mark Lee                                  Edit |
 | Condition: Like New                               Del  |
 ---------------------------------------------------------
```

### **Book Options Menu**

```
 --------------------
 | Edit Book Details |
 | Delete Book       |
 --------------------
```

### **Edit Book Screen**

```
 ----------------------- Edit Book ------------------------
 | Cover Image: [Upload]                                   |
 | Title:        [_________________]                        |
 | Author:       [_________________]                        |
 | Category:     [Dropdown]                                 |
 | Condition:    [Dropdown]                                 |
 | Description:                                             |
 | [Multiline Field]                                        |
 -----------------------------------------------------------
 |                 [ Save Changes ]                         |
 -----------------------------------------------------------
```

---

# ----------------------------------------------------------

Below is your **updated wireframe** with the new **Courier Option**, **Meet-up Flow**, **Exchange/Donation Completion**, and **Review System** — fully integrated into **My Requests** and **Requests to Me** tabs.

Everything is rewritten cleanly so you can use it as your final design.

---

# 🟦 3️⃣ **MY REQUESTS TAB**

---

### **Each Request Card (Same as Before)**

```
 ---------------------------------------------------------
 | [Cover]  Book Title                                   |
 | Author: John Doe                                      |
 | Owner: User A                                         |
 | Requested On: 12 Mar 2025                             |
 | Status: ● Pending / ● Approved / ● Rejected           |
 | Chat: [ Open Chat Room ]                              |
 ---------------------------------------------------------
 | Timeline:                                              |
 |  Step 1: Request Sent          ✔                      |
 |  Step 2: Waiting Approval      ○                      |
 |  Step 3: Exchange Completed    ○                      |
 ---------------------------------------------------------
```

---

# 🟩 **If Approved (Updated With Courier Option)**

```
 | Status: ● Approved                                     |
 | Chat: [ Continue Chat ]                                |
 ----------------------------------------------------------
 | How do you want to receive the book?                   |
 |  ( ) Meet in Person                                    |
 |  ( ) Courier Service                                   |
 ----------------------------------------------------------
```

---

## 🟩 **If "Meet in Person" Selected**

```
 | Meeting Time: Not Set                                  |
 | Location: Not Set                                       |
 | Buttons: [ Set Time ]   [ Set Location ]               |
 ----------------------------------------------------------
```

After setting:

```
 ---------------- Exchange Details -----------------------
 | Meeting Time: 5 PM, Tomorrow                           |
 | Location: Campus Main Gate                              |
 -----------------------------------------------------------
 | [ Mark as Exchanged ]                                   |
 -----------------------------------------------------------
```

---

## 🟩 **If "Courier Service" Selected**

```
 ---------------- Courier Exchange ------------------------
 | Courier Method: Not Selected                            |
 | Tracking ID: Not Provided                               |
 -----------------------------------------------------------
 | Buttons: [ Select Courier ]  [ Enter Tracking Code ]    |
 -----------------------------------------------------------
 | (No meeting time/location required)                     |
 -----------------------------------------------------------
 | [ Mark as Exchanged ]                                   |
 -----------------------------------------------------------
```

---

# 🟩 **After Exchange / Donation Completion (Both Users Must Confirm)**

```
 ------------------- Exchange Completion -------------------
 | User A: Marked as Completed ✔                           |
 | You: [ Confirm Completion ]                             |
 -----------------------------------------------------------
```

Once both confirm:

```
 ---------------------- Success ---------------------------
 | Exchange Completed Successfully                         |
 | Type: Exchange / Donation                               |
 | You can now review each other.                          |
 | [ Give Review ]                                         |
 -----------------------------------------------------------
```

Reviews remain available anytime:

```
 -----------------------------------------------------------
 | [ View / Edit Review ]                                  |
 -----------------------------------------------------------
```

---

### **If Rejected (Same as Before)**

```
 | Status: ● Rejected                                     |
 | Reason: Request was declined.                          |
 | Moves to History Tab                                   |
```

---

# ----------------------------------------------------------

# 🟧 4️⃣ **REQUESTS TO ME TAB (Updated With Courier Option)**

```
 ---------------------------------------------------------
 | Requested By: User B                                   |
 | [Avatar]                                               |
 | Requested Book: “Book Title”                           |
 | Author: John Doe                                       |
 | Date: 10 Mar 2025                                      |
 | Chat: [ Open Chat Room ]                               |
 ---------------------------------------------------------
 | Buttons: [ Approve ]     [ Reject ]                    |
 ---------------------------------------------------------
 | Timeline:                                              |
 |  Step 1: User Requested   ✔                            |
 |  Step 2: My Approval      ○                            |
 |  Step 3: Exchange Stage   ○                            |
 ---------------------------------------------------------
```

---

# 🟧 **After Approving (Updated With Courier Option)**

```
 | Status: Approved ✔                                      |
 | Chat: [ Continue Chat ]                                 |
 ----------------------------------------------------------
 | How do you want to exchange the book?                  |
 |  ( ) Meet in Person                                     |
 |  ( ) Courier Service                                    |
 ----------------------------------------------------------
```

---

## 🟧 If "Meet in Person" Selected

```
 | Meeting Time: Not Set                                   |
 | Location: Not Set                                       |
 | Buttons: [ Set Time ]   [ Set Location ]                |
 ----------------------------------------------------------
 | [ Mark as Exchanged ]                                   |
 ----------------------------------------------------------
```

---

## 🟧 If "Courier Service" Selected

```
 ---------------- Courier Exchange ------------------------
 | Courier Method: Not Selected                            |
 | Tracking ID: Not Provided                               |
 -----------------------------------------------------------
 | Buttons: [ Select Courier ]  [ Enter Tracking Code ]    |
 -----------------------------------------------------------
 | [ Mark as Exchanged ]                                   |
 -----------------------------------------------------------
```

---

# 🟧 **After Exchange (Both Must Confirm)**

```
 ------------------- Waiting for Confirmation --------------
 | You: Marked as Completed ✔                               |
 | User B: Pending Confirmation                             |
 -----------------------------------------------------------
```

After both confirm:

```
 ----------------------- Success ---------------------------
 | Exchange Completed Successfully                           |
 | You can now leave a review.                              |
 | [ Give Review ]                                           |
 -----------------------------------------------------------
```

Review always available later:

```
 | [ View / Edit Review ]                                   |
```


# ----------------------------------------------------------

# 🟨 5️⃣ **HISTORY TAB**

# ----------------------------------------------------------

### **Status Filters**

```
 ---------------------------------------------------------
 | All | Successful | Rejected | Cancelled | Donated |
 ---------------------------------------------------------
```

### **History Cards**

#### **Successful**

```
 ====================== SUCCESSFUL ========================
 ---------------------------------------------------------
 | [Cover]  Book Title (You ↔ User A)                     |
 | Author: John Doe                                       |
 | Type: Exchange / Donation                              |
 | Completed On: 15 Feb 2025                              |
 | Feedback: ⭐⭐⭐⭐⭐                                       |
 ---------------------------------------------------------
```

#### **Unsuccessful**

```
 ===================== UNSUCCESSFUL ======================
 ---------------------------------------------------------
 | [Cover]  Book Title (User C)                           |
 | Author: Mark Lee                                       |
 | Status: Rejected                                       |
 | Date: 20 Feb 2025                                      |
 ---------------------------------------------------------
```

---

# ----------------------------------------------------------

# 🟦 6️⃣ **UPDATED CHAT ROOM WIREFRAME**

# ----------------------------------------------------------

### **Chat Room Title**

**Book Name — Author Name & Owner Name**

Example:
**“Atomic Habits — James Clear & Owner: User A”**

```
 ------------------ Atomic Habits — James Clear & User A ------------------
```

---

### **Book Info Section (Clickable)**

```
 ---------------------------------------------------------------
 |  [Book Cover]   Atomic Habits                               |
 |  Author: James Clear                                        |
 |  Owner: User A                                              |
 |                                                             |
 |  [ View Book Details ] (Opens Full Book Page)               |
 ---------------------------------------------------------------
```

---

### **Current Status Section (Clickable)**

```
 --------------------- Current Status --------------------------
 | Status: ● Approved                                          |
 | [ View Request Timeline ]                                   |
 ---------------------------------------------------------------
```

If pending:

```
 | Status: ● Pending (Tap for details)                         |
```

If meeting is set:

```
 ---------------- Exchange Arrangement -------------------------
 | Meeting Time: 5 PM, Tomorrow                                |
 | Location: Campus Main Gate                                   |
 | [ Change ]                                                   |
 ---------------------------------------------------------------
```

---

### **Messages Section (Only Text)**

```
 ----------------------------- Chat -----------------------------
 | Them: Hi, thanks for requesting the book.                     |
 |                                                               |
 | You: When can we meet to exchange it?                         |
 |                                                               |
 | Them: Tomorrow evening works.                                |
 ----------------------------------------------------------------
```

---

### **Message Input**

```
 ---------------------------------------------------------------
 | [ Type your message...                          ] [ Send ]  |
 ---------------------------------------------------------------
```

---

### **Completion (After Exchange)**

```
 ------------------ Exchange Completion -------------------------
 | [ Mark as Completed ]                                        |
 ----------------------------------------------------------------
```

Moves to History when both users confirm.

---
