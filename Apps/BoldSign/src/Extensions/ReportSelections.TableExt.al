namespace PrintVis.BoldSign.Extensions;

using Microsoft.Foundation.Reporting;
using PrintVis.BoldSign.Workflows;

tableextension 50600 "PVS BS Report Selections" extends "Report Selections"
{
    fields
    {
        field(50600; "PVS BS Use for BoldSign Sign."; Boolean)
        {
            Caption = 'Use for BoldSign Signature';
            DataClassification = CustomerContent;
        }
        field(50601; "PVS BS Sent Doc. Workflow"; Code[20])
        {
            Caption = 'BoldSign Sent Document Workflow';
            DataClassification = CustomerContent;
            TableRelation = "PVS BS Document Workflow";
        }
        field(50602; "PVS BS Signed Doc. Workflow"; Code[20])
        {
            Caption = 'BoldSign Signed Document Workflow';
            DataClassification = CustomerContent;
            TableRelation = "PVS BS Document Workflow";
        }
        field(50603; "PVS BS Expired Doc. Workflow"; Code[20])
        {
            Caption = 'BoldSign Expired Document Workflow';
            DataClassification = CustomerContent;
            TableRelation = "PVS BS Document Workflow";
        }
        field(50604; "PVS BS Declined Doc. Workflow"; Code[20])
        {
            Caption = 'BoldSign Declined Document Workflow';
            DataClassification = CustomerContent;
            TableRelation = "PVS BS Document Workflow";
        }
        field(50605; "PVS BS Add Decline Button"; Boolean)
        {
            Caption = 'BoldSign Add Decline button';
            DataClassification = CustomerContent;
            ToolTip = 'Gives this signer the ability to decline to sign by showing a "decline" button in their user interface. Declining cancels the signing process.';
        }
        field(50606; "PVS BS Allow Delegate"; Boolean)
        {
            Caption = 'BoldSign Allow Delegate';
            DataClassification = CustomerContent;
            ToolTip = 'Gives this signer the ability to delegate to someone else showing a "delegate" button in their user interface.';
        }
    }
}