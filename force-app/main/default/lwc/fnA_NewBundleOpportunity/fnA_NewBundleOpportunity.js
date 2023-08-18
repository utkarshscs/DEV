import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import BundleRecordTypeId from '@salesforce/label/c.BundleRecordTypeId';

export default class FnA_NewBundleOpportunity extends NavigationMixin(LightningElement) {
    @api recordId;
    @track objectApiName = 'Opportunity';
    @track loaded = false;
    @api recordTypeId;
    @track recTypeId;
    @track showCancelButton = true;

    connectedCallback() {
        console.log('recordTypeId fna---' + this.recordTypeId);
        if (this.recordTypeId != undefined) {
            this.recTypeId = this.recordTypeId;
            this.showCancelButton = false;
        }
        else {
            this.recTypeId = BundleRecordTypeId;
            this.showCancelButton = true;
        }
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleBackAction() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Opportunity',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }

    onSubmitHandler() {
        this.loaded = true;
    }

    handleSuccess(event) {
        this.loaded = false;
        console.log(event.detail.id);
        //Display a success toast
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Bundle opportunity created successfully!',
                variant: 'success'
            })
        );
        //this.navigateToChildOpportunity(event.detail.id);
        this.navigatetoChild(event.detail.id);
    }

    navigatetoChild(oppoId) {
        var compDefinition = { componentDef: "c:addChildOpportunityLWC", attributes: { recordId: oppoId } };
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        window.open('/one/one.app#' + encodedCompDef, '_self');
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleError(event) {
        console.log("handleError event");
        console.log(JSON.stringify(event.detail));
    }
}