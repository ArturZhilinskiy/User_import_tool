import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import importUsers from '@salesforce/apex/UserImportServiceClass.importUsers';


export default class Uit_userImportTool extends NavigationMixin(LightningElement) {
    @track isDataRecived = false;
    @track isLoading = false;
    @track importResult = {
        importedRecords : 1,
        updatedRecords : 13,
        importStatus : 'Sucess'
    }
   

    handleImportData() {
        this.isLoading = true;

        
        importUsers()
            .then(result => {
                this.importResult = result;
                this.isLoading=false;
                this.isDataRecived = true;
            })
            .catch(error => {
                this.importResult = {
                    importedRecords : 0,
                    updatedRecords : 0,
                    importStatus : 'Error: ' + error.body.message + ' ' + error.body.stackTrace
                };
                console.log(error);
                this.isLoading=false;
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