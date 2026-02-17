trigger UserCreationTrigger on User (after insert, after update) {

    UserCreatedApex.createUserOrUpdateMethod(Trigger.new, Trigger.isInsert ? 'create' : 'update');
}