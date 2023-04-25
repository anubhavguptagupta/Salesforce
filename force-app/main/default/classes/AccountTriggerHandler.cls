public class AccountTriggerHandler implements ITriggerHandler{
     
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
     
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
     
    public void beforeInsert(List<sObject> newList) {
        List<Account> accounts=(List<Account>) newList;
        for(Account acc:accounts)
        {
            acc.Active__c='No';
        }
    }
     
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        //Create two default team members on account creation
        List<SQX_Team_Members__c> teamMembers=new List<SQX_Team_Members__c>();
        for(Account acc:(List<Account>)newList){
         teamMembers.add(new SQX_Team_Members__c(Name='Team Member 1', Account__c=acc.Id));
         teammembers.add(new SQX_Team_Members__c(Name='Team Member 2', Account__c=acc.Id));
        }
         insert teamMembers;
    }
     
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
       //Map of account where Accounts are activated 
       Map<Id,Account> accountsToBeChecked=new Map<Id,Account>();
        for(Account acc: (List<Account>)newList){
            if(((Account)oldMap.get(acc.Id)).Active__c=='No' && acc.Active__c=='Yes')
            {
                accountsToBeChecked.put(acc.Id,acc);
            }
        }
        if(accountsToBeChecked.size()>0){
            
            List<Account> accountsWithTeamMembers = [Select  Id, (SELECT ID, Member_Type__c FROM Team_Members__r) From Account where ID IN : accountsToBeChecked.keyset() ];
            System.debug('Accounts with Team Members : '+accountsWithTeamMembers);
            for(Account tmp:accountsWithTeamMembers)
            {
                System.debug('Individual Account is : '+tmp);
                Boolean isHr=false;
                Boolean isAdmin=false;
                if(tmp.Team_Members__r.size()>1)
                {
                    System.debug('team Members greater than 1');
                    for(Integer i=0;i<tmp.Team_Members__r.size();i++)
                    {
                        if(isHr&&isAdmin)
                        {
                            break;
                        }
                        else if(tmp.Team_Members__r[i].Member_Type__c=='HR')
                        {
                            isHr=true;
                        }
                        else if(tmp.Team_Members__r[i].Member_Type__c=='Admin')
                        {
                            isAdmin=true;
                        }
                    }
                    if(!isHR || !isAdmin)
                    {
                        ((Account)newMap.get(tmp.Id)).addError('Accounts can not be activated without team members of HR and Admin member type');
      
                    }
                    
                }
                else
                {
                    ((Account)newMap.get(tmp.Id)).addError('Accounts can not be activated without team members of HR and Admin member type');
                }
            }
        }
        
    }
     
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap,  List<sObject> oldList, Map<Id, sObject> oldMap) {
         
    }
     
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
         
    }
     
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
         
    }
     
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
         
    }
}