import 'package:flutter/material.dart';
import 'notification_service.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  @override
  void initState() {
    super.initState();
    // Fetch setiap kali halaman ini dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.instance.fetchNotifikasi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("Notifikasi"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2F80ED),
        foregroundColor: Colors.white,
        actions: [
          ListenableBuilder(
            listenable: NotificationService.instance,
            builder: (_, __) {
              if (!NotificationService.instance.hasUnread) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () async {
                  await NotificationService.instance.tandaiSemuaDibaca();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Semua notifikasi ditandai sudah dibaca"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Baca Semua",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: NotificationService.instance,
        builder: (context, _) {
          final svc = NotificationService.instance;

          if (svc.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (svc.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(svc.error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: svc.fetchNotifikasi,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Coba Lagi"),
                  ),
                ],
              ),
            );
          }

          if (svc.notifikasi.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("Belum ada notifikasi",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: svc.fetchNotifikasi,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: svc.notifikasi.length,
              itemBuilder: (context, index) {
                return _NotifikasiCard(
                  notif: svc.notifikasi[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotifikasiCard extends StatelessWidget {
  final AppNotification notif;
  const _NotifikasiCard({required this.notif});

  @override
  Widget build(BuildContext context) {
    final isUnread = !notif.sudahDibaca;

    return GestureDetector(
      onTap: () async {
        if (isUnread) {
          await NotificationService.instance.tandaiDibaca(notif.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: isUnread
              ? const Color(0xFFE8F0FE)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? const Color(0xFF2F80ED).withOpacity(0.3)
                : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon tipe
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _getTipeColor(notif.tipe).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getTipeIcon(notif.tipe),
                  color: _getTipeColor(notif.tipe),
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              // Konten
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notif.judul,
                            style: TextStyle(
                              fontWeight: isUnread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2F80ED),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      notif.pesan,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getTipeColor(notif.tipe).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getTipeLabel(notif.tipe),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getTipeColor(notif.tipe),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTanggal(notif.tanggal),
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTipeColor(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'pengaduan':
        return Colors.orange;
      case 'pengajuan':
        return const Color(0xFF2F80ED);
      default:
        return Colors.grey;
    }
  }

  IconData _getTipeIcon(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'pengaduan':
        return Icons.report_outlined;
      case 'pengajuan':
        return Icons.description_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _getTipeLabel(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'pengaduan':
        return 'Pengaduan';
      case 'pengajuan':
        return 'Pengajuan Surat';
      default:
        return tipe;
    }
  }

  String _formatTanggal(String raw) {
    if (raw.isEmpty) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
      if (diff.inHours < 24) return '${diff.inHours} jam lalu';
      if (diff.inDays < 7) return '${diff.inDays} hari lalu';

      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}