// ============================================================
// TableExtension: Purchase Header Extension
// ============================================================
tableextension 50100 "Purchase Header Tender Ext" extends "Purchase Header"
{
    fields
    {
        field(50100; "Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            TableRelation = "Tender Header";
        }
        field(50101; "Source Module"; Enum "Tender Source Module")
        {
            Caption = 'Source Module';
        }
        field(50102; "Source ID"; Code[20])
        {
            Caption = 'Source ID';
        }
        field(50103; "Select Vendor"; Boolean)
        {
            Caption = 'Select Vendor';
        }
        field(50104; "Tender Item Type"; Enum "Tender Item Type")
        {
            Caption = 'Tender Item Type';
        }
        field(50105; "Bid Validity Date"; Date)
        {
            Caption = 'Bid Validity Date';
        }
        field(50106; "Bid Submitted"; Boolean)
        {
            Caption = 'Bid Submitted';
        }
        field(50107; "Bid Submit DateTime"; DateTime)
        {
            Caption = 'Bid Submit DateTime';
        }
        field(50108; "Negotiate Date"; Date)
        {
            Caption = 'Negotiate Date';
        }
        field(50109; "Negotiate Place"; Text[100])
        {
            Caption = 'Negotiate Place';
        }
        field(50110; "Negotiation Notes"; Text[500])
        {
            Caption = 'Negotiation Notes';
        }
        field(50111; "Rate Contract Tender No."; Code[20])
        {
            Caption = 'Rate Contract Tender No.';
            TableRelation = "Tender Header";
        }
        field(50112; "Is Rate Contract Order"; Boolean)
        {
            Caption = 'Is Rate Contract Order';
        }
    }
}

// ============================================================
// TableExtension: Purchase Line Extension
// ============================================================
tableextension 50101 "Purchase Line Tender Ext" extends "Purchase Line"
{
    fields
    {
        field(50100; "Tender Line No."; Integer)
        {
            Caption = 'Tender Line No.';
        }
        field(50101; "Indentation"; Integer)
        {
            Caption = 'Indentation';
        }
        field(50102; "Line Type"; Enum "Tender Line Type")
        {
            Caption = 'Line Type';
        }
        field(50103; "BOQ Serial No."; Text[20])
        {
            Caption = 'BOQ Serial No.';
        }
        field(50104; "Description Blob"; Blob)
        {
            Caption = 'Description Blob';
        }
        field(50105; "Short Description"; Text[250])
        {
            Caption = 'Short Description';
        }
        field(50106; "Style"; Text[20])
        {
            Caption = 'Style';
        }
        field(50107; "Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
        }
    }
}

// ============================================================
// EnumExtension: Purchase Document Type + Work Order
// ============================================================
enumextension 50100 "Purch. Doc Type Tender Ext" extends "Purchase Document Type"
{
    value(50100; "Work Order")
    {
        Caption = 'Work Order';
    }
}