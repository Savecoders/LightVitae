import 'package:client_service/repositories/cliente_repository.dart';
import 'package:client_service/models/cliente.dart';
import 'package:client_service/models/vehiculo.dart';
import 'package:client_service/models/empleado.dart';
import 'package:client_service/utils/colors.dart';
import 'package:client_service/utils/font.dart';
import 'package:client_service/view/widgets/shared/button.dart';
import 'package:client_service/viewmodel/vehiculo_viewmodel.dart';
import 'package:client_service/viewmodel/empleado_viewmodel.dart';
import 'package:client_service/services/service_locator.dart';
import 'package:client_service/view/widgets/flash_messages.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditVehicle extends StatefulWidget {
  final Alquiler vehiculo;

  const EditVehicle({super.key, required this.vehiculo});

  @override
  State<EditVehicle> createState() => _EditVehicleState();
}

class _EditVehicleState extends State<EditVehicle> {
  void _sanearTipoVehiculo() {
    // Eliminar duplicados y asegurar que el valor seleccionado sea válido
    tiposVehiculo = tiposVehiculo.toSet().toList();
    if (selectTipoVehiculo != null &&
        !tiposVehiculo.contains(selectTipoVehiculo)) {
      selectTipoVehiculo = null;
    }
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreComercial = TextEditingController();
  final TextEditingController _direccion = TextEditingController();
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _correo = TextEditingController();
  final TextEditingController _montoAlquiler = TextEditingController();
  final TextEditingController _fechaReserva = TextEditingController();
  final TextEditingController _fechaTrabajo = TextEditingController();

  String? selectTipoVehiculo;
  List<String> tiposVehiculo = [
    'Automóvil',
    'Vehículo pesado',
    'Grua',
    'Vehículo grande',
  ];

  String? selectPersonalAsistio;
  List<Empleado> empleados = [];

  final AlquilerViewModel _alquilerViewModel = sl<AlquilerViewModel>();
  final EmpleadoViewmodel _empleadoViewModel = sl<EmpleadoViewmodel>();

  @override
  void initState() {
    super.initState();
    _loadVehicleData();
    _loadEmpleados();
  }

  void _loadEmpleados() async {
    empleados = await _empleadoViewModel.obtenerEmpleados();
    setState(() {});
  }

  void _loadVehicleData() {
    _nombreComercial.text = widget.vehiculo.nombreComercial;
    _direccion.text = widget.vehiculo.direccion;
    _telefono.text = widget.vehiculo.telefono;
    _correo.text = widget.vehiculo.correo;
    _montoAlquiler.text = widget.vehiculo.montoAlquiler.toString();
    _fechaReserva.text =
        DateFormat('dd/MM/yyyy').format(widget.vehiculo.fechaReserva);
    _fechaTrabajo.text =
        DateFormat('dd/MM/yyyy').format(widget.vehiculo.fechaTrabajo);
    selectTipoVehiculo = widget.vehiculo.tipoVehiculo;
    selectPersonalAsistio = widget.vehiculo.personalAsistio;
    // Si personalAsistio no está en la lista de empleados (por cédula), ponerlo en null
    if (!empleados.any((e) => e.cedula == selectPersonalAsistio)) {
      selectPersonalAsistio = null;
    }
  }

  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      setState(() {
        controller.text = formattedDate;
      });
    }
  }

  void _updateVehicle() async {
    if (_nombreComercial.text.isEmpty ||
        _direccion.text.isEmpty ||
        _telefono.text.isEmpty ||
        _correo.text.isEmpty ||
        _montoAlquiler.text.isEmpty ||
        selectPersonalAsistio == null ||
        _fechaReserva.text.isEmpty ||
        _fechaTrabajo.text.isEmpty ||
        selectTipoVehiculo == null) {
      FlashMessages.showWarning(
        context: context,
        message: 'Por favor complete todos los campos',
      );
      return;
    }

    try {
      final updatedVehicle = Alquiler(
        id: widget.vehiculo.id,
        nombreComercial: _nombreComercial.text.trim(),
        direccion: _direccion.text.trim(),
        telefono: _telefono.text.trim(),
        correo: _correo.text.trim(),
        tipoVehiculo: selectTipoVehiculo!,
        fechaReserva: DateFormat('dd/MM/yyyy').parse(_fechaReserva.text),
        fechaTrabajo: DateFormat('dd/MM/yyyy').parse(_fechaTrabajo.text),
        montoAlquiler: double.tryParse(_montoAlquiler.text.trim()) ?? 0,
        personalAsistio: selectPersonalAsistio!,
      );

      await _alquilerViewModel.actualizarAlquiler(updatedVehicle);

      FlashMessages.showSuccess(
        context: context,
        message: 'Vehículo actualizado exitosamente',
      );

      Navigator.pop(context);
    } catch (e) {
      FlashMessages.showError(
        context: context,
        message: 'Error al actualizar el vehículo: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _sanearTipoVehiculo();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Editar Vehículo'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Editar Información de Vehículo',
                      style: AppFonts.titleBold.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildForm(),
                    const SizedBox(height: 30),
                    BtnElevated(
                      text: 'Actualizar Vehículo',
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updateVehicle();
                        }
                      },
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

  Widget _buildForm() {
    return Column(
      children: [
        _buildTextField(
          'Nombre Comercial',
          _nombreComercial,
          'Ingrese el nombre comercial',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre comercial es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildTextField(
          'Dirección',
          _direccion,
          'Ingrese la dirección',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La dirección es obligatoria';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildTextField(
          'Teléfono',
          _telefono,
          'Ingrese el teléfono',
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El teléfono es obligatorio';
            }
            final phoneReg = RegExp(r'^[0-9+\-]{7,15}$');
            if (!phoneReg.hasMatch(value.trim())) {
              return 'Teléfono inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildTextField(
          'Correo',
          _correo,
          'Ingrese el correo electrónico',
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El correo es obligatorio';
            }
            final emailReg = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailReg.hasMatch(value.trim())) {
              return 'Correo inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildDropdown(
          'Tipo de Vehículo',
          selectTipoVehiculo,
          tiposVehiculo,
          (value) {
            setState(() {
              selectTipoVehiculo = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Seleccione un tipo de vehículo';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () =>
              _selectDate(context, _fechaReserva, widget.vehiculo.fechaReserva),
          child: AbsorbPointer(
            child: _buildTextField(
              'Fecha de Reserva',
              _fechaReserva,
              'Seleccione la fecha de reserva',
              readOnly: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La fecha de reserva es obligatoria';
                }
                return null;
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () =>
              _selectDate(context, _fechaTrabajo, widget.vehiculo.fechaTrabajo),
          child: AbsorbPointer(
            child: _buildTextField(
              'Fecha de Trabajo',
              _fechaTrabajo,
              'Seleccione la fecha de trabajo',
              readOnly: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La fecha de trabajo es obligatoria';
                }
                return null;
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        _buildTextField(
          'Monto de Alquiler',
          _montoAlquiler,
          'Ingrese el monto',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El monto es obligatorio';
            }
            if (double.tryParse(value.trim()) == null) {
              return 'Monto inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 15),
        _buildEmployeeDropdown(
          'Personal que Asistió',
          selectPersonalAsistio,
          empleados,
          (value) {
            setState(() {
              selectPersonalAsistio = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Seleccione el personal que asistió';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    bool readOnly = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.bodyNormal.copyWith(
            color: AppColors.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColors.greyColor.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColors.greyColor.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.bodyNormal.copyWith(
            color: AppColors.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColors.greyColor.withOpacity(0.3)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
          hint: Text(
            'Seleccione $label',
            style: AppFonts.text.copyWith(
              color: AppColors.greyColor,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: AppFonts.text.copyWith(
                  color: AppColors.textColor,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildEmployeeDropdown(
    String label,
    String? value,
    List<Empleado> employees,
    ValueChanged<String?> onChanged, {
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.bodyNormal.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  BorderSide(color: AppColors.greyColor.withOpacity(0.3)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
          hint: Text(
            'Seleccione $label',
            style: AppFonts.text.copyWith(
              color: AppColors.greyColor,
            ),
          ),
          items: employees.map((Empleado empleado) {
            return DropdownMenuItem<String>(
              value: empleado.cedula,
              child: Text(empleado.nombreCompletoConCargo),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
