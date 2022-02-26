@isTest
public class BooksToAuthorsBatchTest {
    
    private static final Integer ONE_HUNDRED = 100;
    private static final Integer TWO_HUNDRED = 200;
	
    @testSetup
    static void setup() {
        List<Author__c> authors = new List<Author__c>();
        for (Integer i = 0; i < 200; i++) {
            authors.add(new Author__c());
        }
        insert authors;
        authors = [SELECT Name FROM Author__c];
        
        List<Book__c> books = new List<Book__c>();
        for (Integer i = 0; i < 200; i++){
            books.add(new Book__c(Name='Book with Author',
                                 Author__c = authors[i].Name));
        }
        for (Integer i = 0; i < 100; i++){
            books.add(new Book__c(Name='Book without Author'));
        }
        insert books;
        books = [SELECT Id FROM Book__c];

		List<BookToAuthor__c> bta = new List<BookToAuthor__c>();
        for (Integer i = 0; i < 100; i++) {
            bta.add(new BookToAuthor__c(Author__c = authors[i].Id, Book__c = books[i].Id));
        }
        insert bta;
    }
    
    @isTest static void TestInsertBooksAndAuthors(){
        Test.startTest();
        Database.executeBatch(new BooksToAuthorsBatch());
        Test.stopTest();
        System.assertEquals(ONE_HUNDRED, [select count() from Book__c where Author__c = null], 'Count of authors is not expected');
        System.assertEquals(TWO_HUNDRED, [select count() from Book__c where Author__c != null], 'Count of authors is not expected');
    }
    
     @isTest static void TestCreateJunctionObject(){
        System.assertEquals(ONE_HUNDRED, [select count() from BookToAuthor__c], 'Count of junction objects is not expected');
        Test.startTest();
        Database.executeBatch(new BooksToAuthorsBatch());
        Test.stopTest();
        System.assertEquals(TWO_HUNDRED, [select count() from BookToAuthor__c], 'Count of junction objects is not expected');
    }
}