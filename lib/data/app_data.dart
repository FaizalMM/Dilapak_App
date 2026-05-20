import '../models/permohonan_model.dart';
import '../models/notifikasi_model.dart';

class AppData {
  AppData._();

  static List<Permohonan> get daftarPermohonan => [
        Permohonan(
          id: '1',
          nomorResi: 'RESI-20231025-001',
          jenisLayanan: 'Penerbitan KTP-el Baru',
          namaPemohon: 'Budi Santoso',
          tanggalPengajuan: DateTime(2023, 10, 25, 9, 30),
          status: StatusPermohonan.baru,
          trackingSteps: [
            TrackingStep(
              title: 'Permohonan Diterima',
              description: 'Permohonan telah diterima oleh sistem',
              timestamp: DateTime(2023, 10, 25, 9, 30),
              status: TrackingStepStatus.selesai,
            ),
            const TrackingStep(
              title: 'Verifikasi Dokumen',
              description: 'Menunggu verifikasi dokumen oleh petugas',
              status: TrackingStepStatus.aktif,
            ),
            const TrackingStep(
              title: 'Proses Pencetakan',
              description: 'KTP-el sedang dalam proses pencetakan',
              status: TrackingStepStatus.menunggu,
            ),
            const TrackingStep(
              title: 'Selesai',
              description: 'KTP-el siap diambil',
              status: TrackingStepStatus.menunggu,
            ),
          ],
        ),
        Permohonan(
          id: '2',
          nomorResi: 'RESI-20231024-042',
          jenisLayanan: 'Pembaruan Kartu Keluarga',
          namaPemohon: 'Siti Aminah',
          tanggalPengajuan: DateTime(2023, 10, 24, 14, 15),
          status: StatusPermohonan.diproses,
          trackingSteps: [
            TrackingStep(
              title: 'Permohonan Diterima',
              description: 'Permohonan telah diterima oleh sistem',
              timestamp: DateTime(2023, 10, 24, 14, 15),
              status: TrackingStepStatus.selesai,
            ),
            TrackingStep(
              title: 'Verifikasi Dokumen',
              description: 'Dokumen sedang diverifikasi',
              timestamp: DateTime(2023, 10, 25, 8, 0),
              status: TrackingStepStatus.selesai,
            ),
            TrackingStep(
              title: 'Proses Pembaruan',
              description: 'Data Kartu Keluarga sedang diperbarui',
              timestamp: DateTime(2023, 10, 25, 10, 30),
              status: TrackingStepStatus.aktif,
            ),
            const TrackingStep(
              title: 'Selesai',
              description: 'Kartu Keluarga siap diambil',
              status: TrackingStepStatus.menunggu,
            ),
          ],
        ),
        Permohonan(
          id: '3',
          nomorResi: 'RESI-20231020-089',
          jenisLayanan: 'Pembuatan KIA (Kartu Identitas Anak)',
          namaPemohon: 'Ahmad Dhani (Anak)',
          tanggalPengajuan: DateTime(2023, 10, 20, 10, 0),
          status: StatusPermohonan.selesai,
          trackingSteps: [
            TrackingStep(
              title: 'Permohonan Diterima',
              description: 'Permohonan telah diterima oleh sistem',
              timestamp: DateTime(2023, 10, 20, 10, 0),
              status: TrackingStepStatus.selesai,
            ),
            TrackingStep(
              title: 'Verifikasi Dokumen',
              description: 'Dokumen telah diverifikasi',
              timestamp: DateTime(2023, 10, 21, 9, 0),
              status: TrackingStepStatus.selesai,
            ),
            TrackingStep(
              title: 'Proses Pencetakan',
              description: 'KIA telah dicetak',
              timestamp: DateTime(2023, 10, 22, 14, 0),
              status: TrackingStepStatus.selesai,
            ),
            TrackingStep(
              title: 'Selesai',
              description: 'KIA sudah diambil oleh pemohon',
              timestamp: DateTime(2023, 10, 23, 11, 0),
              status: TrackingStepStatus.selesai,
            ),
          ],
        ),
        Permohonan(
          id: '4',
          nomorResi: 'RESI-20231018-112',
          jenisLayanan: 'Surat Keterangan Pindah WNI',
          namaPemohon: 'Joko Susilo',
          tanggalPengajuan: DateTime(2023, 10, 18, 15, 45),
          status: StatusPermohonan.ditolak,
          trackingSteps: [
            TrackingStep(
              title: 'Permohonan Diterima',
              description: 'Permohonan telah diterima oleh sistem',
              timestamp: DateTime(2023, 10, 18, 15, 45),
              status: TrackingStepStatus.selesai,
            ),
            TrackingStep(
              title: 'Verifikasi Dokumen',
              description: 'Dokumen tidak memenuhi persyaratan',
              timestamp: DateTime(2023, 10, 19, 10, 0),
              status: TrackingStepStatus.selesai,
            ),
            TrackingStep(
              title: 'Ditolak',
              description:
                  'Permohonan ditolak karena dokumen tidak lengkap. Silakan ajukan ulang.',
              timestamp: DateTime(2023, 10, 19, 11, 0),
              status: TrackingStepStatus.aktif,
            ),
          ],
        ),
        Permohonan(
          id: '5',
          nomorResi: 'RESI-20231015-056',
          jenisLayanan: 'Akta Kelahiran',
          namaPemohon: 'Budi Santoso',
          tanggalPengajuan: DateTime(2023, 10, 15, 8, 30),
          status: StatusPermohonan.selesai,
          trackingSteps: [
            TrackingStep(
              title: 'Permohonan Diterima',
              timestamp: DateTime(2023, 10, 15, 8, 30),
              status: TrackingStepStatus.selesai,
            ),
            TrackingStep(
              title: 'Verifikasi Dokumen',
              timestamp: DateTime(2023, 10, 16, 9, 0),
              status: TrackingStepStatus.selesai,
            ),
            TrackingStep(
              title: 'Proses Pencetakan',
              timestamp: DateTime(2023, 10, 17, 14, 0),
              status: TrackingStepStatus.selesai,
            ),
            TrackingStep(
              title: 'Selesai',
              timestamp: DateTime(2023, 10, 18, 10, 0),
              status: TrackingStepStatus.selesai,
            ),
          ],
        ),
        Permohonan(
          id: '6',
          nomorResi: 'RESI-20231012-033',
          jenisLayanan: 'Surat Keterangan Domisili',
          namaPemohon: 'Siti Aminah',
          tanggalPengajuan: DateTime(2023, 10, 12, 13, 0),
          status: StatusPermohonan.diproses,
          trackingSteps: [
            TrackingStep(
              title: 'Permohonan Diterima',
              timestamp: DateTime(2023, 10, 12, 13, 0),
              status: TrackingStepStatus.selesai,
            ),
            TrackingStep(
              title: 'Verifikasi Dokumen',
              timestamp: DateTime(2023, 10, 13, 9, 0),
              status: TrackingStepStatus.aktif,
            ),
            const TrackingStep(
              title: 'Penerbitan Surat',
              status: TrackingStepStatus.menunggu,
            ),
            const TrackingStep(
              title: 'Selesai',
              status: TrackingStepStatus.menunggu,
            ),
          ],
        ),
      ];

  static List<Notifikasi> get daftarNotifikasi => [
        const Notifikasi(
          id: '1',
          type: NotifikasiType.statusUpdate,
          judul: 'Status Permohonan Diperbarui',
          isi:
              'Permohonan KTP-el Anda (Nomor: KTP-2023-089) telah selesai diproses dan siap diambil.',
          waktu: 'Baru saja',
          isNew: true,
        ),
        const Notifikasi(
          id: '2',
          type: NotifikasiType.infoLayanan,
          judul: 'Informasi Layanan Publik',
          isi:
              'Layanan administrasi kependudukan akan mengalami pemeliharaan sistem pada Sabtu, 28 Okt 2023.',
          waktu: '2 Jam yang lalu',
          isNew: true,
        ),
        const Notifikasi(
          id: '3',
          type: NotifikasiType.dokumenTidakLengkap,
          judul: 'Dokumen Tidak Lengkap',
          isi:
              'Mohon maaf, permohonan Kartu Keluarga Anda tertunda. Harap unggah dokumen yang diperlukan.',
          waktu: 'Kemarin',
          isNew: false,
        ),
        const Notifikasi(
          id: '4',
          type: NotifikasiType.permohonanDiterima,
          judul: 'Permohonan Diterima',
          isi:
              'Permohonan Akta Kelahiran atas nama Budi Santoso telah kami terima dan sedang diproses.',
          waktu: '20 Nov 2023',
          isNew: false,
        ),
      ];
}
