import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import { CloseActionScreenEvent } from "lightning/actions"
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllOpptyWithOlis from '@salesforce/apex/AddChildOpportunityLWCController.getAllOpptyWithOlis';
import getPricebookEntry from '@salesforce/apex/AddChildOpportunityLWCController.getPricebookEntry';
import upsertOpptyList from '@salesforce/apex/AddChildOpportunityLWCController.upsertOpptyList';
import deleteOpportunity from '@salesforce/apex/AddChildOpportunityLWCController.deleteOpportunity';
import getPricebookAndRecordType from '@salesforce/apex/AddChildOpportunityLWCController.getPricebookAndRecordType';
import SubScopeErrorMessage from '@salesforce/label/c.SubScopeErrorMessage';
import NoChildOpptyMsg from '@salesforce/label/c.NoChildOpptyMsg';

import LightningConfirm from "lightning/confirm";
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

const FIELDS = [
    'Opportunity.Id',
    'Opportunity.AccountId',
    'Opportunity.Type',
    'Opportunity.Name',
    'Opportunity.Language__c',
    'Opportunity.StageName',
    'Opportunity.CloseDate',
    'Opportunity.LeadSource',
    'Opportunity.Program_List__c'
];

export default class AddChildOpportunityLWC extends NavigationMixin(LightningElement) {
    @api recordId;
    @track error;
    @track showSpinner = false;
    @track options = [];
    @track pricebookOptions = [];
    @track opptyWithOlis = [];
    @track wiredOpptyOLIs = [];
    @track existingOpptyList = [];
    @track blankRow = [];
    @track blankRowOLI = [];
    @track recordIdtoDel;
    @track oliList = [];
    @track subScopeList = [];
    @track standardList = [];
    @track newOppList = [];
    @track filteredRecTypeId;
    @track parentOpptyName = '';
    @track opptyPageUrl = '';
    @track backToOppty = '';
    @track showAddMoreButton = false;
    @track showTable = true;
    @track disableButton = false;
    @track isShowModal = false;
    @track selectedOpptyName;
    @track showLossReason = false;
    @track currentOpptyId;
    @track currentOpptyProgram;
    @track subScopeErrorMsg = SubScopeErrorMessage;
    @track noChildOpptyMsg = NoChildOpptyMsg;
    @track showOLIHeader = true;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    opportunity;

    get accountId() {
        return this.opportunity.data.fields.AccountId.value;
    }

    get type() {
        return this.opportunity.data.fields.Type.value;
    }

    get name() {
        console.log('recordId-58-' + this.recordId);
        return this.opportunity.data.fields.Name.value;
    }

    get id() {
        return this.opportunity.data.fields.Id.value;
    }

    get stagename() {
        return this.opportunity.data.fields.StageName.value;
    }

    get closedate() {
        return this.opportunity.data.fields.CloseDate.value;
    }

    get language() {
        return this.opportunity.data.fields.Language__c.value;
    }

    get leadsource() {
        return this.opportunity.data.fields.LeadSource.value;
    }

    get programlist() {
        return this.opportunity.data.fields.Program_List__c.value;
    }

    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    objectInfo({ error, data }) {
        if (data) {
            let optionsValues = [];
            const rtis = data.recordTypeInfos;

            Object.keys(rtis).forEach(element => {
                optionsValues.push({
                    label: rtis[element].name,
                    value: rtis[element].recordTypeId
                })
            });
            this.options = optionsValues;
            console.log('rtisoptionsValues ===> ' + JSON.stringify(optionsValues));
            const filteredRecTypeId = this.options.find((obj) => {
                return (obj.label === "Food and Agriculture");
            });
            console.log('filteredRecTypeId--' + JSON.stringify(filteredRecTypeId.label));
            this.filteredRecTypeId = filteredRecTypeId.value;
        } else if (error) {
            this.showToast('Error !', error, 'error', 'dismissable');
        }
    };

    @wire(getAllOpptyWithOlis, { bundleOpptyId: '$id' })
    wiredOpptiesWithOlis(response) {
        if (response.data) {
            this.wiredOpptyOLIs = response;
            this.opptyWithOlis = [];
            console.log('NewJSON.stringify(response.data)---' + JSON.stringify(response.data));
            let allOppty = JSON.parse(JSON.stringify(response.data));
            allOppty.forEach(element => {
                let pricebookOptions = [];
                if (element.pricebookList != undefined) {
                    let pricebookList = JSON.parse(JSON.stringify(element.pricebookList));
                    console.log('NewpricebookList---' + JSON.stringify(pricebookList));
                    pricebookList.forEach(pb => {
                        pricebookOptions.push({ label: pb.Name, value: pb.Id });
                    });
                }
                let subScopeOptions = [];
                let hasSubScopeOptions = false;
                if (element.subScopeList != undefined) {
                    let subScopeList = JSON.parse(JSON.stringify(element.subScopeList));
                    subScopeList.forEach(sb => {
                        subScopeOptions.push({ label: sb.Title__c, value: sb.Id });
                    });
                    hasSubScopeOptions = true;
                }
                else {
                    //subScopeOptions.push({ label: '--None--', value: '--None--' });
                    hasSubScopeOptions = false;
                }
                console.log('subScopeOptions--' + JSON.stringify(subScopeOptions));
                this.opptyWithOlis.push({
                    "Id": element.opp.Id,
                    "RecordTypeId": element.opp.RecordTypeId,
                    "Pricebook2Id": element.opp.Pricebook2Id,
                    "AccountId": element.opp.AccountId,
                    "Name": element.opp.Name,
                    "Program_List__c": element.opp.Program_List__c,
                    "Engagement_Type__c": element.opp.Engagement_Type__c,
                    "StageName": element.opp.StageName,
                    "CloseDate": element.opp.CloseDate,
                    "Type": element.opp.Type,
                    "HasOpportunityLineItem": element.opp.HasOpportunityLineItem,
                    "Bundle_Opportunity__c": element.opp.Bundle_Opportunity__c,
                    "Language__c": element.opp.Language__c,
                    "Programc__c": element.opp.Programc__c,
                    "TotalAmount__c": element.opp.TotalAmount__c,
                    "LeadSource": element.opp.LeadSource,
                    "OpportunityLineItems": element.opp.OpportunityLineItems,
                    "isChecked": false,
                    "pricebookOptions": pricebookOptions,
                    "pricebookName": element.pricebookName,
                    "Scope__r": element.opp.Scope__r,
                    "subScopeOptions": subScopeOptions,
                    "Standard_Covered__r": element.opp.Standard_Covered__r,
                    "HasStandardCovered": element.hasStandardCovered,
                    "HasSubScope": element.hasSubScope,
                    "HasSubScopeOptions": hasSubScopeOptions
                });
            });
            console.log('this.opptyWithOlis-153--- ' + JSON.stringify(this.opptyWithOlis));
            this.parentOpptyName = this.name;
            this.backToOppty = 'Back to ' + this.name;

            if (this.opptyWithOlis.length > 0) {
                this.showAddMoreButton = true;
                this.showTable = true;

                let arrLen = this.opptyWithOlis.length;
                let lastRecIndex = arrLen - 1;
                var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
                this.disableButton = false;
                console.log('NewtempList[lastRecIndex]---' + JSON.stringify(tempList[lastRecIndex].HasOpportunityLineItem));
                if (tempList[lastRecIndex].HasOpportunityLineItem == false) {

                    var innerArray = [];
                    innerArray.push({
                        "OpportunityId": tempList[lastRecIndex].Id,
                        "Id": null,
                        "Product2Id": null,
                        "Quantity": 1,
                        "Discount": null,
                        "Discount_Amount__c": null,
                        "UnitPrice": 0,
                        "Description": ""
                    });
                    tempList[lastRecIndex].OpportunityLineItems = innerArray;
                    tempList[lastRecIndex].isChecked = true;
                    this.opptyWithOlis = tempList;
                    this.opptyWithOlis = [];
                    setTimeout(() => {
                        this.opptyWithOlis = tempList;
                    }, 250);
                    this.disableButton = true;
                }
            }
            else {
                this.showAddMoreButton = false;
                this.showTable = false;
                this.disableButton = false;
            }
        } else if (response.error) {
            this.error = JSON.stringify(response.error.body);
            this.showToast('Error !', this.error, 'error', 'dismissable');
            console.log('Wire Error--- ' + JSON.stringify(response.error));
        }
        console.log('this.opptyWithOlis-Wire-Updated ' + JSON.stringify(this.opptyWithOlis));
    }

    handleAddOpptyRow() {
        if (this.programlist != undefined) {
            getPricebookAndRecordType({ programName: this.programlist })
                .then(result => {
                    let genericPricebookId = '';
                    if (result.pricebookList.length > 50) {
                        const filtered = result.pricebookList.find((obj) => {
                            return (obj.Name === "Generic Pricebook");
                        });
                        console.log('filtered--' + JSON.stringify(filtered));
                        console.log('filtered--' + JSON.stringify(filtered.Id));
                        genericPricebookId = filtered.Id;
                    }
                    var programId = result.prg.Id;
                    console.log('programId--' + JSON.stringify(programId));
                    var recordTypeName = result.prg.Reporting_Division__c;
                    console.log('recordTypeName--' + JSON.stringify(recordTypeName));
                    let options = [];
                    for (var key in result.pricebookList) {
                        options.push({ label: result.pricebookList[key].Name, value: result.pricebookList[key].Id });
                    }
                    this.pricebookOptions = options;
                    console.log('PB Options--- ' + this.pricebookOptions);
                    let recordTypeId;
                    for (var key in this.options) {
                        if (this.options[key].label == recordTypeName) {
                            recordTypeId = this.options[key].value;
                        }
                    }

                    var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
                    var innerArray = [];
                    tempList.push({
                        "Id": null,
                        "RecordTypeId": recordTypeId,
                        "Pricebook2Id": genericPricebookId,
                        "AccountId": this.accountId,
                        "Name": "",
                        "Program_List__c": this.programlist,
                        "Engagement_Type__c": "",
                        "StageName": this.stagename,
                        "CloseDate": this.closedate,
                        "Type": this.type,
                        "HasOpportunityLineItem": false,
                        "Bundle_Opportunity__c": this.recordId,
                        "Language__c": this.language,
                        "Programc__c": programId,
                        "TotalAmount__c": "",
                        "LeadSource": this.leadsource,
                        "OpportunityLineItems": innerArray,
                        "pricebookOptions": this.pricebookOptions
                    });
                    this.opptyWithOlis = tempList;
                    this.showTable = true;
                    this.disableButton = true;
                })
                .catch(error => {
                    console.log('error394-- ' + JSON.stringify(error));
                    this.showToast('Error !', error.body.message, 'error', 'dismissable');
                    this.showSpinner = false;
                });
        }
        else {
            var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
            var oliArray = [];
            var subScopeArray = [];
            var standardArray = [];
            tempList.push({
                "Id": null,
                "RecordTypeId": "",
                "Pricebook2Id": "",
                "AccountId": this.accountId,
                "Name": "",
                "Program_List__c": "",
                "Engagement_Type__c": "",
                "StageName": this.stagename,
                "CloseDate": this.closedate,
                "Type": this.type,
                "HasOpportunityLineItem": false,
                "Bundle_Opportunity__c": this.recordId,
                "Language__c": this.language,
                "Programc__c": null,
                "TotalAmount__c": "",
                "LeadSource": this.leadsource,
                "OpportunityLineItems": oliArray,
                "isChecked": false,
                "Scope__r": subScopeArray,
                "Standard_Covered__r": standardArray
            });
            console.log('tempList-3022-' + JSON.stringify(tempList));
            this.opptyWithOlis = tempList;
            this.showTable = true;
            this.disableButton = true;
        }
        console.log('oppRecordId-3022-' + JSON.stringify(this.opptyWithOlis));
    }

    handleDeleteOppty(event) {
        this.showLossReason = false;
        this.recordIdtoDel = event.target.dataset.id;
        this.selectedOpptyName = event.target.dataset.element;
        const rowIndex = event.target.dataset.index;
        if (this.recordIdtoDel != undefined) {
            //this.handleAlertMessage();
            this.isShowModal = true;
        }
        else {
            let opptyWithOlis = this.opptyWithOlis;
            opptyWithOlis.splice(rowIndex, 1);
            this.opptyWithOlis = opptyWithOlis;
            if (this.opptyWithOlis.length > 0) {
                this.showTable = true;
            }
            else {
                this.showTable = false;
                this.disableButton = false;
            }
        }
    }

    handleDeleteOli(event) {
        this.recordIdtoDel = event.target.dataset.id;
        const rowIndex = event.target.dataset.element;
        const rowIndex2 = event.target.dataset.index;
        if (this.recordIdtoDel != undefined) {
            this.handleAlertMessage();
        }
        else {
            var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
            console.log('tempList[rowIndex].OpportunityLineItems--' + JSON.stringify(tempList[rowIndex].OpportunityLineItems));
            tempList[rowIndex].OpportunityLineItems.splice(rowIndex2, 1);
            this.opptyWithOlis = tempList;
        }
        console.log('opptyWithOlis-handleDeleteOli-' + JSON.stringify(this.opptyWithOlis));
    }

    handleShowOli(event) {
        const rowIndex = event.target.dataset.index;
        var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
        tempList[rowIndex].isChecked = true;
        this.opptyWithOlis = tempList;
    }

    handleHideOli(event) {
        const rowIndex = event.target.dataset.index;
        var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
        tempList[rowIndex].isChecked = false;
        this.opptyWithOlis = tempList;
    }

    async handleAlertMessage() {
        const result = await LightningConfirm.open({
            message: "Are you sure you want to delete this record ?",
            variant: "default", // headerless
            label: "Delete a record"
        });

        if (result) {
            this.showSpinner = true;
            deleteOpportunity({ recordId: this.recordIdtoDel })
                .then(result => {
                    this.showToast('Record deleted Successfully', 'Success', 'success');
                    refreshApex(this.wiredOpptyOLIs);
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.log('error237-- ' + JSON.stringify(error));
                    this.showToast('Error !', error.body.message, 'error', 'dismissable');
                    this.showSpinner = false;
                });
        } else {
            this.dispatchEvent(new CloseActionScreenEvent());
        }
    }

    handleRecordType(event) {
        const rowIndex = event.target.dataset.index;
        let blankRow = JSON.parse(JSON.stringify(this.opptyWithOlis));
        blankRow[rowIndex].RecordTypeId = event.target.value;
        this.opptyWithOlis = blankRow;
    }

    handleName(event) {
        const rowIndex = event.target.dataset.index;
        console.log('oppRecordId-216-' + JSON.stringify(this.opptyWithOlis));
        let blankRow = JSON.parse(JSON.stringify(this.opptyWithOlis));
        blankRow[rowIndex].Name = event.target.value;
        this.opptyWithOlis = blankRow;
        console.log('oppRecordId-190-' + JSON.stringify(this.opptyWithOlis));
    }

    handleAccount(event) {
        const rowIndex = event.target.dataset.index;
        let blankRow = JSON.parse(JSON.stringify(this.opptyWithOlis));
        blankRow[rowIndex].AccountId = event.target.value;
        this.opptyWithOlis = blankRow;
    }

    handleStage(event) {
        const rowIndex = event.target.dataset.index;
        let blankRow = JSON.parse(JSON.stringify(this.opptyWithOlis));
        blankRow[rowIndex].StageName = event.target.value;
        this.opptyWithOlis = blankRow;
    }

    handleCloseDate(event) {
        const rowIndex = event.target.dataset.index;
        let blankRow = JSON.parse(JSON.stringify(this.opptyWithOlis));
        blankRow[rowIndex].CloseDate = event.target.value;
        this.opptyWithOlis = blankRow;
    }

    handleTargetAuditDate(event) {
        const rowIndex = event.target.dataset.index;
        let blankRow = JSON.parse(JSON.stringify(this.opptyWithOlis));
        blankRow[rowIndex].Target_Audit_Date__c = event.target.value;
        this.opptyWithOlis = blankRow;
    }

    handleEngagementType(event) {
        const rowIndex = event.target.dataset.index;
        let blankRow = JSON.parse(JSON.stringify(this.opptyWithOlis));
        blankRow[rowIndex].Engagement_Type__c = event.target.value;
        this.opptyWithOlis = blankRow;
    }

    handleLanguage(event) {
        const rowIndex = event.target.dataset.index;
        let blankRow = JSON.parse(JSON.stringify(this.opptyWithOlis));
        blankRow[rowIndex].Language__c = event.target.value;
        this.opptyWithOlis = blankRow;
    }

    handleProgramList(event) {
        const selectedValue = event.target.value;
        console.log('ProgramList-selectedValue-- ' + selectedValue);
        const rowIndex = event.target.dataset.index;
        console.log('ProgramList-rowIndex-- ' + rowIndex);

        this.pricebookOptions = [];
        getPricebookAndRecordType({ programName: selectedValue })
            .then(result => {
                let genericPricebookId = '';
                console.log('result475--' + JSON.stringify(result));
                if (result.pricebookList.length > 50) {
                    const filtered = result.pricebookList.find((obj) => {
                        return (obj.Name === "Generic Pricebook");
                    });
                    console.log('filtered--' + JSON.stringify(filtered));
                    console.log('filtered--' + JSON.stringify(filtered.Id));
                    genericPricebookId = filtered.Id;
                }
                var programId = result.prg.Id;
                console.log('programId--' + JSON.stringify(programId));
                var recordTypeName = result.prg.Reporting_Division__c;
                console.log('recordTypeName--' + JSON.stringify(recordTypeName));
                let options = [];
                for (var key in result.pricebookList) {
                    options.push({ label: result.pricebookList[key].Name, value: result.pricebookList[key].Id });
                }
                this.pricebookOptions = options;

                /*const query = '[data-pricebookid="' + rowIndex + '"]';
                console.log('this.template.querySelector(query)--' + this.template.querySelector(query));
                let picklist = this.template.querySelector(query);

                if (picklist.name == 'pricebook') {
                    picklist.options = this.pricebookOptions;
                }*/

                let recordTypeId;
                for (var key in this.options) {
                    if (this.options[key].label == recordTypeName) {
                        recordTypeId = this.options[key].value;
                    }
                }
                console.log('Check--selectedValue---' + selectedValue);
                console.log('Check--recordTypeId---' + recordTypeId);
                console.log('Check--genericPricebookId---' + genericPricebookId);
                console.log('Check--this.pricebookOptions---' + JSON.stringify(this.pricebookOptions));
                let blankRow = JSON.parse(JSON.stringify(this.opptyWithOlis));
                blankRow[rowIndex].Programc__c = programId;
                console.log('New Program List---' + blankRow[rowIndex].Program_List__c);
                if (blankRow[rowIndex].Program_List__c != selectedValue) {
                    var standardArray = [];
                    blankRow[rowIndex].Standard_Covered__r = standardArray;
                }
                blankRow[rowIndex].isChecked = false;
                blankRow[rowIndex].Program_List__c = selectedValue;
                blankRow[rowIndex].RecordTypeId = recordTypeId;
                blankRow[rowIndex].Pricebook2Id = genericPricebookId;
                blankRow[rowIndex].pricebookOptions = this.pricebookOptions;
                this.opptyWithOlis = blankRow;
            })
            .catch(error => {
                console.log('error394-- ' + JSON.stringify(error));
                this.showToast('Error !', error.body, 'error', 'dismissable');
                this.showSpinner = false;
            });
        console.log('this.opptyWithOlis-Pricebook- ' + JSON.stringify(this.opptyWithOlis));
    }

    handlePricebookId(event) {
        const rowIndex = event.target.dataset.index;
        let blankRow = JSON.parse(JSON.stringify(this.opptyWithOlis));
        /*if (blankRow[rowIndex].Pricebook2Id != event.target.value) {
            blankRow[rowIndex].isChecked = false;
            blankRow[rowIndex].OpportunityLineItems.splice(0, 1);
        }*/
        blankRow[rowIndex].isChecked = false;
        blankRow[rowIndex].Pricebook2Id = event.target.value;
        this.opptyWithOlis = blankRow;
    }

    handleViewOpportunity(event) {
        const rowRecordId = event.target.dataset.id;
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: rowRecordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }

    handleViewOLI(event) {
        const rowRecordId = event.target.dataset.id;
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: rowRecordId,
                objectApiName: 'OpportunityLineItem',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }

    handleAddOLIRow(event) {
        const oppRecordId = event.target.dataset.id;
        const rowIndex = event.target.dataset.index;

        var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
        tempList[rowIndex].isChecked = true;
        var innerArray = [];
        innerArray.push({
            "OpportunityId": oppRecordId,
            "Id": null,
            "Product2Id": null,
            "Quantity": 1,
            "Discount": null,
            "Discount_Amount__c": null,
            "UnitPrice": 0,
            "Description": ""
        });

        if (tempList[rowIndex].OpportunityLineItems != undefined) {
            tempList[rowIndex].OpportunityLineItems.push({
                "OpportunityId": oppRecordId,
                "Id": null,
                "Product2Id": null,
                "Quantity": 1,
                "Discount": null,
                "Discount_Amount__c": null,
                "UnitPrice": 0,
                "Description": ""
            });
        }
        else {
            tempList[rowIndex].OpportunityLineItems = innerArray;
        }
        this.opptyWithOlis = tempList;
        console.log('oppRecoopptyWithOlisrdId-330-' + JSON.stringify(this.opptyWithOlis));
    }

    handleProduct2Id(event) {
        console.log('lookupCmp-event-' + event);
        console.log('lookupCmp-detail.selectedRecord-' + event.detail.selectedRecord);
        const rowIndex = event.target.dataset.element;
        const rowIndex2 = event.target.dataset.index;

        if (event.detail.selectedRecord != undefined) {
            console.log('EventtttSelected Record Value on Parent Component is ' + JSON.stringify(event.detail.selectedRecord));
            this.showSpinner = true;

            getPricebookEntry({ product2Id: event.detail.selectedRecord.Product2Id })
                .then(result => {
                    console.log('result.UnitPrice---' + JSON.stringify(result.UnitPrice));
                    this.showSpinner = false;
                    var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
                    tempList[rowIndex].OpportunityLineItems[rowIndex2].Product2Id = event.detail.selectedRecord.Product2Id;
                    tempList[rowIndex].OpportunityLineItems[rowIndex2].UnitPrice = result.UnitPrice;
                    this.opptyWithOlis = tempList;
                })
                .catch(error => {
                    console.log('error457-- ' + JSON.stringify(error));
                    this.showToast('Error !', error, 'error', 'dismissable');
                    this.showSpinner = false;
                });
        }
        else {
            var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
            tempList[rowIndex].OpportunityLineItems[rowIndex2].Product2Id = null;
            tempList[rowIndex].OpportunityLineItems[rowIndex2].UnitPrice = 0;
            this.opptyWithOlis = tempList;
        }
    }

    handleQuantity(event) {
        const rowIndex = event.target.dataset.element;
        const rowIndex2 = event.target.dataset.index;
        var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
        tempList[rowIndex].OpportunityLineItems[rowIndex2].Quantity = event.target.value;
        this.opptyWithOlis = tempList;
    }

    handleUnitPrice(event) {
        const rowIndex = event.target.dataset.element;
        const rowIndex2 = event.target.dataset.index;
        if (event.target.value < 0) {
            this.showToast('Error !', "Sales Price cannot be less than 0.", 'error', 'dismissable');
        }
        else {
            var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
            tempList[rowIndex].OpportunityLineItems[rowIndex2].UnitPrice = event.target.value;
            this.opptyWithOlis = tempList;
        }
    }

    handleDiscount(event) {
        console.log('event.target.value67111---' + JSON.stringify(event.target.value));
        const rowIndex = event.target.dataset.element;
        const rowIndex2 = event.target.dataset.index;
        if (event.target.value > 100) {
            this.showToast('Error !', "Discount percentage cannot be greater than 100.", 'error', 'dismissable');
        }
        else {
            var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
            if (event.target.value == "") {
                tempList[rowIndex].OpportunityLineItems[rowIndex2].Discount = null;
            }
            else {
                tempList[rowIndex].OpportunityLineItems[rowIndex2].Discount = event.target.value;
            }
            this.opptyWithOlis = tempList;
        }
    }

    handleDiscountAmount(event) {
        const rowIndex = event.target.dataset.element;
        const rowIndex2 = event.target.dataset.index;
        var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
        const unitPrice = tempList[rowIndex].OpportunityLineItems[rowIndex2].UnitPrice;
        if (event.target.value > unitPrice) {
            this.showToast('Error !', "Discount Amount cannot be greater than Sales Price.", 'error', 'dismissable');
        }
        else {
            if (event.target.value == "") {
                tempList[rowIndex].OpportunityLineItems[rowIndex2].Discount_Amount__c = null;
            }
            else {
                tempList[rowIndex].OpportunityLineItems[rowIndex2].Discount_Amount__c = event.target.value;
            }
            this.opptyWithOlis = tempList;
        }
    }

    handleDescription(event) {
        const rowIndex = event.target.dataset.element;
        const rowIndex2 = event.target.dataset.index;
        var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
        tempList[rowIndex].OpportunityLineItems[rowIndex2].Description = event.target.value;
        this.opptyWithOlis = tempList;
    }

    validateFields() {
        return [...this.template.querySelectorAll(".validate")].reduce((validSoFar, field) => {
            console.log('dasddasdas' + validSoFar + '---' + field.reportValidity());
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return (validSoFar && field.reportValidity());
        }, true);
    }

    handleSaveOppty(event) {
        if (!this.validateFields()) {
            this.showToast('Error !', "Review all error messages below to correct your data.", 'error', 'dismissable');
        }
        else {
            console.log('this.opptyWithOlis-423- ' + JSON.stringify(this.opptyWithOlis));
            this.showSpinner = true;

            let allOppty = JSON.parse(JSON.stringify(this.opptyWithOlis));
            this.oliList = [];
            this.newOppList = [];
            this.subScopeList = [];
            this.standardList = [];
            let showError = false;
            let showDiscountError = false;
            allOppty.forEach(element => {
                if (element.OpportunityLineItems) {
                    element.OpportunityLineItems.forEach(oli => {
                        console.log('element.OpportunityLineItems--' + oli.Product2Id);
                        if (oli.Product2Id == null) {
                            showError = true;
                        }
                        else if (oli.Discount != null && oli.Discount_Amount__c != null) {
                            showDiscountError = true;
                        }
                        else {
                            this.oliList.push(oli);
                        }
                    });
                }

                if (element.Scope__r) {
                    element.Scope__r.forEach(scope => {
                        this.subScopeList.push(scope);
                    });
                }

                if (element.Standard_Covered__r) {
                    element.Standard_Covered__r.forEach(stan => {
                        this.standardList.push(stan);
                    });
                }

                console.log('this.oliList-length--' + showError);
                var oppId;
                if (element.Id != null) {
                    oppId = element.Id;
                }
                else {
                    oppId = null;
                }
                this.newOppList.push({
                    "Id": oppId,
                    "RecordTypeId": element.RecordTypeId,
                    "Pricebook2Id": element.Pricebook2Id,
                    "AccountId": element.AccountId,
                    "Name": element.Name,
                    "Program_List__c": element.Program_List__c,
                    "Engagement_Type__c": element.Engagement_Type__c,
                    "StageName": element.StageName,
                    "CloseDate": element.CloseDate,
                    "Type": element.Type,
                    "Bundle_Opportunity__c": this.recordId,
                    "Language__c": element.Language__c,
                    "Programc__c": element.Programc__c,
                    "TotalAmount__c": element.TotalAmount__c,
                    "LeadSource": element.LeadSource
                });
            });

            console.log('this.443oliList-432- ' + JSON.stringify(this.oliList));
            console.log('this.443newOppList-478- ' + JSON.stringify(this.newOppList));
            console.log('this.subScopeList-478- ' + JSON.stringify(this.subScopeList));
            console.log('this.standardList-478- ' + JSON.stringify(this.standardList));

            if (!showError && !showDiscountError) {
                upsertOpptyList({
                    opptyList: JSON.stringify(this.newOppList), oliList: JSON.stringify(this.oliList),
                    subScopeList: JSON.stringify(this.subScopeList), standardList: JSON.stringify(this.standardList)
                })
                    .then(result => {
                        this.showToast('Record Saved Successfully', 'Success', 'success');
                        refreshApex(this.wiredOpptyOLIs);
                        this.blankRow = [];
                        this.showSpinner = false;
                    })
                    .catch(error => {
                        console.log('error226-- ' + JSON.stringify(error));
                        this.showToast('Error !', error.body.message, 'error', 'dismissable');
                        this.showSpinner = false;
                    });
            }
            else if (showError) {
                this.showToast('Error !', "Please add a product!", 'error', 'dismissable');
                this.showSpinner = false;
            }
            else if (showDiscountError) {
                this.showToast('Error !', 'You can fill only one field, either the "Discount %" or the "Discount Amount".', 'error', 'dismissable');
                this.showSpinner = false;
            }
        }
    }

    handleNavigateOpportunity() {
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        }).then(url => {
            this.opptyPageUrl = url;
        });
    }

    closeAction() {
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Opportunity',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_self");
        });
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

    closeModal() {
        this.isShowModal = false;
    }

    handleStageName(event) {
        if (event.target.value == 'Closed Lost') {
            this.showLossReason = true;
        }
        else {
            this.showLossReason = false;
        }
    }

    onSubmitHandler() {
        this.showSpinner = true;
        this.isShowModal = false;
    }

    handleSuccess(event) {
        this.showSpinner = false;
        console.log(event.detail.id);
        refreshApex(this.wiredOpptyOLIs);
        //Display a success toast
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Successfully removed from bundle opportunity list!',
                variant: 'success'
            })
        );
    }

    handleError(event) {
        console.log("handleError event");
        console.log(JSON.stringify(event.detail));
    }

    handleAddSubScopeRow(event) {
        alert
        const oppRecordId = event.target.dataset.id;
        const programId = event.target.dataset.program;
        const rowIndex = event.target.dataset.index;

        var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
        tempList[rowIndex].isChecked = true;
        tempList[rowIndex].HasSubScope = true;
        var innerArray = [];
        innerArray.push({
            "Sub_Scope__c": '',
            "Opportunity__c": oppRecordId,
            "Program__c": programId
        });

        if (tempList[rowIndex].Scope__r != undefined) {
            tempList[rowIndex].Scope__r.push({
                "Sub_Scope__c": '',
                "Opportunity__c": oppRecordId,
                "Program__c": programId
            });
        }
        else {
            tempList[rowIndex].Scope__r = innerArray;
        }
        this.opptyWithOlis = tempList;
        console.log('oppRecoopptyWithOlisrdId-330-' + JSON.stringify(this.opptyWithOlis));
    }

    handleSubScope(event) {
        const rowIndex = event.target.dataset.element;
        const rowIndex2 = event.target.dataset.index;
        var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
        tempList[rowIndex].Scope__r[rowIndex2].Sub_Scope__c = event.target.value;
        this.opptyWithOlis = tempList;
        console.log('oppSubScope--851---' + JSON.stringify(this.opptyWithOlis));
    }

    handleViewSubScope(event) {
        const rowRecordId = event.target.dataset.id;
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: rowRecordId,
                objectApiName: 'Scope__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }

    handleDeleteSubScope(event) {
        this.recordIdtoDel = event.target.dataset.id;
        const rowIndex = event.target.dataset.element;
        const rowIndex2 = event.target.dataset.index;
        if (this.recordIdtoDel != undefined) {
            this.handleAlertMessage();
        }
        else {
            var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
            console.log('tempList[rowIndex].OpportunityLineItems--' + JSON.stringify(tempList[rowIndex].Scope__r));
            tempList[rowIndex].Scope__r.splice(rowIndex2, 1);
            if (tempList[rowIndex].Scope__r.length > 0) {
                tempList[rowIndex].HasSubScope = true;
            }
            else {
                tempList[rowIndex].HasSubScope = false;
            }
            this.opptyWithOlis = tempList;
        }
    }

    handleAddStandard(event) {
        const oppRecordId = event.target.dataset.id;
        const programId = event.target.dataset.program;
        const rowIndex = event.target.dataset.index;

        var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
        tempList[rowIndex].isChecked = true;
        tempList[rowIndex].HasStandardCovered = true;
        var innerArray = [];
        innerArray.push({
            "Standard__c": null,
            "Opportunity__c": oppRecordId,
            "Program__c": programId
        });

        if (tempList[rowIndex].Standard_Covered__r != undefined) {
            tempList[rowIndex].Standard_Covered__r.push({
                "Standard__c": null,
                "Opportunity__c": oppRecordId,
                "Program__c": programId
            });
        }
        else {
            tempList[rowIndex].Standard_Covered__r = innerArray;
        }
        this.opptyWithOlis = tempList;
        console.log('oppRecoopptyWithOlisrdId-330-' + JSON.stringify(this.opptyWithOlis));
    }

    handleStandard(event) {
        const rowIndex = event.target.dataset.element;
        const rowIndex2 = event.target.dataset.index;
        var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
        tempList[rowIndex].Standard_Covered__r[rowIndex2].Standard__c = event.target.value;
        this.opptyWithOlis = tempList;
        console.log('oppSubScope--851---' + JSON.stringify(this.opptyWithOlis));
    }

    handleViewStandard(event) {
        const rowRecordId = event.target.dataset.id;
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                recordId: rowRecordId,
                objectApiName: 'Standard_Covered__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, "_blank");
        });
    }

    handleDeleteStandard(event) {
        this.recordIdtoDel = event.target.dataset.id;
        const rowIndex = event.target.dataset.element;
        const rowIndex2 = event.target.dataset.index;
        if (this.recordIdtoDel != undefined) {
            this.handleAlertMessage();
        }
        else {
            var tempList = JSON.parse(JSON.stringify(this.opptyWithOlis));
            console.log('tempList[rowIndex].Standard_Covered__r--' + JSON.stringify(tempList[rowIndex].Standard_Covered__r));
            tempList[rowIndex].Standard_Covered__r.splice(rowIndex2, 1);
            console.log('tempList[rowIndex].Standard_Covered__r-length-' + JSON.stringify(tempList[rowIndex].Standard_Covered__r.length));
            if (tempList[rowIndex].Standard_Covered__r.length > 0) {
                tempList[rowIndex].HasStandardCovered = true;
            }
            else {
                tempList[rowIndex].HasStandardCovered = false;
            }
            this.opptyWithOlis = tempList;
        }
    }

}