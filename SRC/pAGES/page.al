// ============================================================
// Page 50100 - Tender Setup
// Purpose: Single-record configuration page.
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
                Caption = 'Feature Toggles';
                field("Enable NIT Publishing"; Rec."Enable NIT Publishing") { ApplicationArea = All; }
                field("Enable Reverse Auction"; Rec."Enable Reverse Auction") { ApplicationArea = All; }
                field("Enable Vendor Performance"; Rec."Enable Vendor Performance") { ApplicationArea = All; }
                field("Enable Digital Signatures"; Rec."Enable Digital Signatures") { ApplicationArea = All; }
                field("Enable Auto-Disqualification"; Rec."Enable Auto-Disqualification") { ApplicationArea = All; }
                field("Enable Rate Contracts"; Rec."Enable Rate Contracts") { ApplicationArea = All; }
            }
            group(Approvals)
            {
                Caption = 'Approval';
                field("Tender Approval Workflow Code"; Rec."Tender Approval Workflow Code") { ApplicationArea = All; }
                field("Negot. Approval Workflow Code"; Rec."Negot. Approval Workflow Code") { ApplicationArea = All; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}

// ============================================================
// Page 50101 - Tender List
// Purpose: Shows all tenders with filters and key columns.
// ============================================================
page 50101 "Tender List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Tender Header";
    Caption = 'Tender List';
    CardPageId = "Tender Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
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
        area(FactBoxes)
        {
            systempart(Notes; Notes) { ApplicationArea = All; }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewTender)
            {
                Caption = 'New Tender';
                ApplicationArea = All;
                Image = NewDocument;
                RunObject = page "Tender Card";
                RunPageMode = Create;
            }
        }
    }
}

// ============================================================
// Page 50102 - Tender Card
// Purpose: Main document page for viewing/editing a tender.
//          Contains all FastTabs and process actions.
// ============================================================
page 50102 "Tender Card"
{
    PageType = Document;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "Tender Header";
    Caption = 'Tender Card';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Tender No."; Rec."Tender No.")
                {
                    ApplicationArea = All;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    var
                        TenderSetup: Record "Tender Setup";
                        NoSeriesMgt: Codeunit NoSeriesManagement;
                    begin
                        TenderSetup.GetSetup();
                        if NoSeriesMgt.SelectSeries(TenderSetup."Tender No. Series", Rec."No. Series", Rec."No. Series") then begin
                            NoSeriesMgt.SetSeries(Rec."Tender No.");
                            CurrPage.Update();
                        end;
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Source Module"; Rec."Source Module")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Source ID"; Rec."Source ID")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Item Type"; Rec."Item Type")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Work Type"; Rec."Work Type")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StatusStyleExpr;
                }
                field("Approval Status"; Rec."Approval Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(SourceInfo)
            {
                Caption = 'Source Information';
                Editable = false;
                field("Budget Amount"; Rec."Budget Amount") { ApplicationArea = All; }
                field("Business Unit Code"; Rec."Business Unit Code") { ApplicationArea = All; }
                field("Sanction No."; Rec."Sanction No.") { ApplicationArea = All; }
            }
            group(Dates)
            {
                Caption = 'Dates';
                field("Created Date"; Rec."Created Date") { ApplicationArea = All; }
                field("NIT Publish Date"; Rec."NIT Publish Date")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Bid Start Date"; Rec."Bid Start Date")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Bid End Date"; Rec."Bid End Date")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
                field("Bid Validity Date"; Rec."Bid Validity Date")
                {
                    ApplicationArea = All;
                    Editable = IsEditable;
                }
            }
            group(NegotiationGrp)
            {
                Caption = 'Negotiation';
                field("Negotiate Date"; Rec."Negotiate Date") { ApplicationArea = All; }
                field("Negotiate Place"; Rec."Negotiate Place") { ApplicationArea = All; }
                field("Allocated Engineer"; Rec."Allocated Engineer") { ApplicationArea = All; }
                field("Negotiation Approval Status"; Rec."Negotiation Approval Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(RateContractGrp)
            {
                Caption = 'Rate Contract';
                Visible = IsRateContract;
                field("Rate Contract Valid From"; Rec."Rate Contract Valid From") { ApplicationArea = All; }
                field("Rate Contract Valid To"; Rec."Rate Contract Valid To") { ApplicationArea = All; }
                field("Rate Contract Ceiling Amount"; Rec."Rate Contract Ceiling Amount") { ApplicationArea = All; }
            }
            group(ReverseAuctionGrp)
            {
                Caption = 'Reverse Auction';
                Visible = Rec."Reverse Auction Enabled";
                field("Reverse Auction Enabled"; Rec."Reverse Auction Enabled") { ApplicationArea = All; }
                field("Current Auction Round"; Rec."Current Auction Round") { ApplicationArea = All; }
                field("Auction Status"; Rec."Auction Status") { ApplicationArea = All; }
            }
            group(OrderDetails)
            {
                Caption = 'Order Details';
                Visible = Rec."Created Order No." <> '';
                field("Created Order No."; Rec."Created Order No.") { ApplicationArea = All; }
                field("Created Order Document Type"; Rec."Created Order Document Type") { ApplicationArea = All; }
                field("Re-Tender Reference No."; Rec."Re-Tender Reference No.") { ApplicationArea = All; }
            }
            group(Statistics)
            {
                Caption = 'Statistics';
                Editable = false;
                field("No. of Vendors Allocated"; Rec."No. of Vendors Allocated") { ApplicationArea = All; }
                field("No. of Tender Lines"; Rec."No. of Tender Lines") { ApplicationArea = All; }
                field("Total Tender Amount"; Rec."Total Tender Amount") { ApplicationArea = All; }
                field("No. of Archived Versions"; Rec."No. of Archived Versions") { ApplicationArea = All; }
                field("No. of Corrigendums"; Rec."No. of Corrigendums") { ApplicationArea = All; }
            }
            part(TenderLines; "Tender Lines Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "Tender No." = field("Tender No.");
                UpdatePropagation = Both;
            }
        }
        area(FactBoxes)
        {
            systempart(Notes; Notes) { ApplicationArea = All; }
            systempart(Links; Links) { ApplicationArea = All; }
        }
    }

    actions
    {
        area(Processing)
        {
            group(Process)
            {
                Caption = 'Process';

                action(PublishNIT)
                {
                    Caption = 'Publish NIT';
                    ApplicationArea = All;
                    Image = SendTo;
                    Enabled = Rec.Status = Rec.Status::Draft;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.PublishNIT(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(AllocateVendors)
                {
                    Caption = 'Allocate Vendors';
                    ApplicationArea = All;
                    Image = Vendor;
                    RunObject = page "Tender Vendor Allocation";
                    RunPageLink = "Tender No." = field("Tender No.");
                }
                action(SendForApproval)
                {
                    Caption = 'Send for Approval';
                    ApplicationArea = All;
                    Image = SendApprovalRequest;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.SendForApproval(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(Approve)
                {
                    Caption = 'Approve';
                    ApplicationArea = All;
                    Image = Approve;
                    Enabled = Rec.Status = Rec.Status::"Pending Approval";

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.ApproveTender(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(Reject)
                {
                    Caption = 'Reject';
                    ApplicationArea = All;
                    Image = Reject;
                    Enabled = Rec.Status = Rec.Status::"Pending Approval";

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.RejectTender(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(CreateQuotes)
                {
                    Caption = 'Create Quotes';
                    ApplicationArea = All;
                    Image = MakeOrder;
                    Enabled = Rec.Status = Rec.Status::Approved;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.CreateQuotesForAllVendors(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(OpenBidding)
                {
                    Caption = 'Open Bidding';
                    ApplicationArea = All;
                    Image = Open;
                    Enabled = Rec.Status = Rec.Status::"Quotes Created";

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.OpenBidding(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(CloseBidding)
                {
                    Caption = 'Close Bidding';
                    ApplicationArea = All;
                    Image = Close;
                    Enabled = Rec.Status = Rec.Status::"Bidding Open";

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.CloseBidding(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(StartReverseAuction)
                {
                    Caption = 'Start Reverse Auction';
                    ApplicationArea = All;
                    Image = Recalculate;
                    Enabled = (Rec.Status = Rec.Status::"Bidding Closed") and Rec."Reverse Auction Enabled";

                    trigger OnAction()
                    var
                        AuctionMgt: Codeunit "Tender Reverse Auction Mgt.";
                    begin
                        AuctionMgt.InitializeAuction(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(MoveToEvaluation)
                {
                    Caption = 'Move to Evaluation';
                    ApplicationArea = All;
                    Image = Evaluate;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.MoveToEvaluation(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(SendToNegotiation)
                {
                    Caption = 'Send to Negotiation';
                    ApplicationArea = All;
                    Image = SendConfirmation;
                    Enabled = Rec.Status = Rec.Status::"Vendor Selected";

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.SendToNegotiation(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(ApproveNegotiation)
                {
                    Caption = 'Approve Negotiation';
                    ApplicationArea = All;
                    Image = Approve;
                    Enabled = Rec.Status = Rec.Status::Negotiation;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.ApproveNegotiation(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(ImportAmendedBOQ)
                {
                    Caption = 'Import Amended BOQ';
                    ApplicationArea = All;
                    Image = Import;
                    Enabled = Rec.Status = Rec.Status::Negotiation;

                    trigger OnAction()
                    var
                        ImportExport: Codeunit "Tender Import Export";
                    begin
                        ImportExport.ImportAmendedBOQ(Rec."Tender No.");
                        CurrPage.Update(false);
                    end;
                }
                action(CreatePurchaseOrder)
                {
                    Caption = 'Create Purchase Order';
                    ApplicationArea = All;
                    Image = CreateDocument;
                    Enabled = (Rec."Item Type" = Rec."Item Type"::HSN) and
                              (Rec.Status in [Rec.Status::"Negotiation Approved", Rec.Status::"Vendor Selected"]);

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.CreatePurchaseOrder(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(CreateWorkOrder)
                {
                    Caption = 'Create Work Order';
                    ApplicationArea = All;
                    Image = CreateDocument;
                    Enabled = (Rec."Item Type" = Rec."Item Type"::SAC) and
                              (Rec.Status in [Rec.Status::"Negotiation Approved", Rec.Status::"Vendor Selected"]);

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.CreateWorkOrder(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(IssueCorrigendum)
                {
                    Caption = 'Issue Corrigendum';
                    ApplicationArea = All;
                    Image = Change;
                    Enabled = Rec.Status = Rec.Status::"Bidding Open";

                    trigger OnAction()
                    var
                        CorrMgt: Codeunit "Tender Corrigendum Mgt.";
                    begin
                        CorrMgt.CreateCorrigendum(Rec, "Corrigendum Changes Type"::"Terms Only");
                        CurrPage.Update(false);
                    end;
                }
                action(ReTender)
                {
                    Caption = 'Re-Tender';
                    ApplicationArea = All;
                    Image = Redo;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        if Confirm('Are you sure you want to re-tender? This will create a new tender and archive the current one.') then begin
                            TenderMgt.ReTender(Rec);
                            CurrPage.Update(false);
                        end;
                    end;
                }
                action(CloseTender)
                {
                    Caption = 'Close Tender';
                    ApplicationArea = All;
                    Image = Close;

                    trigger OnAction()
                    var
                        TenderMgt: Codeunit "Tender Management";
                    begin
                        TenderMgt.CloseTender(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(ArchiveTender)
                {
                    Caption = 'Archive Tender';
                    ApplicationArea = All;
                    Image = Archive;

                    trigger OnAction()
                    var
                        ArchiveMgt: Codeunit "Tender Archive Management";
                    begin
                        ArchiveMgt.ArchiveTender(Rec, "Tender Archive Reason"::Manual);
                        CurrPage.Update(false);
                        Message('Tender archived successfully.');
                    end;
                }
            }
        }
        area(Navigation)
        {
            group(Navigate)
            {
                Caption = 'Navigate';

                action(Vendors)
                {
                    Caption = 'Vendors';
                    ApplicationArea = All;
                    Image = Vendor;
                    RunObject = page "Tender Vendor Allocation";
                    RunPageLink = "Tender No." = field("Tender No.");
                }
                action(Corrigendums)
                {
                    Caption = 'Corrigendums';
                    ApplicationArea = All;
                    Image = Change;
                    RunObject = page "Tender Corrigendum List";
                    RunPageLink = "Tender No." = field("Tender No.");
                }
                action(ArchiveVersions)
                {
                    Caption = 'Archive Versions';
                    ApplicationArea = All;
                    Image = Archive;
                    RunObject = page "Tender Header Archive List";
                    RunPageLink = "Tender No." = field("Tender No.");
                }
                action(AuctionRounds)
                {
                    Caption = 'Auction Rounds';
                    ApplicationArea = All;
                    Image = Recalculate;
                    Visible = Rec."Reverse Auction Enabled";
                    RunObject = page "Reverse Auction Rounds";
                    RunPageLink = "Tender No." = field("Tender No.");
                }
                action(DisqualificationRules)
                {
                    Caption = 'Disqualification Rules';
                    ApplicationArea = All;
                    Image = CheckRulesSyntax;
                    RunObject = page "Tender Disqual. Rules";
                    RunPageLink = "Tender No." = field("Tender No.");
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(PublishNITRef; PublishNIT) { }
                actionref(SendForApprovalRef; SendForApproval) { }
                actionref(ApproveRef; Approve) { }
                actionref(CreateQuotesRef; CreateQuotes) { }
                actionref(CreatePurchaseOrderRef; CreatePurchaseOrder) { }
                actionref(CreateWorkOrderRef; CreateWorkOrder) { }
            }
        }
    }

    var
        IsEditable: Boolean;
        IsRateContract: Boolean;
        StatusStyleExpr: Text;

    trigger OnAfterGetRecord()
    begin
        IsEditable := Rec.IsEditable();
        IsRateContract := Rec."Tender Type" = Rec."Tender Type"::"Rate Contract";
        SetStatusStyle();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsEditable := true;
    end;

    local procedure SetStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Draft:
                StatusStyleExpr := 'Standard';
            Rec.Status::Approved:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Rejected:
                StatusStyleExpr := 'Unfavorable';
            Rec.Status::Closed:
                StatusStyleExpr := 'Subordinate';
            Rec.Status::"Order Created":
                StatusStyleExpr := 'StrongAccent';
            else
                StatusStyleExpr := 'Ambiguous';
        end;
    end;
}

// ============================================================
// Page 50103 - Tender Lines Subpage
// Purpose: ListPart embedded in Tender Card.
//          Displays BOQ with indentation and conditional styling.
// ============================================================
page 50103 "Tender Lines Subpage"
{
    PageType = ListPart;
    ApplicationArea = All;
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
                IndentationControls = "Short Description";

                field("BOQ Serial No."; Rec."BOQ Serial No.")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyleExpr;
                }
                field("Line Type"; Rec."Line Type")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyleExpr;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Visible = IsHSN;
                }
                field("Short Description"; Rec."Short Description")
                {
                    ApplicationArea = All;
                    StyleExpr = LineStyleExpr;

                    trigger OnDrillDown()
                    var
                        BlobViewer: Page "Tender Blob Viewer";
                    begin
                        BlobViewer.SetTenderLine(Rec);
                        BlobViewer.RunModal();
                        CurrPage.Update(false);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Visible = IsHSN;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = Rec.IsQuantityLine();
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Editable = Rec.IsQuantityLine();
                    BlankZero = true;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    Editable = Rec.IsQuantityLine();
                    BlankZero = true;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    ApplicationArea = All;
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
                Caption = 'Import BOQ from Excel';
                ApplicationArea = All;
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
                            Error('Please set the Item Type on the tender header first.');
                    end;
                    CurrPage.Update(false);
                end;
            }
            action(ViewFullDescription)
            {
                Caption = 'View Full Description';
                ApplicationArea = All;
                Image = ViewDescription;

                trigger OnAction()
                var
                    BlobViewer: Page "Tender Blob Viewer";
                begin
                    BlobViewer.SetTenderLine(Rec);
                    BlobViewer.RunModal();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var
        IsHSN: Boolean;
        LineStyleExpr: Text;

    trigger OnAfterGetRecord()
    var
        TenderHeader: Record "Tender Header";
    begin
        if TenderHeader.Get(Rec."Tender No.") then
            IsHSN := TenderHeader."Item Type" = TenderHeader."Item Type"::HSN;

        case Rec.Style of
            Rec.Style::Bold:
                LineStyleExpr := 'Strong';
            Rec.Style::BoldItalic:
                LineStyleExpr := 'StrongAccent';
            else
                LineStyleExpr := 'Standard';
        end;
    end;
}

// ============================================================
// Page 50104 - Tender Vendor Allocation
// Purpose: Manage which vendors are invited to the tender.
// ============================================================
page 50104 "Tender Vendor Allocation"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = "Tender Vendor Allocation";
    Caption = 'Tender Vendor Allocation';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Tender No."; Rec."Tender No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
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
            action(DisqualifyVendor)
            {
                Caption = 'Disqualify Vendor';
                ApplicationArea = All;
                Image = Cancel;

                trigger OnAction()
                var
                    Reason: Text[250];
                begin
                    Reason := '';
                    if not (Page.RunModal(0) = Action::LookupOK) then begin
                        // Simple input
                    end;
                    Rec."Quote Status" := Rec."Quote Status"::Disqualified;
                    Rec."Disqualification Reason" := 'Manual disqualification';
                    Rec.Modify();
                    CurrPage.Update(false);
                end;
            }
            action(RunAutoDisqualification)
            {
                Caption = 'Run Auto-Disqualification';
                ApplicationArea = All;
                Image = CheckRulesSyntax;

                trigger OnAction()
                var
                    DisqualEngine: Codeunit "Tender Disqualification Engine";
                begin
                    DisqualEngine.RunAutoDisqualification(Rec."Tender No.");
                    CurrPage.Update(false);
                end;
            }
            action(SelectVendor)
            {
                Caption = 'Select as Winner';
                ApplicationArea = All;
                Image = Approve;

                trigger OnAction()
                var
                    TenderMgt: Codeunit "Tender Management";
                begin
                    TenderMgt.SelectVendor(Rec."Tender No.", Rec."Vendor No.");
                    CurrPage.Update(false);
                end;
            }
        }
    }
}

// ============================================================
// Page 50105 - Tender Blob Viewer
// Purpose: View and edit the full SAC description stored in Blob.
// ============================================================
page 50105 "Tender Blob Viewer"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Full Description';

    layout
    {
        area(Content)
        {
            group(Header)
            {
                Caption = 'Line Information';
                Editable = false;
                field(BOQSerialNo; BOQSerialNo)
                {
                    Caption = 'BOQ Serial No.';
                    ApplicationArea = All;
                }
                field(LineTypeDisplay; LineTypeDisplay)
                {
                    Caption = 'Line Type';
                    ApplicationArea = All;
                }
            }
            group(DescriptionGroup)
            {
                Caption = 'Description';
                field(FullDescription; FullDescription)
                {
                    Caption = 'Full Description';
                    ApplicationArea = All;
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SaveDescription)
            {
                Caption = 'Save';
                ApplicationArea = All;
                Image = Save;

                trigger OnAction()
                begin
                    TenderLineRec.SetDescriptionBlob(FullDescription);
                    Message('Description saved.');
                end;
            }
            action(ClearDescription)
            {
                Caption = 'Clear';
                ApplicationArea = All;
                Image = ClearLog;

                trigger OnAction()
                begin
                    FullDescription := '';
                end;
            }
        }
    }

    var
        TenderLineRec: Record "Tender Line";
        FullDescription: Text;
        BOQSerialNo: Text[20];
        LineTypeDisplay: Text;

    procedure SetTenderLine(var TenderLine: Record "Tender Line")
    begin
        TenderLineRec := TenderLine;
        BOQSerialNo := TenderLine."BOQ Serial No.";
        LineTypeDisplay := Format(TenderLine."Line Type");
        FullDescription := TenderLine.GetDescriptionBlob();
    end;
}

// ============================================================
// Page 50106 - Tender Corrigendum List
// Purpose: List of corrigendums for a tender.
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
                field("Archive Version No."; Rec."Archive Version No.") { ApplicationArea = All; }
                field("Issued By User ID"; Rec."Issued By User ID") { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ApplyTermsChanges)
            {
                Caption = 'Apply Terms Changes';
                ApplicationArea = All;
                Image = Apply;

                trigger OnAction()
                var
                    CorrMgt: Codeunit "Tender Corrigendum Mgt.";
                begin
                    CorrMgt.ApplyTermsChanges(Rec);
                    Message('Terms changes applied.');
                end;
            }
            action(NotifyVendors)
            {
                Caption = 'Notify Vendors';
                ApplicationArea = All;
                Image = SendMail;

                trigger OnAction()
                var
                    CorrMgt: Codeunit "Tender Corrigendum Mgt.";
                begin
                    CorrMgt.NotifyVendors(Rec);
                end;
            }
        }
    }
}

// ============================================================
// Page 50107 - Tender Header Archive List
// ============================================================
page 50107 "Tender Header Archive List"
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
                field("Bid End Date"; Rec."Bid End Date") { ApplicationArea = All; }
            }
        }
    }
}

// ============================================================
// Page 50108 - Reverse Auction Rounds
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
                field(Status; Rec.Status) { ApplicationArea = All; }
                field("Round Start DateTime"; Rec."Round Start DateTime") { ApplicationArea = All; }
                field("Round End DateTime"; Rec."Round End DateTime") { ApplicationArea = All; }
                field("Time Limit Minutes"; Rec."Time Limit Minutes") { ApplicationArea = All; }
                field("Min Decrement Percentage"; Rec."Min Decrement Percentage") { ApplicationArea = All; }
                field(Remarks; Rec.Remarks) { ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateNewRound)
            {
                Caption = 'Create New Round';
                ApplicationArea = All;
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
                Caption = 'Open Round';
                ApplicationArea = All;
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
                Caption = 'Close Round';
                ApplicationArea = All;
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
                Caption = 'View Entries';
                ApplicationArea = All;
                Image = ViewDetails;
                RunObject = page "Reverse Auction Entries";
                RunPageLink = "Tender No." = field("Tender No."), "Round No." = field("Round No.");
            }
        }
    }
}

// ============================================================
// Page 50109 - Reverse Auction Entries
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
}

// ============================================================
// Page 50110 - Tender Disqualification Rules
// ============================================================
page 50110 "Tender Disqual. Rules"
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
// Page 50111 - Vendor Performance Rating
// ============================================================
page 50111 "Vendor Performance Rating"
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
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field("Order No."; Rec."Order No.") { ApplicationArea = All; }
                field("Order Document Type"; Rec."Order Document Type") { ApplicationArea = All; }
                field("Completion Date"; Rec."Completion Date") { ApplicationArea = All; }
            }
            group(Ratings)
            {
                Caption = 'Ratings';
                field("Quality Rating"; Rec."Quality Rating") { ApplicationArea = All; }
                field("Timeliness Rating"; Rec."Timeliness Rating") { ApplicationArea = All; }
                field("Compliance Rating"; Rec."Compliance Rating") { ApplicationArea = All; }
                field("Communication Rating"; Rec."Communication Rating") { ApplicationArea = All; }
                field("Overall Rating"; Rec."Overall Rating") { ApplicationArea = All; }
            }
            group(Feedback)
            {
                Caption = 'Feedback';
                field(Comments; Rec.Comments) { ApplicationArea = All; MultiLine = true; }
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
                Caption = 'Submit Rating';
                ApplicationArea = All;
                Image = Approve;

                trigger OnAction()
                begin
                    Rec.CalculateOverallRating();
                    Rec.Status := Rec.Status::Submitted;
                    Rec."Rated By User ID" := CopyStr(UserId(), 1, MaxStrLen(Rec."Rated By User ID"));
                    Rec."Rated DateTime" := CurrentDateTime();
                    Rec.Modify(true);
                    Message('Rating submitted.');
                end;
            }
        }
    }
}

// ============================================================
// Page 50112 - Tender Questionnaire Responses
// ============================================================
page 50112 "Tender Quest. Responses"
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
                field(Score; Rec.Score) { ApplicationArea = All; }
                field("Meets Requirement"; Rec."Meets Requirement") { ApplicationArea = All; }
            }
        }
    }
}

// ============================================================
// Page 50113 - Digital Signature Log
// ============================================================
page 50113 "Tender Digi. Signature Log"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Tender Digi. Signature Log";
    Caption = 'Digital Signature Log';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
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
// Page 50114 - Rate Contract Usage List
// ============================================================
page 50114 "Rate Contract Usage List"
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
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field("Purchase Order No."; Rec."Purchase Order No.") { ApplicationArea = All; }
                field("Vendor No."; Rec."Vendor No.") { ApplicationArea = All; }
                field("Item No."; Rec."Item No.") { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Quantity Ordered"; Rec."Quantity Ordered") { ApplicationArea = All; }
                field("Unit Cost"; Rec."Unit Cost") { ApplicationArea = All; }
                field("Line Amount"; Rec."Line Amount") { ApplicationArea = All; }
                field("Order Date"; Rec."Order Date") { ApplicationArea = All; }
            }
        }
    }
}

// ============================================================
// Page 50115 - Tender Document Attachment Stages
// ============================================================
page 50115 "Tender Doc. Attach. Stages"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Tender Doc. Attachment Stage";
    Caption = 'Tender Document Attachments';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Tender No."; Rec."Tender No.") { ApplicationArea = All; }
                field("Attachment Entry No."; Rec."Attachment Entry No.") { ApplicationArea = All; }
                field(Stage; Rec.Stage) { ApplicationArea = All; }
                field(Description; Rec.Description) { ApplicationArea = All; }
                field("Is Mandatory"; Rec."Is Mandatory") { ApplicationArea = All; }
                field(Verified; Rec.Verified) { ApplicationArea = All; }
                field("Uploaded By User ID"; Rec."Uploaded By User ID") { ApplicationArea = All; }
                field("Uploaded DateTime"; Rec."Uploaded DateTime") { ApplicationArea = All; }
            }
        }
    }
}