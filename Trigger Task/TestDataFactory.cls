@isTest
public class TestDataFactory {   
    
    public static void createOpportunity(Integer quantity){
        List<Opportunity> opportunityList = new List<Opportunity>();
        for(Integer i = 0; i < quantity; i++){
            Opportunity opportunity = new Opportunity(Name = 'Opportunity ' + i,
            								 		 CloseDate = Date.today(),
                            	             		 StageName = 'Prospecting',
                                    	     		 Amount = 100);
            opportunityList.add(opportunity);
        }
        insert opportunityList;
    }
    
    public static void createOpportunityWithCard(Integer quantity, Boolean status){
        List<Gift_Card__c> cardList = new List<Gift_Card__c>();
        for(Integer i = 0; i < quantity; i++){
            Gift_Card__c card = new Gift_Card__c(Active__c = status,
                                                Amount__c = 50);
            cardList.add(card);
        }
        insert cardList;
        cardList = [SELECT Name FROM Gift_Card__c];
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        for(Integer i = 0; i < quantity; i++){
            Opportunity opportunity = new Opportunity(Name = 'Opportunity ' + i,
            								 		 CloseDate = Date.today(),
                            	             		 StageName = 'Prospecting',
                                    	     		 Amount = 100,
                                                     Gift_Card__c = cardList[i].Name);
            opportunityList.add(opportunity);
        }
        insert opportunityList;
    }
    
    public static void updateOpportunityWithCard(Integer quantity, Boolean status){
        TestDataFactory.createOpportunityWithCard(quantity, status);
        
        List<Gift_Card__c> cardList = new List<Gift_Card__c>();
        for(Integer i = 0; i < quantity; i++){
            Gift_Card__c card = new Gift_Card__c(Active__c = status,
                                                Amount__c = 30);
            cardList.add(card);
        }
        insert cardList;
        cardList = [SELECT Name FROM Gift_Card__c WHERE Amount__c = 30];
        
        
        List<Opportunity> opportunityList = [SELECT Gift_Card__c FROM Opportunity];
        for(Integer i = 0; i < quantity; i++){
            opportunityList[i].Gift_Card__c = cardList[i].Name;
        }
        update opportunityList;
    }
    
    public static void createOpportunityWithNotValidCard(Integer quantity, Boolean status){
        createOpportunity(quantity);
        List<Opportunity> opportunityList = [SELECT Gift_Card__c FROM Opportunity];
        for(Integer i = 0; i < quantity; i++){
            opportunityList[i].Gift_Card__c = 'Not valid card';
        }
        update opportunityList;
    }
    
    public static void createOpportunityWithAccount(Integer quantity, Date registrationDate){
        List<Account> accountList = new List<Account>();
        for(Integer i = 0; i < quantity; i++){
        	Account account = new Account (Name = 'Test ' + i,
                        	              Registration_Date__c = registrationDate);
            accountList.add(account);
        }
        insert accountList;
        accountList = [select Id from Account];
        
        createOpportunity(quantity);
        List<Opportunity> opportunityList = [SELECT AccountId FROM Opportunity];
        for(Integer i = 0; i < quantity; i++){
            opportunityList[i].AccountId = accountList[i].Id;
        }
        update opportunityList;
    }
}