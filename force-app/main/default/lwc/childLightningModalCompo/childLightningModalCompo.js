import { LightningElement,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';

const columns=[
    {label:'Contact Name',fieldName:'Name'},
    {label:'Contact Email',fieldName:'Email'},
    {label:'Contact Phone',fieldName:'Phone'},
]
export default class ChildLightningModalCompo extends LightningElement {
    @api recievedData;
    @api closedRecieved;
    columns=columns;

    handleCancel(){
        //this.dispatchEvent(new CloseActionScreenEvent());
        // this.closedRecieved;
        // if(this.closedRecieved && typeof this.closedRecieved === 'function'){
        //     this.dispatchEvent(new CloseActionScreenEvent());
        // }
        // console.log('closedRecieved ::'+this.closedRecieved);
        //this.close();

        const evt = this.dispatchEvent(new CustomEvent('cls',{detail:false}));
    }

    handlePreviousBotton(){
        const evt1=this.dispatchEvent(new CustomEvent('previous',{detail:'PreviousButton'}));
    }
}