import 'package:client_service/models/instalacion.dart';
import 'package:client_service/utils/colors.dart';
import 'package:client_service/view/widgets/shared/apptitle.dart';
import 'package:client_service/view/widgets/shared/button.dart';
import 'package:client_service/view/widgets/shared/search_with_filter.dart';
import 'package:client_service/view/widgets/shared/toolbar.dart';
import 'package:client_service/view/widgets/date_filter_modal.dart';
import 'package:client_service/viewmodel/instalacion_viewmodel.dart';
import 'package:client_service/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client_service/view/service/installation/edit_installation.dart';

class ReportInstalacion extends StatefulWidget {
  const ReportInstalacion({super.key});

  @override
  State<ReportInstalacion> createState() => _ReportInstalacionState();
}

class _ReportInstalacionState extends State<ReportInstalacion> {
  late final InstalacionViewModel viewModel;
  DateRangeFilter? _currentFilter;

  @override
  void initState() {
    super.initState();
    viewModel = sl<InstalacionViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundColor,
        ),
        child: Column(
          children: [
            const Apptitle(title: 'Reporte de Instalaciones', isVisible: true),
            SearchWithFilter(
              filterText: _currentFilter?.toString(),
              onFilterPressed: _showDateFilterModal,
              onClearFilter: _clearFilter,
              hasActiveFilter: _currentFilter?.hasFilter == true,
            ),
            Expanded(
              child: FutureBuilder<List<Instalacion>>(
                future: _currentFilter?.hasFilter == true
                    ? viewModel.obtenerInstalacionesFiltradas(
                        startDate: _currentFilter!.startDate,
                        endDate: _currentFilter!.endDate,
                      )
                    : viewModel.obtenerInstalaciones(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay clientes'));
                  } else {
                    final instalaciones = snapshot.data!;
                    return ListView.builder(
                      itemCount: instalaciones.length,
                      itemBuilder: (context, index) {
                        final instalacion = instalaciones[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: const BoxDecoration(
                            color: AppColors.whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(instalacion.numeroTarea),
                                Text(instalacion.nombreComercial),
                                Text(DateFormat('yyyy-MM-dd')
                                    .format(instalacion.fechaInstalacion)),
                                Text(instalacion.direccion),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              color: AppColors.whiteColor,
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) async {
                                if (value == 'editar') {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditInstallation(
                                          instalacion: instalacion),
                                    ),
                                  );
                                  if (result == true) {
                                    setState(() {});
                                  }
                                } else if (value == 'eliminar') {
                                  await viewModel
                                      .eliminarInstalacion(instalacion.id!);
                                  setState(() {});
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'editar',
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Editar'),
                                      Icon(
                                        Icons.edit,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'eliminar',
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Eliminar'),
                                      Icon(
                                        Icons.delete,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: BtnFloating(
        onPressed: () {
          if (_currentFilter?.hasFilter == true) {
            viewModel.exportarInstalacionesFiltradas(
              startDate: _currentFilter!.startDate,
              endDate: _currentFilter!.endDate,
            );
          } else {
            viewModel.exportarInstalaciones();
          }
        },
        icon: Icons.download_rounded,
        text: 'Descargar',
      ),
      bottomNavigationBar: const Toolbar(),
    );
  }

  Future<void> _showDateFilterModal() async {
    final filter = await DateFilterModal.show(
      context: context,
      initialFilter: _currentFilter,
      title: 'Filtrar instalación',
    );

    if (filter != null) {
      setState(() {
        _currentFilter = filter;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _currentFilter = null;
    });
  }
}
