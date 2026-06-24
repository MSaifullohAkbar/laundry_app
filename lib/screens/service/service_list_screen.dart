import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../providers/service_provider.dart';
import '../../widgets/common/bottom_action_bar.dart';
import '../../widgets/cards/service_card.dart';
import '../../models/service.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchServices();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Daftar Layanan',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<ServiceProvider>(
            builder: (ctx, prov, _) {
              if (prov.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (prov.services.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Column(
                      children: [
                        Icon(Icons.local_laundry_service,
                            size: 64, color: AppColors.onSurfaceVariant),
                        const SizedBox(height: 16),
                        const Text('Belum ada layanan',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        const Text('Tekan "Tambah Layanan" untuk mulai',
                            style: TextStyle(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                );
              }
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        if (prov.kiloanServices.isNotEmpty)
                          _buildCategory(
                            'Kiloan Reguler',
                            Icons.scale,
                            AppColors.secondaryFixed,
                            prov.kiloanServices,
                            isGrid: true,
                          ),
                        if (prov.kiloanServices.isNotEmpty && prov.satuanServices.isNotEmpty)
                          const SizedBox(height: 24),
                        if (prov.satuanServices.isNotEmpty)
                          _buildCategory(
                            'Satuan Premium',
                            Icons.checkroom,
                            AppColors.tertiaryFixed,
                            prov.satuanServices,
                            isGrid: true,
                          ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomActionBar(
              leftInfo: Consumer<ServiceProvider>(
                builder: (ctx, prov, _) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    'Total: ${prov.services.length} Layanan',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              rightAction: GradientButton(
                label: 'Tambah Layanan',
                icon: Icons.add,
                onPressed: () => context.go('/services/add'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(
    String title,
    IconData icon,
    Color iconBg,
    List<ServiceType> services, {
    bool isGrid = false,
  }) {
    void showActionMenu(BuildContext context, ServiceType service) {
      showModalBottomSheet(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Edit Layanan'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/services/edit/${service.id}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Hapus Layanan', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('Hapus Layanan'),
                      content: Text('Apakah Anda yakin ingin menghapus layanan ${service.name}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dCtx, true),
                          child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    try {
                      await context.read<ServiceProvider>().deleteService(service.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Layanan berhasil dihapus'), backgroundColor: AppColors.secondary),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal menghapus layanan'), backgroundColor: AppColors.error),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.onSurface),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.82,
          ),
          itemCount: services.length,
          itemBuilder: (ctx, i) => ServiceCard(
            service: services[i],
            isGridMode: true,
            onTap: () => showActionMenu(context, services[i]),
            onAdd: () {},
          ),
        ),
      ],
    );
  }
}
