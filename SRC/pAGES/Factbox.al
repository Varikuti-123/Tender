// ============================================================
// Page 50119: Tender Line Description FactBox
// Professional, no-scroll, full description display
// ============================================================
page 50119 "Tender Line Desc. FactBox"
{
    PageType = CardPart;
    SourceTable = "Tender Line";
    Caption = 'Line Description';
    Editable = false;

    layout
    {
        area(Content)
        {
            // ─────────────────────────────────────────
            // SECTION 1: Line Identity — Compact Header
            // ─────────────────────────────────────────
            group(LineIdentity)
            {
                Caption = ' ';
                Visible = HasLine;

                grid(IdentityGrid)
                {
                    GridLayout = Rows;

                    group(Row1)
                    {
                        ShowCaption = false;

                        field(SerialAndType; LineIdentityText)
                        {
                            ApplicationArea = All;
                            Caption = 'Line';
                            Editable = false;
                            Style = StrongAccent;
                            ToolTip = 'BOQ Serial No. and Line Type of the selected line.';
                        }
                    }
                    group(Row2)
                    {
                        ShowCaption = false;

                        field(QuantityInfo; QuantityInfoText)
                        {
                            ApplicationArea = All;
                            Caption = 'Specification';
                            Editable = false;
                            Style = Strong;
                            Visible = HasQuantity;
                            ToolTip = 'Quantity, Unit of Measure, Rate and Amount.';
                        }
                    }
                    group(Row3)
                    {
                        ShowCaption = false;

                        field(AmountInfo; AmountInfoText)
                        {
                            ApplicationArea = All;
                            Caption = 'Amount';
                            Editable = false;
                            Style = Favorable;
                            Visible = HasQuantity;
                            ToolTip = 'Calculated line amount.';
                        }
                    }
                    group(Row4)
                    {
                        ShowCaption = false;
                        Visible = IsHeading;

                        field(HeadingBadge; HeadingBadgeText)
                        {
                            ApplicationArea = All;
                            Caption = 'Note';
                            Editable = false;
                            Style = Ambiguous;
                            ToolTip = 'This is a heading line — no quantities.';
                        }
                    }
                }
            }

            // ─────────────────────────────────────────
            // SECTION 2: Full Description — THE MAIN AREA
            // Uses multiple fixed-height fields to avoid scroll
            // Each field shows a portion of the description
            // ─────────────────────────────────────────
            group(DescriptionArea)
            {
                Caption = 'Description';
                Visible = HasLine and (DescLine1 <> '');

                field(Desc01; DescLine1)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = AttentionAccent;
                    Visible = DescLine1 <> '';
                }
                field(Desc02; DescLine2)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                    Visible = DescLine2 <> '';
                }
                field(Desc03; DescLine3)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                    Visible = DescLine3 <> '';
                }
                field(Desc04; DescLine4)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                    Visible = DescLine4 <> '';
                }
                field(Desc05; DescLine5)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                    Visible = DescLine5 <> '';
                }
                field(Desc06; DescLine6)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                    Visible = DescLine6 <> '';
                }
                field(Desc07; DescLine7)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                    Visible = DescLine7 <> '';
                }
                field(Desc08; DescLine8)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                    Visible = DescLine8 <> '';
                }
                field(Desc09; DescLine9)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                    Visible = DescLine9 <> '';
                }
                field(Desc10; DescLine10)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                    Visible = DescLine10 <> '';
                }
                field(Desc11; DescLine11)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                    Visible = DescLine11 <> '';
                }
                field(Desc12; DescLine12)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    MultiLine = true;
                    Style = Standard;
                    Visible = DescLine12 <> '';
                }
            }

            // ─────────────────────────────────────────
            // SECTION 3: Item Info (for HSN lines)
            // ─────────────────────────────────────────
            group(ItemInfoGroup)
            {
                Caption = 'Item Details';
                Visible = HasLine and IsHSNLine;

                field(ItemNoDisplay; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Caption = 'Item No.';
                    Editable = false;
                    Style = StrongAccent;
                }
                field(HSNCodeDisplay; Rec."HSN SAC Code")
                {
                    ApplicationArea = All;
                    Caption = 'HSN/SAC Code';
                    Editable = false;
                    Style = Standard;
                    Visible = Rec."HSN SAC Code" <> '';
                }
                field(GSTGroupDisplay; Rec."GST Group Code")
                {
                    ApplicationArea = All;
                    Caption = 'GST Group';
                    Editable = false;
                    Style = Standard;
                    Visible = Rec."GST Group Code" <> '';
                }
            }

            // ─────────────────────────────────────────
            // SECTION 4: Empty State
            // ─────────────────────────────────────────
            group(EmptyState)
            {
                Caption = ' ';
                Visible = not HasLine;

                field(EmptyMessage; EmptyStateText)
                {
                    ApplicationArea = All;
                    Caption = ' ';
                    Editable = false;
                    ShowCaption = false;
                    Style = Subordinate;
                }
            }
        }
    }

    var
        // Control variables
        HasLine: Boolean;
        HasQuantity: Boolean;
        IsHeading: Boolean;
        IsHSNLine: Boolean;
        IsSACLine: Boolean;

        // Display texts
        LineIdentityText: Text;
        QuantityInfoText: Text;
        AmountInfoText: Text;
        HeadingBadgeText: Text;
        EmptyStateText: Text;

        // Description split into lines (no scrolling)
        DescLine1: Text[250];
        DescLine2: Text[250];
        DescLine3: Text[250];
        DescLine4: Text[250];
        DescLine5: Text[250];
        DescLine6: Text[250];
        DescLine7: Text[250];
        DescLine8: Text[250];
        DescLine9: Text[250];
        DescLine10: Text[250];
        DescLine11: Text[250];
        DescLine12: Text[250];

    trigger OnAfterGetRecord()
    begin
        LoadEverything();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        LoadEverything();
    end;

    local procedure LoadEverything()
    begin
        ClearAllFields();

        HasLine := (Rec."Line No." <> 0);
        if not HasLine then begin
            EmptyStateText := '← Select a tender line to view its full description here.';
            exit;
        end;

        DetermineLineType();
        BuildIdentityText();
        BuildQuantityText();
        BuildDescriptionLines();
    end;

    local procedure ClearAllFields()
    begin
        HasLine := false;
        HasQuantity := false;
        IsHeading := false;
        IsHSNLine := false;
        IsSACLine := false;
        LineIdentityText := '';
        QuantityInfoText := '';
        AmountInfoText := '';
        HeadingBadgeText := '';
        EmptyStateText := '';
        DescLine1 := '';
        DescLine2 := '';
        DescLine3 := '';
        DescLine4 := '';
        DescLine5 := '';
        DescLine6 := '';
        DescLine7 := '';
        DescLine8 := '';
        DescLine9 := '';
        DescLine10 := '';
        DescLine11 := '';
        DescLine12 := '';
    end;

    local procedure DetermineLineType()
    var
        TenderHeader: Record "Tender Header";
    begin
        if TenderHeader.Get(Rec."Tender No.") then begin
            IsHSNLine := TenderHeader."Item Type" = TenderHeader."Item Type"::HSN;
            IsSACLine := TenderHeader."Item Type" = TenderHeader."Item Type"::SAC;
        end;

        IsHeading := Rec."Line Type" in [
            Rec."Line Type"::"Main Heading",
            Rec."Line Type"::"Heading"
        ];

        HasQuantity := (not IsHeading) and (Rec.Quantity <> 0);
    end;

    local procedure BuildIdentityText()
    var
        TypeText: Text;
        Prefix: Text;
    begin
        // Build a single-line identity string
        case Rec."Line Type" of
            Rec."Line Type"::"Main Heading":
                TypeText := '■ MAIN HEADING';
            Rec."Line Type"::"Heading":
                TypeText := '► HEADING';
            Rec."Line Type"::"Line Item":
                TypeText := '● LINE ITEM';
            Rec."Line Type"::"Sub Item":
                TypeText := '○ SUB ITEM';
            else
                TypeText := '● ITEM';
        end;

        if Rec."BOQ Serial No." <> '' then
            Prefix := Rec."BOQ Serial No." + ' — '
        else if Rec."Item No." <> '' then
            Prefix := Rec."Item No." + ' — '
        else
            Prefix := '';

        LineIdentityText := Prefix + TypeText;

        if IsHeading then
            HeadingBadgeText := 'ℹ Structural heading — no quantities applicable';
    end;

    local procedure BuildQuantityText()
    begin
        if not HasQuantity then
            exit;

        // Line 1: Qty x UoM @ Rate
        QuantityInfoText := StrSubstNo('%1 %2 × %3 per %4',
            Format(Rec.Quantity, 0, '<Precision,2:5><Standard Format,0>'),
            Rec."Unit of Measure Code",
            Format(Rec."Unit Cost", 0, '<Precision,2:2><Standard Format,0>'),
            Rec."Unit of Measure Code"
        );

        // Line 2: Total Amount
        AmountInfoText := StrSubstNo('₹ %1',
            Format(Rec."Line Amount", 0, '<Precision,2:2><Standard Format,0>')
        );
    end;

    local procedure BuildDescriptionLines()
    var
        FullText: Text;
        RemainingText: Text;
        ChunkSize: Integer;
        LineIndex: Integer;
    begin
        // Get the full description from Blob or fallback fields
        FullText := GetFullDescription();

        if FullText = '' then begin
            DescLine1 := '(No description available)';
            exit;
        end;

        // Split the text into chunks of ~200 chars each
        // This prevents scrolling by spreading text across multiple fields
        // Each field renders fully visible without scroll
        ChunkSize := 200;
        RemainingText := FullText;
        LineIndex := 1;

        while (RemainingText <> '') and (LineIndex <= 12) do begin
            AssignDescLine(LineIndex, SmartSplit(RemainingText, ChunkSize));
            LineIndex += 1;
        end;
    end;

    local procedure GetFullDescription(): Text
    var
        BlobText: Text;
    begin
        // Priority 1: Blob (SAC long descriptions)
        BlobText := Rec.GetDescriptionBlob();
        if BlobText <> '' then
            exit(BlobText);

        // Priority 2: Short Description
        if Rec."Short Description" <> '' then
            exit(Rec."Short Description");

        // Priority 3: Standard Description
        if Rec.Description <> '' then
            exit(Rec.Description);

        exit('');
    end;

    local procedure SmartSplit(var RemainingText: Text; MaxLen: Integer): Text[250]
    var
        Chunk: Text;
        SplitPos: Integer;
        TextLen: Integer;
    begin
        TextLen := StrLen(RemainingText);

        if TextLen <= MaxLen then begin
            Chunk := RemainingText;
            RemainingText := '';
            exit(CopyStr(Chunk, 1, 250));
        end;

        // Take MaxLen characters
        Chunk := CopyStr(RemainingText, 1, MaxLen);

        // Try to split at the last space to avoid breaking words
        SplitPos := MaxLen;
        while (SplitPos > MaxLen - 50) and (SplitPos > 1) do begin
            if CopyStr(Chunk, SplitPos, 1) = ' ' then begin
                Chunk := CopyStr(RemainingText, 1, SplitPos);
                RemainingText := CopyStr(RemainingText, SplitPos + 1);
                exit(CopyStr(Chunk, 1, 250));
            end;
            SplitPos -= 1;
        end;

        // No space found in range — force split at MaxLen
        Chunk := CopyStr(RemainingText, 1, MaxLen);
        RemainingText := CopyStr(RemainingText, MaxLen + 1);
        exit(CopyStr(Chunk, 1, 250));
    end;

    local procedure AssignDescLine(LineIndex: Integer; Value: Text[250])
    begin
        case LineIndex of
            1:
                DescLine1 := Value;
            2:
                DescLine2 := Value;
            3:
                DescLine3 := Value;
            4:
                DescLine4 := Value;
            5:
                DescLine5 := Value;
            6:
                DescLine6 := Value;
            7:
                DescLine7 := Value;
            8:
                DescLine8 := Value;
            9:
                DescLine9 := Value;
            10:
                DescLine10 := Value;
            11:
                DescLine11 := Value;
            12:
                DescLine12 := Value;
        end;
    end;
}