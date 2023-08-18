@isTest public class CaseTriggerTest {
    @isTest static void caseAfterInsertTest() {
        JCFS.JiraTriggerTestHelper.testAfterInsert('Case');
    }
    @isTest static void caseAfterUpdateTest() {
        JCFS.JiraTriggerTestHelper.testAfterUpdate('Case');
    }
}