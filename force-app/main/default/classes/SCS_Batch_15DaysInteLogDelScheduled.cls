/*
    Description : Apex Batch Class to delete integration log data before last month
    Author      : Maantic
    Date        : September, 2022

*/

global class SCS_Batch_15DaysInteLogDelScheduled implements Schedulable{
    // Execute on 15th and last day of the month 
    global void execute(SchedulableContext ctx){
        SCS_Batch_Before15DaysInteLogDel intLogDel = new SCS_Batch_Before15DaysInteLogDel();
        Database.executebatch(intLogDel, 200);
    }
}

/*
System.schedule('SCS_Batch_15DaysInteLogDelScheduled 15th', '0 0 0 15 * ?', new SCS_Batch_15DaysInteLogDelScheduled());
System.schedule('SCS_Batch_15DaysInteLogDelScheduled lastDay of the month', '0 0 0 L * ?', new SCS_Batch_15DaysInteLogDelScheduled());
*/