namespace PrintVis.BoldSign.Extensions;

using PrintVis.BoldSign.Documents;

tableextension 50602 "PVS BS Case" extends "PVS Case"
{
    fields
    {
        field(50600; "PVS BS New Documents"; Integer)
        {
            CalcFormula = count("PVS BS Document" where(
                "Case ID" = field(ID),
                Status = const(New)
            ));
            Caption = 'BoldSign New Documents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50601; "PVS BS Uploaded Documents"; Integer)
        {
            CalcFormula = count("PVS BS Document" where(
                "Case ID" = field(ID),
                Status = const(Uploaded)
            ));
            Caption = 'BoldSign Uploaded Documents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50602; "PVS BS Awaiting Sign. Docs."; Integer)
        {
            CalcFormula = count("PVS BS Document" where(
                "Case ID" = field(ID),
                Status = const("Awaiting Signature")
            ));
            Caption = 'BoldSign Awaiting Signature';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50603; "PVS BS Signed Documents"; Integer)
        {
            CalcFormula = count("PVS BS Document" where(
                "Case ID" = field(ID),
                Status = const(Signed)
            ));
            Caption = 'BoldSign Signed Documents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50604; "PVS BS Canceled Documents"; Integer)
        {
            CalcFormula = count("PVS BS Document" where(
                "Case ID" = field(ID),
                Status = const(Canceled)
            ));
            Caption = 'BoldSign Canceled Documents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50605; "PVS BS Removed Documents"; Integer)
        {
            CalcFormula = count("PVS BS Document" where(
                "Case ID" = field(ID),
                Status = const(Removed)
            ));
            Caption = 'BoldSign Removed Documents';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50606; "PVS BS Error Documents"; Integer)
        {
            CalcFormula = count("PVS BS Document" where(
                "Case ID" = field(ID),
                Status = const(Error)
            ));
            Caption = 'BoldSign Error Documents';
            Editable = false;
            FieldClass = FlowField;
        }
    }
}