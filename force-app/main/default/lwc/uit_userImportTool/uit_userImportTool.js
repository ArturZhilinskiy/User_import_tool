import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import importUsers from '@salesforce/apex/UserImportServiceClass.importUsers';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';


export default class Uit_userImportTool extends NavigationMixin(LightningElement) {
    @track channelName = '/event/UIT_Import_Event__e';
    @track isDataReceived = false;
    @track isLoading = false;
    @track importResult = {
        importedRecords : 0,
        updatedRecords : 0,
        errors : 0,
        importStatus : 'Success'
    }

    subscription = {};
   
    connectedCallback() {
        subscribe(this.channelName, -1, (response) => {
            this.importResult = {
                importedRecords : response.data.payload.importedRecords__c,
                updatedRecords : response.data.payload.updatedRecords__c,
                errors : response.data.payload.errors__c,
                importStatus : response.data.payload.importStatus__c
            };
            this.isLoading = false;
            this.isDataReceived = true;
        }).then(response => {
            console.log('Successfully subscribed to : ', JSON.stringify(response.channel));
            this.subscription = response;
        });

        
    }

    handleImportData() {
        this.isLoading = true;

        importUsers()
        .then(result => {
            
        })
        .catch(error => {
            this.importResult = {
                importedRecords : 0,
                updatedRecords : 0,
                errors : 0,
                importStatus : 'Error: ' + error.body.message + ' ' + error.body.stackTrace
            };
            console.log(error);
            this.isLoading = false;
            this.isDataReceived = true;
        });

        
    }

    handleViewRecords() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'UIT_User__c',
                actionName: 'list'
            },
            state: {
                filterName: 'All'
            }
        });
    }
}