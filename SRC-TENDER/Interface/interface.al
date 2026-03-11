// ============================================================
// Interface: ITenderSourceModule
// ============================================================
interface "ITenderSourceModule"
{
    procedure GetSourceDescription(): Text;
    procedure ValidateSourceID(SourceID: Code[20]): Boolean;
    procedure GetBudgetAmount(SourceID: Code[20]): Decimal;
    procedure GetDimensions(SourceID: Code[20]; var DimSetID: Integer);
    procedure GetBusinessUnit(SourceID: Code[20]): Code[20];
    procedure GetSanctionNo(SourceID: Code[20]): Code[20];
    procedure OnAfterOrderCreated(TenderNo: Code[20]; OrderNo: Code[20]);
    procedure GetDefaultDates(SourceID: Code[20]; var StartDate: Date; var EndDate: Date);
    procedure GetAdditionalValidations(SourceID: Code[20]): Boolean;
}