global class DataImportBatch implements Database.Batchable<Integer>, Database.Stateful,  Database.AllowsCallouts {
    
    static final String REQUEST_URL = 'https://reqres.in/api/users?page=';
    Integer CURRENT_PAGE = 1;
    ImportResultData resultData = new ImportResultData();

    global Iterable<Integer> start(Database.BatchableContext context) {
        
        Integer[] values = new Integer[0];
        UserWrapClass response = makeCallout(CURRENT_PAGE);
        while(values.size() < response.total_pages) {
            values.add(values.size());
        }
        return values;
    }

    private UserWrapClass makeCallout(Integer pageNumber) {
        Http callout = new Http();

        HttpRequest request = new HttpRequest();
        request.setEndpoint(REQUEST_URL + String.valueOf(pageNumber));
        request.setMethod('GET');

        HttpResponse response = callout.send(request);
        if (response.getStatusCode() == 200) {
            return UserWrapClass.parse(response.getBody());
        } else {
            return null;
        }
    }

    global void execute(Database.BatchableContext context, Integer[] values) {
        List<UIT_User__c> users = new List<UIT_User__c>();
        for (Integer i : values) {
            UserWrapClass response = makeCallout(CURRENT_PAGE);
            if (response != null) {
                List<UserWrapClass.UitUser> wrappedUsers = response.uit_users;
                users.addAll(getUsers(wrappedUsers));
            }
            CURRENT_PAGE++;
        }
        upsertUitUsers(users);
    }

    private List<UIT_User__c> getUsers(List<UserWrapClass.UitUser> wrappedUsers) {
        List<UIT_User__c> users = new List<UIT_User__c>();
        for (UserWrapClass.UitUser userItem : wrappedUsers) {
            users.add(new UIT_User__c(
                Name = userItem.last_name,
                UIT_User_First_Name__c = userItem.first_name,
                UIT_User_Email__c = userItem.email,
                UIT_User_Avatar__c = userItem.avatar,
                External_ID__c = userItem.id
            ));
        }
        return users;
    }

    private void upsertUitUsers(List<UIT_User__c> users) {
        Database.UpsertResult[] results;

        if (users.size() > 0) {
            results = Database.upsert(users, UIT_User__c.Fields.External_ID__c, false);
        }

        if (results.size() != 0) {
            for (Database.UpsertResult resultItem : results) {
                if (resultItem.isSuccess()) {
                    if (resultItem.isCreated()) {
                        resultData.importedRecords ++;
                    } else {
                        resultData.updatedRecords ++;
                    }
                } else {
                    resultData.errors ++;
                }
                
            }
            if (resultData.importedRecords > 0 || resultData.updatedRecords > 0) {
                resultData.importStatus = 'SUCCESS';
            }
        }
    }
    global void finish(Database.BatchableContext context) {
        List<UIT_Import_Event__e> events = new List<UIT_Import_Event__e>();
        events.add(new UIT_Import_Event__e( 
            importedRecords__c = resultData.importedRecords,
            updatedRecords__c = resultData.updatedRecords,
            errors__c = resultData.errors,
            importStatus__c = resultData.importStatus
        ));
        
        EventBus.publish(events);
    }

    private with sharing class ImportResultData {
        public Integer importedRecords = 0;
        public Integer updatedRecords = 0;
        public Integer errors = 0;
        public String importStatus = 'ERROR';
    }
}
