// ============================================================
// Table 50100: Tender Setup
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
        }
        field(10; "Tender No. Series"; Code[20])
        {
            Caption = 'Tender No. Series';
            TableRelation = "No. Series";
        }
        field(11; "Work Order No. Series"; Code[20])
        {
            Caption = 'Work Order No. Series';
            TableRelation = "No. Series";
        }
        field(12; "Rate Contract No. Series"; Code[20])
        {
            Caption = 'Rate Contract No. Series';
            TableRelation = "No. Series";
        }
        field(13; "Corrigendum No. Series"; Code[20])
        {
            Caption = 'Corrigendum No. Series';
            TableRelation = "No. Series";
        }
        field(20; "Default Bid Validity Days"; Integer)
        {
            Caption = 'Default Bid Validity Days';
            MinValue = 0;
        }
        field(30; "Min Decrement Percentage"; Decimal)
        {
            Caption = 'Min Decrement Percentage';
            MinValue = 0;
        }
        field(31; "Min Decrement Amount"; Decimal)
        {
            Caption = 'Min Decrement Amount';
            MinValue = 0;
        }
        field(32; "Decrement Type"; Enum "Decrement Type")
        {
            Caption = 'Decrement Type';
        }
        field(33; "Default Round Time Limit"; Integer)
        {
            Caption = 'Default Round Time Limit (Minutes)';
            MinValue = 0;
        }
        field(34; "Auction Visibility"; Enum "Auction Visibility")
        {
            Caption = 'Auction Visibility';
        }
        field(35; "Max Auction Rounds"; Integer)
        {
            Caption = 'Max Auction Rounds';
            MinValue = 0;
        }
        field(40; "Enable Reverse Auction"; Boolean)
        {
            Caption = 'Enable Reverse Auction';
        }
        field(41; "Enable Vendor Performance"; Boolean)
        {
            Caption = 'Enable Vendor Performance';
        }
        field(42; "Enable Digital Signatures"; Boolean)
        {
            Caption = 'Enable Digital Signatures';
        }
        field(43; "Enable Auto Disqualification"; Boolean)
        {
            Caption = 'Enable Auto Disqualification';
        }
        field(44; "Enable Rate Contracts"; Boolean)
        {
            Caption = 'Enable Rate Contracts';
        }
        field(50; "Tender Approval Workflow Code"; Code[20])
        {
            Caption = 'Tender Approval Workflow Code';
        }
        field(51; "Negotiation Approval WF Code"; Code[20])
        {
            Caption = 'Negotiation Approval Workflow Code';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetSetup()
    begin
        if not Get() then begin
            Init();
            Insert();
        end;
    end;
}

// ============================================================
// Table 50101: Tender Header
// ============================================================
table 50101 "Tender Header"
{
    Caption = 'Tender Header';
    DataClassification = CustomerContent;
    LookupPageId = "Tender List";
    DrillDownPageId = "Tender List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';

            trigger OnValidate()
            var
                TenderSetup: Record "Tender Setup";
                NoSeriesMgt: Codeunit NoSeriesManagement;
            begin
                if "No." <> xRec."No." then begin
                    TenderSetup.GetSetup();
                    NoSeriesMgt.TestManual(TenderSetup."Tender No. Series");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "Description"; Text[250])
        {
            Caption = 'Description';
        }
        field(3; "Detailed Description"; Blob)
        {
            Caption = 'Detailed Description';
        }
        field(10; "Source Module"; Enum "Tender Source Module")
        {
            Caption = 'Source Module';

            trigger OnValidate()
            begin
                if "Source Module" <> xRec."Source Module" then
                    "Source ID" := '';
            end;
        }
        field(11; "Source Type"; Code[50])
        {
            Caption = 'Source Type';
        }
        field(12; "Source ID"; Code[20])
        {
            Caption = 'Source ID';

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
            Editable = false;
        }
        field(14; "Sanction No."; Code[20])
        {
            Caption = 'Sanction No.';
            Editable = false;
        }
        field(15; "Budget Amount"; Decimal)
        {
            Caption = 'Budget Amount';
            Editable = false;
        }
        field(16; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
        }
        field(20; "Item Type"; Enum "Tender Item Type")
        {
            Caption = 'Item Type';

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(21; "Tender Type"; Enum "Tender Type")
        {
            Caption = 'Tender Type';

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(22; "Work Type"; Code[20])
        {
            Caption = 'Work Type';
        }
        field(23; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(30; "Created Date"; Date)
        {
            Caption = 'Created Date';
            Editable = false;
        }
        field(31; "Bid Start Date"; Date)
        {
            Caption = 'Bid Start Date';
        }
        field(32; "Bid End Date"; Date)
        {
            Caption = 'Bid End Date';

            trigger OnValidate()
            begin
                if ("Bid Start Date" <> 0D) and ("Bid End Date" <> 0D) then
                    if "Bid End Date" < "Bid Start Date" then
                        Error('Bid End Date cannot be before Bid Start Date.');
            end;
        }
        field(33; "Bid Validity Date"; Date)
        {
            Caption = 'Bid Validity Date';
        }
        field(34; "Negotiate Date"; Date)
        {
            Caption = 'Negotiate Date';
        }
        field(35; "Negotiate Place"; Text[100])
        {
            Caption = 'Negotiate Place';
        }
        field(36; "Closed Date"; Date)
        {
            Caption = 'Closed Date';
            Editable = false;
        }
        field(40; "Rate Contract Valid From"; Date)
        {
            Caption = 'Rate Contract Valid From';
        }
        field(41; "Rate Contract Valid To"; Date)
        {
            Caption = 'Rate Contract Valid To';
        }
        field(42; "Rate Contract Ceiling Amount"; Decimal)
        {
            Caption = 'Rate Contract Ceiling Amount';
        }
        field(50; "Status"; Enum "Tender Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(60; "Reverse Auction Enabled"; Boolean)
        {
            Caption = 'Reverse Auction Enabled';
        }
        field(61; "Current Auction Round"; Integer)
        {
            Caption = 'Current Auction Round';
            Editable = false;
        }
        field(62; "Auction Status"; Enum "Tender Auction Status")
        {
            Caption = 'Auction Status';
            Editable = false;
        }
        field(70; "Created Order No."; Code[20])
        {
            Caption = 'Created Order No.';
            Editable = false;
        }
        field(71; "Created Order Doc Type"; Enum "Tender Order Doc Type")
        {
            Caption = 'Created Order Document Type';
            Editable = false;
        }
        field(72; "Re-Tender Reference No."; Code[20])
        {
            Caption = 'Re-Tender Reference No.';
            Editable = false;
        }
        field(80; "Signed By"; Code[50])
        {
            Caption = 'Signed By';
        }
        field(81; "Signed Date"; DateTime)
        {
            Caption = 'Signed Date';
        }
        field(82; "Signature Status"; Enum "Tender Signature Status")
        {
            Caption = 'Signature Status';
        }
        field(90; "Allocated Engineer"; Code[20])
        {
            Caption = 'Allocated Engineer';
        }
        field(91; "Created By User ID"; Code[50])
        {
            Caption = 'Created By User ID';
            Editable = false;
        }
        field(92; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
            Editable = false;
        }
        field(93; "Last Modified DateTime"; DateTime)
        {
            Caption = 'Last Modified DateTime';
            Editable = false;
        }
        field(94; "Last Modified By User ID"; Code[50])
        {
            Caption = 'Last Modified By User ID';
            Editable = false;
        }
        field(95; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(Status; "Status") { }
        key(SourceModule; "Source Module", "Source ID") { }
    }

    trigger OnInsert()
    var
        TenderSetup: Record "Tender Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        if "No." = '' then begin
            TenderSetup.GetSetup();
            TenderSetup.TestField("Tender No. Series");
            NoSeriesMgt.InitSeries(TenderSetup."Tender No. Series", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        "Created Date" := Today;
        "Created DateTime" := CurrentDateTime;
        "Created By User ID" := CopyStr(UserId, 1, 50);
        "Status" := "Status"::Draft;
    end;

    trigger OnModify()
    begin
        "Last Modified DateTime" := CurrentDateTime;
        "Last Modified By User ID" := CopyStr(UserId, 1, 50);
    end;

    trigger OnDelete()
    var
        TenderLine: Record "Tender Line";
        TenderVendor: Record "Tender Vendor Allocation";
    begin
        TestStatusOpen();
        TenderLine.SetRange("Tender No.", "No.");
        TenderLine.DeleteAll(true);
        TenderVendor.SetRange("Tender No.", "No.");
        TenderVendor.DeleteAll(true);
    end;

    procedure TestStatusOpen()
    begin
        if not (Status in [Status::Draft, Status::Rejected]) then
            Error('Tender %1 is not editable in status %2.', "No.", Status);
    end;

    procedure SetDetailedDescription(NewText: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Detailed Description");
        "Detailed Description".CreateOutStream(OutStr);
        OutStr.WriteText(NewText);
        Modify();
    end;

    procedure GetDetailedDescription(): Text
    var
        InStr: InStream;
        Result: Text;
    begin
        CalcFields("Detailed Description");
        if not "Detailed Description".HasValue then
            exit('');
        "Detailed Description".CreateInStream(InStr);
        InStr.ReadText(Result);
        exit(Result);
    end;

    procedure AssistEdit(OldTenderHeader: Record "Tender Header"): Boolean
    var
        TenderSetup: Record "Tender Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        TenderSetup.GetSetup();
        TenderSetup.TestField("Tender No. Series");
        if NoSeriesMgt.SelectSeries(TenderSetup."Tender No. Series", OldTenderHeader."No. Series", "No. Series") then begin
            NoSeriesMgt.SetSeries("No.");
            exit(true);
        end;
    end;
}

// ============================================================
// Table 50102: Tender Line
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
            TableRelation = "Tender Header";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(10; "Indentation"; Integer)
        {
            Caption = 'Indentation';
            MinValue = 0;
            MaxValue = 3;

            trigger OnValidate()
            begin
                SetLineTypeFromIndentation();
                SetStyleFromLineType();
            end;
        }
        field(11; "Line Type"; Enum "Tender Line Type")
        {
            Caption = 'Line Type';
            Editable = false;
        }
        field(12; "BOQ Serial No."; Text[20])
        {
            Caption = 'BOQ Serial No.';
        }
        field(13; "Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
        }
        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if "Item No." <> '' then begin
                    Item.Get("Item No.");
                    Description := Item.Description;
                    "Unit of Measure Code" := Item."Base Unit of Measure";
                    "HSN SAC Code" := Item."HSN/SAC Code";
                end;
            end;
        }
        field(21; "Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(22; "HSN SAC Code"; Code[20])
        {
            Caption = 'HSN/SAC Code';
        }
        field(23; "GST Group Code"; Code[20])
        {
            Caption = 'GST Group Code';
        }
        field(30; "Description Blob"; Blob)
        {
            Caption = 'Description Blob';
        }
        field(31; "Short Description"; Text[250])
        {
            Caption = 'Short Description';
        }
        field(40; "Unit of Measure Code"; Code[20])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = "Unit of Measure";
        }
        field(41; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                CheckHeadingLine();
                CalculateLineAmount();
            end;
        }
        field(42; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                CheckHeadingLine();
                CalculateLineAmount();
            end;
        }
        field(43; "Line Amount"; Decimal)
        {
            Caption = 'Line Amount';
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(50; "Consumed Quantity"; Decimal)
        {
            Caption = 'Consumed Quantity';
            FieldClass = FlowField;
            CalcFormula = sum("Rate Contract Usage"."Quantity Ordered"
                where("Tender No." = field("Tender No."),
                      "Tender Line No." = field("Line No.")));
            Editable = false;
        }
        field(51; "Remaining Quantity"; Decimal)
        {
            Caption = 'Remaining Quantity';
            Editable = false;
        }
        field(60; "Style"; Text[20])
        {
            Caption = 'Style';
            Editable = false;
        }
        field(70; "Last Modified DateTime"; DateTime)
        {
            Caption = 'Last Modified DateTime';
            Editable = false;
        }
        field(71; "Imported"; Boolean)
        {
            Caption = 'Imported';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Tender No.", "Line No.")
        {
            Clustered = true;
        }
        key(BOQ; "Tender No.", "BOQ Serial No.") { }
    }

    trigger OnInsert()
    begin
        "Last Modified DateTime" := CurrentDateTime;
    end;

    trigger OnModify()
    begin
        "Last Modified DateTime" := CurrentDateTime;
    end;

    procedure SetLineTypeFromIndentation()
    begin
        case Indentation of
            0:
                "Line Type" := "Line Type"::"Main Heading";
            1:
                "Line Type" := "Line Type"::"Heading";
            2:
                "Line Type" := "Line Type"::"Line Item";
            3:
                "Line Type" := "Line Type"::"Sub Item";
        end;
    end;

    procedure SetStyleFromLineType()
    begin
        case "Line Type" of
            "Line Type"::"Main Heading",
            "Line Type"::"Heading":
                Style := 'Strong';
            "Line Type"::"Line Item":
                Style := 'Standard';
            "Line Type"::"Sub Item":
                Style := 'Subordinate';
            else
                Style := 'Standard';
        end;
    end;

    procedure CheckHeadingLine()
    begin
        if "Line Type" in ["Line Type"::"Main Heading", "Line Type"::"Heading"] then
            Error('Cannot enter quantity or cost for heading lines.');
    end;

    procedure CalculateLineAmount()
    begin
        "Line Amount" := Quantity * "Unit Cost";
    end;

    procedure SetDescriptionBlob(NewText: Text)
    var
        OutStr: OutStream;
    begin
        Clear("Description Blob");
        "Description Blob".CreateOutStream(OutStr);
        OutStr.WriteText(NewText);
        "Short Description" := CopyStr(NewText, 1, 250);
        Modify();
    end;

    procedure GetDescriptionBlob(): Text
    var
        InStr: InStream;
        Result: Text;
    begin
        CalcFields("Description Blob");
        if not "Description Blob".HasValue then
            exit('');
        "Description Blob".CreateInStream(InStr);
        InStr.ReadText(Result);
        exit(Result);
    end;

    procedure IsHeadingLine(): Boolean
    begin
        exit("Line Type" in ["Line Type"::"Main Heading", "Line Type"::"Heading"]);
    end;

    procedure GetNextLineNo(TenderNo: Code[20]): Integer
    var
        TenderLine: Record "Tender Line";
    begin
        TenderLine.SetRange("Tender No.", TenderNo);
        if TenderLine.FindLast() then
            exit(TenderLine."Line No." + 10000)
        else
            exit(10000);
    end;
}

// ============================================================
// Table 50103: Tender Vendor Allocation
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
            TableRelation = "Tender Header";
        }
        field(2; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if "Vendor No." <> '' then begin
                    Vendor.Get("Vendor No.");
                    "Vendor Name" := Vendor.Name;
                    "Contact Person" := Vendor.Contact;
                    Email := Vendor."E-Mail";
                end;
            end;
        }
        field(3; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            Editable = false;
        }
        field(4; "Contact Person"; Text[100])
        {
            Caption = 'Contact Person';
        }
        field(5; "Email"; Text[80])
        {
            Caption = 'Email';
        }
        field(6; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(10; "Quote No."; Code[20])
        {
            Caption = 'Quote No.';
            Editable = false;
        }
        field(11; "Quote Status"; Enum "Tender Quote Status")
        {
            Caption = 'Quote Status';
        }
        field(12; "Disqualification Reason"; Text[250])
        {
            Caption = 'Disqualification Reason';
        }
        field(13; "Is Selected Vendor"; Boolean)
        {
            Caption = 'Is Selected Vendor';

            trigger OnValidate()
            var
                VendorAlloc: Record "Tender Vendor Allocation";
            begin
                if "Is Selected Vendor" then begin
                    VendorAlloc.SetRange("Tender No.", "Tender No.");
                    VendorAlloc.SetFilter("Vendor No.", '<>%1', "Vendor No.");
                    VendorAlloc.SetRange("Is Selected Vendor", true);
                    if not VendorAlloc.IsEmpty then
                        Error('Only one vendor can be selected per tender.');
                end;
            end;
        }
        field(20; "Allocated Date"; Date)
        {
            Caption = 'Allocated Date';
            Editable = false;
        }
        field(21; "Allocated By User ID"; Code[50])
        {
            Caption = 'Allocated By User ID';
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
        "Allocated Date" := Today;
        "Allocated By User ID" := CopyStr(UserId, 1, 50);
        "Quote Status" := "Quote Status"::"Not Created";
    end;
}

// ============================================================
// Table 50104: Tender Header Archive
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
        }
        field(2; "Version No."; Integer)
        {
            Caption = 'Version No.';
        }
        field(3; "Archive Reason"; Enum "Tender Archive Reason")
        {
            Caption = 'Archive Reason';
        }
        field(4; "Archived DateTime"; DateTime)
        {
            Caption = 'Archived DateTime';
        }
        field(5; "Archived By User ID"; Code[50])
        {
            Caption = 'Archived By User ID';
        }
        // Snapshot fields from Tender Header
        field(10; "Description"; Text[250]) { Caption = 'Description'; }
        field(11; "Source Module"; Enum "Tender Source Module") { Caption = 'Source Module'; }
        field(12; "Source ID"; Code[20]) { Caption = 'Source ID'; }
        field(13; "Item Type"; Enum "Tender Item Type") { Caption = 'Item Type'; }
        field(14; "Tender Type"; Enum "Tender Type") { Caption = 'Tender Type'; }
        field(15; "Status"; Enum "Tender Status") { Caption = 'Status'; }
        field(16; "Bid Start Date"; Date) { Caption = 'Bid Start Date'; }
        field(17; "Bid End Date"; Date) { Caption = 'Bid End Date'; }
        field(18; "Bid Validity Date"; Date) { Caption = 'Bid Validity Date'; }
        field(19; "Currency Code"; Code[10]) { Caption = 'Currency Code'; }
        field(20; "Budget Amount"; Decimal) { Caption = 'Budget Amount'; }
        field(21; "Business Unit Code"; Code[20]) { Caption = 'Business Unit Code'; }
        field(22; "Negotiate Date"; Date) { Caption = 'Negotiate Date'; }
        field(23; "Negotiate Place"; Text[100]) { Caption = 'Negotiate Place'; }
        field(24; "Detailed Description"; Blob) { Caption = 'Detailed Description'; }
        field(25; "Work Type"; Code[20]) { Caption = 'Work Type'; }
        field(26; "Sanction No."; Code[20]) { Caption = 'Sanction No.'; }
        field(27; "Source Type"; Code[50]) { Caption = 'Source Type'; }
        field(28; "Dimension Set ID"; Integer) { Caption = 'Dimension Set ID'; }
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
// Table 50105: Tender Line Archive
// ============================================================
table 50105 "Tender Line Archive"
{
    Caption = 'Tender Line Archive';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20]) { Caption = 'Tender No.'; }
        field(2; "Version No."; Integer) { Caption = 'Version No.'; }
        field(3; "Line No."; Integer) { Caption = 'Line No.'; }
        field(10; "Indentation"; Integer) { Caption = 'Indentation'; }
        field(11; "Line Type"; Enum "Tender Line Type") { Caption = 'Line Type'; }
        field(12; "BOQ Serial No."; Text[20]) { Caption = 'BOQ Serial No.'; }
        field(13; "Parent Line No."; Integer) { Caption = 'Parent Line No.'; }
        field(20; "Item No."; Code[20]) { Caption = 'Item No.'; }
        field(21; "Description"; Text[100]) { Caption = 'Description'; }
        field(22; "HSN SAC Code"; Code[20]) { Caption = 'HSN/SAC Code'; }
        field(23; "GST Group Code"; Code[20]) { Caption = 'GST Group Code'; }
        field(30; "Description Blob"; Blob) { Caption = 'Description Blob'; }
        field(31; "Short Description"; Text[250]) { Caption = 'Short Description'; }
        field(40; "Unit of Measure Code"; Code[20]) { Caption = 'Unit of Measure Code'; }
        field(41; "Quantity"; Decimal) { Caption = 'Quantity'; }
        field(42; "Unit Cost"; Decimal) { Caption = 'Unit Cost'; }
        field(43; "Line Amount"; Decimal) { Caption = 'Line Amount'; }
        field(44; "Style"; Text[20]) { Caption = 'Style'; }
        field(45; "Imported"; Boolean) { Caption = 'Imported'; }
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
// Table 50106: Tender Corrigendum
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
            TableRelation = "Tender Header";
        }
        field(2; "Corrigendum No."; Integer)
        {
            Caption = 'Corrigendum No.';
        }
        field(10; "Issue Date"; Date) { Caption = 'Issue Date'; }
        field(11; "Description"; Text[250]) { Caption = 'Description'; }
        field(12; "Detailed Changes"; Blob) { Caption = 'Detailed Changes'; }
        field(13; "Changes Type"; Enum "Corrigendum Changes Type") { Caption = 'Changes Type'; }
        field(14; "BOQ Re-Imported"; Boolean) { Caption = 'BOQ Re-Imported'; }
        field(15; "Archive Version No."; Integer) { Caption = 'Archive Version No.'; }
        field(16; "Issued By User ID"; Code[50]) { Caption = 'Issued By User ID'; }
        field(20; "New Bid End Date"; Date) { Caption = 'New Bid End Date'; }
        field(21; "New Bid Validity Date"; Date) { Caption = 'New Bid Validity Date'; }
        field(22; "Terms Change Description"; Text[500]) { Caption = 'Terms Change Description'; }
        field(30; "Vendors Notified"; Boolean) { Caption = 'Vendors Notified'; }
        field(31; "Notification DateTime"; DateTime) { Caption = 'Notification DateTime'; }
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
// Table 50107: Reverse Auction Round
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
            TableRelation = "Tender Header";
        }
        field(2; "Round No."; Integer) { Caption = 'Round No.'; }
        field(10; "Round Start DateTime"; DateTime) { Caption = 'Round Start DateTime'; }
        field(11; "Round End DateTime"; DateTime) { Caption = 'Round End DateTime'; }
        field(12; "Time Limit Minutes"; Integer) { Caption = 'Time Limit Minutes'; }
        field(13; "Status"; Enum "Auction Round Status") { Caption = 'Status'; }
        field(14; "Min Decrement Percentage"; Decimal) { Caption = 'Min Decrement Percentage'; }
        field(15; "Min Decrement Amount"; Decimal) { Caption = 'Min Decrement Amount'; }
        field(16; "Created By User ID"; Code[50]) { Caption = 'Created By User ID'; }
        field(17; "Remarks"; Text[250]) { Caption = 'Remarks'; }
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
// Table 50108: Reverse Auction Entry
// ============================================================
table 50108 "Reverse Auction Entry"
{
    Caption = 'Reverse Auction Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20]) { Caption = 'Tender No.'; }
        field(2; "Round No."; Integer) { Caption = 'Round No.'; }
        field(3; "Vendor No."; Code[20]) { Caption = 'Vendor No.'; TableRelation = Vendor; }
        field(4; "Line No."; Integer) { Caption = 'Line No.'; }
        field(10; "Previous Unit Cost"; Decimal) { Caption = 'Previous Unit Cost'; }
        field(11; "New Unit Cost"; Decimal)
        {
            Caption = 'New Unit Cost';

            trigger OnValidate()
            begin
                if "New Unit Cost" > "Previous Unit Cost" then
                    Error('New unit cost cannot be higher than previous unit cost.');
                "New Line Amount" := "New Unit Cost" * GetLineQuantity();
                if "Previous Unit Cost" <> 0 then
                    "Decrement Percentage" := Round(("Previous Unit Cost" - "New Unit Cost") / "Previous Unit Cost" * 100, 0.01);
                "Decrement Amount" := "Previous Unit Cost" - "New Unit Cost";
            end;
        }
        field(12; "Previous Line Amount"; Decimal) { Caption = 'Previous Line Amount'; }
        field(13; "New Line Amount"; Decimal) { Caption = 'New Line Amount'; }
        field(14; "Decrement Percentage"; Decimal) { Caption = 'Decrement Percentage'; Editable = false; }
        field(15; "Decrement Amount"; Decimal) { Caption = 'Decrement Amount'; Editable = false; }
        field(16; "Is Valid Entry"; Boolean) { Caption = 'Is Valid Entry'; Editable = false; }
        field(17; "Submitted DateTime"; DateTime) { Caption = 'Submitted DateTime'; }
        field(18; "Rank"; Integer) { Caption = 'Rank'; Editable = false; }
        field(19; "Currency Code"; Code[10]) { Caption = 'Currency Code'; }
    }

    keys
    {
        key(PK; "Tender No.", "Round No.", "Vendor No.", "Line No.")
        {
            Clustered = true;
        }
    }

    local procedure GetLineQuantity(): Decimal
    var
        TenderLine: Record "Tender Line";
    begin
        if TenderLine.Get("Tender No.", "Line No.") then
            exit(TenderLine.Quantity);
        exit(0);
    end;
}

// ============================================================
// Table 50109: Tender Disqualification Rule
// ============================================================
table 50109 "Tender Disqualification Rule"
{
    Caption = 'Tender Disqualification Rule';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20]) { Caption = 'Tender No.'; TableRelation = "Tender Header"; }
        field(2; "Rule No."; Integer) { Caption = 'Rule No.'; }
        field(10; "Rule Type"; Enum "Disqualification Rule Type") { Caption = 'Rule Type'; }
        field(11; "Rule Description"; Text[250]) { Caption = 'Rule Description'; }
        field(12; "Mandatory"; Boolean) { Caption = 'Mandatory'; }
        field(13; "Min Value"; Decimal) { Caption = 'Min Value'; }
        field(14; "Required Text"; Text[100]) { Caption = 'Required Text'; }
        field(15; "Custom Evaluation"; Boolean) { Caption = 'Custom Evaluation'; }
        field(16; "Active"; Boolean) { Caption = 'Active'; InitValue = true; }
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
// Table 50110: Tender Questionnaire Template
// ============================================================
table 50110 "Tender Quest. Template"
{
    Caption = 'Tender Questionnaire Template';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Code"; Code[20]) { Caption = 'Template Code'; }
        field(2; "Question No."; Integer) { Caption = 'Question No.'; }
        field(10; "Question Text"; Text[500]) { Caption = 'Question Text'; }
        field(11; "Answer Type"; Enum "Questionnaire Answer Type") { Caption = 'Answer Type'; }
        field(12; "Options"; Text[500]) { Caption = 'Options'; }
        field(13; "Is Mandatory"; Boolean) { Caption = 'Is Mandatory'; }
        field(14; "Scoring Weight"; Decimal) { Caption = 'Scoring Weight'; }
        field(15; "Disqualify If Answer"; Text[100]) { Caption = 'Disqualify If Answer'; }
        field(16; "Sequence No."; Integer) { Caption = 'Sequence No.'; }
    }

    keys
    {
        key(PK; "Template Code", "Question No.")
        {
            Clustered = true;
        }
        key(Seq; "Template Code", "Sequence No.") { }
    }
}

// ============================================================
// Table 50111: Tender Questionnaire Response
// ============================================================
table 50111 "Tender Quest. Response"
{
    Caption = 'Tender Questionnaire Response';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20]) { Caption = 'Tender No.'; }
        field(2; "Vendor No."; Code[20]) { Caption = 'Vendor No.'; TableRelation = Vendor; }
        field(3; "Question No."; Integer) { Caption = 'Question No.'; }
        field(10; "Question Text"; Text[500]) { Caption = 'Question Text'; }
        field(11; "Answer Text"; Text[500]) { Caption = 'Answer Text'; }
        field(12; "Answer Number"; Decimal) { Caption = 'Answer Number'; }
        field(13; "Answer Boolean"; Boolean) { Caption = 'Answer Boolean'; }
        field(14; "Answer Date"; Date) { Caption = 'Answer Date'; }
        field(15; "Score"; Decimal) { Caption = 'Score'; }
        field(16; "Meets Requirement"; Boolean) { Caption = 'Meets Requirement'; }
        field(17; "Evaluated By User ID"; Code[50]) { Caption = 'Evaluated By User ID'; }
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
// Table 50112: Rate Contract Usage
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
            AutoIncrement = true;
        }
        field(2; "Tender No."; Code[20]) { Caption = 'Tender No.'; }
        field(3; "Tender Line No."; Integer) { Caption = 'Tender Line No.'; }
        field(4; "Purchase Order No."; Code[20]) { Caption = 'Purchase Order No.'; }
        field(5; "PO Line No."; Integer) { Caption = 'PO Line No.'; }
        field(10; "Vendor No."; Code[20]) { Caption = 'Vendor No.'; TableRelation = Vendor; }
        field(11; "Item No."; Code[20]) { Caption = 'Item No.'; }
        field(12; "Description"; Text[250]) { Caption = 'Description'; }
        field(13; "Quantity Ordered"; Decimal) { Caption = 'Quantity Ordered'; }
        field(14; "Unit Cost"; Decimal) { Caption = 'Unit Cost'; }
        field(15; "Line Amount"; Decimal) { Caption = 'Line Amount'; }
        field(16; "Order Date"; Date) { Caption = 'Order Date'; }
        field(17; "Created By User ID"; Code[50]) { Caption = 'Created By User ID'; }
        field(18; "Currency Code"; Code[10]) { Caption = 'Currency Code'; }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Tender; "Tender No.", "Tender Line No.") { }
    }
}

// ============================================================
// Table 50113: Vendor Performance Rating
// ============================================================
table 50113 "Vendor Performance Rating"
{
    Caption = 'Vendor Performance Rating';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Tender No."; Code[20]) { Caption = 'Tender No.'; }
        field(3; "Vendor No."; Code[20]) { Caption = 'Vendor No.'; TableRelation = Vendor; }
        field(4; "Order No."; Code[20]) { Caption = 'Order No.'; }
        field(5; "Order Document Type"; Enum "Tender Order Doc Type") { Caption = 'Order Document Type'; }
        field(10; "Completion Date"; Date) { Caption = 'Completion Date'; }
        field(11; "Quality Rating"; Decimal) { Caption = 'Quality Rating'; MinValue = 0; MaxValue = 10; }
        field(12; "Timeliness Rating"; Decimal) { Caption = 'Timeliness Rating'; MinValue = 0; MaxValue = 10; }
        field(13; "Compliance Rating"; Decimal) { Caption = 'Compliance Rating'; MinValue = 0; MaxValue = 10; }
        field(14; "Communication Rating"; Decimal) { Caption = 'Communication Rating'; MinValue = 0; MaxValue = 10; }
        field(15; "Overall Rating"; Decimal) { Caption = 'Overall Rating'; Editable = false; }
        field(16; "Rating Scale Max"; Integer) { Caption = 'Rating Scale Max'; InitValue = 5; }
        field(20; "Comments"; Text[500]) { Caption = 'Comments'; }
        field(21; "Detailed Feedback"; Blob) { Caption = 'Detailed Feedback'; }
        field(22; "Rated By User ID"; Code[50]) { Caption = 'Rated By User ID'; }
        field(23; "Rated DateTime"; DateTime) { Caption = 'Rated DateTime'; }
        field(24; "Status"; Enum "Perf. Rating Status") { Caption = 'Status'; }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Tender; "Tender No.", "Vendor No.") { }
    }

    procedure CalculateOverallRating()
    begin
        "Overall Rating" := Round(("Quality Rating" + "Timeliness Rating" +
                                   "Compliance Rating" + "Communication Rating") / 4, 0.01);
    end;
}

// ============================================================
// Table 50114: Tender Digital Signature Log
// ============================================================
table 50114 "Tender Digi. Signature Log"
{
    Caption = 'Tender Digital Signature Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { Caption = 'Entry No.'; AutoIncrement = true; }
        field(2; "Tender No."; Code[20]) { Caption = 'Tender No.'; }
        field(3; "Stage"; Enum "Tender Signature Stage") { Caption = 'Stage'; }
        field(4; "Action"; Enum "Tender Signature Action") { Caption = 'Action'; }
        field(10; "Requested By User ID"; Code[50]) { Caption = 'Requested By User ID'; }
        field(11; "Requested DateTime"; DateTime) { Caption = 'Requested DateTime'; }
        field(12; "Signed By User ID"; Code[50]) { Caption = 'Signed By User ID'; }
        field(13; "Signed DateTime"; DateTime) { Caption = 'Signed DateTime'; }
        field(14; "Signature Reference"; Text[250]) { Caption = 'Signature Reference'; }
        field(15; "Certificate Info"; Text[500]) { Caption = 'Certificate Info'; }
        field(16; "Remarks"; Text[250]) { Caption = 'Remarks'; }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Tender; "Tender No.") { }
    }
}

// ============================================================
// Table 50115: Tender Doc. Attachment Stage
// ============================================================
table 50115 "Tender Doc. Attachment Stage"
{
    Caption = 'Tender Document Attachment Stage';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tender No."; Code[20]) { Caption = 'Tender No.'; }
        field(2; "Attachment Entry No."; Integer) { Caption = 'Attachment Entry No.'; }
        field(10; "Stage"; Enum "Tender Doc Attachment Stage") { Caption = 'Stage'; }
        field(11; "Description"; Text[250]) { Caption = 'Description'; }
        field(12; "Uploaded By User ID"; Code[50]) { Caption = 'Uploaded By User ID'; }
        field(13; "Uploaded DateTime"; DateTime) { Caption = 'Uploaded DateTime'; }
        field(14; "Is Mandatory"; Boolean) { Caption = 'Is Mandatory'; }
        field(15; "Verified"; Boolean) { Caption = 'Verified'; }
    }

    keys
    {
        key(PK; "Tender No.", "Attachment Entry No.")
        {
            Clustered = true;
        }
    }
}