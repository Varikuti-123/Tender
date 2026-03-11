// ============================================================
// Enum 50100 - Tender Source Module
// Purpose: Identifies which module created the tender.
//          Extensible so future modules can plug in.
// ============================================================
enum 50100 "Tender Source Module"
{
    Extensible = true;
    Caption = 'Tender Source Module';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Project)
    {
        Caption = 'Project';
    }
    value(2; "General Service")
    {
        Caption = 'General Service';
    }
}

// ============================================================
// Enum 50101 - Tender Status
// Purpose: Tracks the lifecycle stage of a tender.
//          Each value represents a specific phase.
// ============================================================
enum 50101 "Tender Status"
{
    Extensible = true;
    Caption = 'Tender Status';

    value(0; Draft)
    {
        Caption = 'Draft';
    }
    value(1; "NIT Published")
    {
        Caption = 'NIT Published';
    }
    value(2; "Vendors Allocated")
    {
        Caption = 'Vendors Allocated';
    }
    value(3; "Pending Approval")
    {
        Caption = 'Pending Approval';
    }
    value(4; Approved)
    {
        Caption = 'Approved';
    }
    value(5; "Quotes Created")
    {
        Caption = 'Quotes Created';
    }
    value(6; "Bidding Open")
    {
        Caption = 'Bidding Open';
    }
    value(7; "Bidding Closed")
    {
        Caption = 'Bidding Closed';
    }
    value(8; "Reverse Auction")
    {
        Caption = 'Reverse Auction';
    }
    value(9; "Under Evaluation")
    {
        Caption = 'Under Evaluation';
    }
    value(10; "Vendor Selected")
    {
        Caption = 'Vendor Selected';
    }
    value(11; Negotiation)
    {
        Caption = 'Negotiation';
    }
    value(12; "Negotiation Approved")
    {
        Caption = 'Negotiation Approved';
    }
    value(13; Amended)
    {
        Caption = 'Amended';
    }
    value(14; "Order Created")
    {
        Caption = 'Order Created';
    }
    value(15; Closed)
    {
        Caption = 'Closed';
    }
    value(16; "Re-Tendered")
    {
        Caption = 'Re-Tendered';
    }
    value(17; Rejected)
    {
        Caption = 'Rejected';
    }
}

// ============================================================
// Enum 50102 - Tender Item Type
// Purpose: HSN = physical goods (Items), SAC = services (free text).
//          This drives the entire downstream behavior.
// ============================================================
enum 50102 "Tender Item Type"
{
    Extensible = true;
    Caption = 'Tender Item Type';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; HSN)
    {
        Caption = 'HSN';
    }
    value(2; SAC)
    {
        Caption = 'SAC';
    }
}

// ============================================================
// Enum 50103 - Tender Type
// Purpose: Standard = one-time procurement.
//          Rate Contract = standing agreement for repeated orders.
// ============================================================
enum 50103 "Tender Type"
{
    Extensible = true;
    Caption = 'Tender Type';

    value(0; Standard)
    {
        Caption = 'Standard';
    }
    value(1; "Rate Contract")
    {
        Caption = 'Rate Contract';
    }
}

// ============================================================
// Enum 50104 - Tender Line Type
// Purpose: Controls the BOQ structure.
//          Main Heading and Heading are display-only groupings.
//          Line Item and Sub Item carry actual quantities.
// ============================================================
enum 50104 "Tender Line Type"
{
    Extensible = true;
    Caption = 'Tender Line Type';

    value(0; "Main Heading")
    {
        Caption = 'Main Heading';
    }
    value(1; Heading)
    {
        Caption = 'Heading';
    }
    value(2; "Line Item")
    {
        Caption = 'Line Item';
    }
    value(3; "Sub Item")
    {
        Caption = 'Sub Item';
    }
}

// ============================================================
// Enum 50105 - Tender Line Style
// Purpose: Visual styling for BOQ display on pages.
// ============================================================
enum 50105 "Tender Line Style"
{
    Extensible = true;
    Caption = 'Tender Line Style';

    value(0; Normal)
    {
        Caption = 'Normal';
    }
    value(1; Bold)
    {
        Caption = 'Bold';
    }
    value(2; BoldItalic)
    {
        Caption = 'Bold Italic';
    }
}

// ============================================================
// Enum 50106 - Corrigendum Changes Type
// Purpose: What kind of changes the corrigendum introduces.
// ============================================================
enum 50106 "Corrigendum Changes Type"
{
    Extensible = true;
    Caption = 'Corrigendum Changes Type';

    value(0; "Terms Only")
    {
        Caption = 'Terms Only';
    }
    value(1; "BOQ Only")
    {
        Caption = 'BOQ Only';
    }
    value(2; Both)
    {
        Caption = 'Both';
    }
}

// ============================================================
// Enum 50107 - Auction Visibility
// Purpose: Controls what vendors can see during reverse auction.
// ============================================================
enum 50107 "Auction Visibility"
{
    Extensible = true;
    Caption = 'Auction Visibility';

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; "Rank Only")
    {
        Caption = 'Rank Only';
    }
    value(2; Sealed)
    {
        Caption = 'Sealed';
    }
}

// ============================================================
// Enum 50108 - Decrement Type
// Purpose: How the minimum bid reduction is enforced in auctions.
// ============================================================
enum 50108 "Decrement Type"
{
    Extensible = true;
    Caption = 'Decrement Type';

    value(0; Percentage)
    {
        Caption = 'Percentage';
    }
    value(1; Amount)
    {
        Caption = 'Amount';
    }
    value(2; Either)
    {
        Caption = 'Either';
    }
}

// ============================================================
// Enum 50109 - Auction Round Status
// Purpose: Lifecycle of each auction round.
// ============================================================
enum 50109 "Auction Round Status"
{
    Extensible = true;
    Caption = 'Auction Round Status';

    value(0; Scheduled)
    {
        Caption = 'Scheduled';
    }
    value(1; Open)
    {
        Caption = 'Open';
    }
    value(2; Closed)
    {
        Caption = 'Closed';
    }
}

// ============================================================
// Enum 50110 - Tender Quote Status
// Purpose: Tracks the status of each vendor's quote.
// ============================================================
enum 50110 "Tender Quote Status"
{
    Extensible = true;
    Caption = 'Tender Quote Status';

    value(0; "Not Created")
    {
        Caption = 'Not Created';
    }
    value(1; Created)
    {
        Caption = 'Created';
    }
    value(2; Submitted)
    {
        Caption = 'Submitted';
    }
    value(3; Disqualified)
    {
        Caption = 'Disqualified';
    }
}

// ============================================================
// Enum 50111 - Tender Signature Status
// Purpose: Tracks digital signature state.
// ============================================================
enum 50111 "Tender Signature Status"
{
    Extensible = true;
    Caption = 'Tender Signature Status';

    value(0; "Not Signed")
    {
        Caption = 'Not Signed';
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
    value(2; Signed)
    {
        Caption = 'Signed';
    }
    value(3; Rejected)
    {
        Caption = 'Rejected';
    }
}

// ============================================================
// Enum 50112 - Tender Signature Stage
// Purpose: At which process stage the signature is requested.
// ============================================================
enum 50112 "Tender Signature Stage"
{
    Extensible = true;
    Caption = 'Tender Signature Stage';

    value(0; Approval)
    {
        Caption = 'Approval';
    }
    value(1; "Negotiation Approval")
    {
        Caption = 'Negotiation Approval';
    }
    value(2; "Order Creation")
    {
        Caption = 'Order Creation';
    }
    value(3; "NIT Publishing")
    {
        Caption = 'NIT Publishing';
    }
    value(4; Corrigendum)
    {
        Caption = 'Corrigendum';
    }
}

// ============================================================
// Enum 50113 - Tender Doc Attachment Stage
// Purpose: Classifies document attachments by process stage.
// ============================================================
enum 50113 "Tender Doc Attachment Stage"
{
    Extensible = true;
    Caption = 'Tender Doc Attachment Stage';

    value(0; NIT)
    {
        Caption = 'NIT';
    }
    value(1; BOQ)
    {
        Caption = 'BOQ';
    }
    value(2; Corrigendum)
    {
        Caption = 'Corrigendum';
    }
    value(3; "Vendor Submission")
    {
        Caption = 'Vendor Submission';
    }
    value(4; "Technical Evaluation")
    {
        Caption = 'Technical Evaluation';
    }
    value(5; "Commercial Evaluation")
    {
        Caption = 'Commercial Evaluation';
    }
    value(6; Negotiation)
    {
        Caption = 'Negotiation';
    }
    value(7; Award)
    {
        Caption = 'Award';
    }
    value(8; Completion)
    {
        Caption = 'Completion';
    }
}

// ============================================================
// Enum 50114 - Tender Approval Status
// Purpose: Approval workflow status for tender and negotiation.
// ============================================================
enum 50114 "Tender Approval Status"
{
    Extensible = true;
    Caption = 'Tender Approval Status';

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; Pending)
    {
        Caption = 'Pending';
    }
    value(2; Approved)
    {
        Caption = 'Approved';
    }
    value(3; Rejected)
    {
        Caption = 'Rejected';
    }
}

// ============================================================
// Enum 50115 - Tender Archive Reason
// Purpose: Why the tender was archived.
// ============================================================
enum 50115 "Tender Archive Reason"
{
    Extensible = true;
    Caption = 'Tender Archive Reason';

    value(0; Corrigendum)
    {
        Caption = 'Corrigendum';
    }
    value(1; Amendment)
    {
        Caption = 'Amendment';
    }
    value(2; "Re-Tender")
    {
        Caption = 'Re-Tender';
    }
    value(3; Manual)
    {
        Caption = 'Manual';
    }
}

// ============================================================
// Enum 50116 - Disqualification Rule Type
// Purpose: Types of auto-disqualification criteria.
// ============================================================
enum 50116 "Disqualification Rule Type"
{
    Extensible = true;
    Caption = 'Disqualification Rule Type';

    value(0; "Mandatory Questionnaire")
    {
        Caption = 'Mandatory Questionnaire';
    }
    value(1; "Min Experience Years")
    {
        Caption = 'Min Experience Years';
    }
    value(2; "Min Turnover Amount")
    {
        Caption = 'Min Turnover Amount';
    }
    value(3; "Required Certification")
    {
        Caption = 'Required Certification';
    }
    value(4; "Required Document")
    {
        Caption = 'Required Document';
    }
    value(5; Custom)
    {
        Caption = 'Custom';
    }
}

// ============================================================
// Enum 50117 - Performance Rating Status
// Purpose: Lifecycle of a vendor performance rating.
// ============================================================
enum 50117 "Perf. Rating Status"
{
    Extensible = true;
    Caption = 'Performance Rating Status';

    value(0; Draft)
    {
        Caption = 'Draft';
    }
    value(1; Submitted)
    {
        Caption = 'Submitted';
    }
    value(2; Reviewed)
    {
        Caption = 'Reviewed';
    }
}

// ============================================================
// Enum 50118 - Tender Order Document Type
// Purpose: What type of order was created from the tender.
// ============================================================
enum 50118 "Tender Order Document Type"
{
    Extensible = true;
    Caption = 'Tender Order Document Type';

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; "Purchase Order")
    {
        Caption = 'Purchase Order';
    }
    value(2; "Work Order")
    {
        Caption = 'Work Order';
    }
}

// ============================================================
// Enum 50119 - Auction Status
// Purpose: Overall auction status on the tender header.
// ============================================================
enum 50119 "Tender Auction Status"
{
    Extensible = true;
    Caption = 'Tender Auction Status';

    value(0; "Not Started")
    {
        Caption = 'Not Started';
    }
    value(1; "In Progress")
    {
        Caption = 'In Progress';
    }
    value(2; Closed)
    {
        Caption = 'Closed';
    }
}

// ============================================================
// Enum 50120 - Questionnaire Answer Type
// Purpose: Data type of questionnaire answers.
// ============================================================
enum 50120 "Questionnaire Answer Type"
{
    Extensible = true;
    Caption = 'Questionnaire Answer Type';

    value(0; Text)
    {
        Caption = 'Text';
    }
    value(1; Number)
    {
        Caption = 'Number';
    }
    value(2; Boolean)
    {
        Caption = 'Boolean';
    }
    value(3; Date)
    {
        Caption = 'Date';
    }
    value(4; Option)
    {
        Caption = 'Option';
    }
}

// ============================================================
// Enum 50121 - Digital Signature Action
// ============================================================
enum 50121 "Tender Signature Action"
{
    Extensible = true;
    Caption = 'Tender Signature Action';

    value(0; "Sign Requested")
    {
        Caption = 'Sign Requested';
    }
    value(1; Signed)
    {
        Caption = 'Signed';
    }
    value(2; Rejected)
    {
        Caption = 'Rejected';
    }
    value(3; Expired)
    {
        Caption = 'Expired';
    }
}