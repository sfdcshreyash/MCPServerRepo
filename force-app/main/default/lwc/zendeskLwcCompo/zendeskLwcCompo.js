import { LightningElement } from 'lwc';
import zendeskMethod from "@salesforce/apex/ZendeskApexClass.zendeskMethod";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ZendeskLwcCompo extends LightningElement {

    
    bodyValue;
    subjectValue;
    resultValue;

    zendBodyHandler(event){
    this.bodyValue=event.target.value;
    }

    zendSubjectHandler(event){
     this.subjectValue=event.target.value;
    }

    submitHandler(){
        zendeskMethod({'zendBody' : this.bodyValue , 'zendSubject' : this.subjectValue})
        .then((result)=>{
           this.resultValue=result;
           this.error=undefined;
           if(result ==='Success'){
               this.showToast('Success', 'Zendesk ticket created successfully!', 'success');
           }
           else{
            this.showToast('Error', result, 'error');
           }
            
        })
        .catch((error)=>{
            this.error=error;
            this.result=undefined;
            this.showToast('Error', error.body.message, 'error')
        })
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}