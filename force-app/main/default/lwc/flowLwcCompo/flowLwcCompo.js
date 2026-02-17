import { LightningElement,api,wire,track} from 'lwc';
import getOpps from "@salesforce/apex/AccountProvider.getOpps";
import updateOpportunity from "@salesforce/apex/AccountProvider.updateOpportunity";
import { NavigationMixin } from 'lightning/navigation';
const columns=[
     {
        label: 'Opportunity Name',
        fieldName: 'recordLink',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        }
    },
    {label:'StageName',fieldName:'StageName',type:'text'}

]
export default class FlowLwcCompo extends NavigationMixin(LightningElement) {
     columns=columns;
    @api stageName
    @api accountName

    @track oppData=[];
    @track selectedRow=[];


    @wire(getOpps,{stageName:'$stageName',accId:'$accountName'})
    wireOpps({data,error}){
        if(data){
           this.oppData=data.map(opp=>({
            ...opp,
            recordLink: '/' + opp.Id
           }))

        }
        if(error){
           this.error=error;
        }
    }

    selectedRowsHandler(event){
        this.selectedRow=event.detail.selectedRows.map((row)=>row.Id);
        updateOpportunity({oppIds:this.selectedRow});
    }
}