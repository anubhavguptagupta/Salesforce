@isTest
public class TestAccountTrigger {
    
    @testSetup
    private static void setup()
    {
        Profile custStandardProfile=[Select Id, Name From Profile where Name='Custom Standard User'];
        List<User> users=new List<User>();
        User testUser = new user(alias = 'test123', email='test123@noemail.com', 
                                 emailencodingkey='UTF-8', firstName='Test', lastname='Compliance', languagelocalekey='en_US',
                                 localesidkey='en_IN', profileid = custStandardProfile.Id, country='India',
                                 timezonesidkey='Asia/Kolkata', username='test_g@noemail.com'); 
        
        User testUserNoAccess = new user(alias = 'test1253', email='test123@noemail.com', 
                                         emailencodingkey='UTF-8', firstName='TestNo', lastname='Compliance', languagelocalekey='en_US',
                                         localesidkey='en_IN', profileid = custStandardProfile.Id, country='India',
                                         timezonesidkey='Asia/Kolkata', username='test_b@noemail.com');
        users.add(testUser);
        users.add(testUserNoAccess);
        insert users;
        
        PermissionSet accountAdmin = [SELECT Id FROM PermissionSet WHERE Name = 'Account_Admin'];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = accountAdmin.Id);      
        
    }
    
    @isTest
    private static void testWithHrAndAdminMember()
    {
        User accountAdmin=[Select Id, Name From User where username='test_g@noemail.com'];
        System.runAs(accountAdmin)
        {
            // Account acc=[Select Id, Name, Active__c From Account Where Name='Test'];
            TriggerSetting__c  cs= new TriggerSetting__c();
            cs.Name='AccountTrigger';
            cs.IsActive__c=true;
            insert cs; 
            Account acc=new Account(Name='Test');
            insert acc;
            Test.startTest();    
            List<SQX_Team_Members__c> teamMembers=[Select ID, Member_Type__c FROM SQX_Team_Members__c Where Account__c=:acc.Id ];
            teamMembers[0].Member_Type__c='HR';
            teamMembers[1].Member_Type__c='Admin';
            update teamMembers;
            acc.Active__c='Yes';
            update acc;
            Test.stopTest();
            acc=[Select Id, Name, Active__c From Account Where Name='Test'];
            Assert.areEqual('Yes', acc.Active__c);
        }
    }
    
    @isTest
    private static void testWithOnlyAdminMember()
    {
        User accountAdmin=[Select Id, Name From User where username='test_g@noemail.com'];
        System.runAs(accountAdmin)
        {
            // Account acc=[Select Id, Name, Active__c From Account Where Name='Test'];
            TriggerSetting__c  cs= new TriggerSetting__c();
            cs.Name='AccountTrigger';
            cs.IsActive__c=true;
            insert cs; 
            Account acc=new Account(Name='Test');
            insert acc;
            Test.startTest();    
            List<SQX_Team_Members__c> teamMembers=[Select ID, Member_Type__c FROM SQX_Team_Members__c Where Account__c=:acc.Id ];
            teamMembers[0].Member_Type__c='Admin';
            update teamMembers;
            acc.Active__c='Yes';
            try{
            update acc;
            }
            catch(Exception ex)
            {
              System.debug(ex.getMessage()); 
               Assert.isTrue(ex.getMessage().contains('Accounts can not be activated without team members of HR and Admin member type'));
            }
            Test.stopTest();
        }
    }
    
     @isTest
    private static void testWithoutAccountAdmin()
    {
        User accountAdmin=[Select Id, Name From User where username='test_b@noemail.com'];
        System.runAs(accountAdmin)
        {
            // Account acc=[Select Id, Name, Active__c From Account Where Name='Test'];
            TriggerSetting__c  cs= new TriggerSetting__c();
            cs.Name='AccountTrigger';
            cs.IsActive__c=true;
            insert cs; 
            Account acc=new Account(Name='Test');
            insert acc;
            Test.startTest();    
            List<SQX_Team_Members__c> teamMembers=[Select ID, Member_Type__c FROM SQX_Team_Members__c Where Account__c=:acc.Id ];
            teamMembers[0].Member_Type__c='HR';
            teamMembers[1].Member_Type__c='Admin';
            update teamMembers;
            acc.Active__c='Yes';
            try{
            update acc;
            }
            catch(Exception ex)
            {
              System.debug(ex.getMessage()); 
               Assert.isTrue(ex.getMessage().contains('You don\'t have Account admin permission'));
            }
            Test.stopTest();
        }
    }
    
}