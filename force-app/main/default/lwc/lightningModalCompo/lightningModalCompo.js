import { LightningElement,wire,track } from 'lwc';
import getAccountList from "@salesforce/apex/AccountProvider.getAccountList";
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import getSelectedAccount from "@salesforce/apex/AccountProvider.getSelectedAccount";
import getContactList from "@salesforce/apex/AccountProvider.getContactList";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columns=[
    {label:'Account Name',fieldName:'recordLink',
        type:'url',
        typeAttributes: {
            label: { fieldName: 'accName' },
            target: '_blank'
        } 
    },
    
    {label:'Account Type',fieldName:'accType'},
    {label:'Account Rating',fieldName:'accRating'},
    
];
const selectedColumns=[
    {label:'Account Name',fieldName:'recordLink',
        type:'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        } 
    },
    {label:'Account Type',fieldName:'Type'},
    {label:'Account Rating',fieldName:'Rating'},
    {
        label:'Show Contact',
        type: 'button',
        typeAttributes: {
            label: 'Show Contacts',
            name: 'show_contacts',
            title: 'Click to view contacts',
            variant: 'brand',
            class: 'btn_show_contacts'
        }
    }
]
export default class LightningModalCompo extends NavigationMixin(LightningElement) {
    columns=columns;
    selectedColumns=selectedColumns;
    pageNumber=1;
    pageSize=10;
    isClosed=true;
    accCount;
    totalPage;
    @track selectedAccount=[];
   @track selectedData=[];
   isSelected=false;
   isData=true;
   @track contactList=[];
    @track accList=[];
    isContacts=false;
    errorMessageReply=false;
    errorMessage='';
    isLoading=true;
    title;
    Message;
    variant;
    closeChild=false;


    @wire(getAccountList,{pageNumber:'$pageNumber',pageSize:'$pageSize'})
    wireAcc({data,error}){
        if(data){
            this.isSelected=false;
            this.isLoading=false;
            this.isData=true;
            this.showSuccessToast('Success','Data loaded Successfully','success');
            this.accList=data.map(acc=>({
             ...acc,
             recordLink : '/' + acc.accId
           }))
            this.accCount = data[0].countOfAcc;
           this.totalPage=Math.ceil(this.accCount/this.pageSize)
           console.log('Data ::'+JSON.stringify(this.accList));

        }
           
        if(error){
           this.error=error;
           this.showSuccessToast('Error','Data not loaded','error');
         }
        }
        
    

    handleClose(){
      this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleNext(){
        if(this.pageNumber<this.totalPage){
            this.pageNumber++;
            
        }
    }
    handleFirst(){
        this.pageNumber=1;
        
    }
    handlePrevious(){
        if(this.pageNumber>1){
            this.pageNumber--;
            
            
        }
    }
    handleLast(){
        this.pageNumber=this.totalPage;
        
    }

    selectedAccountHandler(event){
        this.selectedAccount=event.detail.selectedRows.map((row)=>row.accId);
        console.log('selectedAccount ::'+JSON.stringify(this.selectedAccount))
    }

    handleSubmit(){
        if (this.selectedAccount.length ===0) {
            this.errorMessageReply = true;
            console.log('errorMessageReply ::'+this.errorMessageReply);
            this.errorMessage='Need to Select an Accoount and then click on Submit button to see selected account';
            this.isData = true;
            return;
        }
        else{
           
        getSelectedAccount({accIds : this.selectedAccount})
        .then((result)=>{
        this.isSelected=true;
        this.errorMessageReply = false;
        this.showSuccessToast('Success','Account Selected Successfully','success');
        console.log('errorMessageReply ::'+this.errorMessageReply);
        this.isData=false;
        this.selectedData=result.map(acc=>({
             ...acc,
             recordLink : '/' + acc.Id
           }))
        this.error=undefined;
     })
     .catch((error)=>{
        this.error=error;
        this.result=undefined;
     })
        
    }
     
    }

    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        if (actionName === 'show_contacts') {
            this.fetchContacts(row.Id);
        }

    }

    fetchContacts(accountId){ 
     console.log('accountId ::'+accountId);
    getContactList({Idacc : accountId})
    .then((result)=>{
        if(result && result.length>0){
           this.contactList=result;
          this.isContacts=true;
          this.showSuccessToast('Success','Contact Successfully found','success');
          console.log('conList ::'+JSON.stringify(this.contactList));
          this.error=undefined;
        }
         else{
            this.contactList = [];
            this.isContacts = false;
            this.showSuccessToast('No Contacts', 'No contacts found for the selected account.', 'warning');

         }
       
     })

     .catch((error)=>{
        this.error=error;
        this.result=undefined;
     })
    }

    handlePreviousButton(){
         this.isData=true;
         this.showSuccessToast('Success','Data loaded Successfully','success');
         this.isSelected=false;
         
    }

     showSuccessToast(title,Message,variant) {
        const event = new ShowToastEvent({
            title: title,
            message:Message,
            variant:variant,
            mode :'dismissable'
        });
        this.dispatchEvent(event);
    }

    handlerController(event){
         event.detail;
    this.dispatchEvent(new CloseActionScreenEvent());
         console.log('coming from child :'+event.detail);
    }

    previousButtonHandler(event){
      if(event.detail=='PreviousButton'){
        this.isContacts = false;
        this.isSelected=true;
        this.showSuccessToast('Success','Returning to selected account view','success');
        console.log('isSelected ::'+this.isSelected);
      }
   }
}