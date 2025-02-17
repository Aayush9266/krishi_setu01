class Product {
  String productName;
  String productInfo;
  int price;
  String owner;
  String base64image;
  int initialQuantity;
  int quantity;

  Product(
      this.productName,
      this.price,
      this.initialQuantity,
      this.productInfo,
      this.owner,
      this.base64image,
      this.quantity,
      );

  String get getProductName => this.productName;
  String get getProductInfo => this.productInfo;
  int get getPrice => this.price;
  String get getOwner => this.owner;
  String get getImage => this.base64image;
  int get getQuantity => this.quantity;
  int get getInitialQuantity => this.initialQuantity;

  // Method to update the product with the new added quantity
  void addQuantity(int addedQuantity) {
    // Update the initial quantity to reflect the total stock
    initialQuantity += addedQuantity;

    // Update the available quantity
    quantity += addedQuantity;
  }

  Map<String, dynamic> toMap() {
    return {
      "productName": productName,
      "productInfo": productInfo,
      "price": price,
      "owner": owner,
      "base64image": base64image,
      "quantity": quantity,
      "initialQuantity": initialQuantity,
    };
  }
}
