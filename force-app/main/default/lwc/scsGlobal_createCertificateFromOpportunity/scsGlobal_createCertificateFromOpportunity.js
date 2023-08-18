import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCertificateFromOpportunity from '@salesforce/apex/SCSGlobal_CreateCertificateHelper.getCertificateFromOpportunity';
//import PROGRAM_NAME_FIELD from "@salesforce/schema/Opportunity.Program_Name__c";
//import PROGRAM_ID_FIELD from "@salesforce/schema/Opportunity.Programc__c";
//import ACCOUNTID_FIELD from "@salesforce/schema/Opportunity.AccountId";
import { loadStyle } from 'lightning/platformResourceLoader';
import createOCZip from '@salesforce/resourceUrl/CreateOC';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from "lightning/actions";
import getFieldsListFromFieldSet from '@salesforce/apex/SCSGlobal_CreateCertificateHelper.getFieldsListFromFieldSet';
import getCertificateFieldsfromFieldSet from '@salesforce/apex/SCSGlobal_CreateCertificateHelper.getCertificateFieldsfromFieldSet';
import createCertificateAndOC from '@salesforce/apex/SCSGlobal_CreateCertificateHelper.createCertificateAndOC';
import checkProjectExist from '@salesforce/apex/SCSGlobal_CreateCertificateHelper.checkProjectExist';
import { NavigationMixin } from 'lightning/navigation';
import projectMissing from '@salesforce/label/c.Project_Missing_Error';
import RSPOprogramID from '@salesforce/label/c.RSPOprogramID';

export default class ScsGlobal_createCertificateFromOpportunity extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    showSpinner = false;
    programName;
    programId;
    accId;
    certificates;
    showScreen1 = true;
    showScreen2 = false;
    showScreen3 = false;
    selectedCertificateId;
    hideNext = true;
    certificateFields;
    opptyCertificateFields;
    isProjectFound = false;
    isDisable = true;
    errMsg = '';
    // Expose the labels to use in the template.
    label = {
        projectMissing
    };
    //Pagination start...
    @track showTable = false;
    @track pageSize = 10;
    @track pageNumber = 1;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track recordEnd = 0;
    @track recordStart = 0;
    @track isPrev = true;
    @track isNext = true;
    @track labelName;
    @track isShowPaginationButton = false;
    @track noCertificateMessage;
    @track showStartDateField = false;
    //pagination end...

    @track referSCSSchemeNo;
    @track schemeCertNo;
    @track validFrom;
    @track validThrough;
    @track certType;
    @track startDate;

    @track opportunityCertificateInputFields = [];
    @track certificateInputFields = [];
    columns = [
        { label: 'Name', fieldName: 'Name', type: 'text', sortable: "true" },
        { label: 'Scheme Certification Number', fieldName: 'Scheme_Certification_Number__c', type: 'text', sortable: "true" },
        { label: 'SCS Certification Number', fieldName: 'SCS_Certification_Number__c', type: 'text', sortable: "true" },
        {
            label: 'Valid from', fieldName: 'ValidFrom__c', type: 'date', sortable: "true",
            typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
            }
        },
    ];

    connectedCallback() {
        setTimeout(() => {
            this.invokeApexMethods();
        }, 5);

    }
    async invokeApexMethods() {
        // check if project available
        this.isProjectFound = await checkProjectExist({
            oppId: this.recordId
        }).then(result => {
            return result;
        }).catch(error => {
            console.log('Exception Occured:' + error);
            if (Array.isArray(error.body)) {
                this.errMsg = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.errMsg = error.body.message;
            }
        });
        if (this.isProjectFound == true) {
            this.getCertificate();
            this.isDisable = false;
        } else {
            this.errMsg = this.label.projectMissing;//'Project not found. Please create Project.';
        }
    }

    @wire(getRecord, {
        recordId: '$recordId',
        fields: ['Opportunity.Program_Name__c', 'Opportunity.AccountId', 'Opportunity.Programc__c']
    }) wiredOpportunity({
        error,
        data
    }) {
        if (error) {
            this.error = error;
        } else if (data) {
            this.programName = data.fields.Program_Name__c.value;
            var regEx = /^[0-9a-zA-Z]+$/;
            if (this.programName.charAt(this.programName.length - 1).match(regEx)) {
                //return true;
            }
            else {
                this.programName = this.programName.substring(0, this.programName.length - 1);
            }
            console.log('program Name ' + this.programName);
            this.accId = data.fields.AccountId.value;
            console.log('Acc ID  ' + this.accId);
            this.programId = data.fields.Programc__c.value;
            console.log('Program Id ' + this.programId);

            /*if (this.programId == RSPOprogramID) {
                this.showStartDateField = true;
            }
            else {
                this.showStartDateField = false;
            }*/
            //this.getCertificate();
            this.noCertificateMessage = 'No certificate exists for ' + this.programName + '.Please create a new certificate.';

            if (this.programName != '') {
                getCertificateFieldsfromFieldSet({ fieldSetName: this.programName })
                    .then(res => {
                        console.log('Result 14333--> ' + JSON.stringify(res));
                        let result = JSON.parse(res.FIELD_LIST);
                        console.log('Result 14555--> ' + result);
                        if (result != null) {
                            let arr = [];
                            let obj = new Object();

                            result.forEach(elem => {
                                obj = new Object();
                                obj.name = elem.fieldPath;
                                obj.required = elem.required;
                                obj.value = '';
                                arr.push(obj);
                            })
                            this.certificateInputFields = arr;
                        }
                        else {
                            this.showToast('System Error: Program configuration missing. Kindly contact support team.', 'Info', 'info', 'sticky');
                        }
                    })
                    .catch(err => {
                        console.log('Error 16555- ' + err);
                    })
            }
        }
    }

    //Pagination start...
    //handle first
    handlePaginationFirst() {
        this.pageNumber = 1;
        this.getCertificate();
    }
    //handle next
    handlePaginationNext() {
        this.pageNumber = this.pageNumber + 1;
        this.getCertificate();
    }
    //handle prev
    handlePaginationPrev() {
        this.pageNumber = this.pageNumber - 1;
        this.getCertificate();
    }
    //handle prev
    handlePaginationLast() {
        this.pageNumber = this.totalPages;
        this.getCertificate();
    }

    getCertificate() {
        //this.showSpinner = true;
        getCertificateFromOpportunity({ pageSize: this.pageSize, pageNumber: this.pageNumber, oppId: this.recordId })
            .then(result => {
                //this.showSpinner = false;
                if (result) {
                    //
                    var resultData = JSON.parse(result);
                    this.certificates = resultData.certificates;
                    this.showTable = resultData.certificates.length > 0 ? true : false;
                    this.labelName = resultData.certificates.length > 0 ? 'Select certificate for ' + this.programName : 'Create certificate for ' + this.programName;
                    this.pageNumber = resultData.pageNumber;
                    this.totalRecords = resultData.totalRecords;
                    this.isShowPaginationButton = resultData.totalRecords > 10 ? true : false;
                    this.recordStart = resultData.recordStart;
                    this.recordEnd = resultData.recordEnd;
                    this.totalPages = Math.ceil(resultData.totalRecords / this.pageSize);
                    this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                    this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);

                }
            })
            .catch(error => {
                //this.showSpinner = false;
                this.error = error;
            });

    }
    //pagination end...

    handleRowSelection = event => {
        var selectedRows = event.detail.selectedRows;
        if (selectedRows.length != 0) {
            var el = this.template.querySelector('lightning-datatable').getSelectedRows();
            this.selectedCertificateId = el[0].Id;
            this.hideNext = false;
        }
        else if (selectedRows.length == 0) {
            this.selectedCertificateId = null;
            this.hideNext = true;
        }
    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleNext() {
        getFieldsListFromFieldSet({ fieldSetName: this.programName })
            .then(res => {
                this.showSpinner = false;
                console.log('Result 205--> ' + JSON.stringify(res));
                let result = JSON.parse(res.FIELD_LIST);
                console.log('Result 206--> ' + result);
                if (result != null) {
                    let arr = [];
                    let obj = new Object();

                    result.forEach(elem => {
                        obj = new Object();
                        obj.name = elem.fieldPath;
                        obj.required = elem.required;
                        obj.isProductCertificateType = elem.fieldPath == "Product_Certificate_Type__c" ? true : false;
                        arr.push(obj);
                    })
                    this.opportunityCertificateInputFields = arr;
                    this.gotoScreen3();
                }
                else {
                    this.showToast('System Error: Program configuration missing. Kindly contact support team.', 'Info', 'info', 'sticky');
                }
            })
            .catch(err => {
                this.showSpinner = false;
                console.log('Error 220- ' + err);
            })
    }

    handleSaveCertificate(event) {
        //this.template.querySelector('lightning-record-edit-form[data-id=certificate]').submit();
        var tempList = [];
        tempList = this.certificateInputFields;
        event.preventDefault();
        //const fields = event.detail.fields;
        this.certificateFields = event.detail.fields;
        this.showSpinner = true;
        for (let i = 0; i < tempList.length; i++) {
            let fieldApiName = tempList[i].name;
            if (tempList[i].name === fieldApiName) {
                tempList[i].value = this.certificateFields[fieldApiName];
            }
        }

        /*this.schemeCertNo = this.certificateFields.Scheme_Certification_Number__c;
        this.validFrom = this.certificateFields.ValidFrom__c;
        console.log('tempListthis.validFrom---' + this.validFrom);
        this.validThrough = this.certificateFields.ValidThrough__c;
        this.certType = this.certificateFields.Certification_Type__c;
        this.startDate = this.certificateFields.Start_date_of_first_certificate__c;*/
        if (this.certificateFields.Refer_SCS_Scheme_Number__c == 'Scheme Certification Number' && this.certificateFields.Scheme_Certification_Number__c == null) {
            this.showToast('Please enter Scheme Certification Number!', 'Error', 'error', 'sticky');
        }
        else {
            this.handleNext();
        }
    }

    handleCertificateSuccess(event) {
        this.selectedCertificateId = event.detail.id;
        console.log(this.selectedCertificateId);
        //this.showToast('Record Saved Successfully', 'Success', 'success');
        //this.handleNext();
    }

    handleSaveOpptyCertificate(event) {
        //this.template.querySelector('lightning-record-edit-form[data-id=oppty_certificate]').submit();
        event.preventDefault(event);
        this.opptyCertificateFields = event.detail.fields;
        this.showSpinner = true;
        console.log('this.opptyCertificateFields---' + JSON.stringify(this.opptyCertificateFields));
        console.log('this.selectedCertificateId---' + this.selectedCertificateId);
        console.log('this.certificateFields324---' + this.certificateFields);
        createCertificateAndOC({
            cert: this.certificateFields,
            oppCert: this.opptyCertificateFields,
            existingCertId: this.selectedCertificateId
        })
            .then((result) => {
                this.showSpinner = false;
                console.log('Test= Record is created');
                this.showToast('Record Saved Successfully', 'Success', 'success');
                this.closeAction();
                window.open('/lightning/r/Opportunity_Certificate__c/' + result + '/view');
            })
            .catch((error) => {
                console.log(error);
                this.showSpinner = false;
                this.showToast('Error', 'Date provided seems to be incorrect. Please check the help text for more information', 'error', 'sticky')
                this.loading = false;
            });
    }

    handleOpptyCertificateSuccess(event) {
        //this.selectedCertificateId = event.detail.id;
        console.log('ocid-- ' + event.detail.id);
        const ocId = event.detail.id;
        this.showToast('Record Saved Successfully', 'Success', 'success');
        this.closeAction();
        window.open('/' + ocId);
    }

    handleError(event) {
        console.log(JSON.stringify(event.detail));
        var errorObj = JSON.parse(JSON.stringify(event.detail));
        var message = event.detail.message + ': ';
        errorObj.output.errors.forEach(element => {
            message = message + ' ' + element.message + '. ';
        });
        this.showToast(message, 'Server Error !', 'error', 'sticky');
    }

    gotoScreen1() {
        this.showScreen1 = true;
        this.showScreen2 = false;
        this.showScreen3 = false;
        this.selectedCertificateId = null;
        this.hideNext = true;
    }

    gotoScreen2() {
        console.log('referSCSSchemeNo-312-' + this.referSCSSchemeNo);
        this.showScreen2 = true;
        this.showScreen1 = false;
        this.showScreen3 = false;
    }

    gotoScreen3() {
        this.showScreen3 = true;
        this.showScreen2 = false;
        this.showScreen1 = false;
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
    renderedCallback() {
        Promise.all([
            loadStyle(this, createOCZip + '/createOC.css')
        ])
    }
}