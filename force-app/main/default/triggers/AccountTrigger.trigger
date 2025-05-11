trigger AccountTrigger on Account (before insert, before update) {

    AccountTriggerHandler handler = new AccountTriggerHandler();

    if(Trigger.isInsert && Trigger.isBefore){

        handler.onBeforeInsert(trigger.New);

    }else if(Trigger.isUpdate && Trigger.isBefore){

        handler.onBeforeInsert(trigger.New);
    }

}