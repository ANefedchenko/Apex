public class BooksToAuthorsBatch implements Database.Batchable<sObject>{   
   
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Author__c FROM Book__c WHERE Author__c != null');
    }
    
    public void execute(Database.BatchableContext bc, List<Book__c> scope){
        Map<Id, BookToAuthor__c> btaMap = new Map<Id, BookToAuthor__c>();
        for(BookToAuthor__c bta : [SELECT Book__c, Author__c FROM BookToAuthor__c WHERE Book__c IN :scope]){
            btaMap.put(bta.Book__c, bta);
        }

		Set<String> authorsSet = new Set<String>();
		for(Book__c book : scope){
			authorsSet.add(book.Author__c);
            System.debug(book.Author__c);
		}

		Map<String, Author__c> authorsMap = new Map<String, Author__c>();
		for(Author__c author : [SELECT Name FROM Author__c WHERE Name IN :authorsSet]){
            authorsMap.put(author.Name, author);
            System.debug(author.Name);
        }
         
        for(Book__c book : scope){
            if(!btaMap.containsKey(book.Id)){
                btaMap.put(book.Id, new BookToAuthor__c(Author__c = authorsMap.get(book.Author__c).Id, Book__c = book.Id) );
            } else{
            	btaMap.get(book.Id).Author__c = authorsMap.get(book.Author__c).Id;
              }
        }
        upsert btaMap.values();
    }
    
    public void finish(Database.BatchableContext bc){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      	                 TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   		String[] toAddresses = new String[] {a.CreatedBy.Email};
  		mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Sharing Recalculation ' + a.Status);
   		mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
   		                      ' batches with '+ a.NumberOfErrors + ' failures.');
   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}