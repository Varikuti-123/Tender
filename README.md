# Tender
Tender


# 📋 TENDER MANAGEMENT MODULE FOR MICROSOFT DYNAMICS 365 BUSINESS CENTRAL

## Complete README & User Guide

---

## 📖 TABLE OF CONTENTS

1. [What is This Module](#what-is-this-module)
2. [Installation](#installation)
3. [First Time Setup](#first-time-setup)
4. [Understanding Key Concepts](#understanding-key-concepts)
5. [Complete Process Flow — Step by Step](#complete-process-flow)
6. [HSN Process (Goods/Products)](#hsn-process)
7. [SAC Process (Services)](#sac-process)
8. [Rate Contract Process](#rate-contract-process)
9. [Reverse Auction Process](#reverse-auction-process)
10. [Corrigendum Process](#corrigendum-process)
11. [Re-Tender Process](#re-tender-process)
12. [Vendor Performance Rating](#vendor-performance-rating)
13. [Excel Templates](#excel-templates)
14. [Status Flow Diagram](#status-flow-diagram)
15. [Security & Permissions](#security-and-permissions)
16. [Troubleshooting](#troubleshooting)
17. [Technical Reference](#technical-reference)
18. [FAQ](#faq)

---

## 1. WHAT IS THIS MODULE

This module adds a complete **Tender Management** system inside Business Central. It allows your organization to:

- Create tenders for purchasing goods (HSN) or hiring services (SAC)
- Build a Bill of Quantities (BOQ) manually or by importing from Excel
- Invite multiple vendors and auto-create purchase quotes for each vendor
- Collect vendor quotations, compare them side by side
- Run reverse auctions to get the best price
- Negotiate with the selected vendor
- Auto-create a Purchase Order (for goods) or Work Order (for services)
- Track rate contracts with ceiling quantities
- Rate vendor performance after completion
- Maintain a full audit trail with archiving and corrigendums

**It connects to your existing BC data** — Items, Vendors, Purchase Documents, Dimensions, Currencies, and Approval Workflows.

**It is source-agnostic** — tenders can originate from Projects, General Services, or any future module you build. You never need to modify the tender code to add a new source.

---

## 2. INSTALLATION

### Prerequisites
- Microsoft Dynamics 365 Business Central (Online or On-Premises)
- Version 21.0 or later (AL language)
- Administrator access to publish extensions

### Steps

```
1. Download or clone the extension source code
2. Open the project folder in Visual Studio Code with AL Language extension
3. Update app.json with your:
   - Publisher name
   - App ID (generate a new GUID)
   - Version number
   - BC target version
4. Press Ctrl+Shift+B to build
5. Press F5 to deploy to your sandbox/development environment
6. For production: Upload the .app file via Extension Management in BC
```

### File Structure
```
TenderManagement/
├── app.json
├── Enums/
│   ├── Enum50100.TenderSourceModule.al
│   ├── Enum50101.TenderStatus.al
│   ├── ... (20 enum files)
│   └── EnumExt50100.PurchDocType.al
├── Interfaces/
│   └── ITenderSourceModule.al
├── Tables/
│   ├── Tab50100.TenderSetup.al
│   ├── Tab50101.TenderHeader.al
│   ├── ... (16 table files)
│   ├── TabExt50100.PurchaseHeader.al
│   └── TabExt50101.PurchaseLine.al
├── Codeunits/
│   ├── Cod50100.TenderManagement.al
│   ├── ... (10 codeunit files)
├── Pages/
│   ├── Pag50100.TenderSetup.al
│   ├── Pag50101.TenderList.al
│   ├── ... (19 page files)
├── PermissionSets/
│   ├── PermSet50100.TenderAdmin.al
│   ├── ... (7 permission set files)
└── README.md
```

---

## 3. FIRST TIME SETUP

After installing the extension, you must configure it before creating your first tender.

### Step 1: Open Tender Setup

```
Search → "Tender Setup" → Open the page
```

### Step 2: Configure Number Series

| Field | What to Enter | Example |
|-------|--------------|---------|
| Tender No. Series | A number series for tender documents | TENDER |
| Work Order No. Series | A number series for work orders | WO |
| Rate Contract No. Series | A number series for rate contracts | RC |
| Corrigendum No. Series | A number series for corrigendums | CORR |
| Default Bid Validity Days | How many days vendor quotes are valid | 30 |

**How to create a Number Series:**
```
1. Search → "No. Series" → Open
2. Click New
3. Enter Code: TENDER, Description: Tender Numbers
4. Click Lines
5. Enter Starting No.: TND-0001, Ending No.: TND-9999
6. Check "Default Nos." = Yes
7. Repeat for WO, RC, CORR series
```

### Step 3: Configure Reverse Auction Settings

| Field | Description | Suggested Value |
|-------|-------------|----------------|
| Min Decrement Percentage | Vendor must reduce price by at least this % | 1 |
| Min Decrement Amount | Or by at least this amount | 100 |
| Decrement Type | Which rule to apply | Either |
| Default Round Time Limit | Minutes per auction round | 60 |
| Auction Visibility | What vendors can see | Open |
| Max Auction Rounds | Maximum rounds allowed | 5 |

### Step 4: Enable Features

| Toggle | Turn ON if you want to... |
|--------|--------------------------|
| Enable Reverse Auction | Use reverse auction functionality |
| Enable Vendor Performance | Rate vendors after order completion |
| Enable Digital Signatures | Track digital signature events |
| Enable Auto Disqualification | Auto-check vendor eligibility |
| Enable Rate Contracts | Use rate contract tender type |

### Step 5: Assign Permissions to Users

```
1. Search → "Users" → Open
2. Select a user
3. Go to Permission Sets
4. Add the appropriate permission set:
   - TENDER_ADMIN → For administrators
   - TENDER_CREATOR → For people who create and manage tenders
   - TENDER_APPROVER → For people who approve tenders
   - TENDER_EVALUATOR → For people who evaluate vendor quotes
   - TENDER_VIEWER → For read-only access
   - TENDER_AUCTION_ADMIN → For auction managers
   - TENDER_VENDOR_FEEDBACK → For people who rate vendors
```

---

## 4. UNDERSTANDING KEY CONCEPTS

### What is HSN vs SAC?

| | HSN (Products/Goods) | SAC (Services) |
|---|---|---|
| **What** | Physical items from your Item Master | Service work described in text |
| **BOQ Style** | Simple flat list of items | Hierarchical structure with headings |
| **How to add lines** | Pick items OR import from Excel | Import from Excel ONLY |
| **Description** | Short text from Item Master | Long paragraphs stored in Blob |
| **Ends in** | Purchase Order | Work Order |
| **Example** | 100 bags of cement, 50 steel rods | Construction of a boundary wall |

### What is Indentation (SAC only)?

Service BOQs have a tree structure:

```
Level 0 — CIVIL WORKS (Main Heading — bold, no quantity)
  Level 1 — Foundation Work (Heading — bold, no quantity)
    Level 2 — Excavation in ordinary soil... (Line Item — has qty, rate, amount)
    Level 2 — PCC 1:4:8 concrete for base... (Line Item — has qty, rate, amount)
      Level 3 — Including formwork for edges (Sub Item — has qty, rate, amount)
  Level 1 — Structural Work (Heading — bold, no quantity)
    Level 2 — RCC M25 grade concrete... (Line Item — has qty, rate, amount)
Level 0 — ELECTRICAL WORKS (Main Heading — bold, no quantity)
  Level 1 — Internal Wiring (Heading)
    Level 2 — Supply and laying of cable... (Line Item)
```

**Key Rules:**
- Level 0 and 1 are headings — they show structure but have NO quantities
- Level 2 and 3 are actual work items — they have UoM, Quantity, Rate, Amount
- You cannot skip levels (jumping from 0 to 3 is invalid)
- Line Type is AUTO-DETERMINED from the indentation — you never pick it manually

### What is a Rate Contract?

A rate contract is a standing agreement with a vendor for a fixed period at agreed rates. Instead of creating one PO for the entire quantity, you create multiple smaller POs over time, all using the contracted rates.

**Example:** You agree with a vendor to supply cement at ₹350/bag for 12 months. Over the year, you create 10 different POs for different quantities, all at ₹350/bag.

### What is a Corrigendum?

A corrigendum is an official amendment to a tender that has already been published for bidding. It might change:
- The bid deadline (extended by 2 weeks)
- The BOQ (added new items or changed quantities)
- The terms and conditions
- Or a combination of these

When you issue a corrigendum, the system automatically archives the current version before applying changes.

### What is Reverse Auction?

After collecting initial quotes from vendors, you run multiple rounds where vendors compete to offer the lowest price. In each round, they must reduce their price by at least a minimum percentage or amount. The system tracks all bids and ranks vendors automatically.

---

## 5. COMPLETE PROCESS FLOW — STEP BY STEP

Here is the complete lifecycle of a tender from start to finish:

```
┌─────────────────────────────────────────────────────────┐
│                    TENDER LIFECYCLE                       │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ① CREATE TENDER (Status: Draft)                         │
│  Fill header: Description, Source, Item Type, Dates       │
│       │                                                   │
│       ▼                                                   │
│  ② BUILD BOQ (Still Draft)                               │
│  HSN: Add items manually or import Excel                  │
│  SAC: Import from Excel (download template first)         │
│       │                                                   │
│       ▼                                                   │
│  ③ ALLOCATE VENDORS (Status: Vendors Allocated)          │
│  Add 1 or more vendors to the tender                      │
│       │                                                   │
│       ▼                                                   │
│  ④ SEND FOR APPROVAL (Status: Pending Approval)         │
│  Triggers approval workflow                               │
│       │                                                   │
│       ├──→ REJECTED → Back to Draft (edit and resubmit)  │
│       │                                                   │
│       ▼                                                   │
│  ⑤ APPROVED (Status: Approved)                           │
│       │                                                   │
│       ▼                                                   │
│  ⑥ CREATE QUOTES (Status: Quotes Created)                │
│  System auto-creates a Purchase Quote per vendor          │
│       │                                                   │
│       ▼                                                   │
│  ⑦ OPEN BIDDING (Status: Bidding Open)                   │
│  Vendors submit their prices on quotes                    │
│  [Corrigendum can be issued during this phase]            │
│       │                                                   │
│       ▼                                                   │
│  ⑧ CLOSE BIDDING (Status: Bidding Closed)                │
│       │                                                   │
│       ├──→ [If Reverse Auction enabled]                   │
│       │    ⑧a. START AUCTION (Status: Reverse Auction)   │
│       │    Run multiple rounds, vendors reduce prices      │
│       │    Finalize → Status: Under Evaluation            │
│       │                                                   │
│       ▼                                                   │
│  ⑨ EVALUATE (Status: Under Evaluation)                   │
│  Open Comparative Statement to compare vendors            │
│       │                                                   │
│       ▼                                                   │
│  ⑩ SELECT VENDOR (Status: Vendor Selected)               │
│  Mark one vendor as the winner                            │
│       │                                                   │
│       ▼                                                   │
│  ⑪ NEGOTIATION (Status: Negotiation)                     │
│  Negotiate terms with selected vendor                     │
│  [Amended BOQ can be imported during this phase]          │
│       │                                                   │
│       ▼                                                   │
│  ⑫ APPROVE NEGOTIATION (Status: Negotiation Approved)    │
│       │                                                   │
│       ▼                                                   │
│  ⑬ CREATE ORDER (Status: Order Created)                  │
│  HSN → Purchase Order                                     │
│  SAC → Work Order                                         │
│  Rate Contract → Activates standing agreement             │
│       │                                                   │
│       ▼                                                   │
│  ⑭ CLOSE TENDER (Status: Closed)                        │
│  After PO/WO is completed and received                    │
│       │                                                   │
│       ▼                                                   │
│  ⑮ RATE VENDOR (Optional)                                │
│  Submit performance rating after completion               │
│                                                           │
└─────────────────────────────────────────────────────────┘

AT ANY POINT:
  ├── RE-TENDER → Archives current, creates new tender
  └── ARCHIVE → Creates version snapshot for audit trail
```

---

## 6. HSN PROCESS (GOODS/PRODUCTS) — Detailed Steps

### Scenario: Your organization needs to purchase 500 bags of cement, 200 steel rods, and 100 electrical switches through a competitive tender.

### Step 1: Create the Tender

```
1. Search → "Tenders" or "Tender List" → Open
2. Click "New" → A new Tender Card opens
3. Fill in:
   - No.: Auto-assigned (e.g., TND-0001)
   - Description: "Purchase of Construction Materials"
   - Source Module: Project (or General Service, or leave blank)
   - Source ID: Select the project number (if applicable)
     → Budget Amount, Business Unit, Sanction No. auto-fill
   - Item Type: HSN ← THIS IS CRITICAL
   - Tender Type: Standard
   - Bid Start Date: 01/02/2025
   - Bid End Date: 15/02/2025
   - Bid Validity Date: 15/03/2025
```

### Step 2: Add BOQ Lines (Two Options)

**Option A: Manually Add Items**
```
1. In the Tender Lines subpage at the bottom of the card:
2. Click on the first empty line
3. In "Item No." column → Look up and select an item (e.g., CEMENT-50KG)
4. Description and UoM auto-fill from Item Master
5. Enter Quantity: 500
6. Enter Unit Cost: 350.00 (estimated rate)
7. Line Amount auto-calculates: 175,000.00
8. Repeat for each item
```

**Option B: Import from Excel**
```
1. First, download the template:
   → On the Tender Card, click "Download HSN BOQ Template"
   → An Excel file downloads with columns: Item No., Quantity, Unit Cost

2. Fill the Excel:
   | Item No.      | Quantity | Unit Cost |
   |---------------|----------|-----------|
   | CEMENT-50KG   | 500      | 350.00    |
   | STEEL-ROD-12  | 200      | 850.00    |
   | ELEC-SWITCH   | 100      | 125.00    |

3. Save the Excel file

4. On the Tender Lines subpage, click "Import BOQ from Excel"
5. Select your Excel file
6. System validates all Item Nos exist, then creates lines
7. Message: "HSN BOQ imported successfully. 3 lines created."
```

**What you see after adding lines:**

| Item No. | Description | UoM | Qty | Unit Cost | Amount |
|----------|------------|-----|-----|-----------|--------|
| CEMENT-50KG | Portland Cement 50kg | BAG | 500 | 350.00 | 175,000.00 |
| STEEL-ROD-12 | Steel Rod 12mm | NOS | 200 | 850.00 | 170,000.00 |
| ELEC-SWITCH | Electrical Switch 16A | NOS | 100 | 125.00 | 12,500.00 |

**Note:** For HSN, you do NOT see BOQ Serial No. or Line Type columns — they are hidden.

### Step 3: Allocate Vendors

```
1. On the Tender Card, click Process → "Allocate Vendors"
2. The Vendor Allocation page opens
3. Click "Add Vendor"
4. A Vendor List pops up → Select a vendor (e.g., V10001 - ABC Supplies)
5. Repeat to add more vendors (e.g., V10002, V10003)
6. For each vendor, you can optionally set:
   - Currency Code (if vendor quotes in USD, EUR, etc.)
7. Status automatically changes to "Vendors Allocated"
```

### Step 4: Send for Approval

```
1. On the Tender Card, click Process → "Send for Approval"
2. System validates:
   ✓ At least 1 tender line exists
   ✓ Description is filled
   ✓ Item Type is selected
   ✓ Tender Type is selected
   ✓ Bid End Date is filled
3. If all OK → Status changes to "Pending Approval"
4. (In production, this triggers your BC approval workflow)
```

### Step 5: Approve the Tender

```
1. The approver opens the tender
2. Clicks Process → "Approve"
3. Status changes to "Approved"
```

### Step 6: Create Quotes

```
1. On the Tender Card, click Process → "Create Quotes"
2. System automatically creates ONE Purchase Quote per vendor:
   - Quote for V10001 → Quote No. PQ-0001
   - Quote for V10002 → Quote No. PQ-0002
   - Quote for V10003 → Quote No. PQ-0003
3. Each quote contains all the BOQ lines
4. Status changes to "Quotes Created"
5. Message: "Quotes created for all allocated vendors."
```

### Step 7: Bidding Period

```
1. Click Process → "Open Bidding"
2. Status changes to "Bidding Open"
3. During this period:
   - Vendors receive their quotes (manually or via your portal)
   - Each vendor fills in their prices on their quote
   - They "submit" their bid before the Bid End Date
4. After the Bid End Date passes:
   Click Process → "Close Bidding"
5. Status changes to "Bidding Closed"
```

### Step 8: Evaluate and Select Vendor

```
1. Click Navigate → "Quotes" to see all vendor quotes
2. Compare prices across vendors
3. Go to Vendor Allocation page
4. Check "Is Selected Vendor" = Yes for the winning vendor
5. Click Process → "Select Vendor" (if using the action)
6. Status changes to "Vendor Selected"
```

### Step 9: Negotiation

```
1. Click Process → "Send to Negotiation"
2. Status changes to "Negotiation"
3. Fill in:
   - Negotiate Date: Date of negotiation meeting
   - Negotiate Place: "Head Office Board Room"
4. After negotiation is complete:
   Click Process → "Approve Negotiation"
5. Status changes to "Negotiation Approved"
```

### Step 10: Create Purchase Order

```
1. Click Process → "Create Purchase Order"
   (This button is ONLY enabled when Item Type = HSN AND
    Status = Negotiation Approved)
2. System creates a Purchase Order from the selected vendor's quote
3. PO No. is stored in "Created Order No." field
4. Status changes to "Order Created"
5. Message: "Purchase Order PO-0001 created."
6. You can now process this PO through standard BC purchase workflow
```

### Step 11: Close the Tender

```
1. After the PO is fully received and invoiced:
   Click Process → "Close Tender"
2. Status changes to "Closed"
3. Closed Date is automatically set to today
```

---

## 7. SAC PROCESS (SERVICES) — Detailed Steps

### Scenario: Your organization needs to hire a contractor for "Construction of Boundary Wall and Gate" through a competitive tender.

### Step 1: Create the Tender

```
1. Search → "Tenders" → Click "New"
2. Fill in:
   - Description: "Construction of Boundary Wall and Gate"
   - Source Module: Project
   - Source ID: PRJ-0042
   - Item Type: SAC ← THIS CHANGES EVERYTHING
   - Tender Type: Standard
   - Bid Start Date: 01/03/2025
   - Bid End Date: 20/03/2025
```

**What changes when you select SAC:**
- The "Download SAC BOQ Template" action appears
- The Tender Lines subpage shows different columns:
  - BOQ Serial No. (visible)
  - Line Type (visible, read-only)
  - Short Description (visible, with full description in detail area)
  - Item No. column is HIDDEN
- You can ONLY import lines from Excel — manual "Add Line" is disabled

### Step 2: Download the SAC Excel Template

```
1. On the Tender Card, click "Download SAC BOQ Template"
2. An Excel file downloads with TWO sheets:

   Sheet 1: "BOQ Data" — Has columns and sample data
   Sheet 2: "Instructions" — Has detailed guide
```

### Step 3: Prepare Your BOQ in Excel

Open the downloaded template and replace the sample data with your BOQ:

```
| Indentation | BOQ Serial No. | Description | UoM | Qty | Unit Cost |
|-------------|---------------|-------------|-----|-----|-----------|
| 0 | 1 | BOUNDARY WALL CONSTRUCTION | | | |
| 1 | 1.1 | Earth Work | | | |
| 2 | 1.1.1 | Excavation in ordinary soil including ramming of foundation trenches and disposal of surplus earth within 50m lead as per drawing | Cum | 85 | 280 |
| 2 | 1.1.2 | Backfilling with selected excavated earth in layers of 150mm thick including watering and compaction | Cum | 40 | 120 |
| 1 | 1.2 | Concrete Work | | | |
| 2 | 1.2.1 | Providing and laying PCC 1:4:8 using 40mm down size aggregate for foundation base and leveling course | Cum | 12 | 4200 |
| 2 | 1.2.2 | Providing and laying RCC M25 grade concrete in foundation, plinth beam and columns including centering, shuttering, vibrating and curing | Cum | 28 | 6800 |
| 3 | 1.2.2.a | Extra for supply and bending of reinforcement steel Fe500D | MT | 3.5 | 52000 |
| 1 | 1.3 | Masonry Work | | | |
| 2 | 1.3.1 | Providing and constructing brick masonry in cement mortar 1:4 for boundary wall above plinth level | Cum | 65 | 5500 |
| 0 | 2 | GATE CONSTRUCTION | | | |
| 1 | 2.1 | MS Gate Work | | | |
| 2 | 2.1.1 | Fabrication and erection of MS gate 3m x 2m with 40x40x5mm angle frame and 16mm square bar vertical members including primer and 2 coats enamel paint | Nos | 2 | 45000 |
```

**Important rules while filling:**
```
✓ Indentation 0 and 1 → Leave UoM, Qty, Unit Cost BLANK (they are headings)
✓ Indentation 2 and 3 → Fill all columns (they are actual work items)
✓ Description can be as long as you want — the system handles it
✓ BOQ Serial No. must be unique — no duplicates
✓ Don't skip indentation levels (0→3 is invalid, 0→1→2→3 is valid)
✓ Don't change column order or add extra columns
✓ Don't merge cells
```

### Step 4: Import the BOQ

```
1. On the Tender Lines subpage, click "Import BOQ from Excel"
2. Select your filled Excel file
3. System validates:
   ✓ All column headers are correct
   ✓ Indentation hierarchy is valid (no level skipping)
   ✓ BOQ Serial Nos are unique
   ✓ Descriptions are not empty
   ✓ Headings don't have quantities
4. If validation fails → Error message showing all issues
5. If all OK → Lines are created with:
   - Line Type AUTO-SET from Indentation:
     0 → Main Heading
     1 → Heading
     2 → Line Item
     3 → Sub Item
   - Style AUTO-SET for display:
     Main Heading / Heading → Bold
     Line Item → Normal
     Sub Item → Subordinate
   - Long descriptions stored in Blob
   - Short Description = first 250 characters
6. Message: "SAC BOQ imported successfully. 12 lines created."
```

### What you see after import:

```
The Tender Lines subpage shows a tree-like structure:

▼ 1. BOUNDARY WALL CONSTRUCTION          [Bold, no amounts]
  ▼ 1.1 Earth Work                       [Bold, no amounts]
      1.1.1 Excavation in ordinary...    Cum    85   280.00   23,800.00
      1.1.2 Backfilling with selected... Cum    40   120.00    4,800.00
  ▼ 1.2 Concrete Work                    [Bold, no amounts]
      1.2.1 Providing and laying PCC...  Cum    12  4200.00   50,400.00
      1.2.2 Providing and laying RCC...  Cum    28  6800.00  190,400.00
        1.2.2.a Extra for reinforcement  MT    3.5 52000.00  182,000.00
  ▼ 1.3 Masonry Work                     [Bold, no amounts]
      1.3.1 Providing brick masonry...   Cum    65  5500.00  357,500.00
▼ 2. GATE CONSTRUCTION                   [Bold, no amounts]
  ▼ 2.1 MS Gate Work                     [Bold, no amounts]
      2.1.1 Fabrication of MS gate...    Nos     2 45000.00   90,000.00

When you click on any line, the FULL DESCRIPTION appears in the
detail area below the list — no separate page or action needed.
```

### Step 5 onwards: Same as HSN Process

```
The remaining steps are identical to the HSN process:
- Allocate Vendors → Send for Approval → Approve → Create Quotes →
  Open/Close Bidding → Evaluate → Select Vendor → Negotiate →
  Approve Negotiation → Create Order → Close

The ONLY difference at the end:
- Instead of "Create Purchase Order", you click "Create Work Order"
- A Work Order is created (stored as Purchase Header with Document Type = Work Order)
- You can view it in the "Work Order List" or "Work Order Card" pages
```

---

## 8. RATE CONTRACT PROCESS

### Scenario: You want to establish a 12-month rate contract with a vendor for regular supply of office stationery at fixed rates.

### Steps 1-12: Same as Standard Tender

```
The entire process up to "Negotiation Approved" is the same.
The ONLY difference is at Step 1:
- Tender Type: Rate Contract ← Select this instead of Standard
- Rate Contract Valid From: 01/04/2025
- Rate Contract Valid To: 31/03/2026
- Rate Contract Ceiling Amount: 500,000 (optional max spend limit)
```

### Step 13: After Negotiation Approved

```
When you complete the standard process, the tender becomes an
ACTIVE RATE CONTRACT instead of creating a single PO.

The tender status changes to "Order Created" but no PO is created yet.
The rate contract is now "live" and available for use.
```

### Step 14: Creating POs from the Rate Contract (On-Demand)

```
Whenever you need to order items:

1. Open the Tender Card for the rate contract
2. Navigate → "Rate Contract Usage"
3. Or use the Rate Contract PO Creation page
4. You'll see:
   | Item | Contracted Rate | Total Qty | Used Qty | Remaining Qty | Order Qty |
   |------|----------------|-----------|----------|---------------|-----------|
   | Pens | 15.00 | 1000 | 250 | 750 | [Enter: 100] |
   | Paper| 250.00 | 200 | 80 | 120 | [Enter: 20] |

5. Enter the quantities you need right now in "Order Qty"
6. Click "Create Purchase Order"
7. A PO is created at the CONTRACTED RATES (not editable)
8. Usage is recorded in the Rate Contract Usage table
9. If ceiling exists, system prevents exceeding it
```

```
You can repeat this process as many times as needed during
the rate contract validity period. Each PO is tracked.

System warns when:
- You're at 80% of ceiling amount
- Rate contract is nearing expiry (30 days)
- You try to order after expiry date
```

---

## 9. REVERSE AUCTION PROCESS

### When to Use
After collecting initial quotes and closing bidding, you want vendors to compete on price in real-time rounds.

### Prerequisites
```
- Enable Reverse Auction = Yes (in Tender Setup)
- Tender Status must be "Bidding Closed"
- All vendor quotes must be submitted
```

### Step-by-Step

```
1. INITIALIZE AUCTION
   On Tender Card → Process → "Start Reverse Auction"
   - Status changes to "Reverse Auction"
   - First round is auto-created
   - Entries are populated from each vendor's initial quote prices

2. OPEN A ROUND
   Navigate → "Auction Rounds"
   Select Round 1 → Click "Open Round"
   - Timer starts (e.g., 60 minutes)
   - Vendors can now submit revised prices

3. VENDORS SUBMIT BIDS
   On Reverse Auction Entries page:
   - Each vendor sees their current price and enters a new (lower) price
   - System validates: New price < Previous price
   - System validates: Decrement meets minimum requirement
   Example:
     Previous Price: 350.00
     New Price: 340.00
     Decrement: 2.86% (must be ≥ 1%) ✓
     Decrement: 10.00 (must be ≥ 100) ✗ (fails if type = Amount)

4. CLOSE THE ROUND
   Click "Close Round"
   - Rankings are auto-calculated
   - Lowest bidder gets Rank 1

5. OPTIONALLY CREATE MORE ROUNDS
   Click "Create New Round" → "Open Round"
   - Vendors can further reduce prices
   - Repeat until satisfied or max rounds reached

6. FINALIZE AUCTION
   Click "Finalize Auction"
   - Final prices are written back to the Purchase Quotes
   - Status changes to "Under Evaluation"
   - Continue with vendor selection and negotiation
```

### Visibility Settings

| Setting | Vendor Sees |
|---------|------------|
| Open | All vendors' prices — full transparency |
| Rank Only | "You are ranked #2 out of 3" — no prices visible |
| Sealed | Nothing — just submits blind bid |

---

## 10. CORRIGENDUM PROCESS

### When to Use
During the Bidding Open phase, you need to change something about the tender.

### Step-by-Step

```
1. Tender must be in "Bidding Open" status
2. Click Process → "Issue Corrigendum"
3. System automatically:
   - Archives the current tender version (creates a snapshot)
   - Creates a Corrigendum record

4. Choose Changes Type:
   a) Terms Only → Change dates, terms, conditions
      - Modify Bid End Date, Bid Validity Date, etc.
   b) BOQ Only → Change the Bill of Quantities
      - Import a revised Excel BOQ
   c) Both → Change terms AND BOQ

5. Fill in:
   - Description: "Extension of bid deadline by 2 weeks"
   - New Bid End Date: 01/04/2025
   - Terms Change Description: "Due to site inspection delay..."

6. Notify Vendors:
   Click "Notify Vendors" on the Corrigendum
   - System marks all vendors as notified
   - (In production, this raises an event for email integration)

7. View History:
   Navigate → "Corrigendums" shows all corrigendums issued
   Navigate → "Archive Versions" shows all snapshots taken
```

---

## 11. RE-TENDER PROCESS

### When to Use
When you want to cancel the current tender and start fresh — for example, no satisfactory bids received.

### Step-by-Step

```
1. Click Process → "Re-Tender"
2. Confirm the action
3. System automatically:
   - Archives the current tender (full snapshot)
   - Creates a NEW tender with a new number (e.g., TND-0002)
   - Copies all header fields, lines, and vendor allocations
   - Sets "Re-Tender Reference No." on the new tender → TND-0001
   - Marks the original tender as "Re-Tendered" (locked)
4. You now work on the new tender from Draft status
```

---

## 12. VENDOR PERFORMANCE RATING

### When to Use
After a Purchase Order or Work Order is fully received/completed.

### Step-by-Step

```
1. On the Tender Card, Navigate → "Vendor Performance"
2. A new Vendor Performance Rating card opens
3. Fill in:
   - Completion Date: The date work was completed
   - Quality Rating: 1-10 (how good was the quality?)
   - Timeliness Rating: 1-10 (were they on time?)
   - Compliance Rating: 1-10 (did they follow specifications?)
   - Communication Rating: 1-10 (were they responsive?)
   - Overall Rating: Auto-calculated average
   - Comments: "Good quality work, slightly delayed"
4. Click "Submit Rating"
5. Rating is recorded permanently

Future tenders: When evaluating vendors, their historical
ratings are visible for informed decision-making.
```

---

## 13. EXCEL TEMPLATES

### HSN Template (Simple)

| Column A | Column B | Column C |
|----------|----------|----------|
| Item No. | Quantity | Unit Cost |
| CEMENT-50KG | 500 | 350.00 |
| STEEL-ROD-12 | 200 | 850.00 |

```
Download: Tender Card → "Download HSN BOQ Template"
```

### SAC Template (Hierarchical)

| Column A | Column B | Column C | Column D | Column E | Column F |
|----------|----------|----------|----------|----------|----------|
| Indentation | BOQ Serial No. | Description | UoM | Quantity | Unit Cost |
| 0 | 1 | CIVIL WORKS | | | |
| 1 | 1.1 | Foundation Work | | | |
| 2 | 1.1.1 | Excavation in... | Cum | 85 | 280 |

```
Download: Tender Card → "Download SAC BOQ Template" (only visible when Item Type = SAC)
The template includes an Instructions sheet with complete guide.
```

---

## 14. STATUS FLOW DIAGRAM

```
                          ┌──────────┐
                          │  DRAFT   │◄─────────────────┐
                          └────┬─────┘                   │
                               │ Allocate Vendors        │ Reopen
                               ▼                         │
                     ┌──────────────────┐                │
                     │ VENDORS ALLOCATED │                │
                     └────────┬─────────┘                │
                              │ Send for Approval        │
                              ▼                          │
                     ┌──────────────────┐         ┌──────┴────┐
                     │ PENDING APPROVAL │────────►│  REJECTED  │
                     └────────┬─────────┘         └───────────┘
                              │ Approve
                              ▼
                     ┌──────────────────┐
                     │    APPROVED      │
                     └────────┬─────────┘
                              │ Create Quotes
                              ▼
                     ┌──────────────────┐
                     │ QUOTES CREATED   │
                     └────────┬─────────┘
                              │ Open Bidding
                              ▼
                     ┌──────────────────┐
                     │  BIDDING OPEN    │◄──── Corrigendum
                     └────────┬─────────┘      (stays here)
                              │ Close Bidding
                              ▼
                     ┌──────────────────┐
                     │ BIDDING CLOSED   │
                     └───┬─────────┬────┘
          Auction enabled│         │No auction
                         ▼         │
                ┌─────────────┐    │
                │REV. AUCTION │    │
                └──────┬──────┘    │
                       │ Finalize  │
                       ▼           ▼
                   ┌──────────────────┐
                   │UNDER EVALUATION  │
                   └────────┬─────────┘
                            │ Select Vendor
                            ▼
                   ┌──────────────────┐
                   │ VENDOR SELECTED  │
                   └────────┬─────────┘
                            │ Send to Negotiation
                            ▼
                   ┌──────────────────┐
                   │  NEGOTIATION     │◄──── Amended BOQ
                   └────────┬─────────┘      (→ AMENDED → back)
                            │ Approve Negotiation
                            ▼
                   ┌──────────────────┐
                   │  NEG. APPROVED   │
                   └────────┬─────────┘
                            │ Create PO/WO
                            ▼
                   ┌──────────────────┐
                   │ ORDER CREATED    │
                   └────────┬─────────┘
                            │ Close
                            ▼
                   ┌──────────────────┐
                   │     CLOSED       │
                   └──────────────────┘

        ╔══════════════════════════════╗
        ║  FROM ANY STATUS:            ║
        ║  → RE-TENDERED (new tender)  ║
        ║  → ARCHIVE (snapshot)        ║
        ╚══════════════════════════════╝
```

---

## 15. SECURITY AND PERMISSIONS

### Permission Matrix

| Action | Admin | Creator | Approver | Evaluator | Viewer |
|--------|-------|---------|----------|-----------|--------|
| Create Tender | ✅ | ✅ | ❌ | ❌ | ❌ |
| Edit Tender | ✅ | ✅ | ❌ | ❌ | ❌ |
| Import BOQ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Allocate Vendors | ✅ | ✅ | ❌ | ❌ | ❌ |
| Approve/Reject | ✅ | ❌ | ✅ | ❌ | ❌ |
| View Quotes | ✅ | ✅ | ✅ | ✅ | ✅ |
| Select Vendor | ✅ | ❌ | ❌ | ✅ | ❌ |
| Create PO/WO | ✅ | ✅ | ❌ | ❌ | ❌ |
| Manage Auction | ✅ | ❌ | ❌ | ❌ | ❌ |
| Rate Vendor | ✅ | ❌ | ❌ | ❌ | ❌ |
| View Everything | ✅ | ✅ | ✅ | ✅ | ✅ |
| Change Setup | ✅ | ❌ | ❌ | ❌ | ❌ |

---

## 16. TROUBLESHOOTING

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|---------|
| "Tender is not editable in status X" | You're trying to edit a tender that's past Draft/Rejected | Change status back to Draft or use Corrigendum/Amendment |
| "At least one vendor must be allocated" | Trying to advance without vendors | Go to Allocate Vendors and add vendors |
| "At least one tender line must exist" | Trying to send for approval with no BOQ | Import or add BOQ lines first |
| "Item X does not exist" | Excel import has invalid Item No. | Check the Item No. exists in BC Item Master |
| "Cannot skip indentation levels" | SAC Excel has 0 followed by 3 | Fix Excel: use 0, 1, 2, 3 in order |
| "Only one vendor can be selected" | Two vendors marked as selected | Deselect the wrong vendor first |
| "Vendor X is blocked" | Trying to allocate a blocked vendor | Unblock the vendor first or choose another |
| "Expected column header X but found Y" | Excel columns are in wrong order | Use the downloaded template exactly |
| "Bid End Date cannot be before Bid Start Date" | Dates are wrong | Fix the dates |
| "Purchase Order can only be created for HSN" | Clicked Create PO on a SAC tender | Use Create Work Order instead |
| "Work Order can only be created for SAC" | Clicked Create WO on an HSN tender | Use Create Purchase Order instead |
| "Negotiation must be approved" | Trying to create order before negotiation approval | Complete negotiation approval first |
| "Rate contract has expired" | Creating PO from expired rate contract | Check validity dates |
| "Order quantity exceeds remaining" | Rate contract ceiling exceeded | Reduce order quantity |

### How to Recover from Mistakes

```
WRONG STATUS:
→ If rejected: Click Reopen → goes back to Draft
→ If stuck: An admin can manually change status (with care)

WRONG BOQ:
→ If in Draft: Delete lines and re-import
→ If after approval: Use "Import Amended BOQ" during Negotiation
→ If during bidding: Issue a Corrigendum

WRONG VENDOR SELECTED:
→ Go to Vendor Allocation → Uncheck "Is Selected Vendor"
→ Check the correct vendor

WANT TO START OVER:
→ Use "Re-Tender" action → Creates fresh copy
```

---

## 17. TECHNICAL REFERENCE

### Object ID Ranges

| Object Type | ID Range | Count |
|------------|----------|-------|
| Enums | 50100-50119 | 20 |
| Tables | 50100-50115 | 16 |
| Table Extensions | 50100-50101 | 2 |
| Enum Extension | 50100 | 1 |
| Codeunits | 50100-50109 | 10 |
| Pages | 50100-50118 | 19 |
| Permission Sets | 50100-50106 | 7 |

### Key Tables

| Table | Purpose | Records |
|-------|---------|---------|
| Tender Setup | Configuration | 1 (singleton) |
| Tender Header | Main tender record | 1 per tender |
| Tender Line | BOQ lines | Many per tender |
| Tender Vendor Allocation | Invited vendors | Many per tender |
| Tender Header Archive | Snapshots | Many per tender |
| Tender Corrigendum | Amendments | Many per tender |
| Reverse Auction Round | Auction rounds | Many per tender |
| Reverse Auction Entry | Vendor bids | Many per round |
| Rate Contract Usage | PO tracking | Many per rate contract |
| Vendor Performance Rating | Feedback | 1 per tender per vendor |

### Integration Events Available

The module publishes **40+ integration events** that you can subscribe to from other extensions:

```
Tender Lifecycle:
  OnAfterTenderCreated, OnBeforeTenderApproval, OnAfterTenderApproved,
  OnAfterTenderRejected, OnBeforeQuoteCreation, OnAfterQuoteCreated,
  OnBeforeVendorSelection, OnAfterVendorSelected, OnBeforeOrderCreation,
  OnAfterOrderCreated, OnBeforeTenderClose, OnAfterTenderClosed,
  OnBeforeReTender, OnAfterReTender

Two-Envelope (placeholder):
  OnBeforeTechnicalBidOpen, OnAfterTechnicalEvaluation,
  OnBeforeCommercialBidOpen, OnAfterCommercialBidOpen

Negotiation:
  OnBeforeNegotiationApproval, OnAfterNegotiationApproved,
  OnBeforeAmendedBOQImport, OnAfterAmendedBOQImport

Corrigendum:
  OnBeforeCorrigendumIssue, OnAfterCorrigendumIssued, OnAfterVendorsNotified

Reverse Auction:
  OnBeforeAuctionRoundOpen, OnAfterAuctionRoundClosed,
  OnAfterBidSubmitted, OnBeforeAuctionFinalized

Disqualification:
  OnEvaluateCustomRule, OnAfterVendorDisqualified

Digital Signature:
  OnSignatureRequested, OnSignatureCompleted, OnSignatureRejected

Vendor Performance:
  OnBeforePerformanceSubmitted, OnAfterPerformanceSubmitted

BOQ Import:
  OnBeforeBOQImport, OnAfterBOQLineImported, OnAfterBOQImportCompleted

Rate Contract:
  OnBeforeRateContractPOCreated, OnAfterRateContractPOCreated
```

### Adding a New Source Module

To add a new source module (e.g., "Maintenance"):

```al
// Step 1: In your extension, extend the enum
enumextension 51000 "Maintenance Source" extends "Tender Source Module"
{
    value(100; "Maintenance") { Caption = 'Maintenance'; }
}

// Step 2: Create an implementation codeunit
codeunit 51000 "Maintenance Tender Source" implements "ITenderSourceModule"
{
    procedure GetSourceDescription(): Text
    begin
        exit('Maintenance');
    end;

    procedure ValidateSourceID(SourceID: Code[20]): Boolean
    var
        MaintOrder: Record "Maintenance Order"; // Your table
    begin
        exit(MaintOrder.Get(SourceID));
    end;

    // ... implement all interface methods

    procedure GetBudgetAmount(SourceID: Code[20]): Decimal
    begin
        // Return budget from your maintenance order
    end;

    // ... etc.
}

// Step 3: Subscribe to the dispatcher to register your module
// The tender system will automatically use your implementation
// when Source Module = Maintenance is selected on a tender.
```

**No modification to the core tender module is needed.**

---

## 18. FAQ

**Q: Can I create a tender without linking to a Project or General Service?**
A: Yes. Leave Source Module blank. Budget Amount and other auto-fill fields will just be empty.

**Q: Can a tender have both HSN and SAC items?**
A: No. A tender is either HSN or SAC. If you need both, create two separate tenders.

**Q: Can I change Item Type after adding lines?**
A: No. Item Type can only be changed in Draft status and will clear existing lines.

**Q: How many vendors can I allocate?**
A: No limit. But only ONE vendor can be selected as the winner.

**Q: Can I edit vendor quote prices?**
A: The vendor's quote is a standard BC Purchase Quote. Prices can be edited on the quote directly during the bidding period.

**Q: What happens to existing quotes when I issue a corrigendum?**
A: The current state is archived. If BOQ changes, updated lines can be pushed to existing quotes.

**Q: Can I have multiple currencies in one tender?**
A: Yes. Each vendor can quote in their own currency. The Comparative Statement converts everything to LCY for fair comparison.

**Q: Is there a vendor portal?**
A: Not in this module. However, the OnAfterNITPublish and OnAfterVendorsNotified events can be used to integrate with an external portal.

**Q: Can I delete a tender?**
A: Only in Draft or Rejected status. Once approved or beyond, it cannot be deleted — only closed or re-tendered.

**Q: Where are the statistics (count of vendors, total amount, etc.)?**
A: In the FactBox panel on the right side of the Tender Card. They are NOT on the header to keep it clean.

**Q: What is the Work Order?**
A: It's a new Purchase Document Type added to BC. It works like a Purchase Order but is specifically for service contracts (SAC). It has its own Card and List pages.

**Q: Can I customize the module?**
A: Yes. The module publishes 40+ integration events. You can subscribe to any event from your own extension to add custom logic without modifying the core code.

---

## QUICK REFERENCE CARD

```
╔══════════════════════════════════════════════════════════════╗
║                TENDER MANAGEMENT — QUICK REFERENCE           ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  SEARCH PAGES:                                               ║
║  ├── "Tenders" or "Tender List" → All tenders                ║
║  ├── "Tender Setup" → Configuration                          ║
║  ├── "Work Orders" or "Work Order List" → SAC orders         ║
║  └── "Tender Dashboard" → Activity cues                      ║
║                                                              ║
║  CREATE TENDER:                                              ║
║  Tender List → New → Fill Header → Add Lines → Save          ║
║                                                              ║
║  HSN = Goods → Pick Items → Purchase Order                   ║
║  SAC = Services → Import Excel BOQ → Work Order              ║
║                                                              ║
║  TYPICAL FLOW:                                               ║
║  Draft → Allocate Vendors → Approve → Create Quotes →        ║
║  Bidding → Evaluate → Select Vendor → Negotiate →            ║
║  Approve Negotiation → Create PO/WO → Close                  ║
║                                                              ║
║  KEY RULES:                                                  ║
║  ├── One tender = One item type (HSN or SAC)                 ║
║  ├── One tender = One winning vendor                          ║
║  ├── One tender = One PO or One WO                           ║
║  ├── Editable only in Draft/Rejected/Amended                  ║
║  ├── SAC lines: Import only, no manual add                    ║
║  └── Line Type: Auto-set from Indentation, never manual      ║
║                                                              ║
║  SHORTCUTS:                                                   ║
║  ├── Download Template: Tender Card → Download BOQ Template   ║
║  ├── Import BOQ: Tender Lines → Import BOQ from Excel         ║
║  ├── Compare Vendors: Navigate → Comparative Statement        ║
║  ├── View Archives: Navigate → Archive Versions               ║
║  └── Rate Vendor: Navigate → Vendor Performance               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

---

**Module Version:** 1.0.0
**BC Compatibility:** Version 21.0+
**Last Updated:** 2025

---

*For technical support or feature requests, contact your system administrator or the extension developer.*