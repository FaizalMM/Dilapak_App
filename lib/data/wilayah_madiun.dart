class WilayahMadiun {
  WilayahMadiun._();

  static const List<String> kecamatan = [
    'Kecamatan Manguharjo',
    'Kecamatan Taman',
    'Kecamatan Kartoharjo',
  ];

  static const Map<String, List<String>> kelurahan = {
    'Kecamatan Manguharjo': [
      'Kelurahan Manguharjo',
      'Kelurahan Patihan',
      'Kelurahan Nambangan Lor',
      'Kelurahan Nambangan Kidul',
      'Kelurahan Ngegong',
      'Kelurahan Winongo',
      'Kelurahan Mojorejo',
    ],
    'Kecamatan Taman': [
      'Kelurahan Taman',
      'Kelurahan Kejuron',
      'Kelurahan Josenan',
      'Kelurahan Banjarejo',
      'Kelurahan Kuncen',
      'Kelurahan Pilangbango',
      'Kelurahan Pandean',
      'Kelurahan Manisrejo',
    ],
    'Kecamatan Kartoharjo': [
      'Kelurahan Kartoharjo',
      'Kelurahan Klegen',
      'Kelurahan Kanigoro',
      'Kelurahan Demangan',
      'Kelurahan Rejomulyo',
      'Kelurahan Sukosari',
      'Kelurahan Oro-oro Ombo',
    ],
  };

  static List<String> getKelurahan(String kecamatanNama) {
    return kelurahan[kecamatanNama] ?? [];
  }
}
