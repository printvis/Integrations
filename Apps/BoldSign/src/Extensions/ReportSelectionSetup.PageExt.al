namespace PrintVis.BoldSign.Extensions;

pageextension 50600 "PVS BS Report Selection Setup" extends "PVS Report Selection Setup"
{
    layout
    {
        addafter("Use for Email Body")
        {
            field("PVS BS Use for BoldSign Sign."; Rec."PVS BS Use for BoldSign Sign.")
            {
                ApplicationArea = All;
            }
            field("PVS BS Sent Doc. Workflow"; Rec."PVS BS Sent Doc. Workflow")
            {
                ApplicationArea = All;
            }
            field("PVS BS Signed Workflow"; Rec."PVS BS Signed Doc. Workflow")
            {
                ApplicationArea = All;
            }
            field("PVS BS Declined Doc. Workflow"; Rec."PVS BS Declined Doc. Workflow")
            {
                ApplicationArea = All;
            }
            field("PVS BS Expired Document Workflow"; Rec."PVS BS Expired Doc. Workflow")
            {
                ApplicationArea = All;
            }
            field("PVS BS Add Decline Button"; Rec."PVS BS Add Decline Button")
            {
                ApplicationArea = All;
            }
            field("PVS BS Allow Delegate"; Rec."PVS BS Allow Delegate")
            {
                ApplicationArea = All;
            }
        }
    }
}