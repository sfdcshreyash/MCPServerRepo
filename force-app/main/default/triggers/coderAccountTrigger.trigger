trigger coderAccountTrigger on Account (before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            coderAccountTriggerHandler.beforeInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            coderAccountTriggerHandler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}
