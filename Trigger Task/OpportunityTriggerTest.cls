@isTest
public class OpportunityTriggerTest {
    
    private static final String STAGE_NAME = 'Prospecting';
    private static final Integer FIVE_YEARS = 365 * 5;
    private static final Integer ONE = 1;
    private static final Integer TWENTY = 20;
    private static final Integer FIFTY = 50;
    private static final Integer NINETY = 90;
    private static final Integer TWO_HUNDRED = 200;
    
     @isTest static void TestCreateOneEmptyOpportunity(){
        TestDataFactory.createOpportunity(ONE);
        System.assertEquals(ONE, [SELECT count() FROM opportunity WHERE StageName = :STAGE_NAME], 'Count of opportunities is not expected');
    }
    
    @isTest static void TestCreateBulkEmptyOpportunity(){
        TestDataFactory.createOpportunity(TWO_HUNDRED);
        System.assertEquals(TWO_HUNDRED, [SELECT count() FROM opportunity WHERE StageName = :STAGE_NAME], 'Count of opportunities is not expected');
    }
    
    @isTest static void TestApplyGiftCardDiscountOneOpportunity(){
        TestDataFactory.createOpportunityWithCard(ONE, true);
        System.assertEquals(ONE, [SELECT count() FROM opportunity WHERE StageName = :STAGE_NAME], 'Count of opportunities is not expected');
    }
    
    @isTest static void TestApplyGiftCardDiscountBulkOpportunity(){
        TestDataFactory.createOpportunityWithCard(TWO_HUNDRED, true);
        System.assertEquals(TWO_HUNDRED, [SELECT count() FROM opportunity WHERE StageName = :STAGE_NAME], 'Count of opportunities is not expected');
    } 
          
    @isTest static void TestApplyGiftCardDiscountNotActive(){
        try{
            TestDataFactory.createOpportunityWithCard(TWENTY, false);
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains(Label.Gift_Card_Must_Be_Active) ? true : false;
            System.assertEquals(true, expectedExceptionThrown, 'Status of cards is not expected');
    	}
	}
    
    @isTest static void TestApplyGiftCardDiscountBeforeInsert(){
        TestDataFactory.createOpportunityWithCard(TWENTY, true);
        System.assertEquals(TWENTY, [SELECT count() FROM Opportunity WHERE Amount = :FIFTY], 'Count of opportunities is not expected');
	}
    
    @isTest static void TestUpdateGiftCardDiscountBeforeUpdate(){
        TestDataFactory.updateOpportunityWithCard(TWENTY, true);
        System.assertEquals(TWENTY, [SELECT count() FROM Opportunity WHERE Amount = :TWENTY], 'Count of opportunities is not expected');
	}
    
    @isTest static void TestUpdateStatusGiftCard(){
        TestDataFactory.createOpportunityWithCard(TWENTY, true);
        System.assertEquals(TWENTY, [SELECT count() FROM Gift_Card__c WHERE Active__c = false], 'Count of cards is not expected');
	}
    
    @isTest static void TestNotValidGiftCard(){
        try{
            TestDataFactory.createOpportunityWithNotValidCard(TWENTY, true);
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains(Label.Card_Not_Found) ? true : false;
            System.assertEquals(true, expectedExceptionThrown, 'Status of cards is not expected');
    	}
	}
    
    @isTest static void TestApplyGiftCardDiscount5Years(){
        TestDataFactory.createOpportunityWithAccount(TWENTY, Date.today() - FIVE_YEARS);
        System.assertEquals(TWENTY, [SELECT count() FROM Opportunity WHERE Amount = :NINETY], 'Count of opportunities is not expected');
    }
}