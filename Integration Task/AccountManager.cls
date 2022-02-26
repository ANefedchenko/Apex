global with sharing class AccountManager {
    
    private static final String ENDPOINT_BASE = 'https://polytech-internship-developer-edition.eu40.force.com/services/apexrest/Account';
    private static final String POST_METHOD = 'POST';
    private static final String GET_METHOD = 'GET';
    private static final String DELETE_METHOD = 'DELETE';
    
    public static String postCallout (String name, String phone, String website){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT_BASE);
        request.setMethod(POST_METHOD);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
        generator.writeStringField('name', name);
        generator.writeStringField('phone', phone);
        generator.writeStringField('website', website);
        generator.writeEndObject();
        request.setBody(generator.getAsString());
        
        HttpResponse response = http.send(request);
        if(response.getStatusCode() != 201) {
        	String id = String.valueOf(JSON.deserializeUntyped(response.getBody()));
            return id;
        } else {
        	return null;
        }
    }
        
    public static Account getCallout(String id){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT_BASE + '/' + id);
        request.setMethod(GET_METHOD);
        HttpResponse response = http.send(request);

        if(response.getStatusCode() == 200) {
            Account account = (Account) JSON.deserialize(response.getBody(), Account.class);
            return account;
    	}
        else {
            return null;
        }
    }
    
    public static void deleteCallout(String id){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(ENDPOINT_BASE + '/' + id);
        request.setMethod(DELETE_METHOD);
        HttpResponse response = http.send(request);
    }
}