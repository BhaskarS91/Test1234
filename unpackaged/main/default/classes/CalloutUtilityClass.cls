/*ClassName: CalloutUtilityClass
author: Bhaskar Shanigaram
Description:  This is the utility class which is being used for making callout from quaueable and batchclass 
*/
public class CalloutUtilityClass {
    //Utility method and parameters are being passed from batch or quauable class based on record size.
    public void calloutUtilityMethod(List<Contract> Contracts){
        string requestJson;
        try{
            Org2EndPoint__mdt oep =[SELECT DeveloperName,endpoint__c FROM Org2EndPoint__mdt where DeveloperName='EndPointUrl'];
            requestJson = getJSONString(Contracts);
            HttpResponse res1 = makeCallout(requestJson,  'POST', oep.Endpoint__c);
            
           // res1 = h1.send(req1);
            Integer respCode = res1.getStatusCode();
            if(respCode ==200 || respCode==201){
                system.debug('respCode ----'+res1.getBody());
                ContractDetails ctd = new ContractDetails();
                ctd.updateBool();//Avoid reccursive trigger
                ctd.updateBool2();//Avoid reccursive trigger
                Map<String,Object> contractResponce =( Map<String,Object>)JSON.deserializeUntyped(res1.getbody());
                System.debug('contractResponce '+contractResponce);
                List<Contract> conss = new List<Contract>();
                for(String s: contractResponce.keyset()){
                    Object o = (Object)contractResponce.get(s);
                    Map<String,Object> resp = (Map<String,Object>)o;
                    String calloutResp = String.valueOf(resp.get('respStatus'));
                    system.debug('calloutResp '+calloutResp);                     
                    if(calloutResp =='500'){
                        
                        Contract c1 = new Contract();
                        c1.Id = s;
                        c1.Org2ContractId__c = String.valueOf(resp.get('org2ContractId'));
                        c1.callout_Status__c = String.valueOf(resp.get('responceMessage'));
                        c1.Sync_Status__c ='Success';
                        conss.add(c1); 
                    }
                    else if(calloutResp == '501'){
                        Contract c1 = new Contract();
                        c1.Id = s;
                        c1.callout_Status__c =String.valueOf(resp.get('responceMessage'));
                        c1.Sync_Status__c='Failed';
                        conss.add(c1);
                    }
                    system.debug('updated Contract Records '+conss);
                }
                if(Limits.getLimitDmlStatements()>Limits.getDmlStatements())
                update conss;
                else{
                   throw new CustomException('DML Limit is Exceeded. Please contact system Admin');
              
                }
                //system.debug('DMLgetLimitDMLStatements' +LIMITS.getDMLRows());            
            }
            else if(respCode == 404){
                throw new CustomException('Your End point is wrong.please go custom metadatype,check Org2connection record and make sure Endpoint is callout:Org2Connection/services/apexrest/custom_contract in endpoint__c field');
            }
             else if(respCode == 401){
                throw new CustomException('Your Session is Expired so please goto Named Credentials and validate it');
            }
            
        }
        catch( CustomException ce){//CustomException
            ContractDetails.insertExceptionRecords(Contracts,ce.getMessage());
        }
        catch(CalloutException ce){//CalloutException
            String errorMessage= exceptionMessage(ce);
            ContractDetails.insertExceptionRecords(Contracts,errorMessage);
        }
        catch(TypeException ce){//TypeException
            String errorMessage= exceptionMessage(ce);
            ContractDetails.insertExceptionRecords(Contracts,errorMessage);
        }
        catch(JSONException ce){//JSONException
            String errorMessage= exceptionMessage(ce);
            ContractDetails.insertExceptionRecords(Contracts,errorMessage);
        }
        catch(Exception ce){//Exception
            String errorMessage= exceptionMessage(ce);
            ContractDetails.insertExceptionRecords(Contracts,errorMessage);
        }
        
        
    }
        public  string getJSONString(List<Contract> contracts){
        String requestJson;
        List<ContractDetails> contractDetails = new List<ContractDetails>();
            if(contracts.size()>0){
                for(Contract  c: Contracts){
                    //creating JSON String here with all these records
                    ContractDetails cc = new ContractDetails();
                    cc.Description = String.valueOf(c.Description);
                    cc.AccountId = c.Account.Name;
                    cc.BillingCity= c.BillingCity;
                    cc.ContractTerm =String.valueOf(c.ContractTerm);
                    cc.CompanySignedId = c.CompanySignedId;
                    cc.StartDate =String.valueOf(c.StartDate);
                    cc.CustomerSignedTitle =c.CustomerSignedTitle;
                    cc.CustomerSignedDate = String.valueOf(c.CustomerSignedDate);
                    cc.BillingPostalCode =c.BillingPostalCode;
                    cc.Status = c.Status;
                    cc.SpecialTerms = c.SpecialTerms;
                    cc.EndDate = String.valueOf(c.EndDate);
                    cc.BillingCountry = c.BillingCountry;
                    cc.BillingStreet = c.BillingStreet;
                    cc.CompanySignedDate =String.valueOf(c.CompanySignedDate);
                    cc.BillingState = c.BillingState;
                    cc.Org1ContractId = c.Id;
                    cc.Org2ContractId =c.Org2ContractId__c;
                    contractDetails.add(cc);
                }
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeObjectField('Records',contractDetails);
                gen.writeEndObject();
                requestJson = gen.getAsString();
                
            }  
            return requestJson;
    } 
    public HttpResponse makeCallout(String jsonBody, String methodName,String endPointUrl){
            Http h1 = new Http();
            HttpRequest req1 = new HttpRequest();
            req1.setHeader('Content-Type','application/json');
            req1.setHeader('accept','application/json'); 
            req1.setTimeout(120000);
            req1.setBody(jsonBody);//Adding JSON of Contracts
            req1.setMethod(methodName);
            req1.setEndpoint(endPointUrl);//Test EndPPoint URL
            HttpResponse res1=h1.send(req1);
        return res1;
    }
    public string exceptionMessage(Exception ce){
         String errorMessage ='';
            errorMessage += 'Error Message :'+ce.getMessage();
            errorMessage+= ' Cause :'+ce.getCause();
            errorMessage+=' Line Number :'+ce.getLineNumber();
        return errorMessage;
          //  System.debug('errorMessage '+errorMessage);
        
    }
     //@httpDelete
    public void deleteRecords(List<String> recordIds){
            Org2EndPoint__mdt oep =[SELECT DeveloperName,endpoint__c FROM Org2EndPoint__mdt where DeveloperName='EndPointUrl'];
            system.debug('Queuble recordIds '+recordIds);
         system.debug('Test2');
            HttpResponse res1 = makeCallout(JSON.serialize(recordIds),  'DELETE', oep.Endpoint__c);
        
    }

}