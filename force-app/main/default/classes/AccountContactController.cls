public class AccountContactController {

  public List<Account> selectedAccounts {get;set;}
    public List<Contact> Contacts {get;set;}
    public Set<Id> accIdSet {get;set;}
    public Map<Id,Boolean> contactSelectMap {get;set;}
    public Set<Id> selectedConIds {get;set;}
    public Boolean isContacts {get;set;}
    public Boolean isCases {get;set;}
    public List<Case> caseList {get;set;}
    public AccountContactController(ApexPages.StandardSetController st){
        
        selectedAccounts =(List<Account>) st.getSelected();
        system.debug('selectedAccounts ::'+selectedAccounts);
        system.debug('Accounts size ::'+selectedAccounts.size());
        accIdSet = new Set<Id>();
        isContacts=false;
        isCases=false;
        for(Account acc : selectedAccounts){
            accIdSet.add(acc.Id);
            system.debug('accIdSet ::'+accIdSet);
        }
        
        Contacts=new List<Contact>();
        
        Contacts=[Select Id,Name,Email,Phone,Account.Name from Contact where AccountId IN :accIdSet];
        system.debug('Contacts ::'+Contacts);
        system.debug('Contacts size ::'+Contacts.size());
        if(Contacts.size()>0){
            isContacts=true;
            isCases=false;
        }
        else{
            isContacts=false;
        }
        contactSelectMap = new Map<Id,Boolean>();
        for(Contact con : Contacts){
            contactSelectMap.put(con.Id,false);
        }
        
        
    }
    public void getSelectedContactIds(){
        selectedConIds = new Set<Id>();
            for(Id conIds : contactSelectMap.KeySet()){
                if(contactSelectMap.get(conIds)){
                    selectedConIds.add(conIds);
                    system.debug('selectedConIds ::'+selectedConIds);
                    getCases(selectedConIds);
                }
            }
        }
    
    public void getCases(Set<Id> conIds){
        system.debug('get con id ::'+conIds);
        
        caseList = [Select Id,Account.Name,ContactId,CaseNumber,Origin from Case where ContactId IN: conIds];
        if(caseList.size()>0){
            isCases=true;
            isContacts=false;
        }
        else{
            isCases=false;
            isContacts=true;
        }
    }
    
    public void getBacktocontact(){
        isContacts=true;
        isCases=false;
        
    }
}