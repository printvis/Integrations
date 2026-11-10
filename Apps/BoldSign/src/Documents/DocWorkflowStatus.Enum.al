namespace PrintVis.BoldSign.Documents;

enum 50601 "PVS BS Doc. Workflow Status"
{
    Extensible = false;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(10; Awaiting)
    {
        Caption = 'Awaiting';
    }
    value(20; Completed)
    {
        Caption = 'Completed';
    }
    value(30; Failed)
    {
        Caption = 'Failed';
    }
}