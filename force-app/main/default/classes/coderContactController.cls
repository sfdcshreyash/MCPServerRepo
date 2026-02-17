public with sharing class coderContactController {

    @AuraEnabled(cacheable=true)
    public static List<Contact> getTenContacts() {
        return [
            SELECT Id, FirstName, LastName, Name, Email, Phone
            FROM Contact
            ORDER BY CreatedDate DESC
            LIMIT 10
        ];
    }
}
