// ============================================================
// Codeunit 50100: Tender Management
// ============================================================
codeunit 50100 "Tender Management"
{
    procedure CreateTender(var TenderHeader: Record "Tender Header")
    begin
        TenderHeader.Init();
        TenderHeader.Insert(true);
        TenderHeader.Status := TenderHeader.Status::Draft;
        TenderHeader.Modify();

        TenderEventPublisher.OnAfterTenderCreated(TenderHeader);
    end;

    procedure UpdateStatus(var TenderHeader: Record "Tender Header"; NewStatus: Enum "Tender Status")
    begin
        ValidateStatusTransition(TenderHeader, NewStatus);
        TenderHeader.Status := NewStatus;
        TenderHeader.Modify(true);
    end;

    procedure ValidateStatusTransition(TenderHeader: Record "Tender Header"; NewStatus: Enum "Tender Status")
    var
        TenderLine: Record "Tender Line";
        VendorAlloc: Record "Tender Vendor Allocation";
    begin
        case NewStatus of
            NewStatus::"Vendors Allocated":
                begin
                    VendorAlloc.SetRange("Tender No.", TenderHeader."No.");
                    if VendorAlloc.IsEmpty then
                        Error('At least one vendor must be allocated.');
                end;
            NewStatus::"Pending Approval":
                begin
                    TenderLine.SetRange("Tender No.", TenderHeader."No.");
                    if TenderLine.IsEmpty then
                        Error('At least one tender line must exist.');
                    CheckMandatoryFields(TenderHeader);
                end;
            NewStatus::"Approved":
                begin
                    if TenderHeader.Status <> TenderHeader.Status::"Pending Approval" then
                        Error('Tender must be in Pending Approval status.');
                end;
            NewStatus::"Quotes Created":
                begin
                    if TenderHeader.Status <> TenderHeader.Status::Approved then
                        Error('Tender must be in Approved status.');
                end;
            NewStatus::"Bidding Open":
                begin
                    if TenderHeader."Bid Start Date" = 0D then
                        Error('Bid Start Date must be specified.');
                end;
            NewStatus::"Bidding Closed":
                begin
                    if TenderHeader."Bid End Date" = 0D then
                        Error('Bid End Date must be specified.');
                end;
            NewStatus::"Vendor Selected":
                begin
                    VendorAlloc.SetRange("Tender No.", TenderHeader."No.");
                    VendorAlloc.SetRange("Is Selected Vendor", true);
                    if VendorAlloc.IsEmpty then
                        Error('A vendor must be selected.');
                end;
            NewStatus::"Negotiation Approved":
                begin
                    if TenderHeader.Status <> TenderHeader.Status::Negotiation then
                        Error('Tender must be in Negotiation status.');
                end;
            NewStatus::"Order Created":
                begin
                    if not (TenderHeader.Status in [TenderHeader.Status::"Negotiation Approved"]) then
                        Error('Negotiation must be approved before creating an order.');
                end;
        end;
    end;

    procedure CheckMandatoryFields(TenderHeader: Record "Tender Header")
    begin
        TenderHeader.TestField(Description);
        TenderHeader.TestField("Item Type");
        TenderHeader.TestField("Tender Type");
        TenderHeader.TestField("Bid End Date");
    end;

    procedure AllocateVendor(TenderNo: Code[20]; VendorNo: Code[20])
    var
        VendorAlloc: Record "Tender Vendor Allocation";
        TenderHeader: Record "Tender Header";
    begin
        TenderHeader.Get(TenderNo);
        if not (TenderHeader.Status in [TenderHeader.Status::Draft, TenderHeader.Status::"Vendors Allocated"]) then
            Error('Vendors can only be allocated in Draft or Vendors Allocated status.');

        CheckVendorNotBlacklisted(VendorNo);

        VendorAlloc.Init();
        VendorAlloc."Tender No." := TenderNo;
        VendorAlloc."Vendor No." := VendorNo;
        VendorAlloc.Validate("Vendor No.");
        VendorAlloc.Insert(true);

        if TenderHeader.Status = TenderHeader.Status::Draft then
            UpdateStatus(TenderHeader, TenderHeader.Status::"Vendors Allocated");
    end;

    procedure RemoveVendor(TenderNo: Code[20]; VendorNo: Code[20])
    var
        VendorAlloc: Record "Tender Vendor Allocation";
    begin
        VendorAlloc.Get(TenderNo, VendorNo);
        if VendorAlloc."Quote No." <> '' then
            Error('Cannot remove vendor after quote has been created.');
        VendorAlloc.Delete(true);
    end;

    procedure CheckVendorNotBlacklisted(VendorNo: Code[20])
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(VendorNo);
        if Vendor.Blocked <> Vendor.Blocked::" " then
            Error('Vendor %1 is blocked and cannot be allocated.', VendorNo);
    end;

    procedure CreateQuotesForAllVendors(var TenderHeader: Record "Tender Header")
    var
        VendorAlloc: Record "Tender Vendor Allocation";
    begin
        if TenderHeader.Status <> TenderHeader.Status::Approved then
            Error('Tender must be in Approved status to create quotes.');

        VendorAlloc.SetRange("Tender No.", TenderHeader."No.");
        VendorAlloc.SetFilter("Quote Status", '%1', VendorAlloc."Quote Status"::"Not Created");
        if VendorAlloc.FindSet() then
            repeat
                CreateSingleQuote(TenderHeader, VendorAlloc);
            until VendorAlloc.Next() = 0;

        UpdateStatus(TenderHeader, TenderHeader.Status::"Quotes Created");
    end;

    procedure CreateSingleQuote(TenderHeader: Record "Tender Header"; var VendorAlloc: Record "Tender Vendor Allocation")
    var
        PurchHeader: Record "Purchase Header";
    begin
        PurchHeader.Init();
        PurchHeader."Document Type" := PurchHeader."Document Type"::Quote;
        PurchHeader.Insert(true);
        PurchHeader.Validate("Buy-from Vendor No.", VendorAlloc."Vendor No.");
        if VendorAlloc."Currency Code" <> '' then
            PurchHeader.Validate("Currency Code", VendorAlloc."Currency Code");
        PurchHeader."Tender No." := TenderHeader."No.";
        PurchHeader."Source Module" := TenderHeader."Source Module";
        PurchHeader."Source ID" := TenderHeader."Source ID";
        PurchHeader."Tender Item Type" := TenderHeader."Item Type";
        PurchHeader."Bid Validity Date" := TenderHeader."Bid Validity Date";
        PurchHeader.Modify(true);

        CopyTenderLinesToQuote(TenderHeader."No.", PurchHeader);

        VendorAlloc."Quote No." := PurchHeader."No.";
        VendorAlloc."Quote Status" := VendorAlloc."Quote Status"::Created;
        VendorAlloc.Modify();

        TenderEventPublisher.OnAfterQuoteCreated(TenderHeader, PurchHeader);
    end;

    procedure CopyTenderLinesToQuote(TenderNo: Code[20]; var PurchHeader: Record "Purchase Header")
    var
        TenderLine: Record "Tender Line";
        PurchLine: Record "Purchase Line";
        LineNo: Integer;
        InStr: InStream;
        OutStr: OutStream;
        BlobText: Text;
    begin
        TenderLine.SetRange("Tender No.", TenderNo);
        if TenderLine.FindSet() then begin
            LineNo := 10000;
            repeat
                PurchLine.Init();
                PurchLine."Document Type" := PurchHeader."Document Type";
                PurchLine."Document No." := PurchHeader."No.";
                PurchLine."Line No." := LineNo;
                PurchLine."Tender Line No." := TenderLine."Line No.";
                PurchLine."Indentation" := TenderLine.Indentation;
                PurchLine."Line Type" := TenderLine."Line Type";
                PurchLine."BOQ Serial No." := TenderLine."BOQ Serial No.";
                PurchLine."Short Description" := TenderLine."Short Description";
                PurchLine."Style" := TenderLine.Style;
                PurchLine."Parent Line No." := TenderLine."Parent Line No.";

                if TenderLine."Item No." <> '' then begin
                    PurchLine.Type := PurchLine.Type::Item;
                    PurchLine.Validate("No.", TenderLine."Item No.");
                end else begin
                    PurchLine.Type := PurchLine.Type::" ";
                    PurchLine.Description := TenderLine.Description;
                end;

                if not TenderLine.IsHeadingLine() then begin
                    PurchLine."Unit of Measure Code" := TenderLine."Unit of Measure Code";
                    PurchLine.Quantity := TenderLine.Quantity;
                    PurchLine."Direct Unit Cost" := TenderLine."Unit Cost";
                end;

                // Copy Blob
                TenderLine.CalcFields("Description Blob");
                if TenderLine."Description Blob".HasValue then begin
                    BlobText := TenderLine.GetDescriptionBlob();
                    Clear(PurchLine."Description Blob");
                    PurchLine."Description Blob".CreateOutStream(OutStr);
                    OutStr.WriteText(BlobText);
                end;

                PurchLine.Insert(true);
                LineNo += 10000;
            until TenderLine.Next() = 0;
        end;
    end;

    procedure SelectVendor(TenderNo: Code[20]; VendorNo: Code[20])
    var
        VendorAlloc: Record "Tender Vendor Allocation";
        TenderHeader: Record "Tender Header";
        IsHandled: Boolean;
    begin
        TenderEventPublisher.OnBeforeVendorSelection(TenderHeader, VendorNo, IsHandled);
        if IsHandled then
            exit;

        VendorAlloc.Get(TenderNo, VendorNo);
        VendorAlloc.Validate("Is Selected Vendor", true);
        VendorAlloc.Modify(true);

        TenderHeader.Get(TenderNo);
        UpdateStatus(TenderHeader, TenderHeader.Status::"Vendor Selected");

        TenderEventPublisher.OnAfterVendorSelected(TenderHeader, VendorNo);
    end;

    procedure DeselectVendor(TenderNo: Code[20]; VendorNo: Code[20])
    var
        VendorAlloc: Record "Tender Vendor Allocation";
    begin
        VendorAlloc.Get(TenderNo, VendorNo);
        VendorAlloc."Is Selected Vendor" := false;
        VendorAlloc.Modify(true);
    end;

    procedure CreatePurchaseOrder(var TenderHeader: Record "Tender Header")
    var
        VendorAlloc: Record "Tender Vendor Allocation";
        PurchQuoteHeader: Record "Purchase Header";
        PurchOrderHeader: Record "Purchase Header";
        PurchQuoteLine: Record "Purchase Line";
        PurchOrderLine: Record "Purchase Line";
        LineNo: Integer;
        IsHandled: Boolean;
    begin
        TenderEventPublisher.OnBeforeOrderCreation(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        if TenderHeader."Item Type" <> TenderHeader."Item Type"::HSN then
            Error('Purchase Order can only be created for HSN type tenders.');

        ValidateStatusTransition(TenderHeader, TenderHeader.Status::"Order Created");

        VendorAlloc.SetRange("Tender No.", TenderHeader."No.");
        VendorAlloc.SetRange("Is Selected Vendor", true);
        VendorAlloc.FindFirst();

        // Create PO from selected vendor's quote
        PurchOrderHeader.Init();
        PurchOrderHeader."Document Type" := PurchOrderHeader."Document Type"::Order;
        PurchOrderHeader.Insert(true);
        PurchOrderHeader.Validate("Buy-from Vendor No.", VendorAlloc."Vendor No.");
        if VendorAlloc."Currency Code" <> '' then
            PurchOrderHeader.Validate("Currency Code", VendorAlloc."Currency Code");
        PurchOrderHeader."Tender No." := TenderHeader."No.";
        PurchOrderHeader."Source Module" := TenderHeader."Source Module";
        PurchOrderHeader."Source ID" := TenderHeader."Source ID";
        PurchOrderHeader."Tender Item Type" := TenderHeader."Item Type";
        PurchOrderHeader.Modify(true);

        // Copy lines from vendor's quote
        if VendorAlloc."Quote No." <> '' then begin
            PurchQuoteHeader.Get(PurchQuoteHeader."Document Type"::Quote, VendorAlloc."Quote No.");
            PurchQuoteLine.SetRange("Document Type", PurchQuoteLine."Document Type"::Quote);
            PurchQuoteLine.SetRange("Document No.", VendorAlloc."Quote No.");
            LineNo := 10000;
            if PurchQuoteLine.FindSet() then
                repeat
                    PurchOrderLine.Init();
                    PurchOrderLine.TransferFields(PurchQuoteLine);
                    PurchOrderLine."Document Type" := PurchOrderLine."Document Type"::Order;
                    PurchOrderLine."Document No." := PurchOrderHeader."No.";
                    PurchOrderLine."Line No." := LineNo;
                    PurchOrderLine.Insert(true);
                    LineNo += 10000;
                until PurchQuoteLine.Next() = 0;
        end;

        TenderHeader."Created Order No." := PurchOrderHeader."No.";
        TenderHeader."Created Order Doc Type" := TenderHeader."Created Order Doc Type"::"Purchase Order";
        UpdateStatus(TenderHeader, TenderHeader.Status::"Order Created");

        TenderEventPublisher.OnAfterOrderCreated(TenderHeader, PurchOrderHeader."No.",
            TenderHeader."Created Order Doc Type");

        // Notify source module
        TenderSourceDispatcher.NotifySourceOnOrderCreated(TenderHeader, PurchOrderHeader."No.");
    end;

    procedure CreateWorkOrder(var TenderHeader: Record "Tender Header")
    var
        VendorAlloc: Record "Tender Vendor Allocation";
        PurchHeader: Record "Purchase Header";
        TenderSetup: Record "Tender Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
    begin
        TenderEventPublisher.OnBeforeOrderCreation(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        if TenderHeader."Item Type" <> TenderHeader."Item Type"::SAC then
            Error('Work Order can only be created for SAC type tenders.');

        ValidateStatusTransition(TenderHeader, TenderHeader.Status::"Order Created");

        VendorAlloc.SetRange("Tender No.", TenderHeader."No.");
        VendorAlloc.SetRange("Is Selected Vendor", true);
        VendorAlloc.FindFirst();

        TenderSetup.GetSetup();
        TenderSetup.TestField("Work Order No. Series");

        PurchHeader.Init();
        PurchHeader."Document Type" := PurchHeader."Document Type"::"Work Order";
        PurchHeader."No." := NoSeriesMgt.GetNextNo(TenderSetup."Work Order No. Series", Today, true);
        PurchHeader.Insert(true);
        PurchHeader.Validate("Buy-from Vendor No.", VendorAlloc."Vendor No.");
        if VendorAlloc."Currency Code" <> '' then
            PurchHeader.Validate("Currency Code", VendorAlloc."Currency Code");
        PurchHeader."Tender No." := TenderHeader."No.";
        PurchHeader."Source Module" := TenderHeader."Source Module";
        PurchHeader."Source ID" := TenderHeader."Source ID";
        PurchHeader."Tender Item Type" := TenderHeader."Item Type";
        PurchHeader.Modify(true);

        CopyTenderLinesToQuote(TenderHeader."No.", PurchHeader);

        TenderHeader."Created Order No." := PurchHeader."No.";
        TenderHeader."Created Order Doc Type" := TenderHeader."Created Order Doc Type"::"Work Order";
        UpdateStatus(TenderHeader, TenderHeader.Status::"Order Created");

        TenderEventPublisher.OnAfterOrderCreated(TenderHeader, PurchHeader."No.",
            TenderHeader."Created Order Doc Type");

        TenderSourceDispatcher.NotifySourceOnOrderCreated(TenderHeader, PurchHeader."No.");
    end;

    procedure CreatePOFromRateContract(TenderNo: Code[20]; var TempRateContractLine: Record "Tender Line" temporary)
    var
        TenderHeader: Record "Tender Header";
        VendorAlloc: Record "Tender Vendor Allocation";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        RCUsage: Record "Rate Contract Usage";
        TenderLine: Record "Tender Line";
        LineNo: Integer;
        IsHandled: Boolean;
    begin
        TenderHeader.Get(TenderNo);
        if TenderHeader."Tender Type" <> TenderHeader."Tender Type"::"Rate Contract" then
            Error('This is not a rate contract tender.');

        if (TenderHeader."Rate Contract Valid From" <> 0D) and (Today < TenderHeader."Rate Contract Valid From") then
            Error('Rate contract is not yet valid.');
        if (TenderHeader."Rate Contract Valid To" <> 0D) and (Today > TenderHeader."Rate Contract Valid To") then
            Error('Rate contract has expired.');

        TenderEventPublisher.OnBeforeRateContractPOCreated(TenderNo, PurchHeader, IsHandled);
        if IsHandled then
            exit;

        VendorAlloc.SetRange("Tender No.", TenderNo);
        VendorAlloc.SetRange("Is Selected Vendor", true);
        VendorAlloc.FindFirst();

        PurchHeader.Init();
        PurchHeader."Document Type" := PurchHeader."Document Type"::Order;
        PurchHeader.Insert(true);
        PurchHeader.Validate("Buy-from Vendor No.", VendorAlloc."Vendor No.");
        PurchHeader."Tender No." := TenderNo;
        PurchHeader."Rate Contract Tender No." := TenderNo;
        PurchHeader."Is Rate Contract Order" := true;
        PurchHeader.Modify(true);

        LineNo := 10000;
        if TempRateContractLine.FindSet() then
            repeat
                if TempRateContractLine.Quantity > 0 then begin
                    TenderLine.Get(TenderNo, TempRateContractLine."Line No.");

                    // Check ceiling
                    TenderLine.CalcFields("Consumed Quantity");
                    if TenderHeader."Rate Contract Ceiling Amount" > 0 then
                        if (TenderLine."Consumed Quantity" + TempRateContractLine.Quantity) > TenderLine.Quantity then
                            Error('Order quantity exceeds remaining rate contract quantity for line %1.', TenderLine."BOQ Serial No.");

                    PurchLine.Init();
                    PurchLine."Document Type" := PurchLine."Document Type"::Order;
                    PurchLine."Document No." := PurchHeader."No.";
                    PurchLine."Line No." := LineNo;
                    if TenderLine."Item No." <> '' then begin
                        PurchLine.Type := PurchLine.Type::Item;
                        PurchLine.Validate("No.", TenderLine."Item No.");
                    end;
                    PurchLine.Validate(Quantity, TempRateContractLine.Quantity);
                    PurchLine.Validate("Direct Unit Cost", TenderLine."Unit Cost");
                    PurchLine."Tender Line No." := TenderLine."Line No.";
                    PurchLine.Insert(true);

                    // Record usage
                    RCUsage.Init();
                    RCUsage."Tender No." := TenderNo;
                    RCUsage."Tender Line No." := TenderLine."Line No.";
                    RCUsage."Purchase Order No." := PurchHeader."No.";
                    RCUsage."PO Line No." := PurchLine."Line No.";
                    RCUsage."Vendor No." := VendorAlloc."Vendor No.";
                    RCUsage."Item No." := TenderLine."Item No.";
                    RCUsage.Description := TenderLine.Description;
                    RCUsage."Quantity Ordered" := TempRateContractLine.Quantity;
                    RCUsage."Unit Cost" := TenderLine."Unit Cost";
                    RCUsage."Line Amount" := TempRateContractLine.Quantity * TenderLine."Unit Cost";
                    RCUsage."Order Date" := Today;
                    RCUsage."Created By User ID" := CopyStr(UserId, 1, 50);
                    RCUsage.Insert(true);

                    LineNo += 10000;
                end;
            until TempRateContractLine.Next() = 0;

        TenderEventPublisher.OnAfterRateContractPOCreated(TenderNo, PurchHeader);
    end;

    procedure CloseTender(var TenderHeader: Record "Tender Header")
    var
        IsHandled: Boolean;
    begin
        TenderEventPublisher.OnBeforeTenderClose(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        TenderHeader."Closed Date" := Today;
        UpdateStatus(TenderHeader, TenderHeader.Status::Closed);

        TenderEventPublisher.OnAfterTenderClosed(TenderHeader);
    end;

    procedure ReOpenTender(var TenderHeader: Record "Tender Header")
    begin
        if TenderHeader.Status <> TenderHeader.Status::Rejected then
            Error('Only rejected tenders can be re-opened.');
        UpdateStatus(TenderHeader, TenderHeader.Status::Draft);
    end;

    procedure ReTender(var TenderHeader: Record "Tender Header")
    var
        NewTenderHeader: Record "Tender Header";
        TenderLine: Record "Tender Line";
        NewTenderLine: Record "Tender Line";
        VendorAlloc: Record "Tender Vendor Allocation";
        NewVendorAlloc: Record "Tender Vendor Allocation";
        ArchiveMgt: Codeunit "Tender Archive Management";
        IsHandled: Boolean;
    begin
        TenderEventPublisher.OnBeforeReTender(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        // Archive current tender
        ArchiveMgt.ArchiveTender(TenderHeader, "Tender Archive Reason"::"Re-Tender");

        // Create new tender
        NewTenderHeader.Init();
        NewTenderHeader.Insert(true);
        NewTenderHeader.TransferFields(TenderHeader, false);
        NewTenderHeader."Re-Tender Reference No." := TenderHeader."No.";
        NewTenderHeader.Status := NewTenderHeader.Status::Draft;
        NewTenderHeader."Created Date" := Today;
        NewTenderHeader."Created DateTime" := CurrentDateTime;
        NewTenderHeader."Created By User ID" := CopyStr(UserId, 1, 50);
        NewTenderHeader."Created Order No." := '';
        NewTenderHeader."Created Order Doc Type" := NewTenderHeader."Created Order Doc Type"::" ";
        NewTenderHeader.Modify(true);

        // Copy lines
        TenderLine.SetRange("Tender No.", TenderHeader."No.");
        if TenderLine.FindSet() then
            repeat
                NewTenderLine.Init();
                NewTenderLine.TransferFields(TenderLine);
                NewTenderLine."Tender No." := NewTenderHeader."No.";
                // Copy Blob
                TenderLine.CalcFields("Description Blob");
                if TenderLine."Description Blob".HasValue then begin
                    NewTenderLine."Description Blob" := TenderLine."Description Blob";
                end;
                NewTenderLine.Insert(true);
            until TenderLine.Next() = 0;

        // Copy vendor allocations
        VendorAlloc.SetRange("Tender No.", TenderHeader."No.");
        if VendorAlloc.FindSet() then
            repeat
                NewVendorAlloc.Init();
                NewVendorAlloc."Tender No." := NewTenderHeader."No.";
                NewVendorAlloc."Vendor No." := VendorAlloc."Vendor No.";
                NewVendorAlloc.Validate("Vendor No.");
                NewVendorAlloc.Insert(true);
            until VendorAlloc.Next() = 0;

        // Mark original as Re-Tendered
        TenderHeader.Status := TenderHeader.Status::"Re-Tendered";
        TenderHeader.Modify(true);

        TenderEventPublisher.OnAfterReTender(TenderHeader."No.", NewTenderHeader."No.");
    end;

    procedure CheckBudgetAvailability(TenderHeader: Record "Tender Header"): Boolean
    begin
        if TenderHeader."Budget Amount" = 0 then
            exit(true);
        exit(CalculateTenderTotal(TenderHeader."No.") <= TenderHeader."Budget Amount");
    end;

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

    procedure GetVendorQuoteTotal(TenderNo: Code[20]; VendorNo: Code[20]): Decimal
    var
        VendorAlloc: Record "Tender Vendor Allocation";
        PurchLine: Record "Purchase Line";
        Total: Decimal;
    begin
        if not VendorAlloc.Get(TenderNo, VendorNo) then
            exit(0);
        if VendorAlloc."Quote No." = '' then
            exit(0);

        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Quote);
        PurchLine.SetRange("Document No.", VendorAlloc."Quote No.");
        if PurchLine.FindSet() then
            repeat
                Total += PurchLine."Line Amount";
            until PurchLine.Next() = 0;
        exit(Total);
    end;

    procedure ConvertToLCY(Amount: Decimal; CurrencyCode: Code[10]; PostingDate: Date): Decimal
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if CurrencyCode = '' then
            exit(Amount);
        exit(CurrExchRate.ExchangeAmtFCYToLCY(PostingDate, CurrencyCode, Amount, CurrExchRate.ExchangeRate(PostingDate, CurrencyCode)));
    end;

    procedure ValidateIndentationHierarchy(TenderNo: Code[20]): Boolean
    var
        TenderLine: Record "Tender Line";
        PrevIndentation: Integer;
    begin
        TenderLine.SetRange("Tender No.", TenderNo);
        TenderLine.SetCurrentKey("Tender No.", "Line No.");
        PrevIndentation := 0;
        if TenderLine.FindSet() then
            repeat
                if TenderLine.Indentation > PrevIndentation + 1 then
                    Error('Invalid indentation hierarchy at line %1. Cannot skip indentation levels.', TenderLine."BOQ Serial No.");
                PrevIndentation := TenderLine.Indentation;
            until TenderLine.Next() = 0;
        exit(true);
    end;

    procedure GetNoOfVendors(TenderNo: Code[20]): Integer
    var
        VendorAlloc: Record "Tender Vendor Allocation";
    begin
        VendorAlloc.SetRange("Tender No.", TenderNo);
        exit(VendorAlloc.Count);
    end;

    procedure GetNoOfQuotes(TenderNo: Code[20]): Integer
    var
        VendorAlloc: Record "Tender Vendor Allocation";
    begin
        VendorAlloc.SetRange("Tender No.", TenderNo);
        VendorAlloc.SetFilter("Quote No.", '<>%1', '');
        exit(VendorAlloc.Count);
    end;

    procedure GetNoOfLines(TenderNo: Code[20]): Integer
    var
        TenderLine: Record "Tender Line";
    begin
        TenderLine.SetRange("Tender No.", TenderNo);
        exit(TenderLine.Count);
    end;

    procedure GetNoOfArchives(TenderNo: Code[20]): Integer
    var
        Archive: Record "Tender Header Archive";
    begin
        Archive.SetRange("Tender No.", TenderNo);
        exit(Archive.Count);
    end;

    procedure GetNoOfCorrigendums(TenderNo: Code[20]): Integer
    var
        Corrigendum: Record "Tender Corrigendum";
    begin
        Corrigendum.SetRange("Tender No.", TenderNo);
        exit(Corrigendum.Count);
    end;

    var
        TenderEventPublisher: Codeunit "Tender Event Publishers";
        TenderSourceDispatcher: Codeunit "Tender Source Dispatcher";
}

// ============================================================
// Codeunit 50101: Tender Archive Management
// ============================================================
codeunit 50101 "Tender Archive Management"
{
    procedure ArchiveTender(TenderHeader: Record "Tender Header"; ArchiveReason: Enum "Tender Archive Reason")
    var
        HeaderArchive: Record "Tender Header Archive";
        LineArchive: Record "Tender Line Archive";
        TenderLine: Record "Tender Line";
        VersionNo: Integer;
    begin
        // Get next version
        HeaderArchive.SetRange("Tender No.", TenderHeader."No.");
        if HeaderArchive.FindLast() then
            VersionNo := HeaderArchive."Version No." + 1
        else
            VersionNo := 1;

        // Archive header
        HeaderArchive.Init();
        HeaderArchive."Tender No." := TenderHeader."No.";
        HeaderArchive."Version No." := VersionNo;
        HeaderArchive."Archive Reason" := ArchiveReason;
        HeaderArchive."Archived DateTime" := CurrentDateTime;
        HeaderArchive."Archived By User ID" := CopyStr(UserId, 1, 50);
        HeaderArchive.Description := TenderHeader.Description;
        HeaderArchive."Source Module" := TenderHeader."Source Module";
        HeaderArchive."Source ID" := TenderHeader."Source ID";
        HeaderArchive."Item Type" := TenderHeader."Item Type";
        HeaderArchive."Tender Type" := TenderHeader."Tender Type";
        HeaderArchive.Status := TenderHeader.Status;
        HeaderArchive."Bid Start Date" := TenderHeader."Bid Start Date";
        HeaderArchive."Bid End Date" := TenderHeader."Bid End Date";
        HeaderArchive."Bid Validity Date" := TenderHeader."Bid Validity Date";
        HeaderArchive."Currency Code" := TenderHeader."Currency Code";
        HeaderArchive."Budget Amount" := TenderHeader."Budget Amount";
        HeaderArchive."Business Unit Code" := TenderHeader."Business Unit Code";
        HeaderArchive."Negotiate Date" := TenderHeader."Negotiate Date";
        HeaderArchive."Negotiate Place" := TenderHeader."Negotiate Place";
        HeaderArchive."Work Type" := TenderHeader."Work Type";
        HeaderArchive."Sanction No." := TenderHeader."Sanction No.";
        HeaderArchive."Source Type" := TenderHeader."Source Type";
        HeaderArchive."Dimension Set ID" := TenderHeader."Dimension Set ID";

        // Copy blob
        TenderHeader.CalcFields("Detailed Description");
        if TenderHeader."Detailed Description".HasValue then
            HeaderArchive."Detailed Description" := TenderHeader."Detailed Description";

        HeaderArchive.Insert(true);

        // Archive lines
        TenderLine.SetRange("Tender No.", TenderHeader."No.");
        if TenderLine.FindSet() then
            repeat
                LineArchive.Init();
                LineArchive."Tender No." := TenderLine."Tender No.";
                LineArchive."Version No." := VersionNo;
                LineArchive."Line No." := TenderLine."Line No.";
                LineArchive.Indentation := TenderLine.Indentation;
                LineArchive."Line Type" := TenderLine."Line Type";
                LineArchive."BOQ Serial No." := TenderLine."BOQ Serial No.";
                LineArchive."Parent Line No." := TenderLine."Parent Line No.";
                LineArchive."Item No." := TenderLine."Item No.";
                LineArchive.Description := TenderLine.Description;
                LineArchive."HSN SAC Code" := TenderLine."HSN SAC Code";
                LineArchive."GST Group Code" := TenderLine."GST Group Code";
                LineArchive."Short Description" := TenderLine."Short Description";
                LineArchive."Unit of Measure Code" := TenderLine."Unit of Measure Code";
                LineArchive.Quantity := TenderLine.Quantity;
                LineArchive."Unit Cost" := TenderLine."Unit Cost";
                LineArchive."Line Amount" := TenderLine."Line Amount";
                LineArchive.Style := TenderLine.Style;
                LineArchive.Imported := TenderLine.Imported;

                TenderLine.CalcFields("Description Blob");
                if TenderLine."Description Blob".HasValue then
                    LineArchive."Description Blob" := TenderLine."Description Blob";

                LineArchive.Insert(true);
            until TenderLine.Next() = 0;
    end;

    procedure RestoreFromArchive(TenderNo: Code[20]; VersionNo: Integer)
    var
        TenderHeader: Record "Tender Header";
        HeaderArchive: Record "Tender Header Archive";
        TenderLine: Record "Tender Line";
        LineArchive: Record "Tender Line Archive";
    begin
        TenderHeader.Get(TenderNo);

        // Archive current state first
        ArchiveTender(TenderHeader, "Tender Archive Reason"::Manual);

        HeaderArchive.Get(TenderNo, VersionNo);

        // Restore header
        TenderHeader.Description := HeaderArchive.Description;
        TenderHeader."Bid Start Date" := HeaderArchive."Bid Start Date";
        TenderHeader."Bid End Date" := HeaderArchive."Bid End Date";
        TenderHeader."Bid Validity Date" := HeaderArchive."Bid Validity Date";
        TenderHeader."Negotiate Date" := HeaderArchive."Negotiate Date";
        TenderHeader."Negotiate Place" := HeaderArchive."Negotiate Place";
        TenderHeader.Status := TenderHeader.Status::Draft;
        TenderHeader.Modify(true);

        // Clear and restore lines
        TenderLine.SetRange("Tender No.", TenderNo);
        TenderLine.DeleteAll();

        LineArchive.SetRange("Tender No.", TenderNo);
        LineArchive.SetRange("Version No.", VersionNo);
        if LineArchive.FindSet() then
            repeat
                TenderLine.Init();
                TenderLine."Tender No." := LineArchive."Tender No.";
                TenderLine."Line No." := LineArchive."Line No.";
                TenderLine.Indentation := LineArchive.Indentation;
                TenderLine."Line Type" := LineArchive."Line Type";
                TenderLine."BOQ Serial No." := LineArchive."BOQ Serial No.";
                TenderLine."Parent Line No." := LineArchive."Parent Line No.";
                TenderLine."Item No." := LineArchive."Item No.";
                TenderLine.Description := LineArchive.Description;
                TenderLine."HSN SAC Code" := LineArchive."HSN SAC Code";
                TenderLine."GST Group Code" := LineArchive."GST Group Code";
                TenderLine."Short Description" := LineArchive."Short Description";
                TenderLine."Unit of Measure Code" := LineArchive."Unit of Measure Code";
                TenderLine.Quantity := LineArchive.Quantity;
                TenderLine."Unit Cost" := LineArchive."Unit Cost";
                TenderLine."Line Amount" := LineArchive."Line Amount";
                TenderLine.Style := LineArchive.Style;
                TenderLine.Imported := LineArchive.Imported;

                LineArchive.CalcFields("Description Blob");
                if LineArchive."Description Blob".HasValue then
                    TenderLine."Description Blob" := LineArchive."Description Blob";

                TenderLine.Insert(true);
            until LineArchive.Next() = 0;
    end;

    procedure GetArchiveCount(TenderNo: Code[20]): Integer
    var
        Archive: Record "Tender Header Archive";
    begin
        Archive.SetRange("Tender No.", TenderNo);
        exit(Archive.Count);
    end;
}

// ============================================================
// Codeunit 50102: Tender Corrigendum Management
// ============================================================
codeunit 50102 "Tender Corrigendum Mgt."
{
    procedure CreateCorrigendum(var TenderHeader: Record "Tender Header"; ChangesType: Enum "Corrigendum Changes Type"): Integer
    var
        Corrigendum: Record "Tender Corrigendum";
        ArchiveMgt: Codeunit "Tender Archive Management";
        CorrigendumNo: Integer;
        IsHandled: Boolean;
    begin
        TenderEventPublisher.OnBeforeCorrigendumIssue(TenderHeader, Corrigendum, IsHandled);
        if IsHandled then
            exit(0);

        if not (TenderHeader.Status in [TenderHeader.Status::"Bidding Open"]) then
            Error('Corrigendums can only be issued during Bidding Open status.');

        // Archive current state
        ArchiveMgt.ArchiveTender(TenderHeader, "Tender Archive Reason"::Corrigendum);

        // Get next corrigendum no
        Corrigendum.SetRange("Tender No.", TenderHeader."No.");
        if Corrigendum.FindLast() then
            CorrigendumNo := Corrigendum."Corrigendum No." + 1
        else
            CorrigendumNo := 1;

        Corrigendum.Init();
        Corrigendum."Tender No." := TenderHeader."No.";
        Corrigendum."Corrigendum No." := CorrigendumNo;
        Corrigendum."Issue Date" := Today;
        Corrigendum."Changes Type" := ChangesType;
        Corrigendum."Issued By User ID" := CopyStr(UserId, 1, 50);
        Corrigendum."Archive Version No." := ArchiveMgt.GetArchiveCount(TenderHeader."No.");
        Corrigendum.Insert(true);

        TenderEventPublisher.OnAfterCorrigendumIssued(TenderHeader, Corrigendum);

        exit(CorrigendumNo);
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
    begin
        Corrigendum."Vendors Notified" := true;
        Corrigendum."Notification DateTime" := CurrentDateTime;
        Corrigendum.Modify(true);

        TenderHeader.Get(Corrigendum."Tender No.");
        TenderEventPublisher.OnAfterVendorsNotified(TenderHeader, Corrigendum);
    end;

    var
        TenderEventPublisher: Codeunit "Tender Event Publishers";
}

// ============================================================
// Codeunit 50103: Tender Reverse Auction Mgt.
// ============================================================
codeunit 50103 "Tender Reverse Auction Mgt."
{
    procedure InitializeAuction(var TenderHeader: Record "Tender Header")
    begin
        if TenderHeader.Status <> TenderHeader.Status::"Bidding Closed" then
            Error('Auction can only start after Bidding Closed.');

        TenderHeader."Reverse Auction Enabled" := true;
        TenderHeader."Auction Status" := TenderHeader."Auction Status"::"Not Started";
        TenderHeader."Current Auction Round" := 0;
        TenderHeader.Status := TenderHeader.Status::"Reverse Auction";
        TenderHeader.Modify(true);

        CreateNewRound(TenderHeader."No.");
    end;

    procedure CreateNewRound(TenderNo: Code[20])
    var
        AuctionRound: Record "Reverse Auction Round";
        TenderSetup: Record "Tender Setup";
        TenderHeader: Record "Tender Header";
        RoundNo: Integer;
    begin
        TenderSetup.GetSetup();
        TenderHeader.Get(TenderNo);

        if TenderSetup."Max Auction Rounds" > 0 then
            if TenderHeader."Current Auction Round" >= TenderSetup."Max Auction Rounds" then
                Error('Maximum number of auction rounds reached.');

        AuctionRound.SetRange("Tender No.", TenderNo);
        if AuctionRound.FindLast() then
            RoundNo := AuctionRound."Round No." + 1
        else
            RoundNo := 1;

        AuctionRound.Init();
        AuctionRound."Tender No." := TenderNo;
        AuctionRound."Round No." := RoundNo;
        AuctionRound.Status := AuctionRound.Status::Scheduled;
        AuctionRound."Time Limit Minutes" := TenderSetup."Default Round Time Limit";
        AuctionRound."Min Decrement Percentage" := TenderSetup."Min Decrement Percentage";
        AuctionRound."Min Decrement Amount" := TenderSetup."Min Decrement Amount";
        AuctionRound."Created By User ID" := CopyStr(UserId, 1, 50);
        AuctionRound.Insert(true);

        TenderHeader."Current Auction Round" := RoundNo;
        TenderHeader.Modify(true);

        // Initialize entries from last round or original quotes
        InitializeRoundEntries(TenderNo, RoundNo);
    end;

    local procedure InitializeRoundEntries(TenderNo: Code[20]; RoundNo: Integer)
    var
        VendorAlloc: Record "Tender Vendor Allocation";
        TenderLine: Record "Tender Line";
        AuctionEntry: Record "Reverse Auction Entry";
        PrevEntry: Record "Reverse Auction Entry";
        PurchLine: Record "Purchase Line";
    begin
        VendorAlloc.SetRange("Tender No.", TenderNo);
        VendorAlloc.SetFilter("Quote Status", '<>%1', VendorAlloc."Quote Status"::Disqualified);
        if VendorAlloc.FindSet() then
            repeat
                TenderLine.SetRange("Tender No.", TenderNo);
                TenderLine.SetFilter("Line Type", '%1|%2',
                    TenderLine."Line Type"::"Line Item", TenderLine."Line Type"::"Sub Item");
                if TenderLine.FindSet() then
                    repeat
                        AuctionEntry.Init();
                        AuctionEntry."Tender No." := TenderNo;
                        AuctionEntry."Round No." := RoundNo;
                        AuctionEntry."Vendor No." := VendorAlloc."Vendor No.";
                        AuctionEntry."Line No." := TenderLine."Line No.";
                        AuctionEntry."Currency Code" := VendorAlloc."Currency Code";

                        // Get previous price
                        if RoundNo > 1 then begin
                            if PrevEntry.Get(TenderNo, RoundNo - 1, VendorAlloc."Vendor No.", TenderLine."Line No.") then begin
                                AuctionEntry."Previous Unit Cost" := PrevEntry."New Unit Cost";
                                AuctionEntry."Previous Line Amount" := PrevEntry."New Line Amount";
                            end;
                        end else begin
                            // From original quote
                            if VendorAlloc."Quote No." <> '' then begin
                                PurchLine.SetRange("Document Type", PurchLine."Document Type"::Quote);
                                PurchLine.SetRange("Document No.", VendorAlloc."Quote No.");
                                PurchLine.SetRange("Tender Line No.", TenderLine."Line No.");
                                if PurchLine.FindFirst() then begin
                                    AuctionEntry."Previous Unit Cost" := PurchLine."Direct Unit Cost";
                                    AuctionEntry."Previous Line Amount" := PurchLine."Line Amount";
                                end;
                            end;
                        end;

                        AuctionEntry."New Unit Cost" := AuctionEntry."Previous Unit Cost";
                        AuctionEntry."New Line Amount" := AuctionEntry."Previous Line Amount";
                        AuctionEntry.Insert(true);
                    until TenderLine.Next() = 0;
            until VendorAlloc.Next() = 0;
    end;

    procedure OpenRound(TenderNo: Code[20]; RoundNo: Integer)
    var
        AuctionRound: Record "Reverse Auction Round";
        TenderHeader: Record "Tender Header";
        IsHandled: Boolean;
    begin
        TenderEventPublisher.OnBeforeAuctionRoundOpen(TenderHeader, RoundNo, IsHandled);
        if IsHandled then
            exit;

        AuctionRound.Get(TenderNo, RoundNo);
        AuctionRound.Status := AuctionRound.Status::Open;
        AuctionRound."Round Start DateTime" := CurrentDateTime;
        if AuctionRound."Time Limit Minutes" > 0 then
            AuctionRound."Round End DateTime" := CurrentDateTime + (AuctionRound."Time Limit Minutes" * 60000);
        AuctionRound.Modify(true);

        TenderHeader.Get(TenderNo);
        TenderHeader."Auction Status" := TenderHeader."Auction Status"::"In Progress";
        TenderHeader.Modify(true);
    end;

    procedure CloseRound(TenderNo: Code[20]; RoundNo: Integer)
    var
        AuctionRound: Record "Reverse Auction Round";
        TenderHeader: Record "Tender Header";
    begin
        AuctionRound.Get(TenderNo, RoundNo);
        AuctionRound.Status := AuctionRound.Status::Closed;
        AuctionRound."Round End DateTime" := CurrentDateTime;
        AuctionRound.Modify(true);

        CalculateRankings(TenderNo, RoundNo);

        TenderHeader.Get(TenderNo);
        TenderEventPublisher.OnAfterAuctionRoundClosed(TenderHeader, RoundNo);
    end;

    procedure ValidateBidDecrement(var AuctionEntry: Record "Reverse Auction Entry")
    var
        AuctionRound: Record "Reverse Auction Round";
        TenderSetup: Record "Tender Setup";
    begin
        AuctionRound.Get(AuctionEntry."Tender No.", AuctionEntry."Round No.");

        if AuctionRound.Status <> AuctionRound.Status::Open then
            Error('Round is not open for bidding.');

        if (AuctionRound."Round End DateTime" <> 0DT) and (CurrentDateTime > AuctionRound."Round End DateTime") then
            Error('Round time limit has expired.');

        if AuctionEntry."New Unit Cost" > AuctionEntry."Previous Unit Cost" then
            Error('New price cannot be higher than previous price.');

        TenderSetup.GetSetup();
        AuctionEntry."Is Valid Entry" := true;

        case TenderSetup."Decrement Type" of
            TenderSetup."Decrement Type"::Percentage:
                if AuctionEntry."Decrement Percentage" < AuctionRound."Min Decrement Percentage" then begin
                    AuctionEntry."Is Valid Entry" := false;
                    Error('Decrement must be at least %1%.', AuctionRound."Min Decrement Percentage");
                end;
            TenderSetup."Decrement Type"::Amount:
                if AuctionEntry."Decrement Amount" < AuctionRound."Min Decrement Amount" then begin
                    AuctionEntry."Is Valid Entry" := false;
                    Error('Decrement must be at least %1.', AuctionRound."Min Decrement Amount");
                end;
            TenderSetup."Decrement Type"::Either:
                if (AuctionEntry."Decrement Percentage" < AuctionRound."Min Decrement Percentage") and
                   (AuctionEntry."Decrement Amount" < AuctionRound."Min Decrement Amount") then begin
                    AuctionEntry."Is Valid Entry" := false;
                    Error('Decrement must meet minimum percentage or amount requirement.');
                end;
        end;
    end;

    procedure CalculateRankings(TenderNo: Code[20]; RoundNo: Integer)
    var
        AuctionEntry: Record "Reverse Auction Entry";
        TenderLine: Record "Tender Line";
        RankEntry: Record "Reverse Auction Entry";
        Rank: Integer;
    begin
        TenderLine.SetRange("Tender No.", TenderNo);
        TenderLine.SetFilter("Line Type", '%1|%2',
            TenderLine."Line Type"::"Line Item", TenderLine."Line Type"::"Sub Item");
        if TenderLine.FindSet() then
            repeat
                RankEntry.SetRange("Tender No.", TenderNo);
                RankEntry.SetRange("Round No.", RoundNo);
                RankEntry.SetRange("Line No.", TenderLine."Line No.");
                RankEntry.SetCurrentKey("New Unit Cost");
                RankEntry.SetAscending("New Unit Cost", true);
                Rank := 0;
                if RankEntry.FindSet() then
                    repeat
                        Rank += 1;
                        RankEntry.Rank := Rank;
                        RankEntry.Modify();
                    until RankEntry.Next() = 0;
            until TenderLine.Next() = 0;
    end;

    procedure FinalizeAuction(var TenderHeader: Record "Tender Header")
    var
        AuctionEntry: Record "Reverse Auction Entry";
        PurchLine: Record "Purchase Line";
        VendorAlloc: Record "Tender Vendor Allocation";
        IsHandled: Boolean;
    begin
        TenderEventPublisher.OnBeforeAuctionFinalized(TenderHeader, IsHandled);
        if IsHandled then
            exit;

        // Update quotes with final auction prices
        AuctionEntry.SetRange("Tender No.", TenderHeader."No.");
        AuctionEntry.SetRange("Round No.", TenderHeader."Current Auction Round");
        if AuctionEntry.FindSet() then
            repeat
                VendorAlloc.Get(TenderHeader."No.", AuctionEntry."Vendor No.");
                if VendorAlloc."Quote No." <> '' then begin
                    PurchLine.SetRange("Document Type", PurchLine."Document Type"::Quote);
                    PurchLine.SetRange("Document No.", VendorAlloc."Quote No.");
                    PurchLine.SetRange("Tender Line No.", AuctionEntry."Line No.");
                    if PurchLine.FindFirst() then begin
                        PurchLine.Validate("Direct Unit Cost", AuctionEntry."New Unit Cost");
                        PurchLine.Modify(true);
                    end;
                end;
            until AuctionEntry.Next() = 0;

        TenderHeader."Auction Status" := TenderHeader."Auction Status"::Closed;
        TenderHeader.Status := TenderHeader.Status::"Under Evaluation";
        TenderHeader.Modify(true);
    end;

    var
        TenderEventPublisher: Codeunit "Tender Event Publishers";
}

// ============================================================
// Codeunit 50104: Tender Import Export
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
        MaxRow: Integer;
        ItemNo: Code[20];
        Qty: Decimal;
        UnitCost: Decimal;
        LineNo: Integer;
        Item: Record Item;
        UploadResult: Boolean;
    begin
        TenderHeader.Get(TenderNo);
        TenderHeader.TestStatusOpen();
        if TenderHeader."Item Type" <> TenderHeader."Item Type"::HSN then
            Error('HSN import is only for HSN type tenders.');

        UploadResult := UploadIntoStream('Select BOQ Excel File', '', 'Excel Files (*.xlsx)|*.xlsx', FileName, InStr);
        if not UploadResult then
            exit;

        SheetName := ExcelBuffer.SelectSheetsNameStream(InStr);
        ExcelBuffer.OpenBookStream(InStr, SheetName);
        ExcelBuffer.ReadSheet();

        // Validate columns
        ValidateExcelColumn(ExcelBuffer, 1, 1, 'Item No.');
        ValidateExcelColumn(ExcelBuffer, 1, 2, 'Quantity');
        ValidateExcelColumn(ExcelBuffer, 1, 3, 'Unit Cost');

        MaxRow := GetMaxRow(ExcelBuffer);
        LineNo := TenderLine.GetNextLineNo(TenderNo);

        for RowNo := 2 to MaxRow do begin
            ItemNo := CopyStr(GetCellValue(ExcelBuffer, RowNo, 1), 1, 20);
            Evaluate(Qty, GetCellValueDecimal(ExcelBuffer, RowNo, 2));
            Evaluate(UnitCost, GetCellValueDecimal(ExcelBuffer, RowNo, 3));

            if ItemNo <> '' then begin
                if not Item.Get(ItemNo) then
                    Error('Item %1 does not exist (Row %2).', ItemNo, RowNo);

                TenderLine.Init();
                TenderLine."Tender No." := TenderNo;
                TenderLine."Line No." := LineNo;
                TenderLine.Indentation := 0;
                TenderLine."Line Type" := TenderLine."Line Type"::"Line Item";
                TenderLine.Style := 'Standard';
                TenderLine.Validate("Item No.", ItemNo);
                TenderLine.Validate(Quantity, Qty);
                TenderLine.Validate("Unit Cost", UnitCost);
                TenderLine.Imported := true;
                TenderLine.Insert(true);

                LineNo += 10000;
            end;
        end;

        Message('HSN BOQ imported successfully. %1 lines created.', (LineNo - 10000) / 10000);
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
        MaxRow: Integer;
        IndentLevel: Integer;
        BOQSerialNo: Text[20];
        DescText: Text;
        UoM: Code[20];
        Qty: Decimal;
        UnitCost: Decimal;
        LineNo: Integer;
        PrevIndentation: Integer;
        UploadResult: Boolean;
        OutStr: OutStream;
        ErrorList: Text;
        HasErrors: Boolean;
        LineCount: Integer;
    begin
        TenderHeader.Get(TenderNo);
        TenderHeader.TestStatusOpen();
        if TenderHeader."Item Type" <> TenderHeader."Item Type"::SAC then
            Error('SAC import is only for SAC type tenders.');

        UploadResult := UploadIntoStream('Select BOQ Excel File', '', 'Excel Files (*.xlsx)|*.xlsx', FileName, InStr);
        if not UploadResult then
            exit;

        SheetName := ExcelBuffer.SelectSheetsNameStream(InStr);
        ExcelBuffer.OpenBookStream(InStr, SheetName);
        ExcelBuffer.ReadSheet();

        // Validate columns
        ValidateExcelColumn(ExcelBuffer, 1, 1, 'Indentation');
        ValidateExcelColumn(ExcelBuffer, 1, 2, 'BOQ Serial No.');
        ValidateExcelColumn(ExcelBuffer, 1, 3, 'Description');
        ValidateExcelColumn(ExcelBuffer, 1, 4, 'UoM');
        ValidateExcelColumn(ExcelBuffer, 1, 5, 'Quantity');
        ValidateExcelColumn(ExcelBuffer, 1, 6, 'Unit Cost');

        MaxRow := GetMaxRow(ExcelBuffer);

        // Pre-validate all rows
        PrevIndentation := 0;
        HasErrors := false;
        ErrorList := '';

        for RowNo := 2 to MaxRow do begin
            Evaluate(IndentLevel, GetCellValueDecimal(ExcelBuffer, RowNo, 1));
            BOQSerialNo := CopyStr(GetCellValue(ExcelBuffer, RowNo, 2), 1, 20);
            DescText := GetCellValue(ExcelBuffer, RowNo, 3);

            // Validate indentation hierarchy
            if RowNo = 2 then begin
                if not (IndentLevel in [0, 1]) then begin
                    ErrorList += StrSubstNo('Row %1: First row must start with indentation 0 or 1.\', RowNo);
                    HasErrors := true;
                end;
            end else begin
                if IndentLevel > PrevIndentation + 1 then begin
                    ErrorList += StrSubstNo('Row %1: Cannot skip indentation levels (from %2 to %3).\', RowNo, PrevIndentation, IndentLevel);
                    HasErrors := true;
                end;
            end;

            if BOQSerialNo = '' then begin
                ErrorList += StrSubstNo('Row %1: BOQ Serial No. is required.\', RowNo);
                HasErrors := true;
            end;

            if DescText = '' then begin
                ErrorList += StrSubstNo('Row %1: Description is required.\', RowNo);
                HasErrors := true;
            end;

            PrevIndentation := IndentLevel;
        end;

        if HasErrors then
            Error('Import validation failed:\%1', ErrorList);

        // Clear existing lines
        TenderLine.SetRange("Tender No.", TenderNo);
        TenderLine.DeleteAll();

        // Import lines
        LineNo := 10000;
        LineCount := 0;

        for RowNo := 2 to MaxRow do begin
            Evaluate(IndentLevel, GetCellValueDecimal(ExcelBuffer, RowNo, 1));
            BOQSerialNo := CopyStr(GetCellValue(ExcelBuffer, RowNo, 2), 1, 20);
            DescText := GetCellValue(ExcelBuffer, RowNo, 3);
            UoM := CopyStr(GetCellValue(ExcelBuffer, RowNo, 4), 1, 20);
            Evaluate(Qty, GetCellValueDecimal(ExcelBuffer, RowNo, 5));
            Evaluate(UnitCost, GetCellValueDecimal(ExcelBuffer, RowNo, 6));

            TenderLine.Init();
            TenderLine."Tender No." := TenderNo;
            TenderLine."Line No." := LineNo;
            TenderLine.Indentation := IndentLevel;
            TenderLine."BOQ Serial No." := BOQSerialNo;

            // Auto-set Line Type from Indentation
            TenderLine.SetLineTypeFromIndentation();
            TenderLine.SetStyleFromLineType();

            // Store description in Blob
            Clear(TenderLine."Description Blob");
            TenderLine."Description Blob".CreateOutStream(OutStr);
            OutStr.WriteText(DescText);
            TenderLine."Short Description" := CopyStr(DescText, 1, 250);
            TenderLine.Description := CopyStr(DescText, 1, 100);

            // Only set qty/rate for line items
            if not TenderLine.IsHeadingLine() then begin
                TenderLine."Unit of Measure Code" := UoM;
                TenderLine.Quantity := Qty;
                TenderLine."Unit Cost" := UnitCost;
                TenderLine.CalculateLineAmount();
            end;

            TenderLine.Imported := true;
            TenderLine.Insert(true);

            LineNo += 10000;
            LineCount += 1;
        end;

        // Build parent references
        BuildParentLineReferences(TenderNo);

        TenderEventPublisher.OnAfterBOQImportCompleted(TenderHeader, 'SAC', LineCount);

        Message('SAC BOQ imported successfully. %1 lines created.', LineCount);
    end;

    procedure ImportAmendedBOQ(TenderNo: Code[20])
    var
        TenderHeader: Record "Tender Header";
        ArchiveMgt: Codeunit "Tender Archive Management";
        IsHandled: Boolean;
    begin
        TenderHeader.Get(TenderNo);

        TenderEventPublisher.OnBeforeBOQImport(TenderHeader, 'Amended', IsHandled);
        if IsHandled then
            exit;

        // Archive current
        ArchiveMgt.ArchiveTender(TenderHeader, "Tender Archive Reason"::Amendment);

        // Import based on type
        case TenderHeader."Item Type" of
            TenderHeader."Item Type"::HSN:
                ImportBOQ_HSN(TenderNo);
            TenderHeader."Item Type"::SAC:
                ImportBOQ_SAC(TenderNo);
        end;

        TenderHeader.Get(TenderNo);
        TenderHeader.Status := TenderHeader.Status::Amended;
        TenderHeader.Modify(true);

        TenderEventPublisher.OnAfterAmendedBOQImport(TenderHeader);
    end;

    procedure ExportBOQTemplate_SAC()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
        InstructionBuffer: Record "Excel Buffer" temporary;
    begin
        // Sheet 1: BOQ Data
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Indentation', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('BOQ Serial No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Description', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('UoM', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Quantity', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Unit Cost', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        // Sample data
        AddSACTemplateSampleRow(ExcelBuffer, 0, '1', 'CIVIL WORKS', '', 0, 0);
        AddSACTemplateSampleRow(ExcelBuffer, 1, '1.1', 'Foundation Work', '', 0, 0);
        AddSACTemplateSampleRow(ExcelBuffer, 2, '1.1.1', 'Excavation in ordinary soil including disposal of excavated material', 'Cum', 150, 250);
        AddSACTemplateSampleRow(ExcelBuffer, 2, '1.1.2', 'PCC 1:4:8 with 40mm aggregate for foundation base', 'Cum', 45, 4500);
        AddSACTemplateSampleRow(ExcelBuffer, 3, '1.1.2.a', 'Including formwork for PCC edges', 'Sqm', 30, 350);
        AddSACTemplateSampleRow(ExcelBuffer, 1, '1.2', 'Structural Work', '', 0, 0);
        AddSACTemplateSampleRow(ExcelBuffer, 2, '1.2.1', 'RCC M25 grade concrete for columns including formwork', 'Cum', 80, 6500);
        AddSACTemplateSampleRow(ExcelBuffer, 0, '2', 'ELECTRICAL WORKS', '', 0, 0);
        AddSACTemplateSampleRow(ExcelBuffer, 1, '2.1', 'Internal Wiring', '', 0, 0);
        AddSACTemplateSampleRow(ExcelBuffer, 2, '2.1.1', 'Supply and laying of 3C x 2.5 sqmm FRLS PVC insulated copper conductor cable', 'RM', 2000, 85);

        ExcelBuffer.CreateNewBook('BOQ Data');
        ExcelBuffer.WriteSheet('BOQ Data', CompanyName, UserId);

        // Sheet 2: Instructions
        ExcelBuffer.DeleteAll();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('TENDER BOQ IMPORT GUIDE - SAC (Service) Items', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('PURPOSE:', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('This template is used to import the Bill of Quantities for service-type tenders.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('The BOQ supports a hierarchical structure with up to 4 levels of nesting.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('COLUMN DEFINITIONS:', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('1. Indentation (Column A) - MANDATORY', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('   0 = Main Heading, 1 = Heading, 2 = Line Item, 3 = Sub Item', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('   Cannot skip levels (e.g., 0 to 3 is invalid)', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('2. BOQ Serial No. (Column B) - MANDATORY, must be unique', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('3. Description (Column C) - MANDATORY, can be very long', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('4. UoM (Column D) - Required only for Level 2 and 3', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('5. Quantity (Column E) - Required only for Level 2 and 3', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('6. Unit Cost (Column F) - Required only for Level 2 and 3', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.NewRow();
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('IMPORTANT: Do not change column order, merge cells, or add extra columns.', false, '', true, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('The system auto-assigns Line Type based on Indentation. You never need to select it.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.WriteSheet('Instructions', CompanyName, UserId);
        ExcelBuffer.CloseBook();
        ExcelBuffer.SetFriendlyFilename('SAC_BOQ_Template');
        ExcelBuffer.OpenExcel();
    end;

    procedure ExportBOQTemplate_HSN()
    var
        ExcelBuffer: Record "Excel Buffer" temporary;
    begin
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn('Item No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Quantity', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Unit Cost', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);

        ExcelBuffer.CreateNewBook('BOQ Data');
        ExcelBuffer.WriteSheet('BOQ Data', CompanyName, UserId);
        ExcelBuffer.CloseBook();
        ExcelBuffer.SetFriendlyFilename('HSN_BOQ_Template');
        ExcelBuffer.OpenExcel();
    end;

    local procedure AddSACTemplateSampleRow(var ExcelBuffer: Record "Excel Buffer" temporary;
        Indent: Integer; SerialNo: Text; Desc: Text; UoM: Text; Qty: Decimal; Cost: Decimal)
    begin
        ExcelBuffer.NewRow();
        ExcelBuffer.AddColumn(Indent, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn(SerialNo, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(Desc, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn(UoM, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        if Qty <> 0 then
            ExcelBuffer.AddColumn(Qty, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number)
        else
            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        if Cost <> 0 then
            ExcelBuffer.AddColumn(Cost, false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number)
        else
            ExcelBuffer.AddColumn('', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
    end;

    local procedure BuildParentLineReferences(TenderNo: Code[20])
    var
        TenderLine: Record "Tender Line";
        ParentStack: array[4] of Integer; // Index 0-3 for indentation levels
    begin
        TenderLine.SetRange("Tender No.", TenderNo);
        TenderLine.SetCurrentKey("Tender No.", "Line No.");
        if TenderLine.FindSet() then
            repeat
                ParentStack[TenderLine.Indentation + 1] := TenderLine."Line No.";
                if TenderLine.Indentation > 0 then
                    TenderLine."Parent Line No." := ParentStack[TenderLine.Indentation]
                else
                    TenderLine."Parent Line No." := 0;
                TenderLine.Modify();
            until TenderLine.Next() = 0;
    end;

    local procedure ValidateExcelColumn(var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer; ColNo: Integer; ExpectedHeader: Text)
    var
        CellValue: Text;
    begin
        CellValue := GetCellValue(ExcelBuffer, RowNo, ColNo);
        if UpperCase(CellValue) <> UpperCase(ExpectedHeader) then
            Error('Expected column header "%1" in column %2, but found "%3".', ExpectedHeader, ColNo, CellValue);
    end;

    local procedure GetCellValue(var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer; ColNo: Integer): Text
    begin
        if ExcelBuffer.Get(RowNo, ColNo) then
            exit(ExcelBuffer."Cell Value as Text");
        exit('');
    end;

    local procedure GetCellValueDecimal(var ExcelBuffer: Record "Excel Buffer" temporary;
        RowNo: Integer; ColNo: Integer): Text
    var
        Val: Text;
    begin
        Val := GetCellValue(ExcelBuffer, RowNo, ColNo);
        if Val = '' then
            Val := '0';
        exit(Val);
    end;

    local procedure GetMaxRow(var ExcelBuffer: Record "Excel Buffer" temporary): Integer
    begin
        if ExcelBuffer.FindLast() then
            exit(ExcelBuffer."Row No.");
        exit(0);
    end;

    var
        TenderEventPublisher: Codeunit "Tender Event Publishers";
}

// ============================================================
// Codeunit 50105: Tender Disqualification Engine
// ============================================================
codeunit 50105 "Tender Disqualification Engine"
{
    procedure RunAutoDisqualification(TenderNo: Code[20])
    var
        VendorAlloc: Record "Tender Vendor Allocation";
        Rule: Record "Tender Disqualification Rule";
        QualifiedCount: Integer;
        DisqualifiedCount: Integer;
        Passed: Boolean;
        Reason: Text[250];
    begin
        VendorAlloc.SetRange("Tender No.", TenderNo);
        VendorAlloc.SetFilter("Quote Status", '<>%1', VendorAlloc."Quote Status"::Disqualified);
        if VendorAlloc.FindSet() then
            repeat
                Passed := CheckSingleVendor(TenderNo, VendorAlloc."Vendor No.", Reason);
                if not Passed then begin
                    VendorAlloc."Quote Status" := VendorAlloc."Quote Status"::Disqualified;
                    VendorAlloc."Disqualification Reason" := Reason;
                    VendorAlloc.Modify();
                    DisqualifiedCount += 1;
                    TenderEventPublisher.OnAfterVendorDisqualified(TenderNo, VendorAlloc."Vendor No.", Reason);
                end else
                    QualifiedCount += 1;
            until VendorAlloc.Next() = 0;

        Message('%1 vendors qualified, %2 vendors disqualified.', QualifiedCount, DisqualifiedCount);
    end;

    procedure CheckSingleVendor(TenderNo: Code[20]; VendorNo: Code[20]; var FailReason: Text[250]): Boolean
    var
        Rule: Record "Tender Disqualification Rule";
        Response: Record "Tender Quest. Response";
        Passed: Boolean;
        IsHandled: Boolean;
    begin
        Rule.SetRange("Tender No.", TenderNo);
        Rule.SetRange(Active, true);
        if Rule.FindSet() then
            repeat
                Passed := true;

                case Rule."Rule Type" of
                    Rule."Rule Type"::"Mandatory Questionnaire":
                        begin
                            Response.SetRange("Tender No.", TenderNo);
                            Response.SetRange("Vendor No.", VendorNo);
                            if Response.IsEmpty then begin
                                Passed := false;
                                FailReason := 'Mandatory questionnaire not completed.';
                            end;
                        end;
                    Rule."Rule Type"::"Min Experience Years":
                        begin
                            Response.SetRange("Tender No.", TenderNo);
                            Response.SetRange("Vendor No.", VendorNo);
                            Response.SetFilter("Answer Number", '<%1', Rule."Min Value");
                            if not Response.IsEmpty then begin
                                Passed := false;
                                FailReason := StrSubstNo('Minimum experience of %1 years not met.', Rule."Min Value");
                            end;
                        end;
                    Rule."Rule Type"::"Min Turnover Amount":
                        begin
                            Response.SetRange("Tender No.", TenderNo);
                            Response.SetRange("Vendor No.", VendorNo);
                            Response.SetFilter("Answer Number", '<%1', Rule."Min Value");
                            if not Response.IsEmpty then begin
                                Passed := false;
                                FailReason := StrSubstNo('Minimum turnover of %1 not met.', Rule."Min Value");
                            end;
                        end;
                    Rule."Rule Type"::Custom:
                        begin
                            TenderEventPublisher.OnEvaluateCustomRule(TenderNo, VendorNo, Rule, Passed, FailReason, IsHandled);
                        end;
                end;

                if (not Passed) and Rule.Mandatory then
                    exit(false);

            until Rule.Next() = 0;

        exit(true);
    end;

    var
        TenderEventPublisher: Codeunit "Tender Event Publishers";
}

// ============================================================
// Codeunit 50106: Tender Source Dispatcher
// ============================================================
codeunit 50106 "Tender Source Dispatcher"
{
    procedure ValidateSource(TenderHeader: Record "Tender Header"): Boolean
    var
        SourceInterface: Interface "ITenderSourceModule";
    begin
        SourceInterface := GetSourceInterface(TenderHeader."Source Module");
        exit(SourceInterface.ValidateSourceID(TenderHeader."Source ID"));
    end;

    procedure FillSourceData(var TenderHeader: Record "Tender Header")
    var
        SourceInterface: Interface "ITenderSourceModule";
        DimSetID: Integer;
        StartDate: Date;
        EndDate: Date;
    begin
        if TenderHeader."Source Module" = TenderHeader."Source Module"::" " then
            exit;
        if TenderHeader."Source ID" = '' then
            exit;

        SourceInterface := GetSourceInterface(TenderHeader."Source Module");

        if not SourceInterface.ValidateSourceID(TenderHeader."Source ID") then
            Error('Source ID %1 is not valid for %2.', TenderHeader."Source ID", TenderHeader."Source Module");

        TenderHeader."Budget Amount" := SourceInterface.GetBudgetAmount(TenderHeader."Source ID");
        TenderHeader."Business Unit Code" := SourceInterface.GetBusinessUnit(TenderHeader."Source ID");
        TenderHeader."Sanction No." := SourceInterface.GetSanctionNo(TenderHeader."Source ID");

        SourceInterface.GetDimensions(TenderHeader."Source ID", DimSetID);
        TenderHeader."Dimension Set ID" := DimSetID;

        SourceInterface.GetDefaultDates(TenderHeader."Source ID", StartDate, EndDate);
        if TenderHeader."Bid Start Date" = 0D then
            TenderHeader."Bid Start Date" := StartDate;
    end;

    procedure NotifySourceOnOrderCreated(TenderHeader: Record "Tender Header"; OrderNo: Code[20])
    var
        SourceInterface: Interface "ITenderSourceModule";
    begin
        if TenderHeader."Source Module" = TenderHeader."Source Module"::" " then
            exit;

        SourceInterface := GetSourceInterface(TenderHeader."Source Module");
        SourceInterface.OnAfterOrderCreated(TenderHeader."No.", OrderNo);
    end;

    local procedure GetSourceInterface(SourceModule: Enum "Tender Source Module"): Interface "ITenderSourceModule"
    var
        ProjectSource: Codeunit "Project Tender Source";
        GenServiceSource: Codeunit "Gen. Service Tender Source";
    begin
        case SourceModule of
            SourceModule::Project:
                exit(ProjectSource);
            SourceModule::GeneralService:
                exit(GenServiceSource);
            else
                Error('No source module implementation found for %1.', SourceModule);
        end;
    end;
}

// ============================================================
// Codeunit 50107: Tender Event Publishers
// ============================================================
codeunit 50107 "Tender Event Publishers"
{
    // Tender Lifecycle Events
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
    procedure OnAfterOrderCreated(TenderHeader: Record "Tender Header"; OrderNo: Code[20]; OrderDocType: Enum "Tender Order Doc Type")
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

    // Two-Envelope Events (placeholder)
    [IntegrationEvent(false, false)]
    procedure OnBeforeTechnicalBidOpen(var TenderHeader: Record "Tender Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterTechnicalEvaluation(TenderHeader: Record "Tender Header"; VendorNo: Code[20]; var Qualified: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeCommercialBidOpen(var TenderHeader: Record "Tender Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterCommercialBidOpen(var TenderHeader: Record "Tender Header")
    begin
    end;

    // Negotiation Events
    [IntegrationEvent(false, false)]
    procedure OnBeforeNegotiationApproval(var TenderHeader: Record "Tender Header"; var IsHandled: Boolean)
    begin
    end;

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

    // Corrigendum Events
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

    // Reverse Auction Events
    [IntegrationEvent(false, false)]
    procedure OnBeforeAuctionRoundOpen(var TenderHeader: Record "Tender Header"; RoundNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterAuctionRoundClosed(TenderHeader: Record "Tender Header"; RoundNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterBidSubmitted(TenderHeader: Record "Tender Header"; RoundNo: Integer; VendorNo: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeAuctionFinalized(var TenderHeader: Record "Tender Header"; var IsHandled: Boolean)
    begin
    end;

    // Disqualification Events
    [IntegrationEvent(false, false)]
    procedure OnEvaluateCustomRule(TenderNo: Code[20]; VendorNo: Code[20]; Rule: Record "Tender Disqualification Rule"; var Passed: Boolean; var Reason: Text[250]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterVendorDisqualified(TenderNo: Code[20]; VendorNo: Code[20]; Reason: Text[250])
    begin
    end;

    // Digital Signature Events
    [IntegrationEvent(false, false)]
    procedure OnSignatureRequested(TenderNo: Code[20]; Stage: Enum "Tender Signature Stage"; UserID: Code[50]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSignatureCompleted(TenderNo: Code[20]; Stage: Enum "Tender Signature Stage"; UserID: Code[50]; SignatureRef: Text[250])
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSignatureRejected(TenderNo: Code[20]; Stage: Enum "Tender Signature Stage"; UserID: Code[50]; Reason: Text[250])
    begin
    end;

    // Vendor Performance Events
    [IntegrationEvent(false, false)]
    procedure OnBeforePerformanceSubmitted(var PerformanceRating: Record "Vendor Performance Rating"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPerformanceSubmitted(PerformanceRating: Record "Vendor Performance Rating")
    begin
    end;

    // BOQ Import Events
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

    // Rate Contract Events
    [IntegrationEvent(false, false)]
    procedure OnBeforeRateContractPOCreated(TenderNo: Code[20]; var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterRateContractPOCreated(TenderNo: Code[20]; PurchaseHeader: Record "Purchase Header")
    begin
    end;
}