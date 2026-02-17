public with sharing class ClaudeService {
    
    /**
     * Sends a prompt to Claude and returns the text response.
     * @param prompt The user input text
     * @return String The content returned by Claude
     */
    public static String getClaudeResponse(String prompt) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // 1. Set the Endpoint using the Named Credential
        request.setEndpoint('callout:Claude_API/v1/messages');
        request.setMethod('POST');
        
        // 2. Security Headers - Using Merge Fields for the API Key
        request.setHeader('x-api-key', '{!$Credential.Claude_External.api_key}');
        request.setHeader('anthropic-version', '2023-06-01');
        request.setHeader('Content-Type', 'application/json');

        // 3. Build the Request Body
        Map<String, Object> bodyMap = new Map<String, Object>();
        bodyMap.put('model', 'claude-3-5-sonnet-20240620');
        bodyMap.put('max_tokens', 1024);
        
        List<Map<String, String>> messages = new List<Map<String, String>>();
        messages.add(new Map<String, String>{'role' => 'user', 'content' => prompt});
        bodyMap.put('messages', messages);
        
        request.setBody(JSON.serialize(bodyMap));

        try {
            HttpResponse response = http.send(request);
            
            if (response.getStatusCode() == 200) {
                // Parse the response (Simplified)
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                List<Object> contentList = (List<Object>) results.get('content');
                Map<String, Object> firstContent = (Map<String, Object>) contentList[0];
                return (String) firstContent.get('text');
            } else {
                System.debug('Error Status: ' + response.getStatus());
                System.debug('Error Body: ' + response.getBody());
                return 'Error: ' + response.getStatus();
            }
        } catch (Exception e) {
            throw new CalloutException('Callout failed: ' + e.getMessage());
        }
    }

}