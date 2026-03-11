// ============================================================
// Page 50100: Tender Setup
// ============================================================
page 50100 "Tender Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Tender Setup";
    Caption = 'Tender Setup';
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Number Series';
                field("Tender No. Series"; Rec."Tender No. Series") { ApplicationArea = All; }
                field("Work Order No. Series"; Rec."Work Order No. Series") { ApplicationArea = All; }
                field("Rate Contract No. Series"; Rec."Rate Contract No. Series") { ApplicationArea = All; }
                field("Corrigendum No. Series"; Rec."Corrigendum No. Series") { ApplicationArea = All; }
                field("Default Bid Validity Days"; Rec."Default Bid Validity Days") { ApplicationArea = All; }
            }
            group(ReverseAuction)
            {
                Caption = 'Reverse Auction';
                field("Min Decrement Percentage"; Rec."Min Decrement Percentage") { ApplicationArea = All; }
                field("Min Decrement Amount"; Rec."Min Decrement Amount") { ApplicationArea = All; }
                field("Decrement Type"; Rec."Decrement Type") { ApplicationArea = All; }
                field("Default Round Time Limit"; Rec."Default Round Time Limit") { ApplicationArea = All; }
                field("Auction Visibility"; Rec."Auction Visibility") { ApplicationArea = All; }
                field("Max Auction Rounds"; Rec."Max Auction Rounds") { ApplicationArea = All; }
            }
            group(Features)
            {
                Caption = 'Features';
                field("Enable Reverse Auction"; Rec."Enable Reverse Auction") { ApplicationArea = All; }
                field("Enable Vendor Performance"; Rec."Enable Vendor Performance") { ApplicationArea = All; }
                field("Enable Digital Signatures"; Rec."Enable Digital Signatures") { ApplicationArea = All; }
                field("Enable Auto Disqualification"; Rec."Enable Auto Disqualification") { ApplicationArea = All; }
                field("Enable Rate Contracts"; Rec."Enable Rate Contracts") { ApplicationArea = All; }
            }
            group(Approval)
            {
                Caption = 'Approval';
                field("Tender Approval Workflow Code"; Rec."Tender Approval Workflow Code") { ApplicationArea = All; }
                field("Negotiation Approval WF Code"; Rec."Negotiation Approval WF Code") { ApplicationArea = All; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}

// ============================================================
// Page 50101: Tender List
// ============================================================
page 50101 "Tender List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Tender Header";
    Caption = 'Tenders';
    CardPageId = "Tender Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Source Module"; Rec."Source Module") { ApplicationArea = All; }
                field("Source ID"; Rec."Source ID") { ApplicationArea = All; }
                field("Item Type"; Rec."Item Type") { ApplicationArea = All; }
                field("Tender Type"; Rec."Tender Type") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Bid End Date"; Rec."Bid End Date") { ApplicationArea = All; }
                field("Created Date"; Rec."Created Date") { ApplicationArea = All; }
                field("Created By User ID"; Rec."Created By User ID") { ApplicationArea = All; }
            }
        }
    }
}

// ============================================================
// Page 50102: Tender Card
// ============================================================
page 50102 "Tender Card"
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "Tender Header";
    Caption = 'Tender Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        if Rec.AssistEdit(xRec) then
                            CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(DetailedDescriptionText; DetailedDescText)
                {
                    ApplicationArea = All;
                    Caption = 'Detailed Description';
                    MultiLine = true;

                    trigger OnValidate()
                    begin
                        Rec.SetDetailedDescription(DetailedDescText);
                    end;
                }
                field("Source Module"; Rec."Source Module") { ApplicationArea = All; }
                field("Source Type"; Rec."Source Type") { ApplicationArea = All; }
                field("Source ID"; Rec."Source ID") { ApplicationArea = All; }
                field("Item Type"; Rec."Item Type") { ApplicationArea = All; }
                field("Tender Type"; Rec."Tender Type") { ApplicationArea = All; }
                field("Work Type"; Rec."Work Type") { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StatusStyle;
                }
                field("Budget Amount"; Rec."Budget Amount") { ApplicationArea = All; Editable = false; }
                field("Business Unit Code"; Rec."Business Unit Code") { ApplicationArea = All; Editable = false; }
                field("Sanction No."; Rec."Sanction No.") { ApplicationArea = All; Editable = false; }
            }
            group(Dates)
            {
                Caption = 'Dates';
                field("Created Date"; Rec."Created Date") { ApplicationArea = All; }
                field("Bid Start Date"; Rec."Bid Start Date") { ApplicationArea = All; }
                field("Bid End Date"; Rec."Bid End Date") { ApplicationArea = All; }
                field("Bid Validity Date"; Rec."Bid Validity Date") { ApplicationArea = All; }
            }
            group(NegotiationGrp)
            {
                Caption = 'Negotiation';
                field("Negotiate Date"; Rec."Negotiate Date") { ApplicationArea = All; }
                field("Negotiate Place"; Rec."Negotiate Place") { ApplicationArea = All; }
                field("Allocated Engineer"; Rec."Allocated Engineer") { ApplicationArea = All; }
            }
            group(ReverseAuctionGrp)
            {
                Caption = 'Reverse Auction';
                Visible = Rec."Reverse Auction Enabled";

                field("Reverse Auction Enabled"; Rec."Reverse Auction Enabled") { ApplicationArea = All; }
                field("Current Auction Round"; Rec."Current Auction Round") { ApplicationArea = All; }
                field("Auction Status"; Rec."Auction Status") { ApplicationArea = All; }
            }
            group(DigitalSignature)
            {
                Caption = 'Digital Signature';
                field("Signed By"; Rec."Signed By") { ApplicationArea = All; }
                field("Signed Date"; Rec."Signed Date") { ApplicationArea = All; }
                field("Signature Status"; Rec."Signature Status") { ApplicationArea = All; }
            }
            group(OrderDetails)
            {
                Caption = 'Order Details';
                Visible = (Rec.Status = Rec.Status::"Order Created") or (Rec.Status = Rec.Status::Closed);

                field("Created Order No."; Rec."Created Order No.") { ApplicationArea = All; }
                field("Created Order Doc Type"; Rec."Created Order Doc Type") { ApplicationArea = All; }
            }
            group(RateContractGrp)
            {
                Caption = 'Rate Contract';
                Visible = Rec."Tender Type" = Rec."Tender Type"::"Rate Contract";

                field("Rate Contract Valid From"; Rec."Rate Contract Valid From") { ApplicationArea = All; }
                field("Rate Contract Valid To"; Rec."Rate Contract Valid To") { ApplicationArea = All; }
                field("Rate Contract Ceiling Amount"; Rec."Rate Contract Ceiling Amount") { ApplicationArea = All; }
            }
            part(TenderLines; "Tender Lines Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "Tender No." = field("No.");
                UpdatePropagation = Both;
            }
        }
        area(FactBoxes)
        {
            part(TenderStatistics; "Tender Statistics FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Process)
            {
                Caption = 'Process';

                action(AllocateVendors)
                {
                    ApplicationArea = All;
                    Caption = 'Allocate Vendors';
                    Image = Allocate;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        VendorAllocPage: Page "Tender Vendor Allocation";
                    begin
                        VendorAllocPage.SetTenderNo(Rec."No.");
                        VendorAllocPage.RunModal();
                    end;
                }
                action(SendForApproval)
                {
                    ApplicationArea = All;
                    Caption = 'Send for Approval';
                    Image = SendApprovalRequest;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                        IsHandled: Boolean;
                        EventPub: Codeunit "Tender Event Publishers";
                    begin
                        EventPub.OnBeforeTenderApproval(Rec, IsHandled);
                        if not IsHandled then begin
                            TenderMgt.UpdateStatus(Rec, Rec.Status::"Pending Approval");
                            // In real implementation, trigger BC approval workflow here
                            Message('Tender sent for approval.');
                        end;
                    end;
                }
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                        EventPub: Codeunit "Tender Event Publishers";
                    begin
                        TenderMgt.UpdateStatus(Rec, Rec.Status::Approved);
                        EventPub.OnAfterTenderApproved(Rec);
                        Message('Tender approved.');
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                        EventPub: Codeunit "Tender Event Publishers";
                    begin
                        Rec.Status := Rec.Status::Rejected;
                        Rec.Modify(true);
                        EventPub.OnAfterTenderRejected(Rec);
                        Message('Tender rejected.');
                    end;
                }
                action(CreateQuotes)
                {
                    ApplicationArea = All;
                    Caption = 'Create Quotes';
                    Image = CreateDocument;
                    Promoted = true;
                    PromotedCategory = Process;
                    Enabled = Rec.Status = Rec.Status::Approved;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.CreateQuotesForAllVendors(Rec);
                        Message('Quotes created for all allocated vendors.');
                    end;
                }
                action(OpenBidding)
                {
                    ApplicationArea = All;
                    Caption = 'Open Bidding';
                    Image = Open;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.UpdateStatus(Rec, Rec.Status::"Bidding Open");
                        Message('Bidding is now open.');
                    end;
                }
                action(CloseBidding)
                {
                    ApplicationArea = All;
                    Caption = 'Close Bidding';
                    Image = Close;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.UpdateStatus(Rec, Rec.Status::"Bidding Closed");
                        Message('Bidding is now closed.');
                    end;
                }
                action(IssueCorrigendum)
                {
                    ApplicationArea = All;
                    Caption = 'Issue Corrigendum';
                    Image = Change;
                    Enabled = Rec.Status = Rec.Status::"Bidding Open";

                    trigger OnAction()
                    var
                        CorrigendumMgt: Codeunit "Tender Corrigendum Mgt.";
                        ChangesType: Enum "Corrigendum Changes Type";
                    begin
                        // Simplified - in production use a dialog page
                        ChangesType := ChangesType::Both;
                        CorrigendumMgt.CreateCorrigendum(Rec, ChangesType);
                        Message('Corrigendum issued.');
                    end;
                }
                action(StartReverseAuction)
                {
                    ApplicationArea = All;
                    Caption = 'Start Reverse Auction';
                    Image = Start;
                    Enabled = Rec.Status = Rec.Status::"Bidding Closed";

                    trigger OnAction()
                    var
                        AuctionMgt: Codeunit "Tender Reverse Auction Mgt.";
                    begin
                        AuctionMgt.InitializeAuction(Rec);
                        Message('Reverse auction initialized.');
                    end;
                }
                action(SelectVendor)
                {
                    ApplicationArea = All;
                    Caption = 'Select Vendor';
                    Image = SelectEntries;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        PAGE.RunModal(PAGE::"Tender Vendor Allocation");
                    end;
                }
                action(SendToNegotiation)
                {
                    ApplicationArea = All;
                    Caption = 'Send to Negotiation';
                    Image = SendTo;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.UpdateStatus(Rec, Rec.Status::Negotiation);
                        Message('Tender sent to negotiation committee.');
                    end;
                }
                action(ApproveNegotiation)
                {
                    ApplicationArea = All;
                    Caption = 'Approve Negotiation';
                    Image = Approve;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                        EventPub: Codeunit "Tender Event Publishers";
                    begin
                        TenderMgt.UpdateStatus(Rec, Rec.Status::"Negotiation Approved");
                        EventPub.OnAfterNegotiationApproved(Rec);
                        Message('Negotiation approved.');
                    end;
                }
                action(ImportAmendedBOQ)
                {
                    ApplicationArea = All;
                    Caption = 'Import Amended BOQ';
                    Image = Import;
                    Enabled = Rec.Status = Rec.Status::Negotiation;

                    trigger OnAction()
                    var
                        ImportExport: Codeunit "Tender Import Export";
                    begin
                        ImportExport.ImportAmendedBOQ(Rec."No.");
                    end;
                }
                action(CreatePurchaseOrder)
                {
                    ApplicationArea = All;
                    Caption = 'Create Purchase Order';
                    Image = CreateDocument;
                    Promoted = true;
                    PromotedCategory = Process;
                    Enabled = (Rec."Item Type" = Rec."Item Type"::HSN) and
                              (Rec.Status = Rec.Status::"Negotiation Approved");

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.CreatePurchaseOrder(Rec);
                        Message('Purchase Order %1 created.', Rec."Created Order No.");
                    end;
                }
                action(CreateWorkOrder)
                {
                    ApplicationArea = All;
                    Caption = 'Create Work Order';
                    Image = CreateDocument;
                    Promoted = true;
                    PromotedCategory = Process;
                    Enabled = (Rec."Item Type" = Rec."Item Type"::SAC) and
                              (Rec.Status = Rec.Status::"Negotiation Approved");

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.CreateWorkOrder(Rec);
                        Message('Work Order %1 created.', Rec."Created Order No.");
                    end;
                }
                action(ReTender)
                {
                    ApplicationArea = All;
                    Caption = 'Re-Tender';
                    Image = Redo;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        if Confirm('Are you sure you want to re-tender? This will archive the current tender and create a new one.') then begin
                            TenderMgt.ReTender(Rec);
                            Message('Re-tender created.');
                        end;
                    end;
                }
                action(CloseTender)
                {
                    ApplicationArea = All;
                    Caption = 'Close Tender';
                    Image = Close;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.CloseTender(Rec);
                        Message('Tender closed.');
                    end;
                }
                action(ArchiveTender)
                {
                    ApplicationArea = All;
                    Caption = 'Archive Tender';
                    Image = Archive;

                    trigger OnAction()
                    var
                        ArchiveMgt: Codeunit "Tender Archive Management";
                    begin
                        ArchiveMgt.ArchiveTender(Rec, "Tender Archive Reason"::Manual);
                        Message('Tender archived.');
                    end;
                }
                action(DownloadSACTemplate)
                {
                    ApplicationArea = All;
                    Caption = 'Download SAC BOQ Template';
                    Image = ExportFile;
                    Visible = Rec."Item Type" = Rec."Item Type"::SAC;

                    trigger OnAction()
                    var
                        ImportExport: Codeunit "Tender Import Export";
                    begin
                        ImportExport.ExportBOQTemplate_SAC();
                    end;
                }
                action(DownloadHSNTemplate)
                {
                    ApplicationArea = All;
                    Caption = 'Download HSN BOQ Template';
                    Image = ExportFile;
                    Visible = Rec."Item Type" = Rec."Item Type"::HSN;

                    trigger OnAction()
                    var
                        ImportExport: Codeunit "Tender Import Export";
                    begin
                        ImportExport.ExportBOQTemplate_HSN();
                    end;
                }
            }
        }
        area(Navigation)
        {
            group(Navigate)
            {
                Caption = 'Navigate';

                action(Quotes)
                {
                    ApplicationArea = All;
                    Caption = 'Quotes';
                    Image = Quote;
                    RunObject = page "Purchase Quotes";
                    RunPageLink = "Tender No." = field("No.");
                }
                action(Vendors)
                {
                    ApplicationArea = All;
                    Caption = 'Vendors';
                    Image = Vendor;

                    trigger OnAction()
                    var
                        VendorAllocPage: Page "Tender Vendor Allocation";
                    begin
                        VendorAllocPage.SetTenderNo(Rec."No.");
                        VendorAllocPage.RunModal();
                    end;
                }
                action(Corrigendums)
                {
                    ApplicationArea = All;
                    Caption = 'Corrigendums';
                    Image = Change;
                    RunObject = page "Tender Corrigendum List";
                    RunPageLink = "Tender No." = field("No.");
                }
                action(Archives)
                {
                    ApplicationArea = All;
                    Caption = 'Archive Versions';
                    Image = Archive;
                    RunObject = page "Tender Archive List";
                    RunPageLink = "Tender No." = field("No.");
                }
                action(AuctionRounds)
                {
                    ApplicationArea = All;
                    Caption = 'Auction Rounds';
                    Image = Lot;
                    RunObject = page "Reverse Auction Rounds";
                    RunPageLink = "Tender No." = field("No.");
                }
                action(DisqualificationRules)
                {
                    ApplicationArea = All;
                    Caption = 'Disqualification Rules';
                    Image = CheckRulesSyntax;
                    RunObject = page "Tender Disqual. Rules";
                    RunPageLink = "Tender No." = field("No.");
                }
                action(SignatureLog)
                {
                    ApplicationArea = All;
                    Caption = 'Signature Log';
                    Image = Log;
                    RunObject = page "Tender Signature Log";
                    RunPageLink = "Tender No." = field("No.");
                }
            }
        }
    }

    var
        DetailedDescText: Text;
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        DetailedDescText := Rec.GetDetailedDescription();
        SetStatusStyle();
    end;

    local procedure SetStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Draft, Rec.Status::Rejected:
                StatusStyle := 'Subordinate';
            Rec.Status::"Pending Approval", Rec.Status::Negotiation:
                StatusStyle := 'Ambiguous';
            Rec.Status::Approved, Rec.Status::"Negotiation Approved":
                StatusStyle := 'Favorable';
            Rec.Status::"Order Created", Rec.Status::Closed:
                StatusStyle := 'Strong';
            else
                StatusStyle := 'Standard';
        end;
    end;
}

// ============================================================
// Page 50103: Tender Lines Subpage
// ============================================================
page 50103 "Tender Lines Subpage"
{
    PageType = ListPart;
    SourceTable = "Tender Line";
    Caption = 'Tender Lines';
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = ShortDescriptionField;
                ShowAsTree = true;

                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("BOQ Serial No."; Rec."BOQ Serial No.")
                {
                    ApplicationArea = All;
                    Visible = IsSAC;
                    Editable = false;
                }
                field("Line Type"; Rec."Line Type")
                {
                    ApplicationArea = All;
                    Visible = IsSAC;
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Visible = IsHSN;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Visible = IsHSN;
                }
                field(ShortDescriptionField; Rec."Short Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Visible = IsSAC;
                    StyleExpr = LineStyleExpr;
                    Editable = false;
                    Width = 50;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = not Rec.IsHeadingLine();
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = not Rec.IsHeadingLine();

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    Editable = not Rec.IsHeadingLine();

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                }
                field("HSN SAC Code"; Rec."HSN SAC Code")
                {
                    ApplicationArea = All;
                    Visible = IsHSN;
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = All;
                    Visible = IsHSN;
                }
            }
            group(DescriptionDetail)
            {
                Caption = 'Full Description';
                Visible = IsSAC;

                field(FullDescriptionText; FullDescText)
                {
                    ApplicationArea = All;
                    Caption = 'Full Description';
                    MultiLine = true;
                    Editable = false;
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportBOQ)
            {
                ApplicationArea = All;
                Caption = 'Import BOQ from Excel';
                Image = Import;

                trigger OnAction()
                var
                    ImportExport: Codeunit "Tender Import Export";
                    TenderHeader: Record "Tender Header";
                begin
                    TenderHeader.Get(Rec."Tender No.");
                    case TenderHeader."Item Type" of
                        TenderHeader."Item Type"::HSN:
                            ImportExport.ImportBOQ_HSN(Rec."Tender No.");
                        TenderHeader."Item Type"::SAC:
                            ImportExport.ImportBOQ_SAC(Rec."Tender No.");
                        else
                            Error('Please select Item Type (HSN or SAC) on the Tender Header first.');
                    end;
                    CurrPage.Update(false);
                end;
            }
            action(DeleteLine)
            {
                ApplicationArea = All;
                Caption = 'Delete Line';
                Image = Delete;

                trigger OnAction()
                begin
                    Rec.Delete(true);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        IsHSN: Boolean;
        IsSAC: Boolean;
        FullDescText: Text;
        LineStyleExpr: Text;
        ParentItemType: Enum "Tender Item Type";

    trigger OnAfterGetRecord()
    begin
        UpdateVisibility();
        LineStyleExpr := Rec.Style;
        if IsSAC then
            FullDescText := Rec.GetDescriptionBlob()
        else
            FullDescText := '';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateVisibility();
        if IsSAC then
            FullDescText := Rec.GetDescriptionBlob()
        else
            FullDescText := '';
    end;

    local procedure UpdateVisibility()
    var
        TenderHeader: Record "Tender Header";
    begin
        if TenderHeader.Get(Rec."Tender No.") then
            ParentItemType := TenderHeader."Item Type";
        IsHSN := ParentItemType = ParentItemType::HSN;
        IsSAC := ParentItemType = ParentItemType::SAC;
    end;
}

// ============================================================
// Page 50104: Tender Vendor Allocation
// ============================================================
page 50104 "Tender Vendor Allocation"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Tender Vendor Allocation";
    Caption = 'Tender Vendor Allocation';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; Editable = false; }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Vendor Name"; Rec."Vendor Name") { ApplicationArea = All; }
                field("Contact Person"; Rec."Contact Person") { ApplicationArea = All; }
                field(Email; Rec.Email) { ApplicationArea = All; }
                field("Currency Code"; Rec."Currency Code") { ApplicationArea = All; }
                field("Quote No."; Rec."Quote No.") { ApplicationArea = All; }
                field("Quote Status"; Rec."Quote Status") { ApplicationArea = All; }
                field("Is Selected Vendor"; Rec."Is Selected Vendor") { ApplicationArea = All; }
                field("Disqualification Reason"; Rec."Disqualification Reason") { ApplicationArea = All; }
                field("Allocated Date"; Rec."Allocated Date") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(AddVendor)
            {
                ApplicationArea = All;
                Caption = 'Add Vendor';
                Image = Add;

                trigger OnAction()
                var
                    TenderMgt: Codeunit "Tender Management";
                    VendorList: Page "Vendor List";
                    Vendor: Record Vendor;
                begin
                    VendorList.LookupMode(true);
                    if VendorList.RunModal() = Action::LookupOK then begin
                        VendorList.GetRecord(Vendor);
                        TenderMgt.AllocateVendor(TenderNoFilter, Vendor."No.");
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(RemoveVendor)
            {
                ApplicationArea = All;
                Caption = 'Remove Vendor';
                Image = Delete;

                trigger OnAction()
                var
                    TenderMgt: Codeunit "Tender Management";
                begin
                    TenderMgt.RemoveVendor(Rec."Tender No.", Rec."Vendor No.");
                    CurrPage.Update(false);
                end;
            }
            action(DisqualifyVendor)
            {
                ApplicationArea = All;
                Caption = 'Disqualify Vendor';
                Image = Cancel;

                trigger OnAction()
                var
                    Reason: Text[250];
                begin
                    Reason := '';
                    if PAGE.RunModal(0) = Action::LookupOK then begin
                        Rec."Quote Status" := Rec."Quote Status"::Disqualified;
                        Rec."Disqualification Reason" := 'Manually disqualified';
                        Rec.Modify();
                    end;
                end;
            }
            action(RunAutoDisqualification)
            {
                ApplicationArea = All;
                Caption = 'Auto-Check Rules';
                Image = CheckRulesSyntax;

                trigger OnAction()
                var
                    DisqualEngine: Codeunit "Tender Disqualification Engine";
                begin
                    DisqualEngine.RunAutoDisqualification(TenderNoFilter);
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        TenderNoFilter: Code[20];

    procedure SetTenderNo(TenderNo: Code[20])
    begin
        TenderNoFilter := TenderNo;
        Rec.SetRange("Tender No.", TenderNo);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Tender No." := TenderNoFilter;
    end;
}

// ============================================================
// Page 50105: Tender Statistics FactBox
// ============================================================
page 50105 "Tender Statistics FactBox"
{
    PageType = CardPart;
    SourceTable = "Tender Header";
    Caption = 'Tender Statistics';

    layout
    {
        area(Content)
        {
            field(NoOfVendors; TenderMgt.GetNoOfVendors(Rec."No."))
            {
                ApplicationArea = All;
                Caption = 'No. of Vendors';
                DrillDown = false;
            }
            field(NoOfQuotes; TenderMgt.GetNoOfQuotes(Rec."No."))
            {
                ApplicationArea = All;
                Caption = 'No. of Quotes';
                DrillDown = false;
            }
            field(NoOfLines; TenderMgt.GetNoOfLines(Rec."No."))
            {
                ApplicationArea = All;
                Caption = 'No. of Lines';
                DrillDown = false;
            }
            field(TotalAmount; TenderMgt.CalculateTenderTotal(Rec."No."))
            {
                ApplicationArea = All;
                Caption = 'Total Tender Amount';
                DrillDown = false;
            }
            field(NoOfArchives; TenderMgt.GetNoOfArchives(Rec."No."))
            {
                ApplicationArea = All;
                Caption = 'Archive Versions';
                DrillDown = false;
            }
            field(NoOfCorrigendums; TenderMgt.GetNoOfCorrigendums(Rec."No."))
            {
                ApplicationArea = All;
                Caption = 'Corrigendums';
                DrillDown = false;
            }
        }
    }

    var
        TenderMgt: Codeunit "Tender Management";
}

// ============================================================
// Page 50106: Tender Corrigendum List
// ============================================================
page 50106 "Tender Corrigendum List"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Tender Corrigendum";
    Caption = 'Tender Corrigendums';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field("Corrigendum No."; Rec."Corrigendum No.") { ApplicationArea = All; }
                field("Issue Date"; Rec."Issue Date") { ApplicationArea = All; }
                field("Changes Type"; Rec."Changes Type") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("BOQ Re-Imported"; Rec."BOQ Re-Imported") { ApplicationArea = All; }
                field("New Bid End Date"; Rec."New Bid End Date") { ApplicationArea = All; }
                field("Vendors Notified"; Rec."Vendors Notified") { ApplicationArea = All; }
                field("Issued By User ID"; Rec."Issued By User ID") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NotifyVendors)
            {
                ApplicationArea = All;
                Caption = 'Notify Vendors';
                Image = SendMail;

                trigger OnAction()
                var
                    CorrigendumMgt: Codeunit "Tender Corrigendum Mgt.";
                begin
                    CorrigendumMgt.NotifyVendors(Rec);
                    Message('Vendors notified.');
                end;
            }
        }
    }
}

// ============================================================
// Page 50107: Tender Archive List
// ============================================================
page 50107 "Tender Archive List"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Tender Header Archive";
    Caption = 'Tender Archive Versions';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field("Version No."; Rec."Version No.") { ApplicationArea = All; }
                field("Archive Reason"; Rec."Archive Reason") { ApplicationArea = All; }
                field("Archived DateTime"; Rec."Archived DateTime") { ApplicationArea = All; }
                field("Archived By User ID"; Rec."Archived By User ID") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RestoreVersion)
            {
                ApplicationArea = All;
                Caption = 'Restore This Version';
                Image = Restore;

                trigger OnAction()
                var
                    ArchiveMgt: Codeunit "Tender Archive Management";
                begin
                    if Confirm('Are you sure you want to restore version %1? Current data will be archived first.', true, Rec."Version No.") then begin
                        ArchiveMgt.RestoreFromArchive(Rec."Tender No.", Rec."Version No.");
                        Message('Version %1 restored.', Rec."Version No.");
                    end;
                end;
            }
        }
    }
}

// ============================================================
// Page 50108: Reverse Auction Rounds
// ============================================================
page 50108 "Reverse Auction Rounds"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Reverse Auction Round";
    Caption = 'Reverse Auction Rounds';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field("Round No."; Rec."Round No.") { ApplicationArea = All; }
                field("Round Start DateTime"; Rec."Round Start DateTime") { ApplicationArea = All; }
                field("Round End DateTime"; Rec."Round End DateTime") { ApplicationArea = All; }
                field("Time Limit Minutes"; Rec."Time Limit Minutes") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
                field(Remarks; Rec.Remarks) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateRound)
            {
                ApplicationArea = All;
                Caption = 'Create New Round';
                Image = New;

                trigger OnAction()
                var
                    AuctionMgt: Codeunit "Tender Reverse Auction Mgt.";
                begin
                    AuctionMgt.CreateNewRound(Rec."Tender No.");
                    CurrPage.Update(false);
                end;
            }
            action(OpenRound)
            {
                ApplicationArea = All;
                Caption = 'Open Round';
                Image = Open;

                trigger OnAction()
                var
                    AuctionMgt: Codeunit "Tender Reverse Auction Mgt.";
                begin
                    AuctionMgt.OpenRound(Rec."Tender No.", Rec."Round No.");
                    CurrPage.Update(false);
                end;
            }
            action(CloseRound)
            {
                ApplicationArea = All;
                Caption = 'Close Round';
                Image = Close;

                trigger OnAction()
                var
                    AuctionMgt: Codeunit "Tender Reverse Auction Mgt.";
                begin
                    AuctionMgt.CloseRound(Rec."Tender No.", Rec."Round No.");
                    CurrPage.Update(false);
                end;
            }
            action(ViewEntries)
            {
                ApplicationArea = All;
                Caption = 'View Entries';
                Image = Entries;
                RunObject = page "Reverse Auction Entries";
                RunPageLink = "Tender No." = field("Tender No."), "Round No." = field("Round No.");
            }
            action(FinalizeAuction)
            {
                ApplicationArea = All;
                Caption = 'Finalize Auction';
                Image = Approve;

                trigger OnAction()
                var
                    AuctionMgt: Codeunit "Tender Reverse Auction Mgt.";
                    TenderHeader: Record "Tender Header";
                begin
                    TenderHeader.Get(Rec."Tender No.");
                    AuctionMgt.FinalizeAuction(TenderHeader);
                    Message('Auction finalized. Quotes updated with final prices.');
                end;
            }
        }
    }
}

// ============================================================
// Page 50109: Reverse Auction Entries
// ============================================================
page 50109 "Reverse Auction Entries"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Reverse Auction Entry";
    Caption = 'Reverse Auction Entries';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field("Line No."; Rec."Line No.") { ApplicationArea = All; }
                field("Previous Unit Cost"; Rec."Previous Unit Cost") { ApplicationArea = All; }
                field("New Unit Cost"; Rec."New Unit Cost") { ApplicationArea = All; }
                field("Decrement Percentage"; Rec."Decrement Percentage") { ApplicationArea = All; }
                field("Decrement Amount"; Rec."Decrement Amount") { ApplicationArea = All; }
                field("Is Valid Entry"; Rec."Is Valid Entry") { ApplicationArea = All; }
                field(Rank; Rec.Rank) { ApplicationArea = All; }
                field("Submitted DateTime"; Rec."Submitted DateTime") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SubmitBid)
            {
                ApplicationArea = All;
                Caption = 'Submit Bid';
                Image = Approve;

                trigger OnAction()
                var
                    AuctionMgt: Codeunit "Tender Reverse Auction Mgt.";
                begin
                    AuctionMgt.ValidateBidDecrement(Rec);
                    Rec."Submitted DateTime" := CurrentDateTime;
                    Rec."Is Valid Entry" := true;
                    Rec.Modify(true);
                    Message('Bid submitted successfully.');
                end;
            }
            action(CalculateRankings)
            {
                ApplicationArea = All;
                Caption = 'Calculate Rankings';
                Image = CalculateLines;

                trigger OnAction()
                var
                    AuctionMgt: Codeunit "Tender Reverse Auction Mgt.";
                begin
                    AuctionMgt.CalculateRankings(Rec."Tender No.", Rec."Round No.");
                    CurrPage.Update(false);
                    Message('Rankings calculated.');
                end;
            }
        }
    }
}

// ============================================================
// Page 50110: Vendor Performance Rating
// ============================================================
page 50110 "Vendor Performance Rating"
{
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Vendor Performance Rating";
    Caption = 'Vendor Performance Rating';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field("Order No."; Rec."Order No.") { ApplicationArea = All; }
                field("Order Document Type"; Rec."Order Document Type") { ApplicationArea = All; }
                field("Completion Date"; Rec."Completion Date") { ApplicationArea = All; }
            }
            group(Ratings)
            {
                Caption = 'Ratings';
                field("Quality Rating"; Rec."Quality Rating")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec.CalculateOverallRating();
                    end;
                }
                field("Timeliness Rating"; Rec."Timeliness Rating")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec.CalculateOverallRating();
                    end;
                }
                field("Compliance Rating"; Rec."Compliance Rating")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec.CalculateOverallRating();
                    end;
                }
                field("Communication Rating"; Rec."Communication Rating")
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        Rec.CalculateOverallRating();
                    end;
                }
                field("Overall Rating"; Rec."Overall Rating")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Style = Strong;
                }
            }
            group(Feedback)
            {
                Caption = 'Feedback';
                field(Comments; Rec.Comments) { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SubmitRating)
            {
                ApplicationArea = All;
                Caption = 'Submit Rating';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    EventPub: Codeunit "Tender Event Publishers";
                    IsHandled: Boolean;
                begin
                    EventPub.OnBeforePerformanceSubmitted(Rec, IsHandled);
                    if not IsHandled then begin
                        Rec.Status := Rec.Status::Submitted;
                        Rec."Rated By User ID" := CopyStr(UserId, 1, 50);
                        Rec."Rated DateTime" := CurrentDateTime;
                        Rec.Modify(true);
                        EventPub.OnAfterPerformanceSubmitted(Rec);
                        Message('Performance rating submitted.');
                    end;
                end;
            }
        }
    }
}

// ============================================================
// Page 50111: Tender Disqualification Rules
// ============================================================
page 50111 "Tender Disqual. Rules"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Tender Disqualification Rule";
    Caption = 'Tender Disqualification Rules';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field("Rule No."; Rec."Rule No.") { ApplicationArea = All; }
                field("Rule Type"; Rec."Rule Type") { ApplicationArea = All; }
                field("Rule Description"; Rec."Rule Description") { ApplicationArea = All; }
                field(Mandatory; Rec.Mandatory) { ApplicationArea = All; }
                field("Min Value"; Rec."Min Value") { ApplicationArea = All; }
                field("Required Text"; Rec."Required Text") { ApplicationArea = All; }
                field(Active; Rec.Active) { ApplicationArea = All; }
            }
        }
    }
}

// ============================================================
// Page 50112: Tender Signature Log
// ============================================================
page 50112 "Tender Signature Log"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Tender Digi. Signature Log";
    Caption = 'Tender Digital Signature Log';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field(Stage; Rec.Stage) { ApplicationArea = All; }
                field(Action; Rec.Action) { ApplicationArea = All; }
                field("Requested By User ID"; Rec."Requested By User ID") { ApplicationArea = All; }
                field("Requested DateTime"; Rec."Requested DateTime") { ApplicationArea = All; }
                field("Signed By User ID"; Rec."Signed By User ID") { ApplicationArea = All; }
                field("Signed DateTime"; Rec."Signed DateTime") { ApplicationArea = All; }
                field("Signature Reference"; Rec."Signature Reference") { ApplicationArea = All; }
                field(Remarks; Rec.Remarks) { ApplicationArea = All; }
            }
        }
    }
}

// ============================================================
// Page 50113: Tender Dashboard Cues
// ============================================================
page 50113 "Tender Dashboard Cues"
{
    PageType = CardPart;
    Caption = 'Tender Activities';

    layout
    {
        area(Content)
        {
            cuegroup(TenderCues)
            {
                Caption = 'Tenders';

                field(DraftTenders; GetTenderCount("Tender Status"::Draft))
                {
                    ApplicationArea = All;
                    Caption = 'Draft';
                    DrillDownPageId = "Tender List";
                }
                field(PendingApproval; GetTenderCount("Tender Status"::"Pending Approval"))
                {
                    ApplicationArea = All;
                    Caption = 'Pending Approval';
                    DrillDownPageId = "Tender List";
                }
                field(BiddingOpen; GetTenderCount("Tender Status"::"Bidding Open"))
                {
                    ApplicationArea = All;
                    Caption = 'Bidding Open';
                    DrillDownPageId = "Tender List";
                }
                field(UnderEvaluation; GetTenderCount("Tender Status"::"Under Evaluation"))
                {
                    ApplicationArea = All;
                    Caption = 'Under Evaluation';
                    DrillDownPageId = "Tender List";
                }
                field(InNegotiation; GetTenderCount("Tender Status"::Negotiation))
                {
                    ApplicationArea = All;
                    Caption = 'In Negotiation';
                    DrillDownPageId = "Tender List";
                }
            }
        }
    }

    local procedure GetTenderCount(StatusFilter: Enum "Tender Status"): Integer
    var
        TenderHeader: Record "Tender Header";
    begin
        TenderHeader.SetRange(Status, StatusFilter);
        exit(TenderHeader.Count);
    end;
}

// ============================================================
// Page 50114: Questionnaire Response
// ============================================================
page 50114 "Tender Quest. Response"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Tender Quest. Response";
    Caption = 'Questionnaire Responses';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field("Question No."; Rec."Question No.") { ApplicationArea = All; }
                field("Question Text"; Rec."Question Text") { ApplicationArea = All; }
                field("Answer Text"; Rec."Answer Text") { ApplicationArea = All; }
                field("Answer Number"; Rec."Answer Number") { ApplicationArea = All; }
                field("Answer Boolean"; Rec."Answer Boolean") { ApplicationArea = All; }
                field("Answer Date"; Rec."Answer Date") { ApplicationArea = All; }
                field(Score; Rec.Score) { ApplicationArea = All; }
                field("Meets Requirement"; Rec."Meets Requirement") { ApplicationArea = All; }
            }
        }
    }
}

// ============================================================
// Page 50115: Work Order List
// ============================================================
page 50115 "Work Order List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Purchase Header";
    SourceTableView = where("Document Type" = const("Work Order"));
    Caption = 'Work Orders';
    CardPageId = "Work Order Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.") { ApplicationArea = All; }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name") { ApplicationArea = All; }
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field("Order Date"; Rec."Order Date") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
        }
    }
}

// ============================================================
// Page 50116: Work Order Card
// ============================================================
page 50116 "Work Order Card"
{
    PageType = Document;
    ApplicationArea = All;
    SourceTable = "Purchase Header";
    SourceTableView = where("Document Type" = const("Work Order"));
    Caption = 'Work Order';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.") { ApplicationArea = All; }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.") { ApplicationArea = All; }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name") { ApplicationArea = All; }
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field("Source Module"; Rec."Source Module") { ApplicationArea = All; }
                field("Source ID"; Rec."Source ID") { ApplicationArea = All; }
                field("Tender Item Type"; Rec."Tender Item Type") { ApplicationArea = All; }
                field("Order Date"; Rec."Order Date") { ApplicationArea = All; }
                field(Status; Rec.Status) { ApplicationArea = All; }
            }
            part(Lines; "Work Order Lines Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "Document Type" = const("Work Order"),
                              "Document No." = field("No.");
            }
        }
    }
}

// ============================================================
// Page 50117: Work Order Lines Subpage
// ============================================================
page 50117 "Work Order Lines Subpage"
{
    PageType = ListPart;
    SourceTable = "Purchase Line";
    SourceTableView = where("Document Type" = const("Work Order"));
    Caption = 'Work Order Lines';

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = ShortDescField;
                ShowAsTree = true;

                field("BOQ Serial No."; Rec."BOQ Serial No.") { ApplicationArea = All; }
                field("Line Type"; Rec."Line Type") { ApplicationArea = All; }
                field(ShortDescField; Rec."Short Description")
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    StyleExpr = Rec.Style;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { ApplicationArea = All; }
                field(Quantity; Rec.Quantity) { ApplicationArea = All; }
                field("Direct Unit Cost"; Rec."Direct Unit Cost") { ApplicationArea = All; }
                field("Line Amount"; Rec."Line Amount") { ApplicationArea = All; }
            }
        }
    }
}

// ============================================================
// Page 50118: Rate Contract Usage List
// ============================================================
page 50118 "Rate Contract Usage List"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Rate Contract Usage";
    Caption = 'Rate Contract Usage';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { ApplicationArea = All; }
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field("Tender Line No."; Rec."Tender Line No.") { ApplicationArea = All; }
                field("Purchase Order No."; Rec."Purchase Order No.") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Quantity Ordered"; Rec."Quantity Ordered") { ApplicationArea = All; }
                field("Unit Cost"; Rec."Unit Cost") { ApplicationArea = All; }
                field("Line Amount"; Rec."Line Amount") { ApplicationArea = All; }
                field("Order Date"; Rec."Order Date") { ApplicationArea = All; }
            }
        }
    }
}