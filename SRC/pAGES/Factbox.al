// ============================================================
// Page 50119: Tender Line Desc. FactBox (with Control Add-in)
// ============================================================
page 50119 "Tender Line Desc. FactBox"
{
    PageType = CardPart;
    SourceTable = "Tender Line";
    Caption = 'Description';

    layout
    {
        area(Content)
        {
            usercontrol(DescViewer; "Description Viewer")
            {
                ApplicationArea = All;

                trigger OnControlReady()
                begin
                    ControlIsReady := true;
                    PushDescription();
                end;
            }
        }
    }

    var
        ControlIsReady: Boolean;

    trigger OnAfterGetRecord()
    begin
        PushDescription();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        PushDescription();
    end;

    local procedure PushDescription()
    var
        DescText: Text;
        LineTypeText: Text;
        SerialNo: Text;
    begin
        if not ControlIsReady then
            exit;

        if Rec."Line No." = 0 then begin
            CurrPage.DescViewer.ClearDescription();
            exit;
        end;

        // Get description
        DescText := GetFullDescription();

        // Get line type as text
        LineTypeText := Format(Rec."Line Type");

        // Get serial no
        SerialNo := Rec."BOQ Serial No.";

        if DescText <> '' then
            CurrPage.DescViewer.SetDescription(DescText, LineTypeText, SerialNo)
        else
            CurrPage.DescViewer.ClearDescription();
    end;

    local procedure GetFullDescription(): Text
    var
        BlobText: Text;
    begin
        BlobText := Rec.GetDescriptionBlob();
        if BlobText <> '' then
            exit(BlobText);

        if Rec."Short Description" <> '' then
            exit(Rec."Short Description");

        if Rec.Description <> '' then
            exit(Rec.Description);

        exit('');
    end;
}
