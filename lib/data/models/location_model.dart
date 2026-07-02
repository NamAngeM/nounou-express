class LocationModel {
  final double latitude, longitude;
  final String address, quartier, ville;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.quartier,
    required this.ville,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
    'quartier': quartier,
    'ville': ville,
  };

  /// Désérialisation robuste : champs manquants → valeurs par défaut.
  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
    address: json['address'] as String? ?? '',
    quartier: json['quartier'] as String? ?? '',
    ville: json['ville'] as String? ?? '',
  );
}
