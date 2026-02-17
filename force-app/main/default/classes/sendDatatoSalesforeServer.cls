global class sendDatatoSalesforeServer {
    
    global static void sendData(String oppId){
        
        Opportunity oppData = [Select id,Name,StageName,CloseDate from Opportunity where id=:oppId];
        
        // Convert Opportunity to JSON
        String jsonBody = JSON.serialize(oppData);

        // Prepare HTTP Request
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:Test_Named_Cred/services/apexrest/receiveOpportunity/');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(jsonBody);

        Http http = new Http();
        HttpResponse res = http.send(req);

        System.debug('Response Status: ' + res.getStatus());
        System.debug('Response Body: ' + res.getBody());
        
        
    }
}