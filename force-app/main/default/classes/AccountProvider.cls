public with sharing class AccountProvider {
    public AccountProvider() {

    }
    @AuraEnabled
    public static List<Account> getAccounts(String accName){
         try {
        if (String.isBlank(accName)) {
            return new List<Account>();
        }

        String searchKey = '%' + accName + '%';
        String query = 'SELECT Id, Name, Type, Rating FROM Account WHERE ' +
                       '(Name LIKE :searchKey OR Type LIKE :searchKey OR Rating LIKE :searchKey) ' +
                       'LIMIT 10';

        return Database.query(query);
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
      
    } 

    @AuraEnabled(cacheable=true)
    public static List<Account> coderGetAccountsByType(String accType){
        try {
            if (String.isBlank(accType)) {
                return new List<Account>();
            }

            return [
                SELECT Id, Name, Type, Rating
                FROM Account
                WHERE Type = :accType
                LIMIT 50
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpps(String accId,String stageName){
        try {

            List<Opportunity> oppList =[Select Id,Name,StageName from Opportunity where AccountId=:accId and StageName=:stageName];
            return oppList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @InvocableMethod(label='Update Opportunity')
    public static void updateOpps(List<String> oppIds){
         try{
            List<Opportunity> oppList = new List<Opportunity>();
            for(Opportunity opp :[Select Id,Name,StageName from Opportunity where Id IN:oppIds]){
                 if(opp.StageName =='Prospecting'){
                   opp.StageName='Qualification';
                 }
                 else{
                    opp.StageName='Prospecting';
                 }
              oppList.add(opp);
            }
            update oppList;
         }
         catch(exception ex){
        throw new AuraHandledException('exceptionText');
         }
    }

    @AuraEnabled
    public static void updateOpportunity(List<String> oppIds){
         try{
            List<Opportunity> oppList = new List<Opportunity>();
            for(Opportunity opp :[Select Id,Name,StageName from Opportunity where Id IN:oppIds]){
                 if(opp.StageName =='Prospecting'){
                   opp.StageName='Qualification';
                 }
                 else{
                    opp.StageName='Prospecting';
                 }
              oppList.add(opp);
            }
            update oppList;
         }
         catch(exception ex){
        throw new AuraHandledException('exceptionText');
         }
    }

    @AuraEnabled(cacheable=true)
    public static List<wrapClass> getAccountList(Integer pageNumber , Integer pageSize){
        try {

            Integer offset =(pageNumber-1)*pageSize;
            List<wrapClass> wrapList = new List<wrapClass>();

            List<Account> accList=[Select Id,Name,Rating,Type from Account LIMIT:pageSize OFFSET:offset];

            Integer accCount=[Select Count() from Account];

            for(Account acc : accList){

                wrapClass wrap = new wrapClass();
                wrap.accId=acc.Id;
                wrap.accName=acc.Name;
                wrap.accType=acc.Type;
                wrap.accRating=acc.Rating;
                wrap.countOfAcc=accCount;
                wrapList.add(wrap);

            }
            return wrapList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class wrapClass{
    @AuraEnabled
    public String accName;
    @AuraEnabled
    public String accId;
    @AuraEnabled
    public String accType;
    @AuraEnabled
    public String accRating;
    @AuraEnabled
    public Integer countOfAcc;  

}

@AuraEnabled
public static List<Account> getSelectedAccount (List<String> accIds){
    try {
        return[Select Id,Name,Rating,Type from Account where Id IN:accIds];
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}

@AuraEnabled
public static List<Contact> getContactList(String Idacc){
    try {
        return[Select Id,Name,Email,Phone from Contact where AccountId =:Idacc];
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}
   
}