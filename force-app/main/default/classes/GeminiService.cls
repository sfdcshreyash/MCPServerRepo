public with sharing class GeminiService {

    // ════════════════════════════════════════════════════════════════════════
    // 1. RAW GEMINI CALLOUT
    // ════════════════════════════════════════════════════════════════════════
    
    public static String getGeminiResponse(String prompt) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // 1. Keep the URL clean (No merge fields here to avoid the 'Illegal Character' error)
        request.setEndpoint('callout:Gemini_API/v1beta/models/gemini-2.5-flash:generateContent');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        
        // 2. Pass the key in the header using the merge field
        // Salesforce will safely swap this out at the moment of the callout
        request.setHeader('x-goog-api-key', '{!$Credential.GeminiExternal.apikey}');

        // 3. Build the Body
        Map<String, Object> requestBody = new Map<String, Object>();
        List<Object> contents = new List<Object>();
        Map<String, Object> contentTurn = new Map<String, Object>();
        List<Object> parts = new List<Object>();
        parts.add(new Map<String, Object>{'text' => prompt});
        contentTurn.put('parts', parts);
        contents.add(contentTurn);
        requestBody.put('contents', contents);
        
        request.setBody(JSON.serialize(requestBody));

        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> candidates = (List<Object>) results.get('candidates');
            Map<String, Object> firstCandidate = (Map<String, Object>) candidates[0];
            Map<String, Object> resContent = (Map<String, Object>) firstCandidate.get('content');
            List<Object> resParts = (List<Object>) resContent.get('parts');
            Map<String, Object> resFirstPart = (Map<String, Object>) resParts[0];
            return (String) resFirstPart.get('text');
        } else {
            return 'Error: ' + response.getStatusCode() + ' ' + response.getBody();
        }
    }
}