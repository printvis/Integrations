namespace PrintVis.BoldSign.Extensions;

using Microsoft.Foundation.Reporting;

tableextension 50601 "PVS BS Folder Setup" extends "PVS Folder Setup"
{
    fields
    {
        field(50600; "PVS BS Sent Documents"; Enum "Report Selection Usage")
        {
            BlankZero = true;
            Caption = 'BoldSign Sent Documents';
            DataClassification = CustomerContent;
            ValuesAllowed =
                "PVS Estimating Report",
                "PVS Quote Report",
                "PVS Order Confirmation Report",
                "PVS Job Ticket Report",
                "PVS Delivery Note Report",
                "PVS Job Costing Report",
                "PVS Purchase Quote Report",
                "PVS Way Bill Report",
                "PVS Package Label Report",
                "PVS Other Report",
                "PVS Cutting Ticket Report",
                "PVS Supplier Enquiry Report",
                "PVS Imposition Report",
                "PVS Planning Report",
                "PVS Archive Report",
                "PVS Case Report 1",
                "PVS Case Report 2",
                "PVS Case Report 3",
                "PVS Case Report 4",
                "PVS Case Report 5",
                "PVS Purchase Order",
                "PVS BS Artwork Approval";
        }
        field(50601; "PVS BS Signed Documents"; Enum "Report Selection Usage")
        {
            BlankZero = true;
            Caption = 'BoldSign Signed Documents';
            DataClassification = CustomerContent;
            ValuesAllowed =
                "PVS Estimating Report",
                "PVS Quote Report",
                "PVS Order Confirmation Report",
                "PVS Job Ticket Report",
                "PVS Delivery Note Report",
                "PVS Job Costing Report",
                "PVS Purchase Quote Report",
                "PVS Way Bill Report",
                "PVS Package Label Report",
                "PVS Other Report",
                "PVS Cutting Ticket Report",
                "PVS Supplier Enquiry Report",
                "PVS Imposition Report",
                "PVS Planning Report",
                "PVS Archive Report",
                "PVS Case Report 1",
                "PVS Case Report 2",
                "PVS Case Report 3",
                "PVS Case Report 4",
                "PVS Case Report 5",
                "PVS Purchase Order",
                "PVS BS Artwork Approval";
        }
        field(50602; "PVS BS Declined Documents"; Enum "Report Selection Usage")
        {
            BlankZero = true;
            Caption = 'BoldSign Declined Documents';
            DataClassification = CustomerContent;
            ValuesAllowed =
                "PVS Estimating Report",
                "PVS Quote Report",
                "PVS Order Confirmation Report",
                "PVS Job Ticket Report",
                "PVS Delivery Note Report",
                "PVS Job Costing Report",
                "PVS Purchase Quote Report",
                "PVS Way Bill Report",
                "PVS Package Label Report",
                "PVS Other Report",
                "PVS Cutting Ticket Report",
                "PVS Supplier Enquiry Report",
                "PVS Imposition Report",
                "PVS Planning Report",
                "PVS Archive Report",
                "PVS Case Report 1",
                "PVS Case Report 2",
                "PVS Case Report 3",
                "PVS Case Report 4",
                "PVS Case Report 5",
                "PVS Purchase Order",
                "PVS BS Artwork Approval";
        }
    }
}
