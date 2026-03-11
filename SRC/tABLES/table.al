// ============================================================
// Table 50100 - Tender Setup
// Purpose: Single-record global configuration table.
//          Stores number series, default settings, and toggles.
// ============================================================
table 50100 "Tender Setup"
{
    Caption = 'Tender Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Tender No. Series"; Code[20])
        {
            Caption = 'Tender No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(11; "Work Order No. Series"; Code[20])
        {
            Caption = 'Work Order No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(12; "Rate Contract No. Series"; Code[20])
        {
            Caption = 'Rate Contract No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(13; "Corrigendum No. Series"; Code[20])
        {
            Caption = 'Corrigendum No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(20; "Default Bid Validity Days"; Integer)
        {
            Caption = 'Default Bid Validity Days';
            DataClassification = CustomerContent;
            MinValue = 0;
        }

        // --- Reverse Auction Settings ---
        field(30; "Min Decrement Percentage"; Decimal)
        {
            Caption = 'Min Decrement Percentage';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
        }
        field(31; "Min Decrement Amount"; Decimal)
        {
            Caption = 'Min Decrement Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(32; "Decrement Type"; Enum "Decrement Type")
        {
            Caption = 'Decrement Type';
            DataClassification = CustomerContent;
        }
        field(33; "Default Round Time Limit"; Integer)
        {
            Caption = 'Default Round Time Limit (Minutes)';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(34; "Auction Visibility"; Enum "Auction Visibility")
        {
            Caption = 'Auction Visibility';
            DataClassification = CustomerContent;
        }
        field(35; "Max Auction Rounds"; Integer)
        {
            Caption = 'Max Auction Rounds';
            DataClassification = CustomerContent;
            MinValue = 0;
        }

        // --- Feature Toggles ---
        field(40; "Enable NIT Publishing"; Boolean)
        {
            Caption = 'Enable NIT Publishing';
            DataClassification = CustomerContent;
        }
        field(41; "Enable Reverse Auction"; Boolean)
        {
            Caption = 'Enable Reverse Auction';
            DataClassification = CustomerContent;
        }
        field(42; "Enable Vendor Performance"; Boolean)
        {
            Caption = 'Enable Vendor Performance';
            DataClassification = CustomerContent;
        }
        field(43; "Enable Digital Signatures"; Boolean)
        {
            Caption = 'Enable Digital Signatures';
            DataClassification = CustomerContent;
        }
        field(44; "Enable Auto-Disqualification"; Boolean)
        {
            Caption = 'Enable Auto-Disqualification';
            DataClassification = CustomerContent;
        }
        field(45; "Enable Rate Contracts"; Boolean)
        {
            Caption = 'Enable Rate Contracts';
            DataClassification = CustomerContent;
        }

        // --- Approval Settings ---
        field(50; "Tender Approval Workflow Code"; Code[20])
        {
            Caption = 'Tender Approval Workflow Code';
            DataClassification = CustomerContent;
        }
        field(51; "Negot. Approval Workflow Code"; Code[20])
        {
            Caption = 'Negotiation Approval Workflow Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// Ensures the single setup record exists before reading
    procedure GetSetup()
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}

// ============================================================
// Table 50101 - Tender Header
// Purpose: Master record for each tender.
//          Contains all header-level information including
//          source module link, dates, status, and order reference.
// ============================================================
table 50101 "Tender Header"
{
    Caption = 'Tender Header';
    DataClassification = CustomerContent;
    LookupPageId = "Tender List";
    DrillDownPageId = "Tender List";

    fields
    {
        field(1; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                TenderSetup: Record "Tender Setup";
                NoSeriesMgt: Codeunit NoSeriesManagement;
            begin
                if "Tender No." <> xRec."Tender No." then begin
                    TenderSetup.GetSetup();
                    NoSeriesMgt.TestManual(TenderSetup."Tender No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Detailed Description"; Blob)
        {
            Caption = 'Detailed Description';
            DataClassification = CustomerContent;
        }

        // --- Source Module Fields ---
        field(10; "Source Module"; Enum "Tender Source Module")
        {
            Caption = 'Source Module';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Source Module" <> xRec."Source Module" then begin
                    "Source Type" := '';
                    "Source ID" := '';
                    "Business Unit Code" := '';
                    "Sanction No." := '';
                    "Budget Amount" := 0;
                    "Dimension Set ID" := 0;
                end;
            end;
        }
        field(11; "Source Type"; Code[50])
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
        }
        field(12; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SourceDispatcher: Codeunit "Tender Source Dispatcher";
            begin
                if "Source ID" <> '' then
                    SourceDispatcher.FillSourceData(Rec);
            end;
        }
        field(13; "Business Unit Code"; Code[20])
        {
            Caption = 'Business Unit Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Sanction No."; Code[20])
        {
            Caption = 'Sanction No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; "Budget Amount"; Decimal)
        {
            Caption = 'Budget Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(16; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = CustomerContent;
            Editable = false;
        }

        // --- Tender Classification ---
        field(20; "Item Type"; Enum "Tender Item Type")
        {
            Caption = 'Item Type';
            DataClassification = CustomerContent;
        }
        field(21; "Tender Type"; Enum "Tender Type")
        {
            Caption = 'Tender Type';
            DataClassification = CustomerContent;
        }
        field(22; "Work Type"; Code[20])
        {
            Caption = 'Work Type';
            DataClassification = CustomerContent;
        }
        field(23; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }

        // --- Date Fields ---
        field(30; "Created Date"; Date)
        {
            Caption = 'Created Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(31; "NIT Publish Date"; Date)
        {
            Caption = 'NIT Publish Date';
            DataClassification = CustomerContent;
        }
        field(32; "Bid Start Date"; Date)
        {
            Caption = 'Bid Start Date';
            DataClassification = CustomerContent;
        }
        field(33; "Bid End Date"; Date)
        {
            Caption = 'Bid End Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Bid End Date" <> 0D) and ("Bid Start Date" <> 0D) then
                    if "Bid End Date" < "Bid Start Date" then
                        Error('Bid End Date cannot be before Bid Start Date.');
            end;
        }
        field(34; "Bid Validity Date"; Date)
        {
            Caption = 'Bid Validity Date';
            DataClassification = CustomerContent;
        }
        field(35; "Negotiate Date"; Date)
        {
            Caption = 'Negotiate Date';
            DataClassification = CustomerContent;
        }
        field(36; "Negotiate Place"; Text[100])
        {
            Caption = 'Negotiate Place';
            DataClassification = CustomerContent;
        }
        field(37; "Closed Date"; Date)
        {
            Caption = 'Closed Date';
            DataClassification = CustomerContent;
            Editable = false;
        }

        // --- Rate Contract Fields ---
        field(40; "Rate Contract Valid From"; Date)
        {
            Caption = 'Rate Contract Valid From';
            DataClassification = CustomerContent;
        }
        field(41; "Rate Contract Valid To"; Date)
        {
            Caption = 'Rate Contract Valid To';
            DataClassification = CustomerContent;
        }
        field(42; "Rate Contract Ceiling Amount"; Decimal)
        {
            Caption = 'Rate Contract Ceiling Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }

        // --- Status Fields ---
        field(50; Status; Enum "Tender Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(51; "Approval Status"; Enum "Tender Approval Status")
        {
            Caption = 'Approval Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(52; "Negotiation Approval Status"; Enum "Tender Approval Status")
        {
            Caption = 'Negotiation Approval Status';
            DataClassification = CustomerContent;
            Editable = false;
        }

        // --- Reverse Auction ---
        field(60; "Reverse Auction Enabled"; Boolean)
        {
            Caption = 'Reverse Auction Enabled';
            DataClassification = CustomerContent;
        }
        field(61; "Current Auction Round"; Integer)
        {
            Caption = 'Current Auction Round';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(62; "Auction Status"; Enum "Tender Auction Status")
        {
            Caption = 'Auction Status';
            DataClassification = CustomerContent;
            Editable = false;
        }

        // --- Order Reference ---
        field(70; "Created Order No."; Code[20])
        {
            Caption = 'Created Order No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(71; "Created Order Document Type"; Enum "Tender Order Document Type")
        {
            Caption = 'Created Order Document Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(72; "Re-Tender Reference No."; Code[20])
        {
            Caption = 'Re-Tender Reference No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Tender Header"."Tender No.";
        }

        // --- Digital Signature ---
        field(80; "Signed By"; Code[50])
        {
            Caption = 'Signed By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(81; "Signed Date"; DateTime)
        {
            Caption = 'Signed Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(82; "Signature Status"; Enum "Tender Signature Status")
        {
            Caption = 'Signature Status';
            DataClassification = CustomerContent;
            Editable = false;
        }

        // --- Allocation ---
        field(90; "Allocated Engineer"; Code[20])
        {
            Caption = 'Allocated Engineer';
            DataClassification = CustomerContent;
        }
        field(91; "Created By User ID"; Code[50])
        {
            Caption = 'Created By User ID';
            DataClassification = CustomerContent;
            Editable = false;
        }

        // --- System Fields ---
        field(100; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(101; "Last Modified DateTime"; DateTime)
        {
            Caption = 'Last Modified DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(102; "Last Modified By User ID"; Code[50])
        {
            Caption = 'Last Modified By User ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(103; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "No. Series";
        }

        // --- FlowFields ---
        field(110; "No. of Vendors Allocated"; Integer)
        {
            Caption = 'No. of Vendors Allocated';
            FieldClass = FlowField;
            CalcFormula = count("Tender Vendor Allocation" where("Tender No." = field("Tender No.")));
            Editable = false;
        }
        field(111; "No. of Tender Lines"; Integer)
        {
            Caption = 'No. of Tender Lines';
            FieldClass = FlowField;
            CalcFormula = count("Tender Line" where("Tender No." = field("Tender No.")));
            Editable = false;
        }
        field(112; "Total Tender Amount"; Decimal)
        {
            Caption = 'Total Tender Amount';
            FieldClass = FlowField;
            CalcFormula = sum("Tender Line"."Line Amount" where("Tender No." = field("Tender No."),
                                                                  "Line Type" = filter("Line Item" | "Sub Item")));
            Editable = false;
        }
        field(113; "No. of Archived Versions"; Integer)
        {
            Caption = 'No. of Archived Versions';
            FieldClass = FlowField;
            CalcFormula = count("Tender Header Archive" where("Tender No." = field("Tender No.")));
            Editable = false;
        }
        field(114; "No. of Corrigendums"; Integer)
        {
            Caption = 'No. of Corrigendums';
            FieldClass = FlowField;
            CalcFormula = count("Tender Corrigendum" where("Tender No." = field("Tender No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Tender No.")
        {
            Clustered = true;
        }
        key(StatusKey; Status) { }
        key(SourceKey; "Source Module", "Source ID") { }
        key(DateKey; "Bid End Date") { }
    }

    trigger OnInsert()
    var
        TenderSetup: Record "Tender Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if "Tender No." = '' then begin
            TenderSetup.GetSetup();
            TenderSetup.TestField("Tender No. Series");
            NoSeriesMgt.InitSeries(
                TenderSetup."Tender No. Series", xRec."No. Series", WorkDate(),
                "Tender No.", "No. Series");
        end;

        "Created Date" := Today();
        "Created DateTime" := CurrentDateTime();
        "Created By User ID" := CopyStr(UserId(), 1, MaxStrLen("Created By User ID"));
        Status := Status::Draft;
        "Approval Status" := "Approval Status"::Open;
        "Negotiation Approval Status" := "Negotiation Approval Status"::Open;
    end;

    trigger OnModify()
    begin
        "Last Modified DateTime" := CurrentDateTime();
        "Last Modified By User ID" := CopyStr(UserId(), 1, MaxStrLen("Last Modified By User ID"));
    end;

    trigger OnDelete()
    var
        TenderLine: Record "Tender Line";
        TenderVendor: Record "Tender Vendor Allocation";
        TenderCorr: Record "Tender Corrigendum";
    begin
        if not (Status in [Status::Draft, Status::Rejected]) then
            Error('You can only delete tenders in Draft or Rejected status.');

        TenderLine.SetRange("Tender No.", "Tender No.");
        TenderLine.DeleteAll(true);

        TenderVendor.SetRange("Tender No.", "Tender No.");
        TenderVendor.DeleteAll(true);

        TenderCorr.SetRange("Tender No.", "Tender No.");
        TenderCorr.DeleteAll(true);
    end;

    /// Helper: Sets and retrieves the Detailed Description blob as text
    procedure SetDetailedDescription(NewDescription: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Detailed Description");
        "Detailed Description".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewDescription);
        Modify();
    end;

    procedure GetDetailedDescription(): Text
    var
        InStr: InStream;
        Result: Text;
    begin
        CalcFields("Detailed Description");
        if not "Detailed Description".HasValue() then
            exit('');
        "Detailed Description".CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(Result);
        exit(Result);
    end;

    /// Helper: Checks if tender header fields can be edited
    procedure IsEditable(): Boolean
    begin
        exit(Status in [Status::Draft, Status::Rejected]);
    end;
}

// ============================================================
// Table 50102 - Tender Line
// Purpose: BOQ line items. For HSN tenders, these reference Items.
//          For SAC tenders, these use Blob descriptions with
//          hierarchical indentation (headings + line items).
// ============================================================
table 50102 "Tender Line"
{
    Caption = 'Tender Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
            TableRelation = "Tender Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        // --- Structure Fields ---
        field(10; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 3;

            trigger OnValidate()
            begin
                // Auto-set Line Type based on Indentation
                case Indentation of
                    0:
                        "Line Type" := "Line Type"::"Main Heading";
                    1:
                        "Line Type" := "Line Type"::Heading;
                    2:
                        "Line Type" := "Line Type"::"Line Item";
                    3:
                        "Line Type" := "Line Type"::"Sub Item";
                end;
                UpdateStyleFromLineType();
                ClearQuantityFieldsIfHeading();
            end;
        }
        field(11; "Line Type"; Enum "Tender Line Type")
        {
            Caption = 'Line Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                case "Line Type" of
                    "Line Type"::"Main Heading":
                        Indentation := 0;
                    "Line Type"::Heading:
                        Indentation := 1;
                    "Line Type"::"Line Item":
                        Indentation := 2;
                    "Line Type"::"Sub Item":
                        Indentation := 3;
                end;
                UpdateStyleFromLineType();
                ClearQuantityFieldsIfHeading();
            end;
        }
        field(12; "BOQ Serial No."; Text[20])
        {
            Caption = 'BOQ Serial No.';
            DataClassification = CustomerContent;
        }
        field(13; "Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
            DataClassification = CustomerContent;
        }

        // --- Item Fields (HSN) ---
        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            var
                ItemRec: Record Item;
            begin
                if "Item No." <> '' then begin
                    ItemRec.Get("Item No.");
                    Description := ItemRec.Description;
                    "Short Description" := ItemRec.Description;
                    "Unit of Measure Code" := ItemRec."Base Unit of Measure";
                end;
            end;
        }
        field(21; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(22; "HSN/SAC Code"; Code[20])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
        }
        field(23; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
            DataClassification = CustomerContent;
        }

        // --- Blob Description (SAC) ---
        field(30; "Description Blob"; Blob)
        {
            Caption = 'Description Blob';
            DataClassification = CustomerContent;
        }
        field(31; "Short Description"; Text[250])
        {
            Caption = 'Short Description';
            DataClassification = CustomerContent;
        }

        // --- Quantity & Pricing ---
        field(40; "Unit of Measure Code"; Code[20])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
        field(41; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalculateLineAmount();
            end;
        }
        field(42; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
            MinValue = 0;

            trigger OnValidate()
            begin
                CalculateLineAmount();
            end;
        }
        field(43; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }

        // --- Rate Contract Tracking ---
        field(50; "Consumed Quantity"; Decimal)
        {
            Caption = 'Consumed Quantity';
            FieldClass = FlowField;
            CalcFormula = sum("Rate Contract Usage"."Quantity Ordered" where("Tender No." = field("Tender No."),
                                                                              "Tender Line No." = field("Line No.")));
            Editable = false;
        }

        // --- Display Formatting ---
        field(60; Style; Enum "Tender Line Style")
        {
            Caption = 'Style';
            DataClassification = CustomerContent;
        }

        // --- System ---
        field(70; "Last Modified DateTime"; DateTime)
        {
            Caption = 'Last Modified DateTime';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(71; Imported; Boolean)
        {
            Caption = 'Imported';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Tender No.", "Line No.")
        {
            Clustered = true;
        }
        key(IndentKey; "Tender No.", Indentation) { }
    }

    trigger OnInsert()
    begin
        "Last Modified DateTime" := CurrentDateTime();
    end;

    trigger OnModify()
    begin
        "Last Modified DateTime" := CurrentDateTime();
    end;

    local procedure CalculateLineAmount()
    begin
        "Line Amount" := Quantity * "Unit Cost";
    end;

    local procedure ClearQuantityFieldsIfHeading()
    begin
        if "Line Type" in ["Line Type"::"Main Heading", "Line Type"::Heading] then begin
            Quantity := 0;
            "Unit Cost" := 0;
            "Line Amount" := 0;
            "Unit of Measure Code" := '';
        end;
    end;

    local procedure UpdateStyleFromLineType()
    begin
        case "Line Type" of
            "Line Type"::"Main Heading":
                Style := Style::Bold;
            "Line Type"::Heading:
                Style := Style::Bold;
            "Line Type"::"Line Item":
                Style := Style::Normal;
            "Line Type"::"Sub Item":
                Style := Style::Normal;
        end;
    end;

    /// Sets the long description blob (for SAC lines)
    procedure SetDescriptionBlob(NewDescription: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Description Blob");
        "Description Blob".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(NewDescription);
        if StrLen(NewDescription) > MaxStrLen("Short Description") then
            "Short Description" := CopyStr(NewDescription, 1, MaxStrLen("Short Description"))
        else
            "Short Description" := CopyStr(NewDescription, 1, MaxStrLen("Short Description"));
        Modify();
    end;

    /// Reads the long description blob
    procedure GetDescriptionBlob(): Text
    var
        InStr: InStream;
        Result: Text;
    begin
        CalcFields("Description Blob");
        if not "Description Blob".HasValue() then
            exit('');
        "Description Blob".CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(Result);
        exit(Result);
    end;

    /// Returns the remaining quantity for rate contracts
    procedure GetRemainingQuantity(): Decimal
    begin
        CalcFields("Consumed Quantity");
        exit(Quantity - "Consumed Quantity");
    end;

    /// Returns true if this line carries quantities (not a heading)
    procedure IsQuantityLine(): Boolean
    begin
        exit("Line Type" in ["Line Type"::"Line Item", "Line Type"::"Sub Item"]);
    end;
}

// ============================================================
// Table 50103 - Tender Vendor Allocation
// Purpose: Links vendors to a tender. Each vendor gets one row.
//          After approval, purchase quotes are auto-created for each.
// ============================================================
table 50103 "Tender Vendor Allocation"
{
    Caption = 'Tender Vendor Allocation';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
            TableRelation = "Tender Header";
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;

            trigger OnValidate()
            var
                VendorRec: Record Vendor;
            begin
                if VendorRec.Get("Vendor No.") then begin
                    "Vendor Name" := VendorRec.Name;
                    "Contact Person" := VendorRec.Contact;
                    Email := VendorRec."E-Mail";
                end;
            end;
        }
        field(10; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Contact Person"; Text[100])
        {
            Caption = 'Contact Person';
            DataClassification = CustomerContent;
        }
        field(12; Email; Text[80])
        {
            Caption = 'Email';
            DataClassification = CustomerContent;
        }
        field(13; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(20; "Quote No."; Code[20])
        {
            Caption = 'Quote No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "Quote Status"; Enum "Tender Quote Status")
        {
            Caption = 'Quote Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(22; "Disqualification Reason"; Text[250])
        {
            Caption = 'Disqualification Reason';
            DataClassification = CustomerContent;
        }
        field(23; "Is Selected Vendor"; Boolean)
        {
            Caption = 'Is Selected Vendor';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                OtherAlloc: Record "Tender Vendor Allocation";
            begin
                // Only one vendor can be selected per tender
                if "Is Selected Vendor" then begin
                    OtherAlloc.SetRange("Tender No.", "Tender No.");
                    OtherAlloc.SetFilter("Vendor No.", '<>%1', "Vendor No.");
                    OtherAlloc.SetRange("Is Selected Vendor", true);
                    if not OtherAlloc.IsEmpty() then
                        Error('Only one vendor can be selected per tender. Please deselect the other vendor first.');
                end;
            end;
        }
        field(30; "Allocated Date"; Date)
        {
            Caption = 'Allocated Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(31; "Allocated By User ID"; Code[50])
        {
            Caption = 'Allocated By User ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Tender No.", "Vendor No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        "Allocated Date" := Today();
        "Allocated By User ID" := CopyStr(UserId(), 1, MaxStrLen("Allocated By User ID"));
        "Quote Status" := "Quote Status"::"Not Created";
    end;

    trigger OnDelete()
    begin
        if "Quote Status" <> "Quote Status"::"Not Created" then
            Error('Cannot remove a vendor after their quote has been created.');
    end;
}

// ============================================================
// Table 50104 - Tender Header Archive
// Purpose: Versioned snapshot of the tender header.
//          Created when corrigendums, amendments, or re-tenders occur.
// ============================================================
table 50104 "Tender Header Archive"
{
    Caption = 'Tender Header Archive';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
        }
        field(2; "Version No."; Integer)
        {
            Caption = 'Version No.';
            DataClassification = CustomerContent;
        }
        field(10; "Archive Reason"; Enum "Tender Archive Reason")
        {
            Caption = 'Archive Reason';
            DataClassification = CustomerContent;
        }
        field(11; "Archived DateTime"; DateTime)
        {
            Caption = 'Archived DateTime';
            DataClassification = CustomerContent;
        }
        field(12; "Archived By User ID"; Code[50])
        {
            Caption = 'Archived By User ID';
            DataClassification = CustomerContent;
        }

        // Snapshot of all header fields
        field(20; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(21; "Source Module"; Enum "Tender Source Module")
        {
            Caption = 'Source Module';
            DataClassification = CustomerContent;
        }
        field(22; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
            DataClassification = CustomerContent;
        }
        field(23; "Item Type"; Enum "Tender Item Type")
        {
            Caption = 'Item Type';
            DataClassification = CustomerContent;
        }
        field(24; "Tender Type"; Enum "Tender Type")
        {
            Caption = 'Tender Type';
            DataClassification = CustomerContent;
        }
        field(25; Status; Enum "Tender Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(26; "Bid Start Date"; Date)
        {
            Caption = 'Bid Start Date';
            DataClassification = CustomerContent;
        }
        field(27; "Bid End Date"; Date)
        {
            Caption = 'Bid End Date';
            DataClassification = CustomerContent;
        }
        field(28; "Budget Amount"; Decimal)
        {
            Caption = 'Budget Amount';
            DataClassification = CustomerContent;
        }
        field(29; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(30; "Bid Validity Date"; Date)
        {
            Caption = 'Bid Validity Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Tender No.", "Version No.")
        {
            Clustered = true;
        }
    }
}

// ============================================================
// Table 50105 - Tender Line Archive
// Purpose: Versioned snapshot of tender lines including Blobs.
// ============================================================
table 50105 "Tender Line Archive"
{
    Caption = 'Tender Line Archive';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
        }
        field(2; "Version No."; Integer)
        {
            Caption = 'Version No.';
            DataClassification = CustomerContent;
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
        }
        field(11; "Line Type"; Enum "Tender Line Type")
        {
            Caption = 'Line Type';
            DataClassification = CustomerContent;
        }
        field(12; "BOQ Serial No."; Text[20])
        {
            Caption = 'BOQ Serial No.';
            DataClassification = CustomerContent;
        }
        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(21; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(22; "Short Description"; Text[250])
        {
            Caption = 'Short Description';
            DataClassification = CustomerContent;
        }
        field(23; "Description Blob"; Blob)
        {
            Caption = 'Description Blob';
            DataClassification = CustomerContent;
        }
        field(30; "Unit of Measure Code"; Code[20])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
        }
        field(31; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(32; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(33; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
        }
        field(34; "HSN/SAC Code"; Code[20])
        {
            Caption = 'HSN/SAC Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Tender No.", "Version No.", "Line No.")
        {
            Clustered = true;
        }
    }
}

// ============================================================
// Table 50106 - Tender Corrigendum
// Purpose: Tracks changes/addendums issued before bid deadline.
//          Each corrigendum archives the current state before changes.
// ============================================================
table 50106 "Tender Corrigendum"
{
    Caption = 'Tender Corrigendum';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
            TableRelation = "Tender Header";
        }
        field(2; "Corrigendum No."; Integer)
        {
            Caption = 'Corrigendum No.';
            DataClassification = CustomerContent;
        }
        field(10; "Issue Date"; Date)
        {
            Caption = 'Issue Date';
            DataClassification = CustomerContent;
        }
        field(11; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(12; "Detailed Changes"; Blob)
        {
            Caption = 'Detailed Changes';
            DataClassification = CustomerContent;
        }
        field(13; "Changes Type"; Enum "Corrigendum Changes Type")
        {
            Caption = 'Changes Type';
            DataClassification = CustomerContent;
        }
        field(14; "BOQ Re-Imported"; Boolean)
        {
            Caption = 'BOQ Re-Imported';
            DataClassification = CustomerContent;
        }
        field(15; "Archive Version No."; Integer)
        {
            Caption = 'Archive Version No.';
            DataClassification = CustomerContent;
        }
        field(16; "Issued By User ID"; Code[50])
        {
            Caption = 'Issued By User ID';
            DataClassification = CustomerContent;
        }
        field(20; "New Bid End Date"; Date)
        {
            Caption = 'New Bid End Date';
            DataClassification = CustomerContent;
        }
        field(21; "New Bid Validity Date"; Date)
        {
            Caption = 'New Bid Validity Date';
            DataClassification = CustomerContent;
        }
        field(22; "Terms Change Description"; Text[500])
        {
            Caption = 'Terms Change Description';
            DataClassification = CustomerContent;
        }
        field(30; "Vendors Notified"; Boolean)
        {
            Caption = 'Vendors Notified';
            DataClassification = CustomerContent;
        }
        field(31; "Notification DateTime"; DateTime)
        {
            Caption = 'Notification DateTime';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Tender No.", "Corrigendum No.")
        {
            Clustered = true;
        }
    }
}

// ============================================================
// Table 50107 - Reverse Auction Round
// Purpose: Each round of the reverse auction.
//          Vendors submit revised prices per round.
// ============================================================
table 50107 "Reverse Auction Round"
{
    Caption = 'Reverse Auction Round';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
            TableRelation = "Tender Header";
        }
        field(2; "Round No."; Integer)
        {
            Caption = 'Round No.';
            DataClassification = CustomerContent;
        }
        field(10; "Round Start DateTime"; DateTime)
        {
            Caption = 'Round Start DateTime';
            DataClassification = CustomerContent;
        }
        field(11; "Round End DateTime"; DateTime)
        {
            Caption = 'Round End DateTime';
            DataClassification = CustomerContent;
        }
        field(12; "Time Limit Minutes"; Integer)
        {
            Caption = 'Time Limit Minutes';
            DataClassification = CustomerContent;
        }
        field(13; Status; Enum "Auction Round Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(14; "Min Decrement Percentage"; Decimal)
        {
            Caption = 'Min Decrement Percentage';
            DataClassification = CustomerContent;
        }
        field(15; "Min Decrement Amount"; Decimal)
        {
            Caption = 'Min Decrement Amount';
            DataClassification = CustomerContent;
        }
        field(16; "Created By User ID"; Code[50])
        {
            Caption = 'Created By User ID';
            DataClassification = CustomerContent;
        }
        field(17; Remarks; Text[250])
        {
            Caption = 'Remarks';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Tender No.", "Round No.")
        {
            Clustered = true;
        }
    }
}

// ============================================================
// Table 50108 - Reverse Auction Entry
// Purpose: Each vendor's bid for each line in each round.
// ============================================================
table 50108 "Reverse Auction Entry"
{
    Caption = 'Reverse Auction Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
        }
        field(2; "Round No."; Integer)
        {
            Caption = 'Round No.';
            DataClassification = CustomerContent;
        }
        field(3; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(10; "Previous Unit Cost"; Decimal)
        {
            Caption = 'Previous Unit Cost';
            DataClassification = CustomerContent;
        }
        field(11; "New Unit Cost"; Decimal)
        {
            Caption = 'New Unit Cost';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "New Unit Cost" > "Previous Unit Cost" then
                    Error('New price cannot be higher than previous price.');
                if Quantity <> 0 then
                    "New Line Amount" := "New Unit Cost" * Quantity;
                CalculateDecrement();
            end;
        }
        field(12; "Previous Line Amount"; Decimal)
        {
            Caption = 'Previous Line Amount';
            DataClassification = CustomerContent;
        }
        field(13; "New Line Amount"; Decimal)
        {
            Caption = 'New Line Amount';
            DataClassification = CustomerContent;
        }
        field(14; "Decrement Percentage"; Decimal)
        {
            Caption = 'Decrement Percentage';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; "Decrement Amount"; Decimal)
        {
            Caption = 'Decrement Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(16; "Is Valid Entry"; Boolean)
        {
            Caption = 'Is Valid Entry';
            DataClassification = CustomerContent;
        }
        field(17; "Submitted DateTime"; DateTime)
        {
            Caption = 'Submitted DateTime';
            DataClassification = CustomerContent;
        }
        field(18; Rank; Integer)
        {
            Caption = 'Rank';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(19; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
        field(20; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Tender No.", "Round No.", "Vendor No.", "Line No.")
        {
            Clustered = true;
        }
        key(RankKey; "Tender No.", "Round No.", "Line No.", "New Unit Cost") { }
    }

    local procedure CalculateDecrement()
    begin
        "Decrement Amount" := "Previous Unit Cost" - "New Unit Cost";
        if "Previous Unit Cost" <> 0 then
            "Decrement Percentage" := ("Decrement Amount" / "Previous Unit Cost") * 100
        else
            "Decrement Percentage" := 0;
    end;
}

// ============================================================
// Table 50109 - Tender Disqualification Rule
// Purpose: Auto-disqualification criteria per tender.
// ============================================================
table 50109 "Tender Disqualification Rule"
{
    Caption = 'Tender Disqualification Rule';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
            TableRelation = "Tender Header";
        }
        field(2; "Rule No."; Integer)
        {
            Caption = 'Rule No.';
            DataClassification = CustomerContent;
        }
        field(10; "Rule Type"; Enum "Disqualification Rule Type")
        {
            Caption = 'Rule Type';
            DataClassification = CustomerContent;
        }
        field(11; "Rule Description"; Text[250])
        {
            Caption = 'Rule Description';
            DataClassification = CustomerContent;
        }
        field(12; Mandatory; Boolean)
        {
            Caption = 'Mandatory';
            DataClassification = CustomerContent;
        }
        field(13; "Min Value"; Decimal)
        {
            Caption = 'Min Value';
            DataClassification = CustomerContent;
        }
        field(14; "Required Text"; Text[100])
        {
            Caption = 'Required Text';
            DataClassification = CustomerContent;
        }
        field(15; "Custom Evaluation"; Boolean)
        {
            Caption = 'Custom Evaluation';
            DataClassification = CustomerContent;
        }
        field(16; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Tender No.", "Rule No.")
        {
            Clustered = true;
        }
    }
}

// ============================================================
// Table 50110 - Tender Questionnaire Template
// Purpose: Reusable template of questions to attach to tenders.
// ============================================================
table 50110 "Tender Quest. Template"
{
    Caption = 'Tender Questionnaire Template';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            DataClassification = CustomerContent;
        }
        field(2; "Question No."; Integer)
        {
            Caption = 'Question No.';
            DataClassification = CustomerContent;
        }
        field(10; "Question Text"; Text[500])
        {
            Caption = 'Question Text';
            DataClassification = CustomerContent;
        }
        field(11; "Answer Type"; Enum "Questionnaire Answer Type")
        {
            Caption = 'Answer Type';
            DataClassification = CustomerContent;
        }
        field(12; Options; Text[500])
        {
            Caption = 'Options';
            DataClassification = CustomerContent;
        }
        field(13; "Is Mandatory"; Boolean)
        {
            Caption = 'Is Mandatory';
            DataClassification = CustomerContent;
        }
        field(14; "Scoring Weight"; Decimal)
        {
            Caption = 'Scoring Weight';
            DataClassification = CustomerContent;
        }
        field(15; "Disqualify If Answer"; Text[100])
        {
            Caption = 'Disqualify If Answer';
            DataClassification = CustomerContent;
        }
        field(16; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Template Code", "Question No.")
        {
            Clustered = true;
        }
        key(SeqKey; "Template Code", "Sequence No.") { }
    }
}

// ============================================================
// Table 50111 - Tender Questionnaire Response
// Purpose: Vendor's answers to questionnaire questions.
// ============================================================
table 50111 "Tender Quest. Response"
{
    Caption = 'Tender Questionnaire Response';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
            TableRelation = "Tender Header";
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(3; "Question No."; Integer)
        {
            Caption = 'Question No.';
            DataClassification = CustomerContent;
        }
        field(10; "Question Text"; Text[500])
        {
            Caption = 'Question Text';
            DataClassification = CustomerContent;
        }
        field(11; "Answer Text"; Text[500])
        {
            Caption = 'Answer Text';
            DataClassification = CustomerContent;
        }
        field(12; "Answer Number"; Decimal)
        {
            Caption = 'Answer Number';
            DataClassification = CustomerContent;
        }
        field(13; "Answer Boolean"; Boolean)
        {
            Caption = 'Answer Boolean';
            DataClassification = CustomerContent;
        }
        field(14; "Answer Date"; Date)
        {
            Caption = 'Answer Date';
            DataClassification = CustomerContent;
        }
        field(15; Score; Decimal)
        {
            Caption = 'Score';
            DataClassification = CustomerContent;
        }
        field(16; "Meets Requirement"; Boolean)
        {
            Caption = 'Meets Requirement';
            DataClassification = CustomerContent;
        }
        field(17; "Evaluated By User ID"; Code[50])
        {
            Caption = 'Evaluated By User ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Tender No.", "Vendor No.", "Question No.")
        {
            Clustered = true;
        }
    }
}

// ============================================================
// Table 50112 - Rate Contract Usage
// Purpose: Tracks POs created against a rate contract tender.
//          Consumed quantities are summed as FlowFields on Tender Line.
// ============================================================
table 50112 "Rate Contract Usage"
{
    Caption = 'Rate Contract Usage';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
            TableRelation = "Tender Header";
        }
        field(11; "Tender Line No."; Integer)
        {
            Caption = 'Tender Line No.';
            DataClassification = CustomerContent;
        }
        field(12; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            DataClassification = CustomerContent;
        }
        field(13; "PO Line No."; Integer)
        {
            Caption = 'PO Line No.';
            DataClassification = CustomerContent;
        }
        field(14; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(15; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(16; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(17; "Quantity Ordered"; Decimal)
        {
            Caption = 'Quantity Ordered';
            DataClassification = CustomerContent;
        }
        field(18; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
        }
        field(19; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            DataClassification = CustomerContent;
        }
        field(20; "Order Date"; Date)
        {
            Caption = 'Order Date';
            DataClassification = CustomerContent;
        }
        field(21; "Created By User ID"; Code[50])
        {
            Caption = 'Created By User ID';
            DataClassification = CustomerContent;
        }
        field(22; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TenderKey; "Tender No.", "Tender Line No.") { }
    }
}

// ============================================================
// Table 50113 - Vendor Performance Rating
// Purpose: Post-completion feedback on vendor performance.
// ============================================================
table 50113 "Vendor Performance Rating"
{
    Caption = 'Vendor Performance Rating';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
            TableRelation = "Tender Header";
        }
        field(11; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(12; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            DataClassification = CustomerContent;
        }
        field(13; "Order Document Type"; Enum "Tender Order Document Type")
        {
            Caption = 'Order Document Type';
            DataClassification = CustomerContent;
        }
        field(14; "Completion Date"; Date)
        {
            Caption = 'Completion Date';
            DataClassification = CustomerContent;
        }
        field(20; "Quality Rating"; Decimal)
        {
            Caption = 'Quality Rating';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10;
        }
        field(21; "Timeliness Rating"; Decimal)
        {
            Caption = 'Timeliness Rating';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10;
        }
        field(22; "Compliance Rating"; Decimal)
        {
            Caption = 'Compliance Rating';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10;
        }
        field(23; "Communication Rating"; Decimal)
        {
            Caption = 'Communication Rating';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 10;
        }
        field(24; "Overall Rating"; Decimal)
        {
            Caption = 'Overall Rating';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(25; "Rating Scale Max"; Integer)
        {
            Caption = 'Rating Scale Max';
            DataClassification = CustomerContent;
            InitValue = 5;
        }
        field(30; Comments; Text[500])
        {
            Caption = 'Comments';
            DataClassification = CustomerContent;
        }
        field(31; "Detailed Feedback"; Blob)
        {
            Caption = 'Detailed Feedback';
            DataClassification = CustomerContent;
        }
        field(32; "Rated By User ID"; Code[50])
        {
            Caption = 'Rated By User ID';
            DataClassification = CustomerContent;
        }
        field(33; "Rated DateTime"; DateTime)
        {
            Caption = 'Rated DateTime';
            DataClassification = CustomerContent;
        }
        field(34; Status; Enum "Perf. Rating Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(VendorKey; "Vendor No.") { }
        key(TenderKey; "Tender No.") { }
    }

    /// Calculates the overall rating as average of component ratings
    procedure CalculateOverallRating()
    begin
        "Overall Rating" := ("Quality Rating" + "Timeliness Rating" + "Compliance Rating" + "Communication Rating") / 4;
    end;
}

// ============================================================
// Table 50114 - Tender Digital Signature Log
// Purpose: Audit trail of digital signature events.
// ============================================================
table 50114 "Tender Digi. Signature Log"
{
    Caption = 'Tender Digital Signature Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(10; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
        }
        field(11; Stage; Enum "Tender Signature Stage")
        {
            Caption = 'Stage';
            DataClassification = CustomerContent;
        }
        field(12; Action; Enum "Tender Signature Action")
        {
            Caption = 'Action';
            DataClassification = CustomerContent;
        }
        field(13; "Requested By User ID"; Code[50])
        {
            Caption = 'Requested By User ID';
            DataClassification = CustomerContent;
        }
        field(14; "Requested DateTime"; DateTime)
        {
            Caption = 'Requested DateTime';
            DataClassification = CustomerContent;
        }
        field(15; "Signed By User ID"; Code[50])
        {
            Caption = 'Signed By User ID';
            DataClassification = CustomerContent;
        }
        field(16; "Signed DateTime"; DateTime)
        {
            Caption = 'Signed DateTime';
            DataClassification = CustomerContent;
        }
        field(17; "Signature Reference"; Text[250])
        {
            Caption = 'Signature Reference';
            DataClassification = CustomerContent;
        }
        field(18; "Certificate Info"; Text[500])
        {
            Caption = 'Certificate Info';
            DataClassification = CustomerContent;
        }
        field(19; Remarks; Text[250])
        {
            Caption = 'Remarks';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TenderKey; "Tender No.") { }
    }
}

// ============================================================
// Table 50115 - Tender Doc. Attachment Stage
// Purpose: Tags each document attachment with a process stage.
// ============================================================
table 50115 "Tender Doc. Attachment Stage"
{
    Caption = 'Tender Document Attachment Stage';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
            TableRelation = "Tender Header";
        }
        field(2; "Attachment Entry No."; Integer)
        {
            Caption = 'Attachment Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; Stage; Enum "Tender Doc Attachment Stage")
        {
            Caption = 'Stage';
            DataClassification = CustomerContent;
        }
        field(11; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(12; "Uploaded By User ID"; Code[50])
        {
            Caption = 'Uploaded By User ID';
            DataClassification = CustomerContent;
        }
        field(13; "Uploaded DateTime"; DateTime)
        {
            Caption = 'Uploaded DateTime';
            DataClassification = CustomerContent;
        }
        field(14; "Is Mandatory"; Boolean)
        {
            Caption = 'Is Mandatory';
            DataClassification = CustomerContent;
        }
        field(15; Verified; Boolean)
        {
            Caption = 'Verified';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Tender No.", "Attachment Entry No.")
        {
            Clustered = true;
        }
        key(StageKey; "Tender No.", Stage) { }
    }
}