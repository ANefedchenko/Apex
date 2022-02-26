public class OpportunityTriggerHandler {
    
    private static Map<String, Gift_Card__c> getUsedGiftCardsMap(List<Opportunity> opportunitiesList){   
        Set<String> usedGiftCards = new Set<String>();
        for(Opportunity opportunity : opportunitiesList){
            usedGiftCards.add(opportunity.Gift_Card__c);
        }
		Map<String, Gift_Card__c> cardsMap = new Map<String, Gift_Card__c>();
		for(Gift_Card__c card : [SELECT Name, Active__c, Amount__c FROM Gift_Card__c WHERE Name IN :usedGiftCards]){
			cardsMap.put(card.Name, card);
		}
        return cardsMap;
    }

	public static void applyGiftCardDiscount(List<Opportunity> opportunitiesList){            
        Map<String, Gift_Card__c> cardsMap = getUsedGiftCardsMap(opportunitiesList);                                
        for (Opportunity opportunity : opportunitiesList){
            if (cardsMap.containsKey(opportunity.Gift_Card__c)){
                if(cardsMap.get(opportunity.Gift_Card__c).Active__c){
					opportunity.Amount -= cardsMap.get(opportunity.Gift_Card__c).Amount__c;
                } else{
					opportunity.Gift_Card__c.addError(Label.Gift_Card_Must_Be_Active);
                } 
			} else if(!cardsMap.containsKey(opportunity.Gift_Card__c) && (opportunity.Gift_Card__c != null)){
				opportunity.Gift_Card__c.addError(Label.Card_Not_Found);
			}
        }
    }

	public static void updateOpportunity(List<Opportunity> opportunitiesListOld, List<Opportunity> opportunitiesListNew){ 
		List<Opportunity> opportunitiesForUpdate = new List<Opportunity>();
        Map<Id, Opportunity> opportunitiesMapOld = new Map<Id, Opportunity>();
        for(Opportunity opportunity : opportunitiesListOld){
			opportunitiesMapOld.put(opportunity.Id, opportunity);
		}
		for(Opportunity opportunity : opportunitiesListNew){
			if(opportunitiesMapOld.get(opportunity.Id).Gift_Card__c != opportunity.Gift_Card__c){
                opportunitiesForUpdate.add(opportunity);
			}
		}
        OpportunityTriggerHandler.applyGiftCardDiscount(opportunitiesForUpdate);
	}

	public static void updateStatusGiftCard(List<Opportunity> opportunitiesList){     
        Map<String, Gift_Card__c> cardsMap = getUsedGiftCardsMap(opportunitiesList);
        for(Gift_Card__c card : cardsMap.values()){
            cardsMap.get(card.Name).Active__c = false;
        }
        update cardsMap.values();
    }
   
    public static void applyMetadataDiscount(List<Opportunity> opportunitiesList){    
    	Set<String> accountIds = new Set<String>();
        for(Opportunity opportunity : opportunitiesList){
        	accountIds.add(opportunity.AccountId);
        }
        List<Cooperation_time__mdt> customMetaList = [SELECT Discount__c, Minimum_period__c 
                                                      FROM Cooperation_time__mdt];
        
        Map<ID, Account> accountMap = new Map<ID, Account>([SELECT Registration_Date__c FROM Account 
                                                            WHERE Id IN :accountIds 
                                                            AND Registration_Date__c != null]);
        
        for(Opportunity opportunity : opportunitiesList){
        	if(accountMap.containsKey(opportunity.AccountId)){
            	Double discount = 0;
                	for(Cooperation_time__mdt customMeta : customMetaList){
                        Date dateOfRegistration = accountMap.get(opportunity.AccountId).Registration_Date__c;
                        Double cooperationPeriod = dateOfRegistration.daysBetween(Date.today())/365.0;
                        if(cooperationPeriod >= customMeta.Minimum_period__c && discount <= customMeta.Discount__c){
							discount = customMeta.Discount__c;
                        }
                    }
                    opportunity.Amount -= discount * opportunity.Amount / 100;
            }
        }
    }
}