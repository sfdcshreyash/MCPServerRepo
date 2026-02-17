import { LightningElement, wire, track } from 'lwc';
import getTenAccounts from '@salesforce/apex/coderAccountController.getTenAccounts';

const COLUMNS = [
    { label: 'Name', fieldName: 'Name', type: 'text' },
    { label: 'Industry', fieldName: 'Industry', type: 'text' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
    { label: 'Type', fieldName: 'Type', type: 'text' },
    { label: 'Rating', fieldName: 'Rating', type: 'text' }
];

export default class coderAccountList extends LightningElement {
    @track accounts;
    @track error;
    columns = COLUMNS;

    @wire(getTenAccounts)
    wiredAccounts({ data, error }) {
        if (data) {
            this.accounts = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.accounts = undefined;
        }
    }
}