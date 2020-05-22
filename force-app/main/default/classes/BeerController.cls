public with sharing class BeerController {
    public BeerController() {

    }

    @AuraEnabled(cacheable=true)
    public static List<Object> searchBeer(String searchParam){
        String likeParam = '%' +searchParam+ '%';
        String Query = '';
        if (searchParam != null) {
            Query = 'SELECT Id, Name, Alcohol__c, Id__c, Image__c, Price__c, Remaining_Quantity__c, Tags__c, Total_Quantity__c, brewery_Name__c, brewery_id__c, Consumed_Quantity__c FROM Beer__c Where Name Like :likeParam LIMIT 50';
        }else {
            Query = 'SELECT Id, Name, Alcohol__c, Id__c, Image__c, Price__c, Remaining_Quantity__c, Tags__c, Total_Quantity__c, brewery_Name__c, brewery_id__c, Consumed_Quantity__c FROM Beer__c LIMIT 50';
        }

        List<SObject> sObjectList = Database.query(Query);
        return sObjectList;
    }

    public static String generateCardId(){
        String CharList = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_';
        Integer position;
        Integer LengthRequired = 30;
        String Res = '';
        for(Integer i = 0; i <= LengthRequired; i++) {
            position = Integer.valueof(String.valueof(Math.roundToLong(CharList.length()*Math.random()))) -1;
            Res += CharList.substring(position,position+1);
        }
        return Res;
    }

    public static String getCouponInformation(String name){
        Coupon__c couponRec = [Select Id, Name, 
                                Price__c 
                                FROM Coupon__c 
                                Where Expired__c = false
                                AND Name =: name];
        return couponRec.Id;
    }

    @AuraEnabled
    public static string createCartItems(String CartId, String BeerId, Decimal Amount){
        Cart_Item__c item = new Cart_Item__c();
        item.Beer__c = BeerId;
        item.Cart__c = CartId;
        item.Item_Quantity__c = 1;
        item.Item_Amount__c = Amount;
        insert item;
        return item.Id;
    }
    

    @AuraEnabled(cacheable=false)
    public static string getCartId(){
        List<Cart__c> cartInfo = [ Select Id, Name 
                                FROM Cart__c 
                                Where User__c =: UserInfo.getUserId()
                                AND Cart_Status__c = 'Open'
                                AND Is_Active__c = true];
        if (cartInfo != null && cartInfo.size() > 0) {
            return cartInfo.get(0).Id;
        } else { 
            Cart__c defaultCart = new Cart__c();
            String couponId = getCouponInformation('Default');
            defaultCart.Cart_Id__c = generateCardId();
            defaultCart.Cart_Status__c = 'Open';
            defaultCart.Is_Active__c = true;
            defaultCart.Coupon__c = couponId;
            defaultCart.User__c = UserInfo.getUserId();
            insert defaultCart;
            return defaultCart.Id;
        }                        
    }

}