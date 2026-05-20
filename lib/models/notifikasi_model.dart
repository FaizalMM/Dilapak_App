enum NotifikasiType {
  statusUpdate,
  infoLayanan,
  dokumenTidakLengkap,
  permohonanDiterima
}

class Notifikasi {
  final String id;
  final NotifikasiType type;
  final String judul;
  final String isi;
  final String waktu;
  final bool isNew;

  const Notifikasi({
    required this.id,
    required this.type,
    required this.judul,
    required this.isi,
    required this.waktu,
    required this.isNew,
  });
}
