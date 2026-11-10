namespace PrintVis.BoldSign.Integration.Services;

using PrintVis.BoldSign.Documents;
using PrintVis.BoldSign.Integration.Http;
using PrintVis.BoldSign.Utilities;

codeunit 50624 "PVS BS Doc. Revoke Service"
{
    Access = Internal;

    var
        Utilities: Codeunit "PVS BS Utility";

    procedure RevokeDocument(var Document: Record "PVS BS Document"): Boolean
    var
        HttpClient: Codeunit "PVS BS Http Client";
        ResponseMessage: HttpResponseMessage;
        RequestBody: JsonObject;
        JsonRequest: Text;
        RevokeDocumentErr: Label 'Document must be awaiting signature to be revoked';
        RevokeReasonLbl: Label 'Revoked from PrintVis.';
        Resource: Text;
    begin
        Document.TestField("Document ID");

        if Document.Status <> Enum::"PVS BS Document Status"::"Awaiting Signature" then
            Error(RevokeDocumentErr);

        Resource := StrSubstNo('document/revoke?documentId=%1', Utilities.FormatGuid(Document."Document ID"));
        RequestBody.Add('Message', RevokeReasonLbl);
        RequestBody.WriteTo(JsonRequest);

        if not HttpClient.SendHttpPostRequest(Resource, JsonRequest, ResponseMessage) then
            Error(RevokeDocumentErr);

        if not ResponseMessage.IsSuccessStatusCode then
            exit(false);

        Document.Validate(Status, Enum::"PVS BS Document Status"::Canceled);
        Document.Modify();
        Commit();

        exit(true);
    end;

    procedure DeleteDocument(var Document: Record "PVS BS Document"): Boolean
    var
        HttpClient: Codeunit "PVS BS Http Client";
        ResponseMessage: HttpResponseMessage;
        RequestBody: JsonObject;
        JsonRequest: Text;
        RevokeDocumentErr: Label 'Document must be awaiting signature to be revoked';
        RevokeReasonLbl: Label 'Revoked from PrintVis.';
        Resource: Text;
    begin
        Document.TestField("Document ID");

        if Document.Status <> Enum::"PVS BS Document Status"::"Awaiting Signature" then
            Error(RevokeDocumentErr);

        Resource := StrSubstNo('document/revoke?documentId=%1', Utilities.FormatGuid(Document."Document ID"));
        RequestBody.Add('Message', RevokeReasonLbl);
        RequestBody.WriteTo(JsonRequest);

        if not HttpClient.SendHttpPostRequest(Resource, JsonRequest, ResponseMessage) then
            Error(RevokeDocumentErr);

        if not ResponseMessage.IsSuccessStatusCode then
            exit(false);

        Document.Validate(Status, Enum::"PVS BS Document Status"::Canceled);
        Document.Modify();
        Commit();

        exit(true);
    end;
}