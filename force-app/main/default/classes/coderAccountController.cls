public with sharing class coderAccountController {

    @AuraEnabled(cacheable=true)
    public static List<Account> getTenAccounts() {
        return [
            SELECT Id, Name, Industry, Phone, Type, Rating
            FROM Account
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];
    }
}