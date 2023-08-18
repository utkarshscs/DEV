import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import opportunityList from '@salesforce/apex/FnA_RenewOpportunityController.getOpportunityList';
import createOpportunity from '@salesforce/apex/FnA_RenewOpportunityController.createBundleOpportunity';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CLOSEDATE_FIELD from '@salesforce/schema/Opportunity.CloseDate';
import BundleRecordTypeId from '@salesforce/label/c.BundleRecordTypeId';
export default class FnA_RenewOpportunity extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @api objectApiName;
    @track oppoList;
    @track bundleName = '';
    @track closeDate = '';
    @track stageName ='';
    @track loaded = false;
    @track isAllChecked = false;
    @track recTypeId = BundleRecordTypeId;
    @track selectedRecord =['Products','Site_Covered','Standard_Covered','Opportunity_Certificates','ContactRole','OpportunityTeam','Scope','SubScope','TermsAndCondition'];
    
    get options() {
        return [{ label: 'Products', value: 'Products' },
        {label: 'Site Covered', value: 'Site_Covered' },
        { label: 'Standard Covered', value: 'Standard_Covered' },
        { label: 'Opportunity Certificates', value: 'Opportunity_Certificates' },
        { label: 'Contact Role', value: 'ContactRole' },
        { label: 'Opportunity Teams', value: 'OpportunityTeam' },
        { label: 'Scope', value: 'Scope' },
        { label: 'Sub Scope', value: 'SubScope' },
        { label: 'Terms and Condition', value: 'TermsAndCondition' }, 
    ];
}
@wire(getRecord, {recordId: "$recordId",fields: [CLOSEDATE_FIELD]})
oppo;

handleRelatedRecord (event){
    this.selectedRecord =  event.detail.value;
    console.log('Rdio1-',JSON.stringify(this.selectedRecord));   
}

handleBundleName(event){
    this.bundleName =  event.detail.value;
    console.log('You selected an Name: ' + event.detail.value);
}

handleCloseDate(event){
    this.closeDate =  event.detail.value;
    console.log('You selected an date: ' + event.detail.value);
}

handleStageName(event){
    this.stageName =  event.detail.value;
    console.log('You selected an stage: ' + event.detail.value);
}

allSelected(event) {
    let selectedRows = this.template.querySelectorAll('lightning-input');
    for(let i = 0; i < selectedRows.length; i++) {
        if(selectedRows[i].type === 'checkbox') {
            selectedRows[i].checked = event.target.checked;
        }
    }
}

@wire(opportunityList, { oppId: '$recordId'})
wiredOpportunity({ error, data }) {
    if (data) {
        console.log('data inside');
        console.log('data'+data);
        this.oppoList = data;
        console.log('data size ',data.length);
        this.isAllChecked = data.length > 0 ? true : false;
        console.log(this.oppoList);
    }  else if (error) {
        
    }
}

closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
}


submitAction(event) {
    let oppoRecordIdList = [];
    let selectedRows = this.template.querySelectorAll('lightning-input');
    for(let i = 0; i < selectedRows.length; i++) {
        if(selectedRows[i].checked && selectedRows[i].type === 'checkbox') {
            oppoRecordIdList.push(selectedRows[i].dataset.id);
        }
    } 
    let opportunityRecord = { 'sobjectType': 'Opportunity' };
    opportunityRecord.Name = this.bundleName;
    opportunityRecord.StageName = this.stageName;
    opportunityRecord.CloseDate = this.closeDate;
    opportunityRecord.Type ='Existing Business';
    let oldCloseDate = getFieldValue(this.oppo.data, CLOSEDATE_FIELD);
    oppoRecordIdList = oppoRecordIdList.filter(function(element ) {
      return element !== undefined;
    });
    console.log('Submit method is calling',oppoRecordIdList.length);
    console.log('Submit method is calling',oppoRecordIdList);
    if(this.bundleName !='' && this.stageName !='' && this.closeDate !='' && this.closeDate !=null && this.closeDate > oldCloseDate && oppoRecordIdList.length > 0 && this.stageName != 'Closed Won' && this.stageName != 'Closed Lost'){
        oppoRecordIdList.push(this.recordId);
        this.loaded = true;
        createOpportunity({oppoIds:oppoRecordIdList,previousId : this.recordId,isRelatedClone :this.selectedRecord,newBundle:opportunityRecord}).then(result => {
            console.log('result',result);
            this.loaded = false;
            this.dispatchEvent(new ShowToastEvent({title: 'Success',message: 'Bundle Opportunity Renew Successfully !',variant: 'success'}));
            //this.dispatchEvent(new CloseActionScreenEvent());
            this.navigateToViewOppoPage(result);
        }).catch(error => {
            console.log('error:',error);
            let errorMessage = '';
            if(error.body.fieldErrors.length > 0) {
                errorMessage = error.body.fieldErrors[0].message;
            } else if (error.body.pageErrors.length > 0) {
                errorMessage = error.body.pageErrors[0].message;
            }
            this.dispatchEvent(new ShowToastEvent({title: 'Error',message: errorMessage ,variant:'error',mode : 'sticky'})); 
            this.loaded = false;
        })
    } else {
        let msg ='';
        if(this.bundleName =='' && this.stageName =='' && this.closeDate =='' ){
            msg = 'Opportunity name,close date and stage must be required';
        } else if(this.stageName =='') { 
            msg = 'Stage must be required';
        } else if(this.closeDate =='' || this.closeDate ==null){
            msg = 'Close date must be required';
        }  else if(this.stageName == 'Closed Won' || this.stageName == 'Closed Lost'){
            msg ='We can not renew bundle opportunity with stage Closed Won/Closed Lost.';  
        } else if(oppoRecordIdList.length == 0){
            msg = 'Please select at least one child opportunity for renewal';  
        } else if (this.closeDate !='' && this.closeDate !=null && this.closeDate <= oldCloseDate){
            msg = 'Close date should be greater than close date of previous bundle opportunity';
        }
        this.dispatchEvent(new ShowToastEvent({title: 'Error',message :msg,variant:'error'})); 
    }   
}

// Navigate to View opportunity Page
navigateToViewOppoPage(rId) {
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: rId,
            objectApiName: this.objectApiName,
            actionName: 'view'
        },
    });
}
}