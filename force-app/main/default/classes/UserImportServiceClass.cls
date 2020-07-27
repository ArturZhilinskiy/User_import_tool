public with sharing class UserImportServiceClass {

    static final String REQUEST_URL = 'https://reqres.in/api/users?page=';
    static Integer CURRENT_PAGE = 1;

    @AuraEnabled
    public static ImportResultData importUsers() {
        List<UIT_User__c> users = getRecords();
        Database.UpsertResult[] results;

        if (users.size() > 0) {
            results = Database.upsert(users, UIT_User__c.Fields.External_ID__c, true);
        }

        ImportResultData resultData = new ImportResultData();

        if (results.size() != 0) {
            for (Database.UpsertResult resultItem : results) {
                if (resultItem.isCreated()) {
                    resultData.importedRecords ++;
                } else {
                    resultData.updatedRecords ++;
                }
            }
            resultData.importStatus = 'SUCCESS';
        }

        return resultData;
    }

    private static List<UIT_User__c> getRecords() {
        List<UIT_User__c> users = new List<UIT_User__c>();
        Integer totalPages = CURRENT_PAGE;
        while (CURRENT_PAGE <= totalPages) {
            UserWrapClass wrapUsers = getExternalUsers();
            for (UserWrapClass.UitUser userItem : wrapUsers.uit_users) {
                users.add(new UIT_User__c(
                    Name = userItem.last_name,
                    UIT_User_First_Name__c = userItem.first_name,
                    UIT_User_Email__c = userItem.email,
                    UIT_User_Avatar__c = userItem.avatar,
                    External_ID__c = userItem.id
                ));
            }
            CURRENT_PAGE = wrapUsers.page + 1;
            totalPages = wrapUsers.total_pages;
        }

        return users;
    }

    private static UserWrapClass getExternalUsers() {
        Http callout = new Http();

        HttpRequest request = new HttpRequest();
        request.setEndpoint(REQUEST_URL + String.valueOf(CURRENT_PAGE));
        request.setMethod('GET');

        HttpResponse response = callout.send(request);
        if (response.getStatusCode() == 200) {
            return UserWrapClass.parse(response.getBody());
        } else {
            return null;
        }
    }

    private with sharing class ImportResultData {
        private Integer importedRecords = 0;
        private Integer updatedRecords = 0;
        private String importStatus = 'ERROR';
    }
}
