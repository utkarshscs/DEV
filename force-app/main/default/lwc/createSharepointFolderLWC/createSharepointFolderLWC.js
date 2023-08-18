import { LightningElement, api, track, wire } from 'lwc';
import checkParentFolder from '@salesforce/apex/CreateSharepointFolderLWCController.checkParentFolder';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from "lightning/actions";
import { CurrentPageReference } from 'lightning/navigation';
import OpptyFolderMissingErrorProject from '@salesforce/label/c.OpptyFolderMissingErrorProject';
import OpptyFolderMissingErrorOC from '@salesforce/label/c.OpptyFolderMissingErrorOC';

export default class CreateSharepointFolderLWC extends LightningElement {
    @track objectApiName;
    @track recordId;
    @track showSpinner = false;
    @track showProjectMessage;
    @track showOCMessage;
    @track showField = false;
    @track disableSave = true;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
            let crpAttribute = currentPageReference.attributes.apiName;
            const objApiName = crpAttribute.split('.').shift();
            this.objectApiName = objApiName;
        }
    }

    connectedCallback() {
        this.showSpinner = true;
        checkParentFolder({ recordId: this.recordId })
            .then(result => {
                //console.log('result.22---' + JSON.stringify(result));
                this.showSpinner = false;
                let record = result;
                if (record != null && record.Id.startsWith("a0e") && record.inspire1__Opportunity1__r.fileforcem1__Sharepoint_Folder_Id__c == undefined) {
                    this.showProjectMessage = OpptyFolderMissingErrorProject;
                }
                else if (record != null && record.Id.startsWith("a2C") && record.Opportunity__r.fileforcem1__Sharepoint_Folder_Id__c == undefined) {
                    this.showOCMessage = OpptyFolderMissingErrorOC;
                }
                else {
                    this.showField = true;
                }
            })
            .catch(error => {
                console.log('error457-- ' + JSON.stringify(error));
                this.showToast('Error !', error, 'error', 'dismissable');
                this.showSpinner = false;
            });
    }

    handleChange(event) {
        let checkbox = event.target.value;
        if (checkbox) {
            this.disableSave = false;
        }
        else {
            this.disableSave = true;
        }
    }

    handleSave() {
        this.showSpinner = true;
    }

    handleSuccess(event) {
        this.showSpinner = false;
        console.log(event.detail.id);
        //Display a success toast
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Folder created successfully!',
                variant: 'success'
            })
        );
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleError(event) {
        console.log("handleError event");
        console.log("handleError event--"+JSON.stringify(event.detail));
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
            mode
        });
        this.dispatchEvent(event);
    }
}