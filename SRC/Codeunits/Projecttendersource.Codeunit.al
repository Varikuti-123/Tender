// ============================================================
// Codeunit 50108 - Project Tender Source
// Purpose: Implements ITenderSourceModule for the Project module.
//          In a real system, this reads from your Project table.
//          Here we provide a working skeleton.
// ============================================================
codeunit 50108 "Project Tender Source" implements ITenderSourceModule
{
    procedure GetSourceDescription(): Text
    begin
        exit('Project');
    end;

    procedure ValidateSourceID(SourceID: Code[20]): Boolean
    begin
        // In production: check if Project record exists
        // Example: exit(ProjectRec.Get(SourceID));
        if SourceID = '' then
            exit(false);
        exit(true);
    end;

    procedure GetBudgetAmount(SourceID: Code[20]): Decimal
    begin
        // In production: read Project Budget Amount
        exit(0);
    end;

    procedure GetDimensions(SourceID: Code[20]; var DimSetID: Integer)
    begin
        // In production: read Project Dimension Set ID
        DimSetID := 0;
    end;

    procedure GetBusinessUnit(SourceID: Code[20]): Code[20]
    begin
        // In production: read Project Business Unit
        exit('');
    end;

    procedure GetSanctionNo(SourceID: Code[20]): Code[20]
    begin
        // In production: read Project Sanction No.
        exit('');
    end;

    procedure OnAfterOrderCreated(TenderNo: Code[20]; OrderNo: Code[20])
    begin
        // In production: update Project record with Order reference
    end;

    procedure GetDefaultDates(SourceID: Code[20]; var StartDate: Date; var EndDate: Date)
    begin
        // In production: read Project start/end dates
        StartDate := Today();
        EndDate := CalcDate('<+1Y>', Today());
    end;

    procedure GetAdditionalValidations(SourceID: Code[20]): Boolean
    begin
        // In production: run Project-specific validations
        exit(true);
    end;
}

// ============================================================
// Codeunit 50109 - General Service Tender Source
// Purpose: Implements ITenderSourceModule for General Services.
// ============================================================
codeunit 50109 "Gen. Service Tender Source" implements ITenderSourceModule
{
    procedure GetSourceDescription(): Text
    begin
        exit('General Service');
    end;

    procedure ValidateSourceID(SourceID: Code[20]): Boolean
    begin
        if SourceID = '' then
            exit(false);
        exit(true);
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
        // Update General Service record
    end;

    procedure GetDefaultDates(SourceID: Code[20]; var StartDate: Date; var EndDate: Date)
    begin
        StartDate := Today();
        EndDate := CalcDate('<+6M>', Today());
    end;

    procedure GetAdditionalValidations(SourceID: Code[20]): Boolean
    begin
        exit(true);
    end;
}