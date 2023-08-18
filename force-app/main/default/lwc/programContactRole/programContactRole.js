import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getProgramContactRoleData from '@salesforce/apex/ProgramContactRole.getProgramContactRoleData';

const FIELDS = [
                    'Opportunity.Id',
                    'Opportunity.AccountId',
                    'Opportunity.Programc__c'
                ];

export default class ProgramContactRole extends LightningElement {

    @track showSpinner = false;
    @track showTable = false;
    @track dataToDisplay = [];
    @track errorMessage = '';

    @api recordId;
    @track programId;
    @track accountId;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    oppor(response){
        if(response.data){
            console.log('Response data -> ', response.data);
            this.programId = response.data.fields.Programc__c.value;
            this.accountId = response.data.fields.AccountId.value;
        }
    }

    @wire(getProgramContactRoleData, {programId : '$programId' , accountId : '$accountId'})
   // @wire(getProgramContactRoleData)
    programRoleData(response){
        this.showSpinner = true;
        if(response.data){

            console.log('response.data - ', response.data);
            console.log('Oppor data Program Id - ', this.programId);
            console.log('Oppor data account Id - ', this.accountId);

            let resp = response.data;

            this.dataToDisplay = resp.map(rec => {

                return {
                    "Id": rec.Id,
                    "program": rec.program,
                    "accountName": rec.accountName,
                    "firstName": rec.firstName,
                    "lastName": rec.lastName,
                    "title": rec.title,
                    "phone": rec.phone,
                    "fax": rec.fax,
                    "email": rec.email,
                    "mobile": rec.mobile,
                    "programRole": rec.programRole,
                    "progId" : "/"+rec.progrId,
                    "accountId" : "/"+ rec.accountId
                }

            });

            if(this.dataToDisplay.length > 0){
                this.showTable = true;
                this.errorMessage = '';
            }           
            else{
                this.showTable = false;
                this.errorMessage = 'No data found';    
            }
            
            console.log('Data to display - ', this.dataToDisplay);
            console.log('Data to display length - ', this.dataToDisplay.length);
            console.log('Show Table - ', this.showTable);
            this.showSpinner = false;

        }
        else if(response.error){
            this.showTable = false;
            this.errorMessage = 'Something went wrong';
        }
    } 

}