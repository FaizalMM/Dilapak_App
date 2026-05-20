enum StatusPermohonan { baru, diproses, selesai, ditolak }

class Permohonan {
  final String id;
  final String nomorResi;
  final String jenisLayanan;
  final String namaPemohon;
  final DateTime tanggalPengajuan;
  final StatusPermohonan status;
  final List<TrackingStep> trackingSteps;

  const Permohonan({
    required this.id,
    required this.nomorResi,
    required this.jenisLayanan,
    required this.namaPemohon,
    required this.tanggalPengajuan,
    required this.status,
    required this.trackingSteps,
  });
}

class TrackingStep {
  final String title;
  final String? description;
  final DateTime? timestamp;
  final TrackingStepStatus status;

  const TrackingStep({
    required this.title,
    this.description,
    this.timestamp,
    required this.status,
  });
}

enum TrackingStepStatus { selesai, aktif, menunggu }
