class Product {
  String productName;
  String productInfo;
  int price;
  String owner;
  String base64image;
  int quantity;

  Product(this.productName, this.price ,this.productInfo, this.owner, this.base64image,this.quantity);
  String get getProductName => this.productName;
  String get getProductInfo => this.productInfo;
  int  get getPrice => this.price;
  String get getOwner => this.owner;
  String get getImage => this.base64image;
  int get getQuantity => this.quantity;
  Map<String, dynamic> toMap() {
    return {
      "productName": productName,
      "productInfo": productInfo,
      "price": price,
      "owner": owner,
      "base64image": base64image,
      "quantity": quantity,
    };}
}