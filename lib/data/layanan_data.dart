class LayananCategory {
  final String name;
  final List<String> items;

  const LayananCategory({required this.name, required this.items});
}

const List<LayananCategory> allLayanan = [
  LayananCategory(
    name: 'KEPENDUDUKAN',
    items: [
      'Penerbitan KTP-el Pindah Datang Bagi WNI Dari Luar Negeri',
      'Penerbitan KTP-el Pindah Datang WNA Dengan ITAP',
      'Penerbitan KTP-el Karena Perpanjangan WNA Dengan ITAP',
      'KTP-el Baru Rekam',
      'KTP-el Pindah Datang',
      'KTP-el Karena Perubahan Data',
      'KTP-el Karena Hilang',
      'KTP-el Karena Rusak',
      'KTP-el Luar Domisili (LD)',
      'KTP-EL Ganti Foto/TTD',
      'KTP-EL SILANDEP',
      'Penerbitan SKPWNI',
      'Penerbitan SKPWNI Keluar + KK',
      'Penerbitan SKPWNI Masuk + KK',
      'Penerbitan SKPWNA',
      'SKTT bagi WNA',
    ],
  ),
  LayananCategory(
    name: 'PENCATATAN SIPIL',
    items: [
      'Penerbitan Akta Perkawinan',
      'Penerbitan Akta Perceraian',
      'Pencatatan Pengangkatan, Pengakuan dan Pengesahan Anak',
      'Pencatatan Perubahan Nama',
      'Penerbitan Kutipan Akta Kelahiran',
      'Penerbitan Kutipan Ke II Akta Kelahiran',
      'Penerbitan Kutipan Akta Kelahiran Karena Hilang',
      'Penerbitan Kutipan Akta Kematian',
      'Penerbitan Kutipan Akta Kematian Karena Hilang/Rusak',
      'Penerbitan Surat Keterangan Lahir Mati WNI',
      'Keabsahan Akta-Akta',
    ],
  ),
  LayananCategory(
    name: 'KARTU KELUARGA & KIA',
    items: [
      'Penerbitan KK',
      'Penerbitan KK Karena Hilang atau Rusak',
      'Penerbitan KK Karena Perubahan Data',
      'KK SILANDEP',
      'KIA (Kartu Identitas Anak) WNI',
      'KIA (Kartu Identitas Anak) WNA',
    ],
  ),
];
