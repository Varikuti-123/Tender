// ============================================================
// TableExtension 50100 - Purchase Header (Tender Fields)
// Purpose: Adds tender reference fields to standard Purchase Header.
//          This allows Purchase Quotes, POs, and Work Orders to
//          link back to their originating tender.
// ============================================================
tableextension 50100 "Purch. Header Tender Ext." extends "Purchase Header"
{
    fields
    {
        field(50100; "MAHE Tender No."; Code[20])
        {
            Caption = 'Tender No.';
            DataClassification = CustomerContent;
            TableRelation = "Tender Header";
        }
        field(50101; "MAHE Source Module"; Enum "Tender Source Module")
        {
            Caption = 'Source Module';
            DataClassification = CustomerContent;
        }
        field(50102; "MAHE Source ID"; Code[20])
        {
            Caption = 'Source ID';
            DataClassification = CustomerContent;
        }
        field(50103; "MAHE Select Vendor"; Boolean)
        {
            Caption = 'Selected Vendor';
            DataClassification = CustomerContent;
        }
        field(50104; "MAHE Tender Item Type"; Enum "Tender Item Type")
        {
            Caption = 'Tender Item Type';
            DataClassification = CustomerContent;
        }
        field(50105; "MAHE Bid Validity Date"; Date)
        {
            Caption = 'Bid Validity Date';
            DataClassification = CustomerContent;
        }
        field(50106; "MAHE Bid Submitted"; Boolean)
        {
            Caption = 'Bid Submitted';
            DataClassification = CustomerContent;
        }
        field(50107; "MAHE Bid Submit DateTime"; DateTime)
        {
            Caption = 'Bid Submit DateTime';
            DataClassification = CustomerContent;
        }
        field(50108; "MAHE Negotiate Date"; Date)
        {
            Caption = 'Negotiate Date';
            DataClassification = CustomerContent;
        }
        field(50109; "MAHE Negotiate Place"; Text[100])
        {
            Caption = 'Negotiate Place';
            DataClassification = CustomerContent;
        }
        field(50110; "MAHE Negotiation Notes"; Text[500])
        {
            Caption = 'Negotiation Notes';
            DataClassification = CustomerContent;
        }
        field(50111; "MAHE Rate Contract Tender No."; Code[20])
        {
            Caption = 'Rate Contract Tender No.';
            DataClassification = CustomerContent;
            TableRelation = "Tender Header";
        }
        field(50112; "MAHE Is Rate Contract Order"; Boolean)
        {
            Caption = 'Is Rate Contract Order';
            DataClassification = CustomerContent;
        }
    }
}

// ============================================================
// TableExtension 50101 - Purchase Line (Tender Fields)
// Purpose: Adds tender line reference and SAC blob fields
//          to standard Purchase Line.
// ============================================================
tableextension 50101 "Purch. Line Tender Ext." extends "Purchase Line"
{
    fields
    {
        field(50100; "MAHE Tender Line No."; Integer)
        {
            Caption = 'Tender Line No.';
            DataClassification = CustomerContent;
        }
        field(50101; "MAHE Indentation"; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
        }
        field(50102; "MAHE Line Type"; Enum "Tender Line Type")
        {
            Caption = 'Line Type';
            DataClassification = CustomerContent;
        }
        field(50103; "MAHE BOQ Serial No."; Text[20])
        {
            Caption = 'BOQ Serial No.';
            DataClassification = CustomerContent;
        }
        field(50104; "MAHE Description Blob"; Blob)
        {
            Caption = 'Description Blob';
            DataClassification = CustomerContent;
        }
        field(50105; "MAHE Short Description"; Text[250])
        {
            Caption = 'Short Description';
            DataClassification = CustomerContent;
        }
        field(50106; "MAHE Style"; Enum "Tender Line Style")
        {
            Caption = 'Style';
            DataClassification = CustomerContent;
        }
        field(50107; "MAHE Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
            DataClassification = CustomerContent;
        }
    }
}