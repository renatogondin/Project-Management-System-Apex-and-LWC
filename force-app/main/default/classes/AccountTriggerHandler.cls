public with sharing class AccountTriggerHandler {
    
    public void onBeforeInsert(List<Account> accounts){

        this.subscribeShuffledName(accounts);

    }

    public void onBeforeUpdate(List<Account> Accounts){

        this.subscribeShuffledName(accounts);
        
    }

    private void subscribeShuffledName(List<Account> accounts){
        for(Account account : accounts){
            if(account.Name != null){
                account.ShuffledAccountName__c = PseudoWordsUtil.pseudoKeyGenerator(account.Name);
            }
        }
    }
}