public class AccountController {
    
    @AuraEnabled
    public static List<Account> getAccounts(String accName){
        String Name ='%'+accName+'%';
        system.debug('accName '+Name);
         List<Account> accs = [Select id,Name,Type,Industry From Account where name Like '%Name%'];
        system.debug('accs '+accs);
        return [Select id,Name,Type,Industry From Account where Name Like:Name];
    }

}