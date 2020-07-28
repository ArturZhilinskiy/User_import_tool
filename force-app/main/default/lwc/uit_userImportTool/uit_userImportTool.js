import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import importUsers from '@salesforce/apex/UserImportServiceClass.importUsers';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';


export default class Uit_userImportTool extends NavigationMixin(LightningElement) {
    @track channelName = '/event/UIT_Import_Event__e';
    @track isDataRecived = false;
    @track isLoading = false;
    @track importResult = {
        importedRecords : 0,
        updatedRecords : 0,
        errors : 0,
        importStatus : 'Sucess'
    }

    subscription = {};
   
    connectedCallback() {
        let resultObj = {};
        const messageCallback = function(response) { 
            
           
            console.log('New message received : ', JSON.stringify(response));
            
            resultObj.errors = response.data.payload.errors__c;
            console.log('haha2');
            resultObj.updatedRecords = response.data.payload.updatedRecords__c;
            resultObj.importedRecords = response.data.payload.importedRecords__c;
            resultObj.importStatus = response.data.payload.importStatus__c;
            console.log('resultObj', resultObj);
            this.importResult = resultObj;
            console.log('importResult', importResult);
            
        };

        subscribe(this.channelName, -1, messageCallback).then(response => {
            console.log('Successfully subscribed to : ', JSON.stringify(response.channel));
            this.subscription = response;
        });

        
    }

    handleMessageCallback(response) {
        this.isLoading = false;
        this.isDataRecived = true;
    }

    handleImportData() {
        this.isLoading = true;

        importUsers()
        .then(result => {
            
        })
        .catch(error => {
            this.importResult = {
                'importedRecords' : 0,
                'updatedRecords' : 0,
                'errors' : 0,
                'importStatus' : 'Error: ' + error.body.message + ' ' + error.body.stackTrace
            };
            console.log(error);
            this.isLoading = false;
            this.isDataRecived = true;
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