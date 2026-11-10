page 50675 "PVS BS HTTP Req. Test"
{
    UsageCategory = Tasks;
    AdditionalSearchTerms = 'BS HTTP TEST';
    PageType = Card;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            group(SendTest)
            {
                Caption = 'Send for signature test';
                field(SignerNameTest; SignerNameTest) { ApplicationArea = All; Caption = 'Signer name'; }
                field(SignerEmailTest; SignerEmailTest) { ApplicationArea = All; Caption = 'Signer email'; }
                field(EmailSubjectTest; EmailSubjectTest) { ApplicationArea = All; Caption = 'Title / subject'; }
                field(EmailBodyTest; EmailBodyTest) { ApplicationArea = All; Caption = 'Message'; }
                field(FileNameTest; FileNameTest) { ApplicationArea = All; Caption = 'File'; Editable = false; }
                field(DocumentIdTest; DocumentIdTest) { ApplicationArea = All; Caption = 'Document ID'; }
            }
            group(SignerFieldsTest)
            {
                Caption = 'Signer and signature field';
                field(SignerOrderTest; SignerOrderTest) { ApplicationArea = All; Caption = 'Signer order'; }
                field(DeliveryModeTest; DeliveryModeTest) { ApplicationArea = All; Caption = 'Delivery mode'; }
                field(FieldTypeTest; FieldTypeTest) { ApplicationArea = All; Caption = 'Form field type'; }
                field(FieldNameTest; FieldNameTest) { ApplicationArea = All; Caption = 'Form field name'; }
                field(FieldPageNumberTest; FieldPageNumberTest) { ApplicationArea = All; Caption = 'Page number'; }
                field(FieldXTest; FieldXTest) { ApplicationArea = All; Caption = 'Bounds X'; }
                field(FieldYTest; FieldYTest) { ApplicationArea = All; Caption = 'Bounds Y'; }
                field(FieldWidthTest; FieldWidthTest) { ApplicationArea = All; Caption = 'Bounds width'; }
                field(FieldHeightTest; FieldHeightTest) { ApplicationArea = All; Caption = 'Bounds height'; }
                field(FieldIsRequiredTest; FieldIsRequiredTest) { ApplicationArea = All; Caption = 'Field is required'; }
            }
            group(URL)
            {
                field(urlGlobal; urlGlobal)
                {
                    Caption = 'Url';
                    ApplicationArea = All;
                    Width = 800;
                }
                field(test1; test1)
                {
                    Visible = false;
                }
                field(test2; test2)
                {
                    Visible = false;
                }
                field(calDateFormL; calDateFormL)
                {
                    Visible = false;
                }
                field(Date1L; Date1L)
                {
                    Visible = false;
                }
                field(Date2L; Date2L)
                {
                    Visible = false;
                }
            }
            group(general1)
            {
                Caption = 'Request Properties';
                field(tokenTxt; tokenTxt)
                {
                    Caption = 'Token';
                    ApplicationArea = All;
                }
                field(RawType; RawType)
                {
                    Caption = 'RawType';
                    ApplicationArea = All;
                }

                field(MethodAutGlobal; MethodAutGlobal)
                {
                    ApplicationArea = All;
                    Caption = 'Auth method';
                }
                field(useBodyForGetGlobal; useBodyForGetGlobal)
                {
                    ApplicationArea = All;
                    Caption = 'Use body on get method';
                }
                field(globalUser; globalUser)
                {
                    ApplicationArea = All;
                    Caption = 'User basic';
                }
                field(globalPassword; globalPassword)
                {
                    ApplicationArea = All;
                    Caption = 'User password';
                }

            }
            group(BodyGroup)
            {
                field(bodyText; bodyText)
                {
                    Caption = 'body message';
                    ApplicationArea = All;
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
            group(ResponseGroup)
            {
                field(responseTextGlobal; responseTextGlobal)
                {
                    Caption = 'Response';
                    ApplicationArea = all;
                    MultiLine = true;
                    ShowCaption = false;
                }
            }


        }
    }
    actions
    {
        area(Processing)
        {
            group(atomyxTest)
            {
                action(postbinaryfiles)
                {
                    ApplicationArea = All;
                    Visible = false;
                    Caption = 'Test Post with binary file on body';
                    trigger OnAction()
                    begin
                        PostReqTestWithBinaryBody();
                    end;
                }

                action(UploadAssetFiles)
                {
                    ApplicationArea = All;
                    Caption = 'Upload a file as an asset';
                    trigger OnAction()
                    var
                        JsonBuffer: Record "JSON Buffer" temporary;
                    begin
                        if tokenTxt = '' then
                            tokenTxt := 'db2d2054-b38a-48cc-bc81-f7fb5f88e009';
                        MethodAutGlobal := MethodAutGlobal::apikey;
                        urlGlobal := 'https://prepare.atomyx.io/api/admin/uploadtempassets';
                        RawType := RawType::JSON;
                        PostReqTestWithBinaryBody();
                        //Get file
                        JsonBuffer.ReadFromText(responseTextGlobal);
                        JsonBuffer.SetRange("Token type", JsonBuffer."Token type"::"Property Name");
                        JsonBuffer.SetRange(Value, 'fileLocation');
                        if JsonBuffer.FindFirst() then begin
                            JsonBuffer.SetRange("Token type");
                            JsonBuffer.SetRange(Value);
                            JsonBuffer.SetRange("Entry No.", JsonBuffer."Entry No." + 1);
                            //if JsonBuffer.FindFirst() then
                            //    InputFileAtom := JsonBuffer.Value;
                        end;
                    end;
                }
            }
            group(BoldSignSend)
            {
                action(BuildSendBody)
                {
                    ApplicationArea = All;
                    Caption = 'Upload PDF and build send body';
                    trigger OnAction()
                    begin
                        BuildSendSignatureBody();
                    end;
                }
                action(ActPostSendingSignature)
                {
                    ApplicationArea = All;
                    Caption = 'Post sending signature';
                    trigger OnAction()
                    begin
                        PostSendingSignature();
                    end;
                }
                action(ActGetDocumentStatus)
                {
                    ApplicationArea = All;
                    Caption = 'Get document status';
                    trigger OnAction()
                    begin
                        GetDocumentStatus();
                    end;
                }
                action(UpdateAndBuildMultSend)
                {
                    ApplicationArea = All;
                    Caption = 'Upload PDF and send multipart';
                    trigger OnAction()
                    begin
                        FunctUpdateAndBuildMultSend();
                    end;
                }
            }
            group(QuickSignIn)
            {
                action(SetApiKeyForBoldSign)
                {
                    ApplicationArea = All;
                    Caption = 'Set Bold Sign API Key';
                    trigger OnAction()
                    begin
                        tokenTxt := 'YmVlYmYyOGUtYTJkNi00MTBjLWJmNDktZDk0NzVhOWU0OWZj';
                        MethodAutGlobal := MethodAutGlobal::apikey;
                        urlGlobal := 'https://api.boldsign.com/v1/';
                        RawType := RawType::JSON;
                    end;
                }
                action(ActsignInPackitoo)
                {
                    ApplicationArea = All;
                    Caption = 'SignIn Packitoo';
                    trigger OnAction()
                    begin
                        SignInPackiToo();
                        MethodAutGlobal := MethodAutGlobal::beaver;
                        RawType := RawType::JSON;
                    end;
                }
                action(SetApiKeyForAtomyx)
                {
                    ApplicationArea = All;
                    Caption = 'Set Atomyx API Key';
                    trigger OnAction()
                    begin
                        tokenTxt := 'db2d2054-b38a-48cc-bc81-f7fb5f88e009';
                        MethodAutGlobal := MethodAutGlobal::apikey;
                        urlGlobal := 'https://prepare.atomyx.io/api/admin/listpreflightprofiles';
                        RawType := RawType::JSON;
                    end;
                }
            }
            group(Generic)
            {
                action(Get)
                {
                    ApplicationArea = All;
                    Caption = 'Test Get';
                    trigger OnAction()
                    begin
                        GetReqTest(bodyText <> '');
                    end;
                }
                action(post)
                {
                    ApplicationArea = All;
                    Caption = 'Test Post';
                    trigger OnAction()
                    begin
                        PostReqTest();
                    end;
                }

                action(QueryTest)
                {
                    ApplicationArea = All;
                    Caption = 'Test Query';
                    trigger OnAction()
                    begin
                        GetReqTest(bodyText <> '');
                    end;
                }
                action(UpdateTest)
                {
                    ApplicationArea = All;
                    Caption = 'Test Update';
                    trigger OnAction()
                    begin
                        UpdateReqTest();
                    end;
                }
            }
            group(packitootest)
            {
                action(test)
                {
                    ApplicationArea = All;
                    Caption = 'first Test';
                    trigger OnAction()
                    begin
                        apiTestRest();
                    end;
                }
            }


            action(ParseResponse)
            {
                ApplicationArea = All;
                caption = 'Parse response';
                trigger OnAction()
                var
                    JsonBuffer: Record "JSON Buffer" temporary;
                begin
                    JsonBuffer.ReadFromText(responseTextGlobal);
                    Page.Run(PAge::"Atomyx JSON OBJECT", JsonBuffer);
                end;
            }
            action(EncodeFilter)
            {
                ApplicationArea = All;
                trigger OnAction()
                begin
                    //bodyText := encodeURL(bodyText);
                end;
            }
            group(miscTest)
            {
                action(testdiv)
                {
                    ApplicationArea = All;
                    Visible = false;
                    trigger OnAction()
                    begin
                        Message('%1', test1 div test2);
                    end;
                }
                action(caldatetest)
                {
                    ApplicationArea = All;
                    Visible = false;
                    trigger OnAction()
                    begin
                        Date2L := CalcDate(calDateFormL, Date1L);
                    end;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        tokenTxt := 'YmVlYmYyOGUtYTJkNi00MTBjLWJmNDktZDk0NzVhOWU0OWZj';
        MethodAutGlobal := MethodAutGlobal::apikey;
        //urlGlobal := 'https://api.boldsign.com/v1/';
        urlGlobal := 'https://api-eu.boldsign.com/v1/';
        RawType := RawType::JSON;
        SignerOrderTest := 1;
        DeliveryModeTest := 'Email';
        FieldTypeTest := 'Signature';
        FieldNameTest := 'sign_field';
        FieldPageNumberTest := 1;
        FieldXTest := 50;
        FieldYTest := 50;
        FieldWidthTest := 200;
        FieldHeightTest := 30;
        FieldIsRequiredTest := true;
    end;

    var
        tokenTxt: Text;
        bodyText: text;
        responseTextGlobal: text;
        globalUser: Text;
        globalPassword: Text;

        urlGlobal: Text;
        MethodOptionGlobal: Option GET,POST;
        MethodAutGlobal: Option empty,basic,beaver,apikey,xapikey;
        RawType: Option plainText,JSON;
        useBodyForGetGlobal: Boolean;
        SignerNameTest: Text;
        SignerEmailTest: Text;
        EmailSubjectTest: Text;
        EmailBodyTest: Text;
        FileNameTest: Text;
        DocumentIdTest: Text;
        SignerOrderTest: Integer;
        DeliveryModeTest: Text;
        FieldTypeTest: Text;
        FieldNameTest: Text;
        FieldPageNumberTest: Integer;
        FieldXTest: Integer;
        FieldYTest: Integer;
        FieldWidthTest: Integer;
        FieldHeightTest: Integer;
        FieldIsRequiredTest: Boolean;
        TempBlobMultipart: Codeunit "Temp Blob";
        MultipartBoundary: Text;

    local procedure FunctUpdateAndBuildMultSend()
    var
        BodyOutStream: OutStream;
        FileInStream: InStream;
        FileName, DocumentTitle : Text;
        CRLF: Text[2];
    begin
        if not UploadIntoStream('Select PDF', '', 'PDF files (*.pdf)|*.pdf', FileName, FileInStream) then
            exit;
        FileNameTest := FileName;

        CRLF[1] := 13;
        CRLF[2] := 10;
        MultipartBoundary := 'BoldSign' + DelChr(Format(CreateGuid()), '=', '{}-');

        DocumentTitle := EmailSubjectTest;
        if DocumentTitle = '' then
            DocumentTitle := FileName;

        Clear(TempBlobMultipart);
        TempBlobMultipart.CreateOutStream(BodyOutStream, TextEncoding::UTF8);
        AddMultipartTextPart(BodyOutStream, 'Title', DocumentTitle);
        if EmailBodyTest <> '' then
            AddMultipartTextPart(BodyOutStream, 'Message', EmailBodyTest);

        AddMultipartTextPart(BodyOutStream, 'Signers[0][Name]', SignerNameTest);
        AddMultipartTextPart(BodyOutStream, 'Signers[0][EmailAddress]', SignerEmailTest);
        AddMultipartTextPart(BodyOutStream, 'Signers[0][SignerOrder]', Format(SignerOrderTest, 0, 9));
        AddMultipartTextPart(BodyOutStream, 'Signers[0][DeliveryMode]', DeliveryModeTest);
        AddMultipartTextPart(BodyOutStream, 'Signers[0][FormFields][0][FieldType]', FieldTypeTest);
        AddMultipartTextPart(BodyOutStream, 'Signers[0][FormFields][0][Name]', FieldNameTest);
        AddMultipartTextPart(BodyOutStream, 'Signers[0][FormFields][0][PageNumber]', Format(FieldPageNumberTest, 0, 9));
        AddMultipartTextPart(BodyOutStream, 'Signers[0][FormFields][0][Bounds][X]', Format(FieldXTest, 0, 9));
        AddMultipartTextPart(BodyOutStream, 'Signers[0][FormFields][0][Bounds][Y]', Format(FieldYTest, 0, 9));
        AddMultipartTextPart(BodyOutStream, 'Signers[0][FormFields][0][Bounds][Width]', Format(FieldWidthTest, 0, 9));
        AddMultipartTextPart(BodyOutStream, 'Signers[0][FormFields][0][Bounds][Height]', Format(FieldHeightTest, 0, 9));
        AddMultipartTextPart(BodyOutStream, 'Signers[0][FormFields][0][IsRequired]', Format(FieldIsRequiredTest, 0, 9));

        BodyOutStream.WriteText('--' + MultipartBoundary + CRLF);
        BodyOutStream.WriteText(StrSubstNo('Content-Disposition: form-data; name="Files"; filename="%1"', FileName) + CRLF);
        BodyOutStream.WriteText('Content-Type: application/pdf' + CRLF + CRLF);
        CopyStream(BodyOutStream, FileInStream);
        BodyOutStream.WriteText(CRLF + '--' + MultipartBoundary + '--' + CRLF);

        MethodAutGlobal := MethodAutGlobal::xapikey;
        urlGlobal := 'https://api-eu.boldsign.com/v1/document/send';
        bodyText := StrSubstNo('multipart body, boundary %1, %2 bytes', MultipartBoundary, TempBlobMultipart.Length());

        PostMultipartSend();
    end;

    local procedure AddMultipartTextPart(var BodyOutStream: OutStream; PartName: Text; PartValue: Text)
    var
        CRLF: Text[2];
    begin
        CRLF[1] := 13;
        CRLF[2] := 10;
        BodyOutStream.WriteText('--' + MultipartBoundary + CRLF);
        BodyOutStream.WriteText(StrSubstNo('Content-Disposition: form-data; name="%1"', PartName) + CRLF + CRLF);
        BodyOutStream.WriteText(PartValue + CRLF);
    end;

    local procedure PostMultipartSend()
    var
        mHttpReqPost: HttpRequestMessage;
        mHttpReqHead: HttpHeaders;
        mHttpContent: HttpContent;
        mHttpReqHeadContent: HttpHeaders;
        mHttpRecMsg: HttpResponseMessage;
        mClient: HttpClient;
        BodyInStream: InStream;
        ResponseBody: Text;
        ResponseJson: JsonObject;
        DocumentIdToken: JsonToken;
    begin
        if TempBlobMultipart.Length() = 0 then
            Error('Build the multipart body first.');
        if not Confirm(StrSubstNo('POST multipart (%1 bytes) to %2 ?', TempBlobMultipart.Length(), urlGlobal)) then
            exit;

        TempBlobMultipart.CreateInStream(BodyInStream);
        mHttpContent.WriteFrom(BodyInStream);
        mHttpContent.GetHeaders(mHttpReqHeadContent);
        mHttpReqHeadContent.Clear();
        mHttpReqHeadContent.Add('Content-Type', 'multipart/form-data; boundary=' + MultipartBoundary);

        mHttpReqPost.SetRequestUri(urlGlobal);
        mHttpReqPost.Method('POST');
        mHttpReqPost.GetHeaders(mHttpReqHead);
        mHttpReqHead.Add('X-API-KEY', tokenTxt);
        mHttpReqPost.Content(mHttpContent);

        mClient.Send(mHttpReqPost, mHttpRecMsg);
        mHttpRecMsg.Content.ReadAs(ResponseBody);
        responseTextGlobal := StrSubstNo('HTTP %1 %2', mHttpRecMsg.HttpStatusCode(), ResponseBody);

        if mHttpRecMsg.IsSuccessStatusCode() then
            if ResponseJson.ReadFrom(ResponseBody) then
                if ResponseJson.Get('documentId', DocumentIdToken) then
                    DocumentIdTest := DocumentIdToken.AsValue().AsText();
    end;

    local procedure GetDocumentStatus()
    begin
        if DocumentIdTest = '' then
            Error('Enter the Document ID first.');

        MethodAutGlobal := MethodAutGlobal::xapikey;
        urlGlobal := 'https://api-eu.boldsign.com/v1/document/properties?documentId=' + DelChr(DocumentIdTest, '=', '{} ');
        bodyText := '';
        GetReqTest(false);
    end;

    local procedure BuildSendSignatureBody()
    var
        Base64Convert: Codeunit "Base64 Convert";
        FileInStream: InStream;
        FilesArray, SignersArray : JsonArray;
        FileObject, SignerObject, RequestBody : JsonObject;
        FileName, DocumentTitle : Text;
    begin
        if not UploadIntoStream('Select PDF', '', 'PDF files (*.pdf)|*.pdf', FileName, FileInStream) then
            exit;
        FileNameTest := FileName;

        FileObject.Add('base64', StrSubstNo('data:application/pdf;base64,%1', Base64Convert.ToBase64(FileInStream)));
        FileObject.Add('fileName', FileName);
        FilesArray.Add(FileObject);

        SignerObject.Add('Name', SignerNameTest);
        SignerObject.Add('EmailAddress', SignerEmailTest);
        SignerObject.Add('SignerType', 'Signer');
        SignersArray.Add(SignerObject);

        DocumentTitle := EmailSubjectTest;
        if DocumentTitle = '' then
            DocumentTitle := FileName;

        RequestBody.Add('Title', DocumentTitle);
        RequestBody.Add('Files', FilesArray);
        RequestBody.Add('Signers', SignersArray);
        RequestBody.Add('UseTextTags', true);
        RequestBody.Add('EnableReassign', false);
        if EmailBodyTest <> '' then
            RequestBody.Add('Message', EmailBodyTest);

        RequestBody.WriteTo(bodyText);

        MethodAutGlobal := MethodAutGlobal::xapikey;
        RawType := RawType::JSON;
        urlGlobal := 'https://api-eu.boldsign.com/v1/document/send';
    end;

    local procedure PostSendingSignature()
    begin
        if bodyText = '' then
            Error('Build the send body first.');
        PostReqTest();
    end;

    procedure SignInPackiToo()
    var
        mHttpReqSignIn: HttpRequestMessage;
        mHttpContent: HttpContent;
        mHttpReqHeadContent: HttpHeaders;
        mHttpRecMsg: HttpResponseMessage;
        mClient: HttpClient;
        RespTxt: Text;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
        i: Integer;
    begin
        if Confirm('Sign in ?') then begin
            //Sign in at first
            mHttpReqSignIn.SetRequestUri('https://printvis-hipe.packitoo.com/api/sign-in');
            mHttpReqSignIn.Method('POST');
            mHttpContent.WriteFrom(StrSubstNo('{"username":"%1","password":"%2"}', globalUser, globalPassword));
            mHttpContent.GetHeaders(mHttpReqHeadContent);
            mHttpReqHeadContent.Clear();
            mHttpReqHeadContent.Add('Content-Type', 'application/json; charset=UTF-8');
            mHttpReqSignIn.Content(mHttpContent);
            mClient.Send(mHttpReqSignIn, mHttpRecMsg);
            mHttpRecMsg.Content.ReadAs(responseTextGlobal);
            JsonObj.ReadFrom(responseTextGlobal);
            JsonObj.Get('token', JsonTok);
            JsonTok.WriteTo(tokenTxt);
            i := StrLen(tokenTxt);
            if (tokenTxt[1] = '"') and (tokenTxt[i] = '"') then
                tokenTxt := CopyStr(tokenTxt, 2, i - 2);
            //tokenTxt := DelChr(tokenTxt, '=', '"');
        end;
    end;

    procedure PostReqTest()
    var
        //Base64ConvertCduL: Codeunit "Base64 Convert";
        Base64ConvertCduL: Codeunit "Base64 Convert";
        mHttpReqPost: HttpRequestMessage;
        mHttpReqHead: HttpHeaders;
        mHttpContent: HttpContent;
        mHttpReqHeadContent: HttpHeaders;
        mHttpRecMsg: HttpResponseMessage;
        mClient: HttpClient;
        RespTxt: Text;
        Username, Password : Text;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
    begin
        if Confirm('POST') then begin
            //Sign in at first
            mHttpReqPost.SetRequestUri(urlGlobal);
            mHttpReqPost.Method('POST');
            mHttpContent.WriteFrom(bodyText);
            if RawType = RawType::JSON then begin
                mHttpContent.GetHeaders(mHttpReqHeadContent);
                mHttpReqHeadContent.Clear();
                mHttpReqHeadContent.Add('Content-Type', 'application/json; charset=UTF-8');
            end;
            if MethodAutGlobal = MethodAutGlobal::basic then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add(
                    'Authorization',
                'Basic ' + Base64ConvertCduL.ToBase64(globalUser + ':' + globalPassword)
                );
            end else if MethodAutGlobal = MethodAutGlobal::apikey then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('api-key', tokenTxt);
            end else if MethodAutGlobal = MethodAutGlobal::xapikey then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('X-API-KEY', tokenTxt);
            end else if MethodAutGlobal = MethodAutGlobal::beaver then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('Authorization', 'Bearer ' + tokenTxt);
            end;
            mHttpReqPost.Content(mHttpContent);
            mClient.Send(mHttpReqPost, mHttpRecMsg);
            mHttpRecMsg.Content.ReadAs(responseTextGlobal);
        end;
    end;

    procedure UpdateReqTest()
    var
        Base64ConvertCduL: Codeunit "Base64 Convert";
        mHttpReqPost: HttpRequestMessage;
        mHttpReqHead: HttpHeaders;
        mHttpContent: HttpContent;
        mHttpReqHeadContent: HttpHeaders;
        mHttpRecMsg: HttpResponseMessage;
        mClient: HttpClient;
        RespTxt: Text;
        Username, Password : Text;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
    begin
        if Confirm('UPDATE record') then begin
            //Sign in at first
            mHttpReqPost.SetRequestUri(urlGlobal);
            mHttpReqPost.Method('PATCH');
            mHttpContent.WriteFrom(bodyText);
            if RawType = RawType::JSON then begin
                mHttpContent.GetHeaders(mHttpReqHeadContent);
                mHttpReqHeadContent.Clear();
                mHttpReqHeadContent.Add('Content-Type', 'application/json; charset=UTF-8');
            end;
            if MethodAutGlobal = MethodAutGlobal::basic then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add(
                    'Authorization',
                'Basic ' + Base64ConvertCduL.ToBase64(globalUser + ':' + globalPassword)
                );
            end else if MethodAutGlobal = MethodAutGlobal::apikey then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('api-key', tokenTxt);
            end else if MethodAutGlobal = MethodAutGlobal::xapikey then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('X-API-KEY', tokenTxt);
            end else if MethodAutGlobal = MethodAutGlobal::beaver then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('Authorization', 'Bearer ' + tokenTxt);
            end;
            mHttpReqPost.Content(mHttpContent);
            mClient.Send(mHttpReqPost, mHttpRecMsg);
            mHttpRecMsg.Content.ReadAs(responseTextGlobal);
        end;
    end;

    procedure GetReqTest(useBodyP: Boolean)
    var
        Base64ConvertCduL: Codeunit "Base64 Convert";
        mClient: HttpClient;
        mHttpReqMsg: HttpRequestMessage;
        mHttpReqSignIn: HttpRequestMessage;
        mHttpInMsg: HttpResponseMessage;
        mHttpContent: HttpContent; //generic
        mHttpReqHead: HttpHeaders;
        mHttpReqHeadContent: HttpHeaders;
        RespTxt: Text;
    begin
        if Confirm('Get ?') then begin
            //With autoirization get company id
            Clear(mHttpReqMsg);
            mHttpReqMsg.SetRequestUri(
                urlGlobal
            );
            mHttpReqMsg.Method('GET');

            if (useBodyP) and (bodyText <> '') then begin
                mHttpContent.WriteFrom(bodyText);
                if RawType = RawType::JSON then begin
                    mHttpContent.GetHeaders(mHttpReqHeadContent);
                    mHttpReqHeadContent.Clear();
                    mHttpReqHeadContent.Add('Content-Type', 'application/json; charset=UTF-8');
                end;
            end;
            //mHttpReqMsg.
            if MethodAutGlobal = MethodAutGlobal::basic then begin
                mHttpReqMsg.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add(
                    'Authorization',
                'Basic ' + Base64ConvertCduL.ToBase64(globalUser + ':' + globalPassword)
                );
            end else if MethodAutGlobal = MethodAutGlobal::beaver then begin
                mHttpReqMsg.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('Authorization', 'Bearer ' + tokenTxt);
            end else if MethodAutGlobal = MethodAutGlobal::xapikey then begin
                mHttpReqMsg.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('X-API-KEY', tokenTxt);
            end else if MethodAutGlobal = MethodAutGlobal::apikey then begin
                mHttpReqMsg.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('api-key', tokenTxt);
            end;

            if (useBodyP) and (bodyText <> '') then begin
                mHttpReqMsg.Content(mHttpContent);
            end;

            mClient.Send(mHttpReqMsg, mHttpInMsg);
            mHttpInMsg.Content.ReadAs(responseTextGlobal);
            if not mHttpInMsg.IsSuccessStatusCode then
                Message('%1', mHttpInMsg.HttpStatusCode.ToText());
        end;
    end;

    procedure GetQueryTest(useBodyP: Boolean)
    var
        Base64ConvertCduL: Codeunit "Base64 Convert";
        mClient: HttpClient;
        mHttpReqMsg: HttpRequestMessage;
        mHttpReqSignIn: HttpRequestMessage;
        mHttpInMsg: HttpResponseMessage;
        mHttpContent: HttpContent; //generic
        mHttpReqHead: HttpHeaders;
        mHttpReqHeadContent: HttpHeaders;
        RespTxt: Text;
    begin
        if Confirm('Query ?') then begin
            //With autoirization get company id
            Clear(mHttpReqMsg);
            mHttpReqMsg.SetRequestUri(
                urlGlobal
            );
            mHttpReqMsg.Method('QUERY');

            if (useBodyP) and (bodyText <> '') then begin
                mHttpContent.WriteFrom(bodyText);
                if RawType = RawType::JSON then begin
                    mHttpContent.GetHeaders(mHttpReqHeadContent);
                    mHttpReqHeadContent.Clear();
                    mHttpReqHeadContent.Add('Content-Type', 'application/json; charset=UTF-8');
                end;
            end;
            //mHttpReqMsg.
            if MethodAutGlobal = MethodAutGlobal::basic then begin
                mHttpReqMsg.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add(
                    'Authorization',
                'Basic ' + Base64ConvertCduL.ToBase64(globalUser + ':' + globalPassword)
                );
            end else if MethodAutGlobal = MethodAutGlobal::apikey then begin
                mHttpReqMsg.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('api-key', tokenTxt);
            end else if MethodAutGlobal = MethodAutGlobal::xapikey then begin
                mHttpReqMsg.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('X-API-KEY', tokenTxt);
            end else if MethodAutGlobal = MethodAutGlobal::beaver then begin
                mHttpReqMsg.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('Authorization', 'Bearer ' + tokenTxt);
            end;

            if (useBodyP) and (bodyText <> '') then begin
                mHttpReqMsg.Content(mHttpContent);
            end;

            mClient.Send(mHttpReqMsg, mHttpInMsg);
            mHttpInMsg.Content.ReadAs(responseTextGlobal);
        end;
    end;

    procedure apiTestRest()
    var
        Base64ConvertCduL: Codeunit "Base64 Convert";
        mClient: HttpClient;
        mHttpReqMsg: HttpRequestMessage;
        mHttpReqSignIn: HttpRequestMessage;
        mHttpInMsg: HttpResponseMessage;
        mHttpContent: HttpContent; //generic
        mHttpReqHead: HttpHeaders;
        mHttpReqHeadContent: HttpHeaders;
        RespTxt: Text;
        Username, Password : Text;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
    begin
        Username := 'bas@printvis.com';
        Password := 'PrintVis1';
        /*
        if Confirm('Sign in ?') then begin
            //Sign in at first
            

            //mHttpReqHead.Clear();
            //mHttpReqHead.Add('Accept', '**');
            mHttpContent.WriteFrom(StrSubstNo('{"username":"%1","password":"%2"}', Username, Password));
            mHttpContent.GetHeaders(mHttpReqHeadContent);
            if mHttpReqHeadContent.Contains('Content-Type') then mHttpReqHeadContent.Remove('Content-Type');
            mHttpReqHeadContent.Add('Content-Type', 'application/json; charset=UTF-8');
            
            mClient.Post('https://printvis-hipe.packitoo.com/api/sign-in', mHttpContent, mHttpInMsg);
            mHttpInMsg.Content.ReadAs(RespTxt);
            Message(RespTxt);
        end;
        */
        if Confirm('Sign in ?') then begin
            //Sign in at first
            mHttpReqSignIn.SetRequestUri('https://printvis-hipe.packitoo.com/api/sign-in');
            mHttpReqSignIn.Method('POST');
            mHttpContent.WriteFrom(StrSubstNo('{"username":"%1","password":"%2"}', Username, Password));
            mHttpContent.GetHeaders(mHttpReqHeadContent);
            mHttpReqHeadContent.Clear();
            mHttpReqHeadContent.Add('Content-Type', 'application/json; charset=UTF-8');
            mHttpReqSignIn.Content(mHttpContent);
            mClient.Send(mHttpReqSignIn, mHttpInMsg);
            mHttpInMsg.Content.ReadAs(RespTxt);
            Message(RespTxt);
            JsonObj.ReadFrom(RespTxt);
            JsonObj.Get('token', JsonTok);
            JsonTok.WriteTo(tokenTxt);
            Message('Token is %1', tokenTxt);
        end;

        if Confirm('health packitoo ?') then begin
            mHttpReqMsg.SetRequestUri('https://printvis-hipe.packitoo.com/api/health');
            mHttpReqMsg.Method := 'GET';
            mClient.Send(mHttpReqMsg, mHttpInMsg);
            mHttpInMsg.Content.ReadAs(RespTxt);
            Message(RespTxt);
            exit;
        end;

        if Confirm('Retrieve customer 173 ?') then begin
            //With autoirization get company id
            Clear(mHttpReqMsg);
            mHttpReqMsg.SetRequestUri(
                StrSubstNo(
                //'https://printvis-hipe.packitoo.com/api/companies/id:%1?access_token=%2',
                'https://printvis-hipe.packitoo.com?access_token=%2/api/companies/id:%1',
                173, tokenTxt
                )
            );
            mHttpReqMsg.Method('GET');
            //mHttpReqMsg.
            //mHttpReqMsg.GetHeaders(mHttpReqHead);
            //if mHttpReqHeadContent.Contains('Content-Type') then
            //    mHttpReqHeadContent.Remove('Content-Type');
            //mHttpReqHead.Add('Accept', 'application/json');
            //mHttpReqHead.Add('Authorization', 'Basic ' + Base64ConvertCduL.ToBase64(Username + ':' + Password));
            //mHttpReqHead.Add('Authorization', 'Bearer ' + tokenTxt);
            mClient.Send(mHttpReqMsg, mHttpInMsg);
            mHttpInMsg.Content.ReadAs(RespTxt);
            Message(RespTxt);
        end;
    end;

    /*
    local procedure OnDelete_Web2PVSLine_OnBeforeDeletingCase(var IsHandled: Boolean)
    var
    test: Record "PVS Web2PVS Line";
    begin

    end;
    */
    var
        test1: Integer;
        test2: Integer;

        calDateFormL: DateFormula;
        Date1L: Date;
        Date2L: date;

    //FILE UPLODAD Media

    local procedure importPictureToPVSEmFileStorage(var TempPVSPicture: Record "PVS Embedded File Storage";
        inCodePicture: Code[20];
        urlFileP: text; inRefresh: Boolean): Boolean
    var
        InStreamL: InStream;
        OutStreamL: OutStream;
        mClient: HttpClient;
        mHttpInMsg: HttpResponseMessage;
        mHttpContent: HttpContent;
        idxL: Integer;
        ByteTest: Byte;
        fileMan: Codeunit "File Management";
        tmpBlob: Codeunit "Temp Blob";
        PVProdPAge: page "PVS Product Card";
    begin
        //tmpBlob.
        TempPVSPicture.Reset();
        TempPVSPicture.SetRange(Code, inCodePicture);
        if TempPVSPicture.FindFirst() then;
        Clear(TempPVSPicture.Picture);

        if (inRefresh) and (urlFileP <> '') then begin
            mClient.Get(urlFileP, mHttpInMsg);
            mHttpContent := mHttpInMsg.Content;
            mHttpContent.ReadAs(InStreamL);

            TempPVSPicture.Picture.CreateOutStream(OutStreamL);
            repeat
                idxL := InStreamL.Read(ByteTest, 1);
                if idxL > 0 then
                    OutStreamL.Write(ByteTest);
            until idxL = 0;
            TempPVSPicture.Modify();
            TempPVSPicture.CalcFields(Picture);
        end;
        exit(true);
    end;

    procedure UploadDataOnBloob(var TempPVSPicture: Record "PVS Embedded File Storage"): Boolean
    var
        InStream: InStream;
        OutStreamL: OutStream;
        FileName: Text;
        idxL: Integer;
        ByteTest: Byte;
    begin
        TempPVSPicture.SetRange(Code, 'tmpdummy');
        if not TempPVSPicture.FindFirst() then begin
            TempPVSPicture.Code := 'tmpdummy';
            TempPVSPicture.Insert();
        end;
        Clear(TempPVSPicture.Picture);
        if UploadIntoStream('', '', '', FileName, InStream) then begin
            TempPVSPicture.Picture.CreateOutStream(OutStreamL);
            repeat
                idxL := InStream.Read(ByteTest, 1);
                if idxL > 0 then
                    OutStreamL.Write(ByteTest);
            until idxL = 0;
            TempPVSPicture.Modify();
            TempPVSPicture.CalcFields(Picture);
            exit(true);
        end;
        exit(false);
    end;

    //ATOMYX
    var
        InStreamGlobal: InStream;

    procedure PostReqTestWithBinaryBody()
    var
        TempPVSPictureL: Record "PVS Embedded File Storage" temporary;
        Base64ConvertCduL: Codeunit "Base64 Convert";
        mHttpReqPost: HttpRequestMessage;
        mHttpReqHead: HttpHeaders;
        mHttpContent: HttpContent;
        mHttpReqHeadContent: HttpHeaders;
        mHttpRecMsg: HttpResponseMessage;
        mClient: HttpClient;
        RespTxt: Text;
        Username, Password : Text;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
        InStreamL: InStream;
        FileNameL: text;
        boundaryTxt: text;
        StreamName: Text;
    begin

        if Confirm('Upload file') then begin
            boundaryTxt := 'AaBby39dx';

            if not UploadDataFileOnMultiPartAndGetBloob(TempPVSPictureL, boundaryTxt) then
                Error('unable to create the instream');

            //Create stream from
            Clear(InStreamGlobal);
            TempPVSPictureL.Picture.CreateInStream(InStreamGlobal);
            /*
            Message('%1 bytes', InStreamGlobal.Length);
            StreamName := 'StreamToCheck.txt';
            if Confirm('dowload the form to file') then begin
                DownloadFromStream(InStreamGlobal, '', '', '', StreamName);
            end;
            */

            if not Confirm(StrSubstNo('body lenght = %1. Post ?', InStreamGlobal.Length)) then
                exit;

            mHttpContent.WriteFrom(InStreamGlobal);

            mHttpReqPost.SetRequestUri(urlGlobal);
            mHttpReqPost.Method('POST');


            mHttpContent.GetHeaders(mHttpReqHeadContent);
            mHttpReqHeadContent.Clear();

            if boundaryTxt <> '' then
                mHttpReqHeadContent.Add('Content-Type', 'multipart/form-data ; boundary="' + boundaryTxt + '"')
            else
                mHttpReqHeadContent.Add('Content-Type', 'multipart/form-data');

            if MethodAutGlobal = MethodAutGlobal::basic then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add(
                    'Authorization',
                'Basic ' + Base64ConvertCduL.ToBase64(globalUser + ':' + globalPassword)
                );
            end else if MethodAutGlobal = MethodAutGlobal::apikey then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('api-key', tokenTxt);
            end else if MethodAutGlobal = MethodAutGlobal::xapikey then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('X-API-KEY', tokenTxt);
                //mHttpReqHead.Add('Content-type', 'multipart/form-data');
            end else if MethodAutGlobal = MethodAutGlobal::beaver then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('Authorization', 'Bearer ' + tokenTxt);
            end;
            mHttpReqPost.Content(mHttpContent);
            mClient.Send(mHttpReqPost, mHttpRecMsg);
            mHttpRecMsg.Content.ReadAs(responseTextGlobal);
        end;
    end;

    local procedure UploadDataFileOnMultiPartAndGetBloob
        (var TempPVSPicture: Record "PVS Embedded File Storage"; inBoundary: Text): Boolean
    var
        InStream: InStream;
        OutStreamL: OutStream;
        FileName: Text;
        StreamName: Text;
        idxL: Integer;
        i: Integer;
        ByteTest: Byte;
        tb: TextBuilder;
        prefixTxt: Text;
        suffixTxt: text;
    begin
        TempPVSPicture.SetRange(Code, 'tmpdummy');
        if not TempPVSPicture.FindFirst() then begin
            TempPVSPicture.Code := 'tmpdummy';
            TempPVSPicture.Insert();
        end;
        Clear(TempPVSPicture.Picture);
        if UploadIntoStream('', '', '', FileName, InStream) then begin
            TempPVSPicture.Picture.CreateOutStream(OutStreamL);
            //Build Prefix
            tb.Clear();
            if inBoundary <> '' then
                tb.AppendLine(StrSubstNo('--%1', inBoundary));
            //tb.AppendLine(StrSubstNo('assetFile=%1;type=application/pdf',FileName));
            tb.AppendLine(StrSubstNo('Content-Disposition: form-data; name="assetFile"; filename="%1"', FileName));
            tb.AppendLine('Content-Type: application/pdf');
            tb.AppendLine();
            prefixTxt := tb.ToText();
            tb.Clear();
            //Build Suffix
            if inBoundary <> '' then
                tb.AppendLine(StrSubstNo('--%1--', inBoundary));
            //tb.AppendLine();
            suffixTxt := tb.ToText();

            //Writing:
            //PREFIX
            for i := 1 to StrLen(prefixTxt) do begin
                OutStreamL.Write(prefixTxt[i]);
            end;

            repeat
                idxL := InStream.Read(ByteTest, 1);
                if idxL > 0 then
                    OutStreamL.Write(ByteTest);
            until idxL = 0;

            //SUFIX
            for i := 1 to StrLen(suffixTxt) do begin
                OutStreamL.Write(suffixTxt[i]);
            end;


            TempPVSPicture.Modify();
            TempPVSPicture.CalcFields(Picture);
            exit(true);
        end;
        exit(false);
    end;

    local procedure UploadDataOnBloobGetInStreamv2(var InStreamP: InStream; inBoundary: Text): Boolean
    var
        TempPVSPicture: Record "PVS Embedded File Storage" temporary;
        InStream: InStream;
        OutStreamL: OutStream;
        FileName: Text;
        idxL: Integer;
        i: Integer;
        ByteTest: Byte;
        tb: TextBuilder;
        prefixTxt: Text;
        suffixTxt: text;
    begin
        TempPVSPicture.SetRange(Code, 'tmpdummy');
        if not TempPVSPicture.FindFirst() then begin
            TempPVSPicture.Code := 'tmpdummy';
            TempPVSPicture.Insert();
        end;
        Clear(TempPVSPicture.Picture);
        if UploadIntoStream('', '', '', FileName, InStream) then begin
            TempPVSPicture.Picture.CreateOutStream(OutStreamL);
            //Build Prefix
            tb.Clear();
            if inBoundary <> '' then
                tb.AppendLine(StrSubstNo('--%1', inBoundary));
            //tb.AppendLine(StrSubstNo('assetFile=%1;type=application/pdf',FileName));
            tb.AppendLine(StrSubstNo('Content-Disposition: form-data; name="assetFile"; filename="%1"', FileName));
            tb.AppendLine('Content-Type: application/pdf');
            tb.AppendLine();
            prefixTxt := tb.ToText();
            tb.Clear();
            //Build Suffix
            if inBoundary <> '' then
                tb.AppendLine(StrSubstNo('--%1--', inBoundary));
            //tb.AppendLine();
            suffixTxt := tb.ToText();

            //PREFIX
            for i := 1 to StrLen(prefixTxt) do begin
                OutStreamL.Write(prefixTxt[i]);
            end;

            repeat
                idxL := InStream.Read(ByteTest, 1);
                if idxL > 0 then
                    OutStreamL.Write(ByteTest);
            until idxL = 0;

            //SUFIX
            for i := 1 to StrLen(suffixTxt) do begin
                OutStreamL.Write(suffixTxt[i]);
            end;


            TempPVSPicture.Modify();
            TempPVSPicture.CalcFields(Picture);
            TempPVSPicture.Picture.CreateInStream(InStreamGlobal);

            exit(true);
        end;
        exit(false);

    end;

    local procedure UploadDataOnBloobGetInStreamv3(var HttpContentP: HttpContent; inBoundary: Text): Boolean
    var
        TempPVSPicture: Record "PVS Embedded File Storage" temporary;
        InStream: InStream;
        OutStreamL: OutStream;
        FileName: Text;
        StreamName: Text;
        idxL: Integer;
        i: Integer;
        ByteTest: Byte;
        tb: TextBuilder;
        prefixTxt: Text;
        suffixTxt: text;
    begin
        TempPVSPicture.SetRange(Code, 'tmpdummy');
        if not TempPVSPicture.FindFirst() then begin
            TempPVSPicture.Code := 'tmpdummy';
            TempPVSPicture.Insert();
        end;
        //Build Prefix
        tb.Clear();
        if inBoundary <> '' then
            tb.AppendLine(StrSubstNo('--%1', inBoundary));
        //tb.AppendLine(StrSubstNo('assetFile=%1;type=application/pdf',FileName));
        tb.AppendLine(StrSubstNo('Content-Disposition: form-data; name="assetFile"; filename="%1"', FileName));
        tb.AppendLine('Content-Type: application/pdf');
        tb.AppendLine();
        prefixTxt := tb.ToText();
        tb.Clear();
        //Build Suffix
        if inBoundary <> '' then
            tb.AppendLine(StrSubstNo('--%1--', inBoundary));
        //tb.AppendLine();
        suffixTxt := tb.ToText();
        Clear(TempPVSPicture.Picture);
        if UploadIntoStream('', '', '', FileName, InStream) then begin
            TempPVSPicture.Picture.CreateOutStream(OutStreamL);
            //PREFIX
            for i := 1 to StrLen(prefixTxt) do begin
                OutStreamL.Write(prefixTxt[i]);
            end;

            repeat
                idxL := InStream.Read(ByteTest, 1);
                if idxL > 0 then
                    OutStreamL.Write(ByteTest);
            until idxL = 0;

            //SUFIX
            for i := 1 to StrLen(suffixTxt) do begin
                OutStreamL.Write(suffixTxt[i]);
            end;


            TempPVSPicture.Modify();
            TempPVSPicture.CalcFields(Picture);
            Clear(InStreamGlobal);
            TempPVSPicture.Picture.CreateInStream(InStreamGlobal);
            Message('%1 bytes', InStreamGlobal.Length);
            StreamName := 'StreamToCheck.txt';
            if Confirm('dowload the form to file') then
                DownloadFromStream(InStreamGlobal, '', '', '', StreamName);
        end;
        HttpContentP.WriteFrom(InStreamGlobal);
        exit(true);
    end;

    procedure UploadDataOnBloobGetInStream(var InStreamP: InStream; inboundary: Text): Boolean
    var
        TempPVSPicture: Record "PVS Embedded File Storage" temporary;
        InStream: InStream;
        OutStreamL: OutStream;
        FileName: Text;
        idxL: Integer;
        i: Integer;
        ByteTest: Byte;
        tb: TextBuilder;
    begin
        TempPVSPicture.SetRange(Code, 'tmpdummy');
        if not TempPVSPicture.FindFirst() then begin
            TempPVSPicture.Code := 'tmpdummy';
            TempPVSPicture.Insert();
        end;
        Clear(TempPVSPicture.Picture);
        if UploadIntoStream('', '', '', FileName, InStream) then begin
            TempPVSPicture.Picture.CreateOutStream(OutStreamL);
            repeat
                idxL := InStream.Read(ByteTest, 1);
                if idxL > 0 then
                    OutStreamL.Write(ByteTest);
            until idxL = 0;

            //now use boundary
            for i := 1 to StrLen(inboundary) do
                OutStreamL.Write(inboundary[i]);
            TempPVSPicture.Modify();
            TempPVSPicture.Picture.CreateInStream(InStreamP);
            exit(true);
        end;
        exit(false);
    end;
    //assetFile=@Banner_400x110.pdf;type=application/pdf
    //OLD
    procedure PostReqTestWithBinaryBodyOLD()
    var
        TempPVSPictureL: Record "PVS Embedded File Storage" temporary;
        Base64ConvertCduL: Codeunit "Base64 Convert";
        mHttpReqPost: HttpRequestMessage;
        mHttpReqHead: HttpHeaders;
        mHttpContent: HttpContent;
        mHttpReqHeadContent: HttpHeaders;
        mHttpRecMsg: HttpResponseMessage;
        mClient: HttpClient;
        RespTxt: Text;
        Username, Password : Text;
        JsonObj: JsonObject;
        JsonTok: JsonToken;
        InStreamL: InStream;
        FileNameL: text;
        boundaryTxt: text;
        StreamName: Text;
    begin
        //Upload files:
        //if not UploadDataOnBloob(TempPVSPictureL) then
        //    exit;

        if Confirm('Upload and POST') then begin
            boundaryTxt := 'AaBby39dx';
            //if not UploadIntoStream('', '', '', FileNameL, InStreamL) then
            //if not UploadDataOnBloobGetInStream(InStreamL, boundaryTxt) then
            //    Error('unable to create the instream');

            mHttpReqPost.SetRequestUri(urlGlobal);
            mHttpReqPost.Method('POST');
            if not UploadDataOnBloobGetInStreamv2(InStreamL, boundaryTxt) then
                Error('unable to create the instream');
            //mHttpContent.WriteFrom(bodyText);
            Message('%1 bytes', InStreamGlobal.Length);
            StreamName := 'StreamToCheck.txt';
            if Confirm('dowload the form to file') then begin
                DownloadFromStream(InStreamGlobal, '', '', '', StreamName);
            end;
            mHttpContent.WriteFrom(InStreamGlobal);

            //mHttpContent.WriteFrom('12456789Border');

            mHttpContent.GetHeaders(mHttpReqHeadContent);
            mHttpReqHeadContent.Clear();
            //mHttpReqHeadContent.Add('Content-Type', 'application/octet-stream');
            //mHttpReqHeadContent.Add('Content', 'multipart/form-data');
            //mHttpReqHeadContent.Add('Content-Type', 'application/octet-stream');
            //if boundaryTxt <> '' then
            ///   mHttpReqHeadContent.Add('Content-Type', 'multipart/form-data ; boundary=' + boundaryTxt)
            //else
            //mHttpReqHeadContent.Add('Content-Type', 'multipart/form-data');
            //mHttpReqHeadContent.Add('Content-Type', 'undefined');
            //mHttpReqHeadContent.Add('Content-Type', 'application/pdf');
            //mHttpReqHeadContent.add('assetFile');
            if boundaryTxt <> '' then
                mHttpReqHeadContent.Add('Content-Type', 'multipart/form-data ; boundary="' + boundaryTxt + '"')
            else
                mHttpReqHeadContent.Add('Content-Type', 'multipart/form-data');

            if MethodAutGlobal = MethodAutGlobal::basic then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add(
                    'Authorization',
                'Basic ' + Base64ConvertCduL.ToBase64(globalUser + ':' + globalPassword)
                );
            end else if MethodAutGlobal = MethodAutGlobal::apikey then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('api-key', tokenTxt);
                //mHttpReqHead.Add('Content-type', 'multipart/form-data');
            end else if MethodAutGlobal = MethodAutGlobal::xapikey then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('X-API-KEY', tokenTxt);
            end else if MethodAutGlobal = MethodAutGlobal::beaver then begin
                mHttpReqPost.GetHeaders(mHttpReqHead);
                mHttpReqHead.Add('Authorization', 'Bearer ' + tokenTxt);
            end;
            mHttpReqPost.Content(mHttpContent);
            mClient.Send(mHttpReqPost, mHttpRecMsg);
            mHttpRecMsg.Content.ReadAs(responseTextGlobal);
        end;
    end;

    procedure encodeURL(SourceTxt: Text): Text
    var
        txtToReturn: Text;
        specialChar: text;
        i, j : Integer;
    begin
        for i := 1 to StrLen(SourceTxt) do begin
            if getSpecialcharEncoded(SourceTxt[i], specialChar) then
                txtToReturn += specialChar
            else
                txtToReturn += SourceTxt[i];
        end;
        exit(txtToReturn);
    end;

    local procedure getSpecialcharEncoded(inChar: Char; var outTxt: Text): Boolean
    begin
        Clear(outTxt);

        case inChar of
            ' ':
                outTxt := '%20';
            '"':
                outTxt := '%22';
            '''':
                outTxt := '%27';
            '{':
                outTxt := '%7B';
            '}':
                outTxt := '%7D';
            '$':
                outTxt := '%24';
            '[':
                outTxt := '%5B';
            ']':
                outTxt := '%5D';
            ':':
                outTxt := '%3A';
            ';':
                outTxt := '%3B';
            ',':
                outTxt := '%2C';
            '.':
                outTxt := '%2E';
        end;

        if outTxt <> '' then
            exit(true);
    end;

}


page 50676 "Atomyx JSON OBJECT"
{
    SourceTable = "JSON Buffer";
    SourceTableTemporary = true;
    PageType = ListPlus;
    layout
    {
        area(Content)
        {
            repeater(Repeater01)
            {
                field("Entry No."; Rec."Entry No.")
                { ApplicationArea = All; }
                field(Depth; Rec.Depth)
                { ApplicationArea = All; }
                field("Token type"; Rec."Token type")
                { ApplicationArea = all; }
                field(ValueType; Rec."Value Type")
                {
                    ApplicationArea = all;
                }
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}