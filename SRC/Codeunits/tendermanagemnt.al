// ============================================================
// Codeunit 50100 - Tender Management
// Purpose: Central codeunit for ALL tender operations.
//          Contains status transitions, validations, quote creation,
//          order creation, and core business logic.
//
// HOW IT WORKS:
// - Each major operation is a separate procedure
// - Status transitions are validated before execution
// - Events are raised at key points for extensibility
// - Error messages are clear and actionable
// ============================================================
codeunit 50100 "Tender Management"
{
    // -------------------------------------------------------
    // STATUS UPDATE: Changes tender status with validation
    // -------------------------------------------------------
    procedure UpdateStatus(var TenderHeader: Record "Tender Header"; NewStatus: Enum "Tender Status")
    begin
        ValidateStatusTransition(TenderHeader, NewStatus);
        TenderHeader.Status := NewStatus;
        TenderHeader.Modify(true);
    end;

    local procedure ValidateStatusTransition(TenderHeader: Record "Tender Header"; NewStatus: Enum "Tender Status")
    var
        TenderLine: Record "Tender Line";
        TenderVendor: Record "Tender Vendor Allocation";
    begin
        case NewStatus of
            NewStatus::"NIT Published":
                begin
                    if TenderHeader.Status <> TenderHeader.Status::Draft then
                        Error('Tender must be in Draft status to publish NIT.');
                    TenderHeader.TestField(Description);
                    TenderHeader.TestField("Item Type");
                end;
            NewStatus::"Vendors Allocated":
                begin
                    if not (TenderHeader.Status in [TenderHeader.Status::"NIT Published", TenderHeader.Status::Draft]) then
                        Error('Tender must be in Draft or NIT Published status to allocate vendors.');
                end;
            NewStatus::"Pending Approval":
                begin
                    TenderVendor.SetRange("Tender No.", TenderHeader."Tender No.");
                    if TenderVendor.IsEmpty() then
                        Error('At least one vendor must be allocated before sending for approval.');
                    TenderLine.SetRange("Tender No.", TenderHeader."Tender No.");
                    if TenderLine.IsEmpty() then
                        Error('At least one tender line must exist before sending for approval.');
                    TenderHeader.TestField("Bid Start Date");
                    TenderHeader.TestField("Bid End Date");
                end;
            NewStatus::Approved:
                begin
                    if TenderHeader.Status <> TenderHeader.Status::"Pending Approval" then
                        Error('Tender must be in Pending Approval status to approve.');
                end;
            NewStatus::"Quotes Created":
                begin
                    if TenderHeader.Status <> TenderHeader.Status::Approved then
                        Error('Tender must be Approved before creating quotes.');
                end;
            NewStatus::"Bidding Open":
                begin
                    if TenderHeader.Status <> TenderHeader.Status::"Quotes Created" then
                        Error('Quotes must be created before opening bidding.');
                end;
            NewStatus::"Bidding Closed":
                begin
                    if TenderHeader.Status <> TenderHeader.Status::"Bidding Open" then
                        Error('Bidding must be open before it can be closed.');
                end;
            NewStatus::"Under Evaluation":
                begin
                    if not (TenderHeader.Status in [TenderHeader.Status::"Bidding Closed",
                                                     TenderHeader.Status::"Reverse Auction"]) then
                        Error('Tender must be in Bidding Closed or Reverse Auction status for evaluation.');
                end;
            NewStatus::"Vendor Selected":
                begin
                    if TenderHeader.Status <> TenderHeader.Status::"Under Evaluation" then
                        Error('Tender must be Under Evaluation to select a vendor.');
                    TenderVendor.SetRange("Tender No.", TenderHeader."Tender No.");
                    TenderVendor.SetRange("Is Selected Vendor", true);
                    if TenderVendor.IsEmpty() then
                        Error('A vendor must be marked as selected.');
                end;
            NewStatus::Negotiation:
                begin
                    if TenderHeader.Status <> TenderHeader.Status::"Vendor Selected" then
                        Error('A vendor must be selected before starting negotiation.');
                end;
            NewStatus::"Negotiation Approved":
                begin
                    if TenderHeader.Status <> TenderHeader.Status::Negotiation then
                        Error('Tender must be in Negotiation status.');
                end;
            NewStatus::"Order Created":
                begin
                    if not (TenderHeader.Status in [TenderHeader.Status::"Negotiation Approved",
                                                     TenderHeader.Status::"Vendor Selected"]) then
                        Error('Negotiation must be approved or vendor selected before creating order.');
                end;
            NewStatus::Closed:
                begin
                    if not (TenderHeader.Status in [TenderHeader.Status::"Order Created",
                                                     TenderHeader.Status::Draft]) then
                        Error('Tender must have an order created or be in Draft to close.');
                end;
        end;
    end;

    // -------------------------------------------------------
    // PUBLISH NIT: Makes the tender publicly visible
    // -------------------------------------------------------
    procedure PublishNIT(var TenderHeader: Record "Tender Header")
    var
        EventPub: Codeunit "Tender Event Publishers";
        IsHandled: Boolean;
    begin
        EventPub.OnBeforeNITPublish(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        TenderHeader.TestField(Description);
        TenderHeader.TestField("Item Type");
        TenderHeader."NIT Publish Date" := Today();
        UpdateStatus(TenderHeader, TenderHeader.Status::"NIT Published");

        EventPub.OnAfterNITPublish(TenderHeader);
        Message('NIT published successfully for Tender %1.', TenderHeader."Tender No.");
    end;

    // -------------------------------------------------------
    // ALLOCATE VENDOR: Adds a vendor to the tender
    // -------------------------------------------------------
    procedure AllocateVendor(TenderNo: Code[20]; VendorNo: Code[20])
    var
        TenderHeader: Record "Tender Header";
        TenderVendor: Record "Tender Vendor Allocation";
        VendorRec: Record Vendor;
    begin
        TenderHeader.Get(TenderNo);
        if not (TenderHeader.Status in [TenderHeader.Status::Draft,
                                         TenderHeader.Status::"NIT Published",
                                         TenderHeader.Status::"Vendors Allocated"]) then
            Error('Vendors can only be allocated when tender is in Draft, NIT Published, or Vendors Allocated status.');

        VendorRec.Get(VendorNo);
        if VendorRec.Blocked <> VendorRec.Blocked::" " then
            Error('Vendor %1 is blocked and cannot be allocated.', VendorNo);

        if TenderVendor.Get(TenderNo, VendorNo) then
            Error('Vendor %1 is already allocated to Tender %2.', VendorNo, TenderNo);

        TenderVendor.Init();
        TenderVendor."Tender No." := TenderNo;
        TenderVendor."Vendor No." := VendorNo;
        TenderVendor.Validate("Vendor No.");
        TenderVendor.Insert(true);

        // Update status if this is the first vendor
        if TenderHeader.Status in [TenderHeader.Status::Draft, TenderHeader.Status::"NIT Published"] then begin
            TenderHeader.Status := TenderHeader.Status::"Vendors Allocated";
            TenderHeader.Modify(true);
        end;

        Message('Vendor %1 allocated to Tender %2.', VendorNo, TenderNo);
    end;

    // -------------------------------------------------------
    // REMOVE VENDOR: Removes a vendor (before quotes created)
    // -------------------------------------------------------
    procedure RemoveVendor(TenderNo: Code[20]; VendorNo: Code[20])
    var
        TenderVendor: Record "Tender Vendor Allocation";
    begin
        TenderVendor.Get(TenderNo, VendorNo);
        TenderVendor.Delete(true); // OnDelete validates quote status
        Message('Vendor %1 removed from Tender %2.', VendorNo, TenderNo);
    end;

    // -------------------------------------------------------
    // SEND FOR APPROVAL: Triggers the approval workflow
    // -------------------------------------------------------
    procedure SendForApproval(var TenderHeader: Record "Tender Header")
    var
        EventPub: Codeunit "Tender Event Publishers";
        IsHandled: Boolean;
    begin
        EventPub.OnBeforeTenderApproval(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        ValidateForApproval(TenderHeader);
        TenderHeader."Approval Status" := TenderHeader."Approval Status"::Pending;
        UpdateStatus(TenderHeader, TenderHeader.Status::"Pending Approval");

        Message('Tender %1 sent for approval.', TenderHeader."Tender No.");
    end;

    procedure ApproveTender(var TenderHeader: Record "Tender Header")
    var
        EventPub: Codeunit "Tender Event Publishers";
    begin
        TenderHeader."Approval Status" := TenderHeader."Approval Status"::Approved;
        UpdateStatus(TenderHeader, TenderHeader.Status::Approved);
        EventPub.OnAfterTenderApproved(TenderHeader);
        Message('Tender %1 approved.', TenderHeader."Tender No.");
    end;

    procedure RejectTender(var TenderHeader: Record "Tender Header")
    var
        EventPub: Codeunit "Tender Event Publishers";
    begin
        TenderHeader."Approval Status" := TenderHeader."Approval Status"::Rejected;
        TenderHeader.Status := TenderHeader.Status::Rejected;
        TenderHeader.Modify(true);
        EventPub.OnAfterTenderRejected(TenderHeader);
        Message('Tender %1 rejected.', TenderHeader."Tender No.");
    end;

    local procedure ValidateForApproval(TenderHeader: Record "Tender Header")
    var
        TenderLine: Record "Tender Line";
        TenderVendor: Record "Tender Vendor Allocation";
    begin
        TenderHeader.TestField(Description);
        TenderHeader.TestField("Item Type");
        TenderHeader.TestField("Bid Start Date");
        TenderHeader.TestField("Bid End Date");

        TenderVendor.SetRange("Tender No.", TenderHeader."Tender No.");
        if TenderVendor.IsEmpty() then
            Error('At least one vendor must be allocated.');

        TenderLine.SetRange("Tender No.", TenderHeader."Tender No.");
        if TenderLine.IsEmpty() then
            Error('At least one tender line (BOQ item) must exist.');
    end;

    // -------------------------------------------------------
    // CREATE QUOTES: Auto-creates Purchase Quote per vendor
    // -------------------------------------------------------
    procedure CreateQuotesForAllVendors(var TenderHeader: Record "Tender Header")
    var
        TenderVendor: Record "Tender Vendor Allocation";
        PurchHeader: Record "Purchase Header";
        EventPub: Codeunit "Tender Event Publishers";
        IsHandled: Boolean;
        QuoteCount: Integer;
    begin
        EventPub.OnBeforeQuoteCreation(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        if TenderHeader.Status <> TenderHeader.Status::Approved then
            Error('Tender must be Approved before creating quotes.');

        TenderVendor.SetRange("Tender No.", TenderHeader."Tender No.");
        TenderVendor.SetFilter("Quote Status", '%1', TenderVendor."Quote Status"::"Not Created");
        if TenderVendor.IsEmpty() then
            Error('No vendors without quotes found.');

        if TenderVendor.FindSet() then
            repeat
                CreateSingleQuote(TenderHeader, TenderVendor, PurchHeader);
                TenderVendor."Quote No." := PurchHeader."No.";
                TenderVendor."Quote Status" := TenderVendor."Quote Status"::Created;
                TenderVendor.Modify();
                QuoteCount += 1;
                EventPub.OnAfterQuoteCreated(TenderHeader, PurchHeader);
            until TenderVendor.Next() = 0;

        UpdateStatus(TenderHeader, TenderHeader.Status::"Quotes Created");
        Message('%1 purchase quote(s) created for Tender %2.', QuoteCount, TenderHeader."Tender No.");
    end;

    local procedure CreateSingleQuote(TenderHeader: Record "Tender Header"; TenderVendor: Record "Tender Vendor Allocation"; var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader.Init();
        PurchHeader."Document Type" := PurchHeader."Document Type"::Quote;
        PurchHeader."No." := '';
        PurchHeader.Insert(true);

        PurchHeader.Validate("Buy-from Vendor No.", TenderVendor."Vendor No.");
        if TenderVendor."Currency Code" <> '' then
            PurchHeader.Validate("Currency Code", TenderVendor."Currency Code");

        PurchHeader."MAHE Tender No." := TenderHeader."Tender No.";
        PurchHeader."MAHE Source Module" := TenderHeader."Source Module";
        PurchHeader."MAHE Source ID" := TenderHeader."Source ID";
        PurchHeader."MAHE Tender Item Type" := TenderHeader."Item Type";
        PurchHeader."MAHE Bid Validity Date" := TenderHeader."Bid Validity Date";
        PurchHeader.Modify(true);

        CopyTenderLinesToQuote(TenderHeader."Tender No.", PurchHeader);
    end;

    /// Copies all tender lines to the purchase quote lines
    procedure CopyTenderLinesToQuote(TenderNo: Code[20]; PurchHeader: Record "Purchase Header")
    var
        TenderLine: Record "Tender Line";
        TenderHeader: Record "Tender Header";
        PurchLine: Record "Purchase Line";
        LineNo: Integer;
    begin
        TenderHeader.Get(TenderNo);
        TenderLine.SetRange("Tender No.", TenderNo);
        if TenderLine.FindSet() then begin
            LineNo := 10000;
            repeat
                PurchLine.Init();
                PurchLine."Document Type" := PurchHeader."Document Type";
                PurchLine."Document No." := PurchHeader."No.";
                PurchLine."Line No." := LineNo;

                // For line items, set up as Item or GL Account
                if TenderLine.IsQuantityLine() then begin
                    if TenderHeader."Item Type" = TenderHeader."Item Type"::HSN then begin
                        PurchLine.Type := PurchLine.Type::Item;
                        if TenderLine."Item No." <> '' then
                            PurchLine.Validate("No.", TenderLine."Item No.");
                    end else begin
                        // SAC: use GL Account type or leave as text description
                        PurchLine.Type := PurchLine.Type::" ";
                    end;
                    PurchLine.Description := TenderLine.Description;
                    PurchLine.Validate("Unit of Measure Code", TenderLine."Unit of Measure Code");
                    PurchLine.Validate(Quantity, TenderLine.Quantity);
                    // Unit Cost left blank - vendor will fill in their price
                end else begin
                    // Headings: text-only lines
                    PurchLine.Type := PurchLine.Type::" ";
                    if TenderLine."Short Description" <> '' then
                        PurchLine.Description := CopyStr(TenderLine."Short Description", 1, MaxStrLen(PurchLine.Description))
                    else
                        PurchLine.Description := TenderLine.Description;
                end;

                // Copy tender reference fields
                PurchLine."MAHE Tender Line No." := TenderLine."Line No.";
                PurchLine."MAHE Indentation" := TenderLine.Indentation;
                PurchLine."MAHE Line Type" := TenderLine."Line Type";
                PurchLine."MAHE BOQ Serial No." := TenderLine."BOQ Serial No.";
                PurchLine."MAHE Short Description" := TenderLine."Short Description";
                PurchLine."MAHE Style" := TenderLine.Style;
                PurchLine."MAHE Parent Line No." := TenderLine."Parent Line No.";

                // Copy blob description for SAC
                CopyBlobBetweenLines(TenderLine, PurchLine);

                PurchLine.Insert(true);
                LineNo += 10000;
            until TenderLine.Next() = 0;
        end;
    end;

    local procedure CopyBlobBetweenLines(TenderLine: Record "Tender Line"; var PurchLine: Record "Purchase Line")
    var
        InStr: InStream;
        OutStr: OutStream;
    begin
        TenderLine.CalcFields("Description Blob");
        if TenderLine."Description Blob".HasValue() then begin
            TenderLine."Description Blob".CreateInStream(InStr);
            PurchLine."MAHE Description Blob".CreateOutStream(OutStr);
            CopyStream(OutStr, InStr);
        end;
    end;

    // -------------------------------------------------------
    // SELECT VENDOR: Mark a vendor as the winner
    // -------------------------------------------------------
    procedure SelectVendor(TenderNo: Code[20]; VendorNo: Code[20])
    var
        TenderVendor: Record "Tender Vendor Allocation";
        EventPub: Codeunit "Tender Event Publishers";
        TenderHeader: Record "Tender Header";
        IsHandled: Boolean;
    begin
        TenderHeader.Get(TenderNo);
        EventPub.OnBeforeVendorSelection(TenderHeader, VendorNo, IsHandled);
        if IsHandled then
            exit;

        TenderVendor.Get(TenderNo, VendorNo);
        if TenderVendor."Quote Status" = TenderVendor."Quote Status"::Disqualified then
            Error('Cannot select a disqualified vendor.');

        TenderVendor.Validate("Is Selected Vendor", true);
        TenderVendor.Modify(true);

        // Also mark the Purchase Quote
        MarkQuoteAsSelected(TenderVendor."Quote No.");

        EventPub.OnAfterVendorSelected(TenderHeader, VendorNo);
        Message('Vendor %1 selected for Tender %2.', VendorNo, TenderNo);
    end;

    local procedure MarkQuoteAsSelected(QuoteNo: Code[20])
    var
        PurchHeader: Record "Purchase Header";
    begin
        if QuoteNo = '' then
            exit;
        if PurchHeader.Get(PurchHeader."Document Type"::Quote, QuoteNo) then begin
            PurchHeader."MAHE Select Vendor" := true;
            PurchHeader.Modify();
        end;
    end;

    // -------------------------------------------------------
    // SEND TO NEGOTIATION
    // -------------------------------------------------------
    procedure SendToNegotiation(var TenderHeader: Record "Tender Header")
    begin
        UpdateStatus(TenderHeader, TenderHeader.Status::Negotiation);
        Message('Tender %1 sent to negotiation.', TenderHeader."Tender No.");
    end;

    procedure ApproveNegotiation(var TenderHeader: Record "Tender Header")
    var
        EventPub: Codeunit "Tender Event Publishers";
    begin
        TenderHeader."Negotiation Approval Status" := TenderHeader."Negotiation Approval Status"::Approved;
        UpdateStatus(TenderHeader, TenderHeader.Status::"Negotiation Approved");
        EventPub.OnAfterNegotiationApproved(TenderHeader);
        Message('Negotiation approved for Tender %1.', TenderHeader."Tender No.");
    end;

    // -------------------------------------------------------
    // CREATE PURCHASE ORDER (for HSN tenders)
    // -------------------------------------------------------
    procedure CreatePurchaseOrder(var TenderHeader: Record "Tender Header")
    var
        TenderVendor: Record "Tender Vendor Allocation";
        PurchQuote: Record "Purchase Header";
        PurchOrder: Record "Purchase Header";
        PurchQuoteLine: Record "Purchase Line";
        PurchOrderLine: Record "Purchase Line";
        EventPub: Codeunit "Tender Event Publishers";
        SourceDispatcher: Codeunit "Tender Source Dispatcher";
        IsHandled: Boolean;
        LineNo: Integer;
    begin
        EventPub.OnBeforeOrderCreation(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        if TenderHeader."Item Type" <> TenderHeader."Item Type"::HSN then
            Error('Use Create Work Order for SAC type tenders.');

        // Find the selected vendor
        TenderVendor.SetRange("Tender No.", TenderHeader."Tender No.");
        TenderVendor.SetRange("Is Selected Vendor", true);
        if not TenderVendor.FindFirst() then
            Error('No vendor has been selected for this tender.');

        // Get the vendor's quote
        if TenderVendor."Quote No." = '' then
            Error('Selected vendor does not have a quote.');
        PurchQuote.Get(PurchQuote."Document Type"::Quote, TenderVendor."Quote No.");

        // Create Purchase Order
        PurchOrder.Init();
        PurchOrder."Document Type" := PurchOrder."Document Type"::Order;
        PurchOrder."No." := '';
        PurchOrder.Insert(true);

        PurchOrder.Validate("Buy-from Vendor No.", TenderVendor."Vendor No.");
        if TenderVendor."Currency Code" <> '' then
            PurchOrder.Validate("Currency Code", TenderVendor."Currency Code");

        PurchOrder."MAHE Tender No." := TenderHeader."Tender No.";
        PurchOrder."MAHE Source Module" := TenderHeader."Source Module";
        PurchOrder."MAHE Source ID" := TenderHeader."Source ID";
        PurchOrder."MAHE Tender Item Type" := TenderHeader."Item Type";
        PurchOrder."MAHE Select Vendor" := true;
        PurchOrder.Modify(true);

        // Copy lines from quote to order
        PurchQuoteLine.SetRange("Document Type", PurchQuote."Document Type");
        PurchQuoteLine.SetRange("Document No.", PurchQuote."No.");
        LineNo := 10000;
        if PurchQuoteLine.FindSet() then
            repeat
                PurchOrderLine.Init();
                PurchOrderLine."Document Type" := PurchOrder."Document Type";
                PurchOrderLine."Document No." := PurchOrder."No.";
                PurchOrderLine."Line No." := LineNo;
                PurchOrderLine.TransferFields(PurchQuoteLine, false);
                PurchOrderLine."Document Type" := PurchOrder."Document Type";
                PurchOrderLine."Document No." := PurchOrder."No.";
                PurchOrderLine."Line No." := LineNo;
                PurchOrderLine.Insert(true);
                LineNo += 10000;
            until PurchQuoteLine.Next() = 0;

        // Update tender header
        TenderHeader."Created Order No." := PurchOrder."No.";
        TenderHeader."Created Order Document Type" := TenderHeader."Created Order Document Type"::"Purchase Order";
        UpdateStatus(TenderHeader, TenderHeader.Status::"Order Created");

        // Notify source module
        SourceDispatcher.NotifySourceOnOrderCreated(TenderHeader, PurchOrder."No.");

        EventPub.OnAfterOrderCreated(TenderHeader, PurchOrder."No.",
            TenderHeader."Created Order Document Type");

        Message('Purchase Order %1 created from Tender %2.', PurchOrder."No.", TenderHeader."Tender No.");
    end;

    // -------------------------------------------------------
    // CREATE WORK ORDER (for SAC tenders)
    // -------------------------------------------------------
    procedure CreateWorkOrder(var TenderHeader: Record "Tender Header")
    var
        TenderVendor: Record "Tender Vendor Allocation";
        PurchQuote: Record "Purchase Header";
        PurchOrder: Record "Purchase Header";
        PurchQuoteLine: Record "Purchase Line";
        PurchOrderLine: Record "Purchase Line";
        TenderSetup: Record "Tender Setup";
        EventPub: Codeunit "Tender Event Publishers";
        SourceDispatcher: Codeunit "Tender Source Dispatcher";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
        LineNo: Integer;
    begin
        EventPub.OnBeforeOrderCreation(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        if TenderHeader."Item Type" <> TenderHeader."Item Type"::SAC then
            Error('Use Create Purchase Order for HSN type tenders.');

        TenderSetup.GetSetup();
        TenderSetup.TestField("Work Order No. Series");

        // Find the selected vendor
        TenderVendor.SetRange("Tender No.", TenderHeader."Tender No.");
        TenderVendor.SetRange("Is Selected Vendor", true);
        if not TenderVendor.FindFirst() then
            Error('No vendor has been selected for this tender.');

        if TenderVendor."Quote No." = '' then
            Error('Selected vendor does not have a quote.');
        PurchQuote.Get(PurchQuote."Document Type"::Quote, TenderVendor."Quote No.");

        // Create Work Order as Purchase Order with special numbering
        PurchOrder.Init();
        PurchOrder."Document Type" := PurchOrder."Document Type"::Order;
        PurchOrder."No." := NoSeriesMgt.GetNextNo(TenderSetup."Work Order No. Series", WorkDate(), true);
        PurchOrder.Insert(true);

        PurchOrder.Validate("Buy-from Vendor No.", TenderVendor."Vendor No.");
        if TenderVendor."Currency Code" <> '' then
            PurchOrder.Validate("Currency Code", TenderVendor."Currency Code");

        PurchOrder."MAHE Tender No." := TenderHeader."Tender No.";
        PurchOrder."MAHE Source Module" := TenderHeader."Source Module";
        PurchOrder."MAHE Source ID" := TenderHeader."Source ID";
        PurchOrder."MAHE Tender Item Type" := TenderHeader."Item Type";
        PurchOrder."MAHE Select Vendor" := true;
        PurchOrder.Modify(true);

        // Copy lines from quote
        PurchQuoteLine.SetRange("Document Type", PurchQuote."Document Type");
        PurchQuoteLine.SetRange("Document No.", PurchQuote."No.");
        LineNo := 10000;
        if PurchQuoteLine.FindSet() then
            repeat
                PurchOrderLine.Init();
                PurchOrderLine."Document Type" := PurchOrder."Document Type";
                PurchOrderLine."Document No." := PurchOrder."No.";
                PurchOrderLine."Line No." := LineNo;
                PurchOrderLine.TransferFields(PurchQuoteLine, false);
                PurchOrderLine."Document Type" := PurchOrder."Document Type";
                PurchOrderLine."Document No." := PurchOrder."No.";
                PurchOrderLine."Line No." := LineNo;
                PurchOrderLine.Insert(true);
                LineNo += 10000;
            until PurchQuoteLine.Next() = 0;

        // Update tender header
        TenderHeader."Created Order No." := PurchOrder."No.";
        TenderHeader."Created Order Document Type" := TenderHeader."Created Order Document Type"::"Work Order";
        UpdateStatus(TenderHeader, TenderHeader.Status::"Order Created");

        SourceDispatcher.NotifySourceOnOrderCreated(TenderHeader, PurchOrder."No.");

        EventPub.OnAfterOrderCreated(TenderHeader, PurchOrder."No.",
            TenderHeader."Created Order Document Type");

        Message('Work Order %1 created from Tender %2.', PurchOrder."No.", TenderHeader."Tender No.");
    end;

    // -------------------------------------------------------
    // CREATE PO FROM RATE CONTRACT
    // -------------------------------------------------------
    procedure CreatePOFromRateContract(TenderNo: Code[20]; var TempTenderLine: Record "Tender Line" temporary)
    var
        TenderHeader: Record "Tender Header";
        TenderVendor: Record "Tender Vendor Allocation";
        TenderLine: Record "Tender Line";
        PurchOrder: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        RateUsage: Record "Rate Contract Usage";
        EventPub: Codeunit "Tender Event Publishers";
        IsHandled: Boolean;
        LineNo: Integer;
    begin
        TenderHeader.Get(TenderNo);
        if TenderHeader."Tender Type" <> TenderHeader."Tender Type"::"Rate Contract" then
            Error('This tender is not a Rate Contract.');
        if Today() > TenderHeader."Rate Contract Valid To" then
            Error('Rate contract has expired.');
        if Today() < TenderHeader."Rate Contract Valid From" then
            Error('Rate contract is not yet active.');

        EventPub.OnBeforeRateContractPOCreated(TenderNo, PurchOrder, IsHandled);
        if IsHandled then
            exit;

        // Find selected vendor
        TenderVendor.SetRange("Tender No.", TenderNo);
        TenderVendor.SetRange("Is Selected Vendor", true);
        TenderVendor.FindFirst();

        // Create PO
        PurchOrder.Init();
        PurchOrder."Document Type" := PurchOrder."Document Type"::Order;
        PurchOrder."No." := '';
        PurchOrder.Insert(true);
        PurchOrder.Validate("Buy-from Vendor No.", TenderVendor."Vendor No.");
        PurchOrder."MAHE Rate Contract Tender No." := TenderNo;
        PurchOrder."MAHE Is Rate Contract Order" := true;
        PurchOrder."MAHE Tender No." := TenderNo;
        PurchOrder.Modify(true);

        LineNo := 10000;
        if TempTenderLine.FindSet() then
            repeat
                if TempTenderLine.Quantity > 0 then begin
                    TenderLine.Get(TenderNo, TempTenderLine."Line No.");

                    // Check remaining quantity
                    if TenderHeader."Rate Contract Ceiling Amount" > 0 then begin
                        TenderLine.CalcFields("Consumed Quantity");
                        if (TenderLine."Consumed Quantity" + TempTenderLine.Quantity) > TenderLine.Quantity then
                            Error('Order quantity exceeds remaining rate contract quantity for line %1.', TenderLine."BOQ Serial No.");
                    end;

                    PurchLine.Init();
                    PurchLine."Document Type" := PurchOrder."Document Type";
                    PurchLine."Document No." := PurchOrder."No.";
                    PurchLine."Line No." := LineNo;
                    if TenderLine."Item No." <> '' then begin
                        PurchLine.Type := PurchLine.Type::Item;
                        PurchLine.Validate("No.", TenderLine."Item No.");
                    end;
                    PurchLine.Validate(Quantity, TempTenderLine.Quantity);
                    PurchLine.Validate("Direct Unit Cost", TenderLine."Unit Cost");
                    PurchLine.Insert(true);

                    // Record usage
                    RateUsage.Init();
                    RateUsage."Tender No." := TenderNo;
                    RateUsage."Tender Line No." := TenderLine."Line No.";
                    RateUsage."Purchase Order No." := PurchOrder."No.";
                    RateUsage."PO Line No." := PurchLine."Line No.";
                    RateUsage."Vendor No." := TenderVendor."Vendor No.";
                    RateUsage."Item No." := TenderLine."Item No.";
                    RateUsage.Description := TenderLine.Description;
                    RateUsage."Quantity Ordered" := TempTenderLine.Quantity;
                    RateUsage."Unit Cost" := TenderLine."Unit Cost";
                    RateUsage."Line Amount" := TempTenderLine.Quantity * TenderLine."Unit Cost";
                    RateUsage."Order Date" := Today();
                    RateUsage."Created By User ID" := CopyStr(UserId(), 1, MaxStrLen(RateUsage."Created By User ID"));
                    RateUsage.Insert(true);

                    LineNo += 10000;
                end;
            until TempTenderLine.Next() = 0;

        EventPub.OnAfterRateContractPOCreated(TenderNo, PurchOrder);
        Message('Purchase Order %1 created from Rate Contract %2.', PurchOrder."No.", TenderNo);
    end;

    // -------------------------------------------------------
    // RE-TENDER: Archives current, creates new tender
    // -------------------------------------------------------
    procedure ReTender(var TenderHeader: Record "Tender Header")
    var
        NewTender: Record "Tender Header";
        TenderLine: Record "Tender Line";
        NewTenderLine: Record "Tender Line";
        TenderVendor: Record "Tender Vendor Allocation";
        NewTenderVendor: Record "Tender Vendor Allocation";
        ArchiveMgt: Codeunit "Tender Archive Management";
        EventPub: Codeunit "Tender Event Publishers";
        IsHandled: Boolean;
        OldTenderNo: Code[20];
    begin
        EventPub.OnBeforeReTender(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        OldTenderNo := TenderHeader."Tender No.";

        // Archive current tender
        ArchiveMgt.ArchiveTender(TenderHeader, "Tender Archive Reason"::"Re-Tender");

        // Create new tender
        NewTender.Init();
        NewTender.TransferFields(TenderHeader, false);
        NewTender."Tender No." := '';
        NewTender.Status := NewTender.Status::Draft;
        NewTender."Approval Status" := NewTender."Approval Status"::Open;
        NewTender."Negotiation Approval Status" := NewTender."Negotiation Approval Status"::Open;
        NewTender."Created Order No." := '';
        NewTender."Re-Tender Reference No." := OldTenderNo;
        NewTender."Created Date" := Today();
        NewTender."Created DateTime" := CurrentDateTime();
        NewTender.Insert(true);

        // Copy lines
        TenderLine.SetRange("Tender No.", OldTenderNo);
        if TenderLine.FindSet() then
            repeat
                NewTenderLine := TenderLine;
                NewTenderLine."Tender No." := NewTender."Tender No.";
                NewTenderLine.Insert();
            until TenderLine.Next() = 0;

        // Copy vendors (without quotes)
        TenderVendor.SetRange("Tender No.", OldTenderNo);
        if TenderVendor.FindSet() then
            repeat
                NewTenderVendor := TenderVendor;
                NewTenderVendor."Tender No." := NewTender."Tender No.";
                NewTenderVendor."Quote No." := '';
                NewTenderVendor."Quote Status" := NewTenderVendor."Quote Status"::"Not Created";
                NewTenderVendor."Is Selected Vendor" := false;
                NewTenderVendor.Insert();
            until TenderVendor.Next() = 0;

        // Mark original as re-tendered
        TenderHeader.Status := TenderHeader.Status::"Re-Tendered";
        TenderHeader.Modify(true);

        EventPub.OnAfterReTender(OldTenderNo, NewTender."Tender No.");
        Message('New Tender %1 created as re-tender of %2.', NewTender."Tender No.", OldTenderNo);
    end;

    // -------------------------------------------------------
    // CLOSE TENDER
    // -------------------------------------------------------
    procedure CloseTender(var TenderHeader: Record "Tender Header")
    var
        EventPub: Codeunit "Tender Event Publishers";
        IsHandled: Boolean;
    begin
        EventPub.OnBeforeTenderClose(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        TenderHeader."Closed Date" := Today();
        UpdateStatus(TenderHeader, TenderHeader.Status::Closed);

        EventPub.OnAfterTenderClosed(TenderHeader);
        Message('Tender %1 closed.', TenderHeader."Tender No.");
    end;

    // -------------------------------------------------------
    // OPEN BIDDING / CLOSE BIDDING
    // -------------------------------------------------------
    procedure OpenBidding(var TenderHeader: Record "Tender Header")
    begin
        UpdateStatus(TenderHeader, TenderHeader.Status::"Bidding Open");
        Message('Bidding opened for Tender %1.', TenderHeader."Tender No.");
    end;

    procedure CloseBidding(var TenderHeader: Record "Tender Header")
    begin
        UpdateStatus(TenderHeader, TenderHeader.Status::"Bidding Closed");
        Message('Bidding closed for Tender %1.', TenderHeader."Tender No.");
    end;

    // -------------------------------------------------------
    // MOVE TO EVALUATION
    // -------------------------------------------------------
    procedure MoveToEvaluation(var TenderHeader: Record "Tender Header")
    begin
        UpdateStatus(TenderHeader, TenderHeader.Status::"Under Evaluation");
        Message('Tender %1 is now under evaluation.', TenderHeader."Tender No.");
    end;

    // -------------------------------------------------------
    // MARK VENDOR SELECTED STATUS
    // -------------------------------------------------------
    procedure MarkVendorSelected(var TenderHeader: Record "Tender Header")
    begin
        UpdateStatus(TenderHeader, TenderHeader.Status::"Vendor Selected");
    end;

    // -------------------------------------------------------
    // UTILITY: Calculate tender total
    // -------------------------------------------------------
    procedure CalculateTenderTotal(TenderNo: Code[20]): Decimal
    var
        TenderLine: Record "Tender Line";
        Total: Decimal;
    begin
        TenderLine.SetRange("Tender No.", TenderNo);
        TenderLine.SetFilter("Line Type", '%1|%2',
            TenderLine."Line Type"::"Line Item", TenderLine."Line Type"::"Sub Item");
        if TenderLine.FindSet() then
            repeat
                Total += TenderLine."Line Amount";
            until TenderLine.Next() = 0;
        exit(Total);
    end;

    /// Gets the next available line number for tender lines
    procedure GetNextLineNo(TenderNo: Code[20]): Integer
    var
        TenderLine: Record "Tender Line";
    begin
        TenderLine.SetRange("Tender No.", TenderNo);
        if TenderLine.FindLast() then
            exit(TenderLine."Line No." + 10000);
        exit(10000);
    end;
}

// ============================================================
// Codeunit 50101 - Tender Archive Management
// Purpose: Creates versioned snapshots of tender header and lines.
//          Called before corrigendums, amendments, and re-tenders.
// ============================================================
codeunit 50101 "Tender Archive Management"
{
    procedure ArchiveTender(TenderHeader: Record "Tender Header"; Reason: Enum "Tender Archive Reason")
    var
        TenderArchive: Record "Tender Header Archive";
        TenderLine: Record "Tender Line";
        TenderLineArchive: Record "Tender Line Archive";
        VersionNo: Integer;
    begin
        // Get next version number
        TenderArchive.SetRange("Tender No.", TenderHeader."Tender No.");
        if TenderArchive.FindLast() then
            VersionNo := TenderArchive."Version No." + 1
        else
            VersionNo := 1;

        // Archive header
        TenderArchive.Init();
        TenderArchive."Tender No." := TenderHeader."Tender No.";
        TenderArchive."Version No." := VersionNo;
        TenderArchive."Archive Reason" := Reason;
        TenderArchive."Archived DateTime" := CurrentDateTime();
        TenderArchive."Archived By User ID" := CopyStr(UserId(), 1, MaxStrLen(TenderArchive."Archived By User ID"));
        TenderArchive.Description := TenderHeader.Description;
        TenderArchive."Source Module" := TenderHeader."Source Module";
        TenderArchive."Source ID" := TenderHeader."Source ID";
        TenderArchive."Item Type" := TenderHeader."Item Type";
        TenderArchive."Tender Type" := TenderHeader."Tender Type";
        TenderArchive.Status := TenderHeader.Status;
        TenderArchive."Bid Start Date" := TenderHeader."Bid Start Date";
        TenderArchive."Bid End Date" := TenderHeader."Bid End Date";
        TenderArchive."Budget Amount" := TenderHeader."Budget Amount";
        TenderArchive."Currency Code" := TenderHeader."Currency Code";
        TenderArchive."Bid Validity Date" := TenderHeader."Bid Validity Date";
        TenderArchive.Insert();

        // Archive lines
        TenderLine.SetRange("Tender No.", TenderHeader."Tender No.");
        if TenderLine.FindSet() then
            repeat
                TenderLineArchive.Init();
                TenderLineArchive."Tender No." := TenderLine."Tender No.";
                TenderLineArchive."Version No." := VersionNo;
                TenderLineArchive."Line No." := TenderLine."Line No.";
                TenderLineArchive.Indentation := TenderLine.Indentation;
                TenderLineArchive."Line Type" := TenderLine."Line Type";
                TenderLineArchive."BOQ Serial No." := TenderLine."BOQ Serial No.";
                TenderLineArchive."Item No." := TenderLine."Item No.";
                TenderLineArchive.Description := TenderLine.Description;
                TenderLineArchive."Short Description" := TenderLine."Short Description";
                TenderLineArchive."Unit of Measure Code" := TenderLine."Unit of Measure Code";
                TenderLineArchive.Quantity := TenderLine.Quantity;
                TenderLineArchive."Unit Cost" := TenderLine."Unit Cost";
                TenderLineArchive."Line Amount" := TenderLine."Line Amount";
                TenderLineArchive."HSN/SAC Code" := TenderLine."HSN/SAC Code";

                // Copy blob
                CopyLineBlob(TenderLine, TenderLineArchive);

                TenderLineArchive.Insert();
            until TenderLine.Next() = 0;
    end;

    local procedure CopyLineBlob(TenderLine: Record "Tender Line"; var ArchiveLine: Record "Tender Line Archive")
    var
        InStr: InStream;
        OutStr: OutStream;
    begin
        TenderLine.CalcFields("Description Blob");
        if TenderLine."Description Blob".HasValue() then begin
            TenderLine."Description Blob".CreateInStream(InStr);
            ArchiveLine."Description Blob".CreateOutStream(OutStr);
            CopyStream(OutStr, InStr);
        end;
    end;

    procedure GetArchiveCount(TenderNo: Code[20]): Integer
    var
        TenderArchive: Record "Tender Header Archive";
    begin
        TenderArchive.SetRange("Tender No.", TenderNo);
        exit(TenderArchive.Count());
    end;
}

// ============================================================
// Codeunit 50102 - Tender Corrigendum Management
// Purpose: Manages corrigendums (changes during bidding).
//          Archives state, applies changes, notifies vendors.
// ============================================================
codeunit 50102 "Tender Corrigendum Mgt."
{
    procedure CreateCorrigendum(var TenderHeader: Record "Tender Header"; ChangesType: Enum "Corrigendum Changes Type")
    var
        Corrigendum: Record "Tender Corrigendum";
        ArchiveMgt: Codeunit "Tender Archive Management";
        EventPub: Codeunit "Tender Event Publishers";
        IsHandled: Boolean;
        NextNo: Integer;
        VersionNo: Integer;
    begin
        EventPub.OnBeforeCorrigendumIssue(TenderHeader, Corrigendum, IsHandled);
        if IsHandled then
            exit;

        // Archive current state
        ArchiveMgt.ArchiveTender(TenderHeader, "Tender Archive Reason"::Corrigendum);

        // Get version number of the archive just created
        VersionNo := ArchiveMgt.GetArchiveCount(TenderHeader."Tender No.");

        // Get next corrigendum number
        Corrigendum.SetRange("Tender No.", TenderHeader."Tender No.");
        if Corrigendum.FindLast() then
            NextNo := Corrigendum."Corrigendum No." + 1
        else
            NextNo := 1;

        // Create corrigendum record
        Corrigendum.Init();
        Corrigendum."Tender No." := TenderHeader."Tender No.";
        Corrigendum."Corrigendum No." := NextNo;
        Corrigendum."Issue Date" := Today();
        Corrigendum."Changes Type" := ChangesType;
        Corrigendum."Archive Version No." := VersionNo;
        Corrigendum."Issued By User ID" := CopyStr(UserId(), 1, MaxStrLen(Corrigendum."Issued By User ID"));
        Corrigendum.Insert();

        EventPub.OnAfterCorrigendumIssued(TenderHeader, Corrigendum);
        Message('Corrigendum %1 created for Tender %2.', NextNo, TenderHeader."Tender No.");
    end;

    procedure ApplyTermsChanges(var Corrigendum: Record "Tender Corrigendum")
    var
        TenderHeader: Record "Tender Header";
    begin
        TenderHeader.Get(Corrigendum."Tender No.");
        if Corrigendum."New Bid End Date" <> 0D then
            TenderHeader."Bid End Date" := Corrigendum."New Bid End Date";
        if Corrigendum."New Bid Validity Date" <> 0D then
            TenderHeader."Bid Validity Date" := Corrigendum."New Bid Validity Date";
        TenderHeader.Modify(true);
    end;

    procedure NotifyVendors(var Corrigendum: Record "Tender Corrigendum")
    var
        TenderHeader: Record "Tender Header";
        EventPub: Codeunit "Tender Event Publishers";
    begin
        TenderHeader.Get(Corrigendum."Tender No.");
        Corrigendum."Vendors Notified" := true;
        Corrigendum."Notification DateTime" := CurrentDateTime();
        Corrigendum.Modify();

        EventPub.OnAfterVendorsNotified(TenderHeader, Corrigendum);
        Message('Vendors notified about Corrigendum %1.', Corrigendum."Corrigendum No.");
    end;
}

// ============================================================
// Codeunit 50103 - Tender Reverse Auction Mgt.
// Purpose: Manages the reverse auction process.
//          Creates rounds, validates bids, calculates rankings.
// ============================================================
codeunit 50103 "Tender Reverse Auction Mgt."
{
    procedure InitializeAuction(var TenderHeader: Record "Tender Header")
    begin
        if TenderHeader.Status <> TenderHeader.Status::"Bidding Closed" then
            Error('Bidding must be closed before starting reverse auction.');

        TenderHeader."Auction Status" := TenderHeader."Auction Status"::"In Progress";
        TenderHeader."Current Auction Round" := 0;
        TenderHeader.Status := TenderHeader.Status::"Reverse Auction";
        TenderHeader.Modify(true);

        CreateNewRound(TenderHeader."Tender No.");
        Message('Reverse Auction initialized for Tender %1.', TenderHeader."Tender No.");
    end;

    procedure CreateNewRound(TenderNo: Code[20])
    var
        TenderHeader: Record "Tender Header";
        AuctionRound: Record "Reverse Auction Round";
        TenderSetup: Record "Tender Setup";
        NextRound: Integer;
    begin
        TenderHeader.Get(TenderNo);
        TenderSetup.GetSetup();

        if TenderSetup."Max Auction Rounds" > 0 then
            if TenderHeader."Current Auction Round" >= TenderSetup."Max Auction Rounds" then
                Error('Maximum number of auction rounds (%1) reached.', TenderSetup."Max Auction Rounds");

        AuctionRound.SetRange("Tender No.", TenderNo);
        if AuctionRound.FindLast() then
            NextRound := AuctionRound."Round No." + 1
        else
            NextRound := 1;

        AuctionRound.Init();
        AuctionRound."Tender No." := TenderNo;
        AuctionRound."Round No." := NextRound;
        AuctionRound.Status := AuctionRound.Status::Scheduled;
        AuctionRound."Time Limit Minutes" := TenderSetup."Default Round Time Limit";
        AuctionRound."Min Decrement Percentage" := TenderSetup."Min Decrement Percentage";
        AuctionRound."Min Decrement Amount" := TenderSetup."Min Decrement Amount";
        AuctionRound."Created By User ID" := CopyStr(UserId(), 1, MaxStrLen(AuctionRound."Created By User ID"));
        AuctionRound.Insert();

        TenderHeader."Current Auction Round" := NextRound;
        TenderHeader.Modify();

        Message('Auction Round %1 created for Tender %2.', NextRound, TenderNo);
    end;

    procedure OpenRound(TenderNo: Code[20]; RoundNo: Integer)
    var
        AuctionRound: Record "Reverse Auction Round";
        EventPub: Codeunit "Tender Event Publishers";
        TenderHeader: Record "Tender Header";
        IsHandled: Boolean;
    begin
        AuctionRound.Get(TenderNo, RoundNo);
        if AuctionRound.Status <> AuctionRound.Status::Scheduled then
            Error('Round must be in Scheduled status to open.');

        TenderHeader.Get(TenderNo);
        EventPub.OnBeforeAuctionRoundOpen(TenderHeader, RoundNo, IsHandled);
        if IsHandled then
            exit;

        AuctionRound.Status := AuctionRound.Status::Open;
        AuctionRound."Round Start DateTime" := CurrentDateTime();
        if AuctionRound."Time Limit Minutes" > 0 then
            AuctionRound."Round End DateTime" := CurrentDateTime() + (AuctionRound."Time Limit Minutes" * 60000);
        AuctionRound.Modify();

        Message('Round %1 is now open.', RoundNo);
    end;

    procedure CloseRound(TenderNo: Code[20]; RoundNo: Integer)
    var
        AuctionRound: Record "Reverse Auction Round";
        EventPub: Codeunit "Tender Event Publishers";
        TenderHeader: Record "Tender Header";
    begin
        AuctionRound.Get(TenderNo, RoundNo);
        AuctionRound.Status := AuctionRound.Status::Closed;
        AuctionRound."Round End DateTime" := CurrentDateTime();
        AuctionRound.Modify();

        CalculateRankings(TenderNo, RoundNo);

        TenderHeader.Get(TenderNo);
        EventPub.OnAfterAuctionRoundClosed(TenderHeader, RoundNo);
        Message('Round %1 closed.', RoundNo);
    end;

    procedure ValidateBidDecrement(AuctionEntry: Record "Reverse Auction Entry")
    var
        TenderSetup: Record "Tender Setup";
    begin
        TenderSetup.GetSetup();

        case TenderSetup."Decrement Type" of
            TenderSetup."Decrement Type"::Percentage:
                if AuctionEntry."Decrement Percentage" < TenderSetup."Min Decrement Percentage" then
                    Error('Bid must decrease by at least %1%.', TenderSetup."Min Decrement Percentage");
            TenderSetup."Decrement Type"::Amount:
                if AuctionEntry."Decrement Amount" < TenderSetup."Min Decrement Amount" then
                    Error('Bid must decrease by at least %1.', TenderSetup."Min Decrement Amount");
            TenderSetup."Decrement Type"::Either:
                if (AuctionEntry."Decrement Percentage" < TenderSetup."Min Decrement Percentage") and
                   (AuctionEntry."Decrement Amount" < TenderSetup."Min Decrement Amount") then
                    Error('Bid must decrease by at least %1% or %2.',
                        TenderSetup."Min Decrement Percentage", TenderSetup."Min Decrement Amount");
        end;
    end;

    procedure CalculateRankings(TenderNo: Code[20]; RoundNo: Integer)
    var
        AuctionEntry: Record "Reverse Auction Entry";
        TenderLine: Record "Tender Line";
        Rank: Integer;
    begin
        TenderLine.SetRange("Tender No.", TenderNo);
        TenderLine.SetFilter("Line Type", '%1|%2',
            TenderLine."Line Type"::"Line Item", TenderLine."Line Type"::"Sub Item");
        if TenderLine.FindSet() then
            repeat
                AuctionEntry.SetRange("Tender No.", TenderNo);
                AuctionEntry.SetRange("Round No.", RoundNo);
                AuctionEntry.SetRange("Line No.", TenderLine."Line No.");
                AuctionEntry.SetCurrentKey("Tender No.", "Round No.", "Line No.", "New Unit Cost");
                AuctionEntry.Ascending(true);
                Rank := 1;
                if AuctionEntry.FindSet() then
                    repeat
                        AuctionEntry.Rank := Rank;
                        AuctionEntry.Modify();
                        Rank += 1;
                    until AuctionEntry.Next() = 0;
            until TenderLine.Next() = 0;
    end;

    procedure FinalizeAuction(var TenderHeader: Record "Tender Header")
    var
        EventPub: Codeunit "Tender Event Publishers";
        IsHandled: Boolean;
    begin
        EventPub.OnBeforeAuctionFinalized(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        TenderHeader."Auction Status" := TenderHeader."Auction Status"::Closed;
        TenderHeader.Modify(true);
        Message('Reverse Auction finalized for Tender %1.', TenderHeader."Tender No.");
    end;
}

// ============================================================
// Codeunit 50104 - Tender Import/Export
// Purpose: Handles BOQ import/export from/to Excel.
//          Supports both HSN (item-based) and SAC (service-based) formats.
//
// HSN Import: Item No., Quantity, Unit Cost
// SAC Import: Indentation, BOQ Serial No., Description, UoM, Qty, Rate
// ============================================================
codeunit 50104 "Tender Import Export"
{
    procedure ImportBOQ_HSN(TenderNo: Code[20])
    var
        TenderHeader: Record "Tender Header";
        TenderLine: Record "Tender Line";
        ExcelBuffer: Record "Excel Buffer" temporary;
        InStr: InStream;
        FileName: Text;
        SheetName: Text;
        RowNo: Integer;
        LineNo: Integer;
        ItemNo: Code[20];
        Qty: Decimal;
        UnitCost: Decimal;
        ImportCount: Integer;
        EventPub: Codeunit "Tender Event Publishers";
        IsHandled: Boolean;
    begin
        TenderHeader.Get(TenderNo);
        if TenderHeader."Item Type" <> TenderHeader."Item Type"::HSN then
            Error('This function is only for HSN type tenders.');

        EventPub.OnBeforeBOQImport(TenderHeader, 'HSN', IsHandled);
        if IsHandled then
            exit;

        // Upload file
        if not UploadIntoStream('Select BOQ Excel File', '', 'Excel Files (*.xlsx)|*.xlsx', FileName, InStr) then
            exit;

        SheetName := ExcelBuffer.SelectSheetsNameStream(InStr);
        if SheetName = '' then
            exit;

        ExcelBuffer.Reset();
        ExcelBuffer.DeleteAll();
        ExcelBuffer.OpenBookStream(InStr, SheetName);
        ExcelBuffer.ReadSheet();

        // Validate header row
        ValidateHSNColumns(ExcelBuffer);

        LineNo := GetNextLineNo(TenderNo);

        // Read data rows (starting from row 2)
        RowNo := 2;
        while ExcelHasRow(ExcelBuffer, RowNo) do begin
            ItemNo := CopyStr(GetCellValue(ExcelBuffer, RowNo, 1), 1, 20);
            Evaluate(Qty, GetCellValueOrZero(ExcelBuffer, RowNo, 2));
            Evaluate(UnitCost, GetCellValueOrZero(ExcelBuffer, RowNo, 3));

            if ItemNo <> '' then begin
                TenderLine.Init();
                TenderLine."Tender No." := TenderNo;
                TenderLine."Line No." := LineNo;
                TenderLine.Indentation := 2;
                TenderLine."Line Type" := TenderLine."Line Type"::"Line Item";
                TenderLine.Style := TenderLine.Style::Normal;
                TenderLine.Validate("Item No.", ItemNo);
                TenderLine.Validate(Quantity, Qty);
                TenderLine.Validate("Unit Cost", UnitCost);
                TenderLine.Imported := true;
                TenderLine.Insert(true);

                EventPub.OnAfterBOQLineImported(TenderLine, 'HSN');
                LineNo += 10000;
                ImportCount += 1;
            end;

            RowNo += 1;
        end;

        EventPub.OnAfterBOQImportCompleted(TenderHeader, 'HSN', ImportCount);
        Message('%1 HSN lines imported successfully.', ImportCount);
    end;

    procedure ImportBOQ_SAC(TenderNo: Code[20])
    var
        TenderHeader: Record "Tender Header";
        TenderLine: Record "Tender Line";
        ExcelBuffer: Record "Excel Buffer" temporary;
        InStr: InStream;
        FileName: Text;
        SheetName: Text;
        RowNo: Integer;
        LineNo: Integer;
        IndentLevel: Integer;
        SerialNo: Text[20];
        Desc: Text;
        UoM: Code[20];
        Qty: Decimal;
        UnitCost: Decimal;
        ImportCount: Integer;
        EventPub: Codeunit "Tender Event Publishers";
        IsHandled: Boolean;
    begin
        TenderHeader.Get(TenderNo);
        if TenderHeader."Item Type" <> TenderHeader."Item Type"::SAC then
            Error('This function is only for SAC type tenders.');

        EventPub.OnBeforeBOQImport(TenderHeader, 'SAC', IsHandled);
        if IsHandled then
            exit;

        if not UploadIntoStream('Select BOQ Excel File', '', 'Excel Files (*.xlsx)|*.xlsx', FileName, InStr) then
            exit;

        SheetName := ExcelBuffer.SelectSheetsNameStream(InStr);
        if SheetName = '' then
            exit;

        ExcelBuffer.Reset();
        ExcelBuffer.DeleteAll();
        ExcelBuffer.OpenBookStream(InStr, SheetName);
        ExcelBuffer.ReadSheet();

        LineNo := GetNextLineNo(TenderNo);

        // Read data rows (starting from row 2)
        RowNo := 2;
        while ExcelHasRow(ExcelBuffer, RowNo) do begin
            Evaluate(IndentLevel, GetCellValueOrZero(ExcelBuffer, RowNo, 1));
            SerialNo := CopyStr(GetCellValue(ExcelBuffer, RowNo, 2), 1, 20);
            Desc := GetCellValue(ExcelBuffer, RowNo, 3);
            UoM := CopyStr(GetCellValue(ExcelBuffer, RowNo, 4), 1, 20);
            Evaluate(Qty, GetCellValueOrZero(ExcelBuffer, RowNo, 5));
            Evaluate(UnitCost, GetCellValueOrZero(ExcelBuffer, RowNo, 6));

            if (SerialNo <> '') or (Desc <> '') then begin
                TenderLine.Init();
                TenderLine."Tender No." := TenderNo;
                TenderLine."Line No." := LineNo;
                TenderLine."BOQ Serial No." := SerialNo;
                TenderLine.Validate(Indentation, IndentLevel);

                // Store description
                if StrLen(Desc) > MaxStrLen(TenderLine.Description) then begin
                    TenderLine.Description := CopyStr(Desc, 1, MaxStrLen(TenderLine.Description));
                    TenderLine."Short Description" := CopyStr(Desc, 1, MaxStrLen(TenderLine."Short Description"));
                end else begin
                    TenderLine.Description := CopyStr(Desc, 1, MaxStrLen(TenderLine.Description));
                    TenderLine."Short Description" := CopyStr(Desc, 1, MaxStrLen(TenderLine."Short Description"));
                end;

                // Only set quantity fields for line items
                if TenderLine.IsQuantityLine() then begin
                    TenderLine."Unit of Measure Code" := UoM;
                    TenderLine.Validate(Quantity, Qty);
                    TenderLine.Validate("Unit Cost", UnitCost);
                end;

                TenderLine.Imported := true;
                TenderLine.Insert(true);

                // Store blob for long descriptions
                if StrLen(Desc) > MaxStrLen(TenderLine.Description) then
                    TenderLine.SetDescriptionBlob(Desc);

                EventPub.OnAfterBOQLineImported(TenderLine, 'SAC');
                LineNo += 10000;
                ImportCount += 1;
            end;

            RowNo += 1;
        end;

        EventPub.OnAfterBOQImportCompleted(TenderHeader, 'SAC', ImportCount);
        Message('%1 SAC lines imported successfully.', ImportCount);
    end;

    procedure ImportAmendedBOQ(TenderNo: Code[20])
    var
        TenderHeader: Record "Tender Header";
        TenderLine: Record "Tender Line";
        ArchiveMgt: Codeunit "Tender Archive Management";
        EventPub: Codeunit "Tender Event Publishers";
        IsHandled: Boolean;
    begin
        TenderHeader.Get(TenderNo);

        EventPub.OnBeforeAmendedBOQImport(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        // Archive current lines
        ArchiveMgt.ArchiveTender(TenderHeader, "Tender Archive Reason"::Amendment);

        // Delete existing lines
        TenderLine.SetRange("Tender No.", TenderNo);
        TenderLine.DeleteAll();

        // Import new BOQ based on type
        case TenderHeader."Item Type" of
            TenderHeader."Item Type"::HSN:
                ImportBOQ_HSN(TenderNo);
            TenderHeader."Item Type"::SAC:
                ImportBOQ_SAC(TenderNo);
        end;

        TenderHeader.Status := TenderHeader.Status::Amended;
        TenderHeader.Modify(true);

        EventPub.OnAfterAmendedBOQImport(TenderHeader);
    end;

    // --- Excel Helper Functions ---

    local procedure GetCellValue(var ExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer): Text
    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            exit(ExcelBuffer."Cell Value as Text");
        exit('');
    end;

    local procedure GetCellValueOrZero(var ExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer): Text
    var
        Val: Text;
    begin
        Val := GetCellValue(ExcelBuffer, RowNo, ColNo);
        if Val = '' then
            exit('0');
        exit(Val);
    end;

    local procedure ExcelHasRow(var ExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer): Boolean
    begin
        ExcelBuffer.SetRange("Row No.", RowNo);
        exit(not ExcelBuffer.IsEmpty());
    end;

    local procedure ValidateHSNColumns(var ExcelBuffer: Record "Excel Buffer" temporary)
    begin
        // Validate that row 1 has the expected headers
        if GetCellValue(ExcelBuffer, 1, 1) = '' then
            Error('Excel file must have headers in row 1. Expected: Item No., Quantity, Unit Cost');
    end;

    local procedure GetNextLineNo(TenderNo: Code[20]): Integer
    var
        TenderLine: Record "Tender Line";
    begin
        TenderLine.SetRange("Tender No.", TenderNo);
        if TenderLine.FindLast() then
            exit(TenderLine."Line No." + 10000);
        exit(10000);
    end;
}

// ============================================================
// Codeunit 50105 - Tender Disqualification Engine
// Purpose: Runs auto-disqualification rules against vendors.
// ============================================================
codeunit 50105 "Tender Disqualification Engine"
{
    procedure RunAutoDisqualification(TenderNo: Code[20])
    var
        TenderVendor: Record "Tender Vendor Allocation";
        Rule: Record "Tender Disqualification Rule";
        Passed: Boolean;
        Reason: Text[250];
        QualifiedCount: Integer;
        DisqualifiedCount: Integer;
    begin
        Rule.SetRange("Tender No.", TenderNo);
        Rule.SetRange(Active, true);
        if Rule.IsEmpty() then begin
            Message('No active disqualification rules found.');
            exit;
        end;

        TenderVendor.SetRange("Tender No.", TenderNo);
        TenderVendor.SetFilter("Quote Status", '<>%1', TenderVendor."Quote Status"::Disqualified);
        if TenderVendor.FindSet() then
            repeat
                if CheckSingleVendor(TenderNo, TenderVendor."Vendor No.", Reason) then
                    QualifiedCount += 1
                else begin
                    TenderVendor."Quote Status" := TenderVendor."Quote Status"::Disqualified;
                    TenderVendor."Disqualification Reason" := Reason;
                    TenderVendor.Modify();
                    DisqualifiedCount += 1;
                end;
            until TenderVendor.Next() = 0;

        Message('Disqualification check complete.\%1 vendor(s) qualified, %2 vendor(s) disqualified.',
            QualifiedCount, DisqualifiedCount);
    end;

    procedure CheckSingleVendor(TenderNo: Code[20]; VendorNo: Code[20]; var FailReason: Text[250]): Boolean
    var
        Rule: Record "Tender Disqualification Rule";
        QuestResp: Record "Tender Quest. Response";
        EventPub: Codeunit "Tender Event Publishers";
        Passed: Boolean;
        CustomPassed: Boolean;
        IsHandled: Boolean;
    begin
        FailReason := '';
        Rule.SetRange("Tender No.", TenderNo);
        Rule.SetRange(Active, true);
        Rule.SetRange(Mandatory, true);
        if Rule.FindSet() then
            repeat
                case Rule."Rule Type" of
                    Rule."Rule Type"::"Mandatory Questionnaire":
                        begin
                            QuestResp.SetRange("Tender No.", TenderNo);
                            QuestResp.SetRange("Vendor No.", VendorNo);
                            if QuestResp.IsEmpty() then begin
                                FailReason := 'Mandatory questionnaire not answered.';
                                exit(false);
                            end;
                        end;
                    Rule."Rule Type"::"Min Experience Years":
                        begin
                            // Check via questionnaire response
                            QuestResp.SetRange("Tender No.", TenderNo);
                            QuestResp.SetRange("Vendor No.", VendorNo);
                            QuestResp.SetFilter("Answer Number", '<%1', Rule."Min Value");
                            if not QuestResp.IsEmpty() then begin
                                FailReason := StrSubstNo('Does not meet minimum experience of %1 years.', Rule."Min Value");
                                exit(false);
                            end;
                        end;
                    Rule."Rule Type"::Custom:
                        begin
                            CustomPassed := true;
                            EventPub.OnEvaluateCustomRule(TenderNo, VendorNo, Rule, CustomPassed, FailReason, IsHandled);
                            if not CustomPassed then
                                exit(false);
                        end;
                end;
            until Rule.Next() = 0;

        exit(true);
    end;
}

// ============================================================
// Codeunit 50106 - Tender Source Module Dispatcher
// Purpose: Routes calls to the correct source module implementation.
//          Uses the Interface + Enum pattern for extensibility.
// ============================================================
codeunit 50106 "Tender Source Dispatcher"
{
    procedure GetSourceInterface(SourceModule: Enum "Tender Source Module"): Interface ITenderSourceModule
    var
        ProjectSource: Codeunit "Project Tender Source";
        GSSource: Codeunit "Gen. Service Tender Source";
    begin
        case SourceModule of
            SourceModule::Project:
                exit(ProjectSource);
            SourceModule::"General Service":
                exit(GSSource);
            else
                Error('Source module %1 is not supported.', SourceModule);
        end;
    end;

    procedure ValidateSource(TenderHeader: Record "Tender Header"): Boolean
    var
        SourceIntf: Interface ITenderSourceModule;
    begin
        if TenderHeader."Source Module" = TenderHeader."Source Module"::" " then
            exit(true);
        SourceIntf := GetSourceInterface(TenderHeader."Source Module");
        exit(SourceIntf.ValidateSourceID(TenderHeader."Source ID"));
    end;

    procedure FillSourceData(var TenderHeader: Record "Tender Header")
    var
        SourceIntf: Interface ITenderSourceModule;
        StartDate: Date;
        EndDate: Date;
        DimSetID: Integer;
    begin
        if TenderHeader."Source Module" = TenderHeader."Source Module"::" " then
            exit;

        SourceIntf := GetSourceInterface(TenderHeader."Source Module");

        if not SourceIntf.ValidateSourceID(TenderHeader."Source ID") then
            Error('Source ID %1 is not valid for module %2.',
                TenderHeader."Source ID", TenderHeader."Source Module");

        TenderHeader."Budget Amount" := SourceIntf.GetBudgetAmount(TenderHeader."Source ID");
        TenderHeader."Business Unit Code" := SourceIntf.GetBusinessUnit(TenderHeader."Source ID");
        TenderHeader."Sanction No." := SourceIntf.GetSanctionNo(TenderHeader."Source ID");
        SourceIntf.GetDimensions(TenderHeader."Source ID", DimSetID);
        TenderHeader."Dimension Set ID" := DimSetID;
    end;

    procedure NotifySourceOnOrderCreated(TenderHeader: Record "Tender Header"; OrderNo: Code[20])
    var
        SourceIntf: Interface ITenderSourceModule;
    begin
        if TenderHeader."Source Module" = TenderHeader."Source Module"::" " then
            exit;
        SourceIntf := GetSourceInterface(TenderHeader."Source Module");
        SourceIntf.OnAfterOrderCreated(TenderHeader."Tender No.", OrderNo);
    end;
}

// ============================================================
// Codeunit 50107 - Tender Event Publishers
// Purpose: Central place for ALL tender events.
//          External modules subscribe to these events.
// ============================================================
codeunit 50107 "Tender Event Publishers"
{
    // --- Tender Lifecycle ---
    [IntegrationEvent(false, false)]
    procedure OnAfterTenderCreated(var TenderHeader: Record "Tender Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeTenderApproval(var TenderHeader: Record "Tender Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterTenderApproved(var TenderHeader: Record "Tender Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterTenderRejected(var TenderHeader: Record "Tender Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeQuoteCreation(var TenderHeader: Record "Tender Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterQuoteCreated(TenderHeader: Record "Tender Header"; PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeVendorSelection(var TenderHeader: Record "Tender Header"; VendorNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterVendorSelected(TenderHeader: Record "Tender Header"; VendorNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeOrderCreation(var TenderHeader: Record "Tender Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterOrderCreated(TenderHeader: Record "Tender Header"; OrderNo: Code[20]; OrderDocType: Enum "Tender Order Document Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeTenderClose(var TenderHeader: Record "Tender Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterTenderClosed(var TenderHeader: Record "Tender Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeReTender(var TenderHeader: Record "Tender Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterReTender(OldTenderNo: Code[20]; NewTenderNo: Code[20])
    begin
    end;

    // --- NIT ---
    [IntegrationEvent(false, false)]
    procedure OnBeforeNITPublish(var TenderHeader: Record "Tender Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterNITPublish(var TenderHeader: Record "Tender Header")
    begin
    end;

    // --- Negotiation ---
    [IntegrationEvent(false, false)]
    procedure OnAfterNegotiationApproved(var TenderHeader: Record "Tender Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeAmendedBOQImport(var TenderHeader: Record "Tender Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterAmendedBOQImport(var TenderHeader: Record "Tender Header")
    begin
    end;

    // --- Corrigendum ---
    [IntegrationEvent(false, false)]
    procedure OnBeforeCorrigendumIssue(var TenderHeader: Record "Tender Header"; var Corrigendum: Record "Tender Corrigendum"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCorrigendumIssued(TenderHeader: Record "Tender Header"; Corrigendum: Record "Tender Corrigendum")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterVendorsNotified(TenderHeader: Record "Tender Header"; Corrigendum: Record "Tender Corrigendum")
    begin
    end;

    // --- Reverse Auction ---
    [IntegrationEvent(false, false)]
    procedure OnBeforeAuctionRoundOpen(var TenderHeader: Record "Tender Header"; RoundNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterAuctionRoundClosed(TenderHeader: Record "Tender Header"; RoundNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeAuctionFinalized(var TenderHeader: Record "Tender Header"; var IsHandled: Boolean)
    begin
    end;

    // --- Disqualification ---
    [IntegrationEvent(false, false)]
    procedure OnEvaluateCustomRule(TenderNo: Code[20]; VendorNo: Code[20]; Rule: Record "Tender Disqualification Rule"; var Passed: Boolean; var Reason: Text[250]; var IsHandled: Boolean)
    begin
    end;

    // --- BOQ Import ---
    [IntegrationEvent(false, false)]
    procedure OnBeforeBOQImport(var TenderHeader: Record "Tender Header"; ImportType: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterBOQLineImported(var TenderLine: Record "Tender Line"; ImportType: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterBOQImportCompleted(TenderHeader: Record "Tender Header"; ImportType: Text; LineCount: Integer)
    begin
    end;

    // --- Rate Contract ---
    [IntegrationEvent(false, false)]
    procedure OnBeforeRateContractPOCreated(TenderNo: Code[20]; var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterRateContractPOCreated(TenderNo: Code[20]; PurchaseHeader: Record "Purchase Header")
    begin
    end;

    // --- Digital Signature ---
    [IntegrationEvent(false, false)]
    procedure OnSignatureRequested(TenderNo: Code[20]; Stage: Enum "Tender Signature Stage"; UserID: Code[50]; var IsHandled: Boolean)
    begin
    end;
}