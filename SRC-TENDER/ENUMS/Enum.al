// ============================================================
// Enum: Tender Source Module
// ============================================================
enum 50100 "Tender Source Module"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Project") { Caption = 'Project'; }
    value(2; "GeneralService") { Caption = 'General Service'; }
}

// ============================================================
// Enum: Tender Status
// ============================================================
enum 50101 "Tender Status"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Draft") { Caption = 'Draft'; }
    value(2; "Vendors Allocated") { Caption = 'Vendors Allocated'; }
    value(3; "Pending Approval") { Caption = 'Pending Approval'; }
    value(4; "Approved") { Caption = 'Approved'; }
    value(5; "Quotes Created") { Caption = 'Quotes Created'; }
    value(6; "Bidding Open") { Caption = 'Bidding Open'; }
    value(7; "Bidding Closed") { Caption = 'Bidding Closed'; }
    value(8; "Reverse Auction") { Caption = 'Reverse Auction'; }
    value(9; "Under Evaluation") { Caption = 'Under Evaluation'; }
    value(10; "Vendor Selected") { Caption = 'Vendor Selected'; }
    value(11; "Negotiation") { Caption = 'Negotiation'; }
    value(12; "Negotiation Approved") { Caption = 'Negotiation Approved'; }
    value(13; "Amended") { Caption = 'Amended'; }
    value(14; "Order Created") { Caption = 'Order Created'; }
    value(15; "Closed") { Caption = 'Closed'; }
    value(16; "Re-Tendered") { Caption = 'Re-Tendered'; }
    value(17; "Rejected") { Caption = 'Rejected'; }
}

// ============================================================
// Enum: Tender Item Type
// ============================================================
enum 50102 "Tender Item Type"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "HSN") { Caption = 'HSN'; }
    value(2; "SAC") { Caption = 'SAC'; }
}

// ============================================================
// Enum: Tender Type
// ============================================================
enum 50103 "Tender Type"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Standard") { Caption = 'Standard'; }
    value(2; "Rate Contract") { Caption = 'Rate Contract'; }
}

// ============================================================
// Enum: Tender Line Type
// ============================================================
enum 50104 "Tender Line Type"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Main Heading") { Caption = 'Main Heading'; }
    value(2; "Heading") { Caption = 'Heading'; }
    value(3; "Line Item") { Caption = 'Line Item'; }
    value(4; "Sub Item") { Caption = 'Sub Item'; }
}

// ============================================================
// Enum: Corrigendum Changes Type
// ============================================================
enum 50105 "Corrigendum Changes Type"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Terms Only") { Caption = 'Terms Only'; }
    value(2; "BOQ Only") { Caption = 'BOQ Only'; }
    value(3; "Both") { Caption = 'Both'; }
}

// ============================================================
// Enum: Auction Visibility
// ============================================================
enum 50106 "Auction Visibility"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Open") { Caption = 'Open'; }
    value(2; "Rank Only") { Caption = 'Rank Only'; }
    value(3; "Sealed") { Caption = 'Sealed'; }
}

// ============================================================
// Enum: Decrement Type
// ============================================================
enum 50107 "Decrement Type"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Percentage") { Caption = 'Percentage'; }
    value(2; "Amount") { Caption = 'Amount'; }
    value(3; "Either") { Caption = 'Either'; }
}

// ============================================================
// Enum: Auction Round Status
// ============================================================
enum 50108 "Auction Round Status"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Scheduled") { Caption = 'Scheduled'; }
    value(2; "Open") { Caption = 'Open'; }
    value(3; "Closed") { Caption = 'Closed'; }
}

// ============================================================
// Enum: Tender Quote Status
// ============================================================
enum 50109 "Tender Quote Status"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Not Created") { Caption = 'Not Created'; }
    value(2; "Created") { Caption = 'Created'; }
    value(3; "Submitted") { Caption = 'Submitted'; }
    value(4; "Disqualified") { Caption = 'Disqualified'; }
}

// ============================================================
// Enum: Signature Status
// ============================================================
enum 50110 "Tender Signature Status"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Not Signed") { Caption = 'Not Signed'; }
    value(2; "Pending") { Caption = 'Pending'; }
    value(3; "Signed") { Caption = 'Signed'; }
    value(4; "Rejected") { Caption = 'Rejected'; }
}

// ============================================================
// Enum: Signature Stage
// ============================================================
enum 50111 "Tender Signature Stage"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Approval") { Caption = 'Approval'; }
    value(2; "Negotiation Approval") { Caption = 'Negotiation Approval'; }
    value(3; "Order Creation") { Caption = 'Order Creation'; }
    value(4; "Corrigendum Issue") { Caption = 'Corrigendum Issue'; }
}

// ============================================================
// Enum: Signature Action
// ============================================================
enum 50112 "Tender Signature Action"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Sign Requested") { Caption = 'Sign Requested'; }
    value(2; "Signed") { Caption = 'Signed'; }
    value(3; "Rejected") { Caption = 'Rejected'; }
    value(4; "Expired") { Caption = 'Expired'; }
}

// ============================================================
// Enum: Doc Attachment Stage
// ============================================================
enum 50113 "Tender Doc Attachment Stage"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "BOQ") { Caption = 'BOQ'; }
    value(2; "Corrigendum") { Caption = 'Corrigendum'; }
    value(3; "Vendor Submission") { Caption = 'Vendor Submission'; }
    value(4; "Technical Evaluation") { Caption = 'Technical Evaluation'; }
    value(5; "Commercial Evaluation") { Caption = 'Commercial Evaluation'; }
    value(6; "Negotiation") { Caption = 'Negotiation'; }
    value(7; "Award") { Caption = 'Award'; }
    value(8; "Completion") { Caption = 'Completion'; }
}

// ============================================================
// Enum: Performance Rating Status
// ============================================================
enum 50114 "Perf. Rating Status"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Draft") { Caption = 'Draft'; }
    value(2; "Submitted") { Caption = 'Submitted'; }
    value(3; "Reviewed") { Caption = 'Reviewed'; }
}

// ============================================================
// Enum: Archive Reason
// ============================================================
enum 50115 "Tender Archive Reason"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Corrigendum") { Caption = 'Corrigendum'; }
    value(2; "Amendment") { Caption = 'Amendment'; }
    value(3; "Re-Tender") { Caption = 'Re-Tender'; }
    value(4; "Manual") { Caption = 'Manual'; }
}

// ============================================================
// Enum: Disqualification Rule Type
// ============================================================
enum 50116 "Disqualification Rule Type"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Mandatory Questionnaire") { Caption = 'Mandatory Questionnaire'; }
    value(2; "Min Experience Years") { Caption = 'Min Experience Years'; }
    value(3; "Min Turnover Amount") { Caption = 'Min Turnover Amount'; }
    value(4; "Required Certification") { Caption = 'Required Certification'; }
    value(5; "Required Document") { Caption = 'Required Document'; }
    value(6; "Custom") { Caption = 'Custom'; }
}

// ============================================================
// Enum: Questionnaire Answer Type
// ============================================================
enum 50117 "Questionnaire Answer Type"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Text") { Caption = 'Text'; }
    value(2; "Number") { Caption = 'Number'; }
    value(3; "Boolean") { Caption = 'Boolean'; }
    value(4; "Date") { Caption = 'Date'; }
    value(5; "Option") { Caption = 'Option'; }
}

// ============================================================
// Enum: Auction Status (Header level)
// ============================================================
enum 50118 "Tender Auction Status"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Not Started") { Caption = 'Not Started'; }
    value(2; "In Progress") { Caption = 'In Progress'; }
    value(3; "Closed") { Caption = 'Closed'; }
}

// ============================================================
// Enum: Order Document Type
// ============================================================
enum 50119 "Tender Order Doc Type"
{
    Extensible = true;

    value(0; " ") { Caption = ' '; }
    value(1; "Purchase Order") { Caption = 'Purchase Order'; }
    value(2; "Work Order") { Caption = 'Work Order'; }
}