import { LightningElement,track } from 'lwc';
import getAccounts from "@salesforce/apex/AccountProvider.getAccounts";
const columns=[
    {label:'Account Name',fieldName:'Name'},
    {label:'Account Type',fieldName:'Type'},
    {label:'Rating',fieldName:'Rating'}
]
export default class TestLwcCompo extends LightningElement {
columns = columns;
    @track accData = [];
    @track accName;
    isData = false;
    errorMessageReply = false;
    errorMessage;
    error = 'Please fill the search input';

    accNameHandler(event) {
        this.accName = event.target.value;
        this.errorMessageReply = false; // hide error once user types
    }

    clickHandler() {
        // Check for null/empty input
        if (!this.accName || this.accName.trim() === '') {
            this.errorMessageReply = true;
            this.isData = false;
            this.accData = [];
            return;
        }

        // Call Apex only if input is valid
        getAccounts({ 'accName': this.accName })
            .then((result) => {
                this.accData = result;
                this.isData = true;
                this.errorMessageReply = false;
            })
            .catch((error) => {
                this.error = error.body.message;
                this.errorMessageReply = true;
                this.accData = [];
                this.isData = false;
            });
    }
}