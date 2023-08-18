import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CloseActionScreenEvent } from "lightning/actions";

export default class AddChildOpportunityParent extends NavigationMixin(LightningElement) {
    @api recordId;

    @api invoke() {
        console.log('This.recordId>>>>>>>>> ' + this.recordId);
        var compDefinition = {
            componentDef: "c:addChildOpportunityLWC",
            attributes: {
                recordId: this.recordId
            }
        };
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        console.log('encodedCompDef-' + encodedCompDef);
        this.dispatchEvent(new CloseActionScreenEvent());
        window.open('/one/one.app#' + encodedCompDef, '_blank');
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}