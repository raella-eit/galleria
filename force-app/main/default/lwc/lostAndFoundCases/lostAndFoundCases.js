import { LightningElement,wire,track } from 'lwc';
import getLostAndFoundCases from '@salesforce/apex/lostAndFoundCasesController.getLostAndFoundCases';
import { NavigationMixin } from 'lightning/navigation';



export default class LostAndFoundCases extends NavigationMixin(LightningElement)

{   
    @track data;
    @track counter = 10;
    @track searchingAndWaiting = true;
    @wire(getLostAndFoundCases, {
        limitSize: 10
    })
    mydata(result) {
        
         if (result.data) {
             this.data=result.data;
             this.searchingAndWaiting = false;
           
         } else if (result.error) {
            this.searchingAndWaiting = false;
             console.log(result.error)
         }
         
     }

     handleCaseView(event){
        let id = event.currentTarget.dataset.item;
        console.log('id',id);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
                     attributes: {
                         pageName: 'lost-and-found-record-detail'

                     },
                    state: {
                        recordId: id
                     }
        });
        
     }

     
     loadMore(){  
        this.counter += 10;    
         
        getLostAndFoundCases({ limitSize: this.counter }).then(result=> {
            if (result) {
                console.log(result);
                this.data=result;
                this.searchingAndWaiting = false;  
              
            } 
        }).catch(error => {
            this.searchingAndWaiting = false;

            console.log('error',error)

        });
     }     

}