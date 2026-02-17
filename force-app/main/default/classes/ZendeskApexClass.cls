public with sharing class ZendeskApexClass {
    public ZendeskApexClass() {

    }
    @AuraEnabled
    public static string zendeskMethod(String zendBody, String zendSubject){
          String returnBody='';
        try{
          
          String returnError='';
          String zendeskEndPoint=Label.Zendesk_Endpoint;
          String zendeskUserName= Label.ZendeskUserName;
          String zendeskApiToken =Label.Zendesk_APIToken;
          String basicAuth = zendeskUserName + ':' + zendeskApiToken;
          String endcodeAuth = EncodingUtil.base64Encode(Blob.valueof(basicAuth));
          String reqBody = JSON.serialize(new Map<String, Object>{
                'ticket' => new Map<String, Object>{
                    'comment' => new Map<String, String>{
                        'body' => zendBody
                    },
                    'priority' => 'urgent',
                    'subject' => zendSubject
                }
            });
         HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setBody(reqBody);
        req.setEndPoint(zendeskEndPoint);
        req.setHeader('content-type','application/json');
        req.setHeader('Authorization','Basic ' + endcodeAuth);

        Http http = new Http();
        HttpResponse res = http.send(req);
            if(res.getStatusCode()==201){
            system.debug('Response body ::'+res.getBody());
               return 'Success';// or parse the JSON
                
            }
            
            else{
                System.debug('Error: ' + res.getStatusCode() + ' - ' + res.getBody());
                return 'Error: ' + res.getStatusCode() + ' - ' + res.getBody();
               
            }
        }
        catch(Exception ex){
            System.debug('Exception: ' + ex.getMessage());
            return 'Exception: ' + ex.getMessage();
        }
        

    }
}