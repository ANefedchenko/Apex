trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update){     
    if(Trigger.isBefore){
        OpportunityTriggerHandler.applyMetadataDiscount(Trigger.New);
        if(Trigger.isInsert){
			OpportunityTriggerHandler.applyGiftCardDiscount(Trigger.New);
        } else if(Trigger.isUpdate){
            OpportunityTriggerHandler.updateOpportunity(Trigger.Old, Trigger.New);
        }
    } else{
        OpportunityTriggerHandler.updateStatusGiftCard(Trigger.New);
    }
}