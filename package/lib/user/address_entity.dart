class AddressEntity {
  String? city;
  String? street;
  String? state;
  String? postalCode;
  String? country;

  AddressEntity(
      {this.city, this.street, this.state, this.postalCode, this.country});

  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'street': street,
      'state': state,
      'postalCode': postalCode,
      'country': country
    };
  }

  factory AddressEntity.fromMap(Map<String, dynamic> map) {
    return AddressEntity(
        city: map['city'],
        street: map['street'],
        state: map['state'],
        postalCode: map['postalCode'],
        country: map['country']);
  }
}
