/**
 1. Оказывается мы можем создать roll-up summary fields на аккаунте для подсчета на opportunity поля. Это исключение, т.к. между ними look-up.
 2. Действительно, я был не прав насчет создания junction объекта, я почему-то был уверен что они создаются на мастере.
 На junction создается 2 MD и он будет дитейл в данном случае.
 */

trigger UpdateRelatedAccount on Opportunity (after insert, after update, after delete, after undelete) {

    if(Trigger.isInsert) {
        UpdateRelatedAccountTriggerHandler.handleInsert(Trigger.new);
    }
    else if(Trigger.isUpdate) {
        UpdateRelatedAccountTriggerHandler.handleUpdate(Trigger.new, Trigger.oldMap);
    }
    else if(Trigger.isUndelete) {
        UpdateRelatedAccountTriggerHandler.handleUnDelete(Trigger.new);
    }
    else if(Trigger.isDelete) {
        UpdateRelatedAccountTriggerHandler.handleDelete(Trigger.old);
    }

    UpdateRelatedAccountTriggerHandler.updateRelatedAccounts();
}