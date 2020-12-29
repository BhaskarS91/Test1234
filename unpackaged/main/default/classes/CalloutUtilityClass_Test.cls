@isTest
public class CalloutUtilityClass_Test {
    @testSetup static void setupRecords() {
        Account a = new Account();
        a.name ='test';
        insert a;
        List<Contract> cons = new List<Contract>();
        Contract c1 = new Contract();
        c1.accountId = a.id;
        cons.add(c1);
        Contract c2 = new Contract();
        c2.accountId = a.id;
        cons.add(c2);
        insert cons;
        
    }
    @isTest
    public static void testMethod1(){
        List<Contract> cons =[SELECT Id,Description,AccountId,CustomerSignedDate,Account.Name,BillingCity,ContractTerm,CompanySignedId,StatusCode,StartDate,
                              CustomerSignedTitle,BillingPostalCode,Status,SpecialTerms,EndDate,BillingCountry,BillingStreet,
                              CompanySignedDate,BillingState,Org2ContractId__c  FROM Contract  limit 2];
        update cons;
        
        ContractDetails c = new ContractDetails();     
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        CalloutUtilityClass cbc =  new CalloutUtilityClass();
        cbc.calloutUtilityMethod(cons);
        // Database.executeBatch(cbc,1);
        c.updateBool();
        c.updateBool2();
        Test.stopTest();
        List<Contract> con =[SELECT Id,SpecialTerms,Description,Account.Name from Contract LIMIT 1];
        System.assertEquals('test', con[0].Account.Name);
        
        
    }
    @isTest   
    public static void testMethod2(){
        List<Contract> cons =[SELECT Id,Description,AccountId,CustomerSignedDate,Account.Name,BillingCity,ContractTerm,CompanySignedId,StatusCode,StartDate,
                              CustomerSignedTitle,BillingPostalCode,Status,SpecialTerms,EndDate,BillingCountry,BillingStreet,
                              CompanySignedDate,BillingState,Org2ContractId__c  FROM Contract  limit 2];
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionResponse());
        update cons;
        CalloutUtilityClass cbc =  new CalloutUtilityClass();
        cbc.calloutUtilityMethod(cons);
        ContractDetails c = new ContractDetails();     
        // update cons;
        c.updateBool2();
        Test.stopTest();
        List<Contract> con =[SELECT Id,SpecialTerms,Description,Account.Name from Contract LIMIT 1];
        System.assertEquals('test', con[0].Account.Name);
        
    }
    @isTest   
    public static void testMethod3(){
        List<Contract> cons =[SELECT Id,Description,AccountId,CustomerSignedDate,Account.Name,BillingCity,ContractTerm,CompanySignedId,StatusCode,StartDate,
                              CustomerSignedTitle,BillingPostalCode,Status,SpecialTerms,EndDate,BillingCountry,BillingStreet,
                              CompanySignedDate,BillingState,Org2ContractId__c  FROM Contract  limit 2];
        
        update cons;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionResponse());
        
        CalloutUtilityClass cbc =  new CalloutUtilityClass();
        cbc.calloutUtilityMethod(cons);
        
        ContractDetails c = new ContractDetails();     
        // update cons;
        c.updateBool2();
        Test.stopTest();
        List<Contract> con =[SELECT Id,SpecialTerms,Description,Account.Name from Contract LIMIT 1];
        System.assertEquals('test', con[0].Account.Name);
        
    }
    @isTest
    public static void testMethod4(){
        List<Contract> cons =[SELECT Id,Description,AccountId,CustomerSignedDate,Account.Name,BillingCity,ContractTerm,CompanySignedId,StatusCode,StartDate,
                              CustomerSignedTitle,BillingPostalCode,Status,SpecialTerms,EndDate,BillingCountry,BillingStreet,
                              CompanySignedDate,BillingState,Org2ContractId__c  FROM Contract  limit 2];
        
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionResponse());
        // update cons;
        CalloutUtilityClass cbc =  new CalloutUtilityClass();
        cbc.deleteRecords(new List<String>{cons[0].id});
        delete cons;
        ContractDetails c = new ContractDetails();     
        // update cons;
        c.updateBool2();
        Test.stopTest();
        List<Contract> con =[SELECT Id,SpecialTerms,Description,Account.Name from Contract LIMIT 1];
        System.assertEquals(0, con.size());
        
    }  
    
    
}