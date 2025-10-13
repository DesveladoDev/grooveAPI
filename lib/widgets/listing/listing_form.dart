import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:salas_beats/config/app_constants.dart';
import 'package:salas_beats/models/listing_model.dart';

class ListingForm extends StatefulWidget {

  const ListingForm({
    required this.onSubmit, super.key,
    this.listing,
    this.onCancel,
  });
  final ListingModel? listing;
  final Function(ListingModel) onSubmit;
  final VoidCallback? onCancel;

  @override
  State<ListingForm> createState() => _ListingFormState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ListingModel?>('listing', listing));
    properties.add(ObjectFlagProperty<Function(ListingModel p1)>.has('onSubmit', onSubmit));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onCancel', onCancel));
  }
}

class _ListingFormState extends State<ListingForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  
  String _selectedCategory = 'studio';
  List<String> _selectedAmenities = [];
  List<String> _selectedEquipment = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.listing != null) {
      _populateFields(widget.listing!);
    }
  }

  void _populateFields(ListingModel listing) {
    _titleController.text = listing.title;
    _descriptionController.text = listing.description;
    _priceController.text = listing.hourlyPrice.toString();
    _capacityController.text = listing.capacity.toString();
    _addressController.text = listing.location.address;
    _cityController.text = listing.location.city;
    _stateController.text = listing.location.state ?? '';
    _zipCodeController.text = listing.zipCode ?? '';
    _selectedCategory = listing.category ?? '';
    _selectedAmenities = List.from(listing.amenities);
    _selectedEquipment = List.from(listing.equipment);
  }

  @override
  Widget build(BuildContext context) => Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildCategorySection(),
            const SizedBox(height: 24),
            _buildAmenitiesSection(),
            const SizedBox(height: 24),
            _buildEquipmentSection(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );

  Widget _buildBasicInfoSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Información Básica',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Título del espacio',
            hintText: 'Ej: Estudio de grabación profesional',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El título es requerido';
            }
            if (value.trim().length < 10) {
              return 'El título debe tener al menos 10 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            hintText: 'Describe tu espacio, equipamiento y servicios...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La descripción es requerida';
            }
            if (value.trim().length < 50) {
              return 'La descripción debe tener al menos 50 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio por hora',
                  prefixText: r'$',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El precio es requerido';
                  }
                  final price = double.tryParse(value);
                  if (price == null || price <= 0) {
                    return 'Ingresa un precio válido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(
                  labelText: 'Capacidad',
                  suffixText: 'personas',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La capacidad es requerida';
                  }
                  final capacity = int.tryParse(value);
                  if (capacity == null || capacity <= 0) {
                    return 'Ingresa una capacidad válida';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildLocationSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ubicación',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Dirección',
            hintText: 'Calle y número',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La dirección es requerida';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La ciudad es requerida';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El estado es requerido';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _zipCodeController,
                decoration: const InputDecoration(
                  labelText: 'CP',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El CP es requerido';
                  }
                  if (value.length != 5) {
                    return 'CP inválido';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );

  Widget _buildCategorySection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.spaceCategories.map((category) {
            final isSelected = _selectedCategory == category['id'];
            return FilterChip(
              label: Text(category['name']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category['id']!;
                });
              },
            );
          }).toList(),
        ),
      ],
    );

  Widget _buildAmenitiesSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comodidades',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.amenities.map((amenity) {
            final isSelected = _selectedAmenities.contains(amenity['id']);
            return FilterChip(
              label: Text(amenity['name']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedAmenities.add(amenity['id']!);
                  } else {
                    _selectedAmenities.remove(amenity['id']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );

  Widget _buildEquipmentSection() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipamiento',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.equipment.map((equipment) {
            final isSelected = _selectedEquipment.contains(equipment['id']);
            return FilterChip(
              label: Text(equipment['name']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedEquipment.add(equipment['id']!);
                  } else {
                    _selectedEquipment.remove(equipment['id']);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );

  Widget _buildActionButtons() => Row(
      children: [
          if (widget.onCancel != null) ...[
            Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : widget.onCancel,
              child: const Text('Cancelar'),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.listing != null ? 'Actualizar' : 'Crear'),
          ),
        ),
      ],
    );

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final listing = ListingModel(
        id: widget.listing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        hostId: widget.listing?.hostId ?? 'current_user_id', // TODO: Get from auth
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        hourlyPrice: double.parse(_priceController.text),
        capacity: int.parse(_capacityController.text),
        location: LocationData(
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          postalCode: _zipCodeController.text.trim(),
          lat: widget.listing?.location.lat ?? 0.0,
          lng: widget.listing?.location.lng ?? 0.0,
        ),
        category: _selectedCategory,
        amenities: _selectedAmenities,
        equipment: _selectedEquipment,
        pricePerHour: double.parse(_priceController.text),
        photos: widget.listing?.photos ?? [],
        active: widget.listing?.active ?? true,
        createdAt: widget.listing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        rating: widget.listing?.rating ?? 0.0,
        reviewCount: widget.listing?.reviewCount ?? 0,
      );

      widget.onSubmit(listing);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }
}