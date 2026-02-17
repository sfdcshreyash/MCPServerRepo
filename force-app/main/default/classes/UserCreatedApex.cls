public class UserCreatedApex {
 
    public static void createUserOrUpdateMethod(List<User> userList , String actionType){
        
        try{
            // External API Configuration (replace with Named Credential ideally)
            String baseUrl = 'https://api.thirdpartyapp.com';
            String endpoint = (actionType == 'create') ? '/user/create' : '/user/update';
            
            if(!userList.isEmpty()){
                for(User u : userList){
                    
                HttpRequest req = new HttpRequest();
                req.setEndpoint(baseUrl + endpoint);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept', 'application/json');
                req.setHeader('Authorization', 'Bearer YOUR_API_KEY'); // optional 
                
                Map<String, Object> userData = new Map<String, Object>();
                userData.put('userId', u.Id);
                userData.put('firstName', u.FirstName);
                userData.put('lastName', u.LastName);
                userData.put('email', u.Email);
                userData.put('username', u.Username);
                userData.put('isActive', u.IsActive);

                req.setBody(JSON.serialize(userData));
                
                Http http = new Http();
                HttpResponse res = http.send(req);
                    
                   System.debug('Response Status: ' + res.getStatus());
                   System.debug('Response Body: ' + res.getBody());
                    
                }
            } 
        }Catch(Exception ex){
            System.debug('Error while sending user data: ' + ex.getMessage());
        }
        
        
    }
    
}