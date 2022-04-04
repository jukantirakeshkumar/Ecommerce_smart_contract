//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.5.0 <0.9.0;

contract Ecommerce{

    struct Product{
        string title;
        string description;
        uint productId;
        uint price;
        address buyer;
        address payable seller;
        bool delivered;
    }

    Product[] public products;
    uint counter=1;

    address payable public manager;      
    constructor(){
        manager=payable(msg.sender);
    }

    bool destroyed=false;

    modifier isNotDestroyed{
        require(!destroyed,"contract does not exist");
        _;
    }

    event registered(string titile,uint productId,address seller);
    event bought(uint productId,address buyer);
    event delivered(uint productId);

    function registerProduct(string memory _title,string memory _description,uint _price) public isNotDestroyed{
        require(_price>0,"Price should be greater than zero");
        Product memory tempProduct;
        tempProduct.title=_title;
        tempProduct.description=_description;
        tempProduct.price=_price*10**18;
        tempProduct.seller=payable(msg.sender);
        tempProduct.productId=counter;
        products.push(tempProduct);
        counter++;
        emit registered(_title,tempProduct.productId,msg.sender);
    } 

    function buy(uint _productId) payable public isNotDestroyed{
        require(products[_productId-1].price==msg.value,"Please Pay the exact price");
        require(products[_productId-1].seller!=msg.sender,"Seller cannot be the buyer");
        products[_productId-1].buyer=msg.sender;
        emit bought(_productId,msg.sender);
    }

    function delivery(uint _productId) public {
        require(products[_productId-1].buyer==msg.sender,"Only buyer can confirm");
        products[_productId-1].delivered=true;
        products[_productId-1].seller.transfer(products[_productId-1].price);
        emit delivered(_productId);
    }

    // function destroy() public{
    //     require(msg.sender==manager,"Only manager can call this function");
    //     selfdestruct(manager);
    // }
    
    function destroy() public isNotDestroyed{
        require(manager == msg.sender);
        manager.transfer(address(this).balance);
        destroyed=true;
    }

    fallback() payable external{
        payable(msg.sender).transfer(msg.value);
    }
}
