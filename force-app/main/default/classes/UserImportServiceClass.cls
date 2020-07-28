public with sharing class UserImportServiceClass {

    @AuraEnabled
    public static void importUsers() {
        Database.executeBatch(new DataImportBatch());
    }
}
