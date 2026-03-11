// ============================================================
// Codeunit: Project Tender Source
// ============================================================
codeunit 50108 "Project Tender Source" implements "ITenderSourceModule"
{
    procedure GetSourceDescription(): Text
    begin
        exit('Project');
    end;

    procedure ValidateSourceID(SourceID: Code[20]): Boolean
    var
        Job: Record Job;
    begin
        exit(Job.Get(SourceID));
    end;

    procedure GetBudgetAmount(SourceID: Code[20]): Decimal
    var
        Job: Record Job;
    begin
        if Job.Get(SourceID) then
            exit(Job."Estimated Total Cost (LCY)");
        exit(0);
    end;

    procedure GetDimensions(SourceID: Code[20]; var DimSetID: Integer)
    var
        Job: Record Job;
    begin
        if Job.Get(SourceID) then
            DimSetID := 0; // Extend as needed for project dimensions
    end;

    procedure GetBusinessUnit(SourceID: Code[20]): Code[20]
    begin
        exit('');
    end;

    procedure GetSanctionNo(SourceID: Code[20]): Code[20]
    begin
        exit('');
    end;

    procedure OnAfterOrderCreated(TenderNo: Code[20]; OrderNo: Code[20])
    begin
        // Custom logic after PO/WO created for a project tender
    end;

    procedure GetDefaultDates(SourceID: Code[20]; var StartDate: Date; var EndDate: Date)
    var
        Job: Record Job;
    begin
        if Job.Get(SourceID) then begin
            StartDate := Job."Starting Date";
            EndDate := Job."Ending Date";
        end;
    end;

    procedure GetAdditionalValidations(SourceID: Code[20]): Boolean
    begin
        exit(true);
    end;
}

// ============================================================
// Codeunit: General Service Tender Source
// ============================================================
codeunit 50109 "Gen. Service Tender Source" implements "ITenderSourceModule"
{
    procedure GetSourceDescription(): Text
    begin
        exit('General Service');
    end;

    procedure ValidateSourceID(SourceID: Code[20]): Boolean
    begin
        // Validate against General Service table
        // Replace with actual table validation
        exit(SourceID <> '');
    end;

    procedure GetBudgetAmount(SourceID: Code[20]): Decimal
    begin
        exit(0);
    end;

    procedure GetDimensions(SourceID: Code[20]; var DimSetID: Integer)
    begin
        DimSetID := 0;
    end;

    procedure GetBusinessUnit(SourceID: Code[20]): Code[20]
    begin
        exit('');
    end;

    procedure GetSanctionNo(SourceID: Code[20]): Code[20]
    begin
        exit('');
    end;

    procedure OnAfterOrderCreated(TenderNo: Code[20]; OrderNo: Code[20])
    begin
        // Custom logic for general service
    end;

    procedure GetDefaultDates(SourceID: Code[20]; var StartDate: Date; var EndDate: Date)
    begin
        StartDate := Today;
        EndDate := CalcDate('<+1Y>', Today);
    end;

    procedure GetAdditionalValidations(SourceID: Code[20]): Boolean
    begin
        exit(true);
    end;
}