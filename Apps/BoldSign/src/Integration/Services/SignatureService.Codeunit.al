namespace PrintVis.BoldSign.Integration.Services;

using System.Text;
using System.Utilities;
using PrintVis.BoldSign.Configuration;
using PrintVis.BoldSign.Documents;
using PrintVis.BoldSign.Integration.Http;
using PrintVis.BoldSign.Utilities;

codeunit 50622 "PVS BS Signature Service"
{
    Access = Internal;

    var
        Utilities: Codeunit "PVS BS Utility";
        SignerOrder: Integer;
        DeliveryMode: Text;
        FieldType: Text;
        FieldName: Text;
        FieldPageNumber: Integer;
        FieldX: Integer;
        FieldY: Integer;
        FieldWidth: Integer;
        FieldHeight: Integer;
        FieldIsRequired: Boolean;

    procedure StartSignaturesProcess(var Document: Record "PVS BS Document";
        var DocumentInStream: InStream;
        EmailSubject: Text;
        EmailBody: Text;
        Signers: Dictionary of [Text, Text]): Boolean
    var
        BoldSignSetup: Record "PVS BS Service Setup";
        PrintVisCase: Record "PVS Case";
        HttpClient: Codeunit "PVS BS Http Client";
        Utility: Codeunit "PVS BS Utility";
        JsonMgt: Codeunit "JSON Management";
        TempBlob: Codeunit "Temp Blob";
        ResponseMessage: HttpResponseMessage;
        BodyInStream: InStream;
        JsonRequest, DocumentTitle, DocumentFileName, DocumentIdText, Boundary : Text;
        DocumentId: Guid;
        ExpiryDays: Integer;
        StartSignaturesProcessErr: Label 'Failed to start signature request: %1 %2', Comment = '%1 = HTTP Status Code, %2 = HTTP Reason Phrase';
        NoSignersErr: Label 'No signers provided';
    begin
        BoldSignSetup.Get();
        if not BoldSignSetup.HasApiKey() then
            Error('Enter the BoldSign API key in BoldSign Setup before sending documents.');
        if Signers.Count() = 0 then
            Error(NoSignersErr);

        if not PrintVisCase.Get(Document."Case ID") then
            Clear(PrintVisCase);

        if EmailSubject <> '' then
            EmailSubject := Utility.ReplaceTextPlaceholders(PrintVisCase, EmailSubject);
        if EmailBody <> '' then
            EmailBody := Utility.ReplaceTextPlaceholders(PrintVisCase, EmailBody);

        DocumentFileName := Utility.GetFileName(Document."Report Type", PrintVisCase) + '.pdf';

        DocumentTitle := EmailSubject;
        if DocumentTitle = '' then
            DocumentTitle := Utility.GetReportFileName(Document."Report Type", Document."Case ID");

        if Document."Expires On" <> 0DT then begin
            ExpiryDays := Document."Expires On".Date - Today;
            if ExpiryDays < 1 then
                ExpiryDays := 1;
        end;

        Boundary := 'BoldSign' + DelChr(Format(CreateGuid()), '=', '{}-');
        this.BuildSendMultipartBody(TempBlob, Boundary, DocumentInStream, DocumentFileName, DocumentTitle, EmailBody,
            Document."Allow Delegate", ExpiryDays, Signers);
        TempBlob.CreateInStream(BodyInStream);

        if not HttpClient.SendHttpPostMultipartRequest('document/send', Boundary, BodyInStream, ResponseMessage) then
            Error(StartSignaturesProcessErr, ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);

        ResponseMessage.Content().ReadAs(JsonRequest);
        if not ResponseMessage.IsSuccessStatusCode() then begin
            Message(JsonRequest);
            exit(false);
        end;

        JsonMgt.InitializeFromString(JsonRequest);
        DocumentIdText := JsonMgt.GetValue('documentId');
        if not Evaluate(DocumentId, DocumentIdText) then
            Error('BoldSign did not return a valid document ID.');

        Document."Document ID" := DocumentId;
        Document.Validate(Status, Enum::"PVS BS Document Status"::"Awaiting Signature");
        Document.Modify();
        Commit();
        exit(true);
    end;

    procedure GetSignatureProcessStatus(var Document: Record "PVS BS Document"): Boolean
    var
        HttpClient: Codeunit "PVS BS Http Client";
        IsSuccess: Boolean;
        ResponseMessage: HttpResponseMessage;
        GetSignatureProcessStatusErr: Label 'Failed to get signature process status: %1 %2', Comment = '%1 = HTTP Status Code, %2 = HTTP Reason Phrase';
        Resource: Text;
    begin
        Clear(ResponseMessage);

        Document.TestField(Status, Enum::"PVS BS Document Status"::"Awaiting Signature");
        Document.TestField("Document ID");

        Resource := StrSubstNo('document/properties?documentId=%1', Utilities.FormatGuid(Document."Document ID"));

        if not HttpClient.SendHttpGetRequest(Resource, ResponseMessage) then
            Error(GetSignatureProcessStatusErr,
                ResponseMessage.HttpStatusCode,
                ResponseMessage.ReasonPhrase);

        IsSuccess := this.HandleGetSignatureProcessStatusResponse(Document, ResponseMessage);
        if IsSuccess then
            if Document.Status in [Enum::"PVS BS Document Status"::Signed, Enum::"PVS BS Document Status"::Canceled] then
                this.DownloadDocument(Document);

        exit(IsSuccess);
    end;

    local procedure HandleGetSignatureProcessStatusResponse(var Document: Record "PVS BS Document"; var ResponseMessage: HttpResponseMessage): Boolean
    var
        JsonMgt: Codeunit "JSON Management";
        JsonResponse, StatusText : Text;
    begin
        ResponseMessage.Content().ReadAs(JsonResponse);

        if not ResponseMessage.IsSuccessStatusCode() then begin
            Message(JsonResponse);
            exit(false);
        end;

        JsonMgt.InitializeFromString(JsonResponse);
        StatusText := JsonMgt.GetValue('status');

        Document.Validate(Status, this.Utilities.TextToDocumentStatus(StatusText));
        if Document.Status in [Enum::"PVS BS Document Status"::Signed, Enum::"PVS BS Document Status"::Canceled] then
            Document."Processed Document ID" := Document."Document ID";
        Document.Modify();
        Commit();

        exit(true);
    end;

    local procedure InitSignatureFieldDefaults()
    begin
        SignerOrder := 1;
        DeliveryMode := 'Email';
        FieldType := 'Signature';
        FieldName := 'sign_field';
        FieldPageNumber := 1;
        FieldX := 50;
        FieldY := 50;
        FieldWidth := 200;
        FieldHeight := 30;
        FieldIsRequired := true;
    end;

    local procedure BuildSendMultipartBody(var TempBlob: Codeunit "Temp Blob"; Boundary: Text; var DocumentInStream: InStream;
        FileName: Text; Title: Text; Message: Text; EnableReassign: Boolean; ExpiryDays: Integer; Signers: Dictionary of [Text, Text])
    var
        BodyOutStream: OutStream;
        SignerName: Text;
        Prefix: Text;
        CRLF: Text[2];
        i: Integer;
    begin
        this.InitSignatureFieldDefaults();
        CRLF[1] := 13;
        CRLF[2] := 10;
        TempBlob.CreateOutStream(BodyOutStream, TextEncoding::UTF8);

        this.AddTextPart(BodyOutStream, Boundary, 'Title', Title);
        this.AddTextPart(BodyOutStream, Boundary, 'EnableReassign', Format(EnableReassign, 0, 9));
        if Message <> '' then
            this.AddTextPart(BodyOutStream, Boundary, 'Message', Message);
        if ExpiryDays > 0 then
            this.AddTextPart(BodyOutStream, Boundary, 'ExpiryDays', Format(ExpiryDays, 0, 9));

        foreach SignerName in Signers.Keys do begin
            Prefix := StrSubstNo('Signers[%1]', i);
            this.AddTextPart(BodyOutStream, Boundary, Prefix + '[Name]', SignerName);
            this.AddTextPart(BodyOutStream, Boundary, Prefix + '[EmailAddress]', Signers.Get(SignerName));
            this.AddTextPart(BodyOutStream, Boundary, Prefix + '[SignerOrder]', Format(SignerOrder + i, 0, 9));
            this.AddTextPart(BodyOutStream, Boundary, Prefix + '[DeliveryMode]', DeliveryMode);
            this.AddTextPart(BodyOutStream, Boundary, Prefix + '[FormFields][0][FieldType]', FieldType);
            this.AddTextPart(BodyOutStream, Boundary, Prefix + '[FormFields][0][Name]', FieldName);
            this.AddTextPart(BodyOutStream, Boundary, Prefix + '[FormFields][0][PageNumber]', Format(FieldPageNumber, 0, 9));
            this.AddTextPart(BodyOutStream, Boundary, Prefix + '[FormFields][0][Bounds][X]', Format(FieldX, 0, 9));
            this.AddTextPart(BodyOutStream, Boundary, Prefix + '[FormFields][0][Bounds][Y]', Format(FieldY, 0, 9));
            this.AddTextPart(BodyOutStream, Boundary, Prefix + '[FormFields][0][Bounds][Width]', Format(FieldWidth, 0, 9));
            this.AddTextPart(BodyOutStream, Boundary, Prefix + '[FormFields][0][Bounds][Height]', Format(FieldHeight, 0, 9));
            this.AddTextPart(BodyOutStream, Boundary, Prefix + '[FormFields][0][IsRequired]', Format(FieldIsRequired, 0, 9));
            i += 1;
        end;

        BodyOutStream.WriteText('--' + Boundary + CRLF);
        BodyOutStream.WriteText(StrSubstNo('Content-Disposition: form-data; name="Files"; filename="%1"', FileName) + CRLF);
        BodyOutStream.WriteText('Content-Type: application/pdf' + CRLF + CRLF);
        CopyStream(BodyOutStream, DocumentInStream);
        BodyOutStream.WriteText(CRLF + '--' + Boundary + '--' + CRLF);
    end;

    local procedure AddTextPart(var BodyOutStream: OutStream; Boundary: Text; PartName: Text; PartValue: Text)
    var
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        BodyOutStream.WriteText('--' + Boundary + CRLF);
        BodyOutStream.WriteText(StrSubstNo('Content-Disposition: form-data; name="%1"', PartName) + CRLF + CRLF);
        BodyOutStream.WriteText(PartValue + CRLF);
    end;

    local procedure DownloadDocument(var Document: Record "PVS BS Document")
    var
        DownloadService: Codeunit "PVS BS Doc. Download Service";
    begin
        DownloadService.DownloadDocument(Document, true, GuiAllowed());
    end;
}