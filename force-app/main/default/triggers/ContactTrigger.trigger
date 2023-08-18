/*
    Description : Trigger for Contact
    Author  :   Utkarsh Goswami
    Date    :   21st March, 2023
*/
trigger ContactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    TriggerDispatcher.run(new ContactTriggerHelper(), 'Contact_Trigger'); 
}