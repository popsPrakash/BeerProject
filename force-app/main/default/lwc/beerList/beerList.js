import { LightningElement, track, wire } from 'lwc';
import searchBeer from '@salesforce/apex/BeerController.searchBeer';
import cartIco from '@salesforce/resourceUrl/cart';
import getCartId from '@salesforce/apex/BeerController.getCartId';
export default class BeerList extends LightningElement {

    @track beerRecords;
    @track errros;
    @track cart = cartIco;
    @track cartId;
    @track itemsinCart = 0;


    connectedCallback(){
        this.defaultCartId();
    }

    defaultCartId(){
        getCartId()
        .then(data => {
            console.log('Data',data);
            this.cartId = data;
        })
        .catch(error => {
            this.cartId = undefined;
        });
    }    

    addToCart(event){
        const selectBeerId = event.detail;
        this.itemsinCart = this.itemsinCart + 1;
        console.log(selectBeerId);
    }

    @wire(searchBeer)
        wiredRecords({error, data}){
            console.log(' Data ', data);
            this.beerRecords = data;
            this.errors = error;
        }

    handleEvent(event){
        const eventVal = event.detail;
        console.log(' Search Param ', eventVal);
        searchBeer({
            searchParam : eventVal
        })
        .then(result => {
            console.log(' Beer Records ', result);
            this.beerRecords = result;
            this.errros = undefined;
        })
        .catch(error => {
            console.log(' Errors ', error);
            this.errors = error;
            this.beerRecords = undefined;
        })
    }
}