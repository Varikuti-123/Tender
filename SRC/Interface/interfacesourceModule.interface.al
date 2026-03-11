// ============================================================
// Interface: ITenderSourceModule
// Purpose: Any module that feeds tenders implements this.
//          The tender module calls these methods at runtime
//          to fetch module-specific data without hard-coding.
// ============================================================
interface "ITenderSourceModule"
{
    /// Returns a human-readable name of the source module
    procedure GetSourceDescription(): Text;

    /// Validates that the given Source ID exists in the source module
    procedure ValidateSourceID(SourceID: Code[20]): Boolean;

    /// Returns the budget amount from the source module
    procedure GetBudgetAmount(SourceID: Code[20]): Decimal;

    /// Fills the Dimension Set ID from the source module
    procedure GetDimensions(SourceID: Code[20]; var DimSetID: Integer);

    /// Returns the Business Unit Code from the source module
    procedure GetBusinessUnit(SourceID: Code[20]): Code[20];

    /// Returns the Sanction No. from the source module
    procedure GetSanctionNo(SourceID: Code[20]): Code[20];

    /// Callback: called after a PO/WO is created from this tender
    procedure OnAfterOrderCreated(TenderNo: Code[20]; OrderNo: Code[20]);

    /// Returns default start/end dates from the source module
    procedure GetDefaultDates(SourceID: Code[20]; var StartDate: Date; var EndDate: Date);

    /// Runs any additional validations specific to the source module
    procedure GetAdditionalValidations(SourceID: Code[20]): Boolean;
}