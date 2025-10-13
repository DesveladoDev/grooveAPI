import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/providers/listing_provider.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Form data
  String _title = '';
  String _description = '';
  String _category = '';
  double _pricePerHour = 0;
  String _location = '';
  final List<String> _amenities = [];
  final List<String> _images = [];
  final Map<String, bool> _availability = {};

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Crear Listado'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveListing,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingWidget()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBasicInfoSection(),
                  const SizedBox(height: 24),
                  _buildLocationSection(),
                  const SizedBox(height: 24),
                  _buildPricingSection(),
                  const SizedBox(height: 24),
                  _buildAmenitiesSection(),
                  const SizedBox(height: 24),
                  _buildImagesSection(),
                  const SizedBox(height: 24),
                  _buildAvailabilitySection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );

  Widget _buildBasicInfoSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Básica',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Título del listado',
                hintText: 'Ej: Estudio de grabación profesional',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El título es requerido';
                }
                return null;
              },
              onSaved: (value) => _title = value!,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Categoría',
              ),
              items: const [
                DropdownMenuItem(value: 'studio', child: Text('Estudio de grabación')),
                DropdownMenuItem(value: 'rehearsal', child: Text('Sala de ensayo')),
                DropdownMenuItem(value: 'live', child: Text('Espacio para conciertos')),
                DropdownMenuItem(value: 'equipment', child: Text('Equipamiento')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La categoría es requerida';
                }
                return null;
              },
              onChanged: (value) => _category = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe tu espacio musical...',
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La descripción es requerida';
                }
                return null;
              },
              onSaved: (value) => _description = value!,
            ),
          ],
        ),
      ),
    );

  Widget _buildLocationSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubicación',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Dirección',
                hintText: 'Calle, número, ciudad',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La ubicación es requerida';
                }
                return null;
              },
              onSaved: (value) => _location = value!,
            ),
          ],
        ),
      ),
    );

  Widget _buildPricingSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Precio',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Precio por hora',
                hintText: '0.00',
                prefixText: r'$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'El precio es requerido';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Ingresa un precio válido';
                }
                return null;
              },
              onSaved: (value) => _pricePerHour = double.parse(value!),
            ),
          ],
        ),
      ),
    );

  Widget _buildAmenitiesSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comodidades',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text('Selecciona las comodidades disponibles:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                'Aire acondicionado',
                'WiFi',
                'Estacionamiento',
                'Instrumentos incluidos',
                'Ingeniero de sonido',
                'Mezcla incluida',
              ].map((amenity) => FilterChip(
                  label: Text(amenity),
                  selected: _amenities.contains(amenity),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _amenities.add(amenity);
                      } else {
                        _amenities.remove(amenity);
                      }
                    });
                  },
                ),).toList(),
            ),
          ],
        ),
      ),
    );

  Widget _buildImagesSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Imágenes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Agregar imágenes'),
            ),
            if (_images.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(_images[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

  Widget _buildAvailabilitySection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Disponibilidad',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text('Configura tu disponibilidad por defecto:'),
            const SizedBox(height: 8),
            ...[
              'Lunes',
              'Martes',
              'Miércoles',
              'Jueves',
              'Viernes',
              'Sábado',
              'Domingo',
            ].map((day) => CheckboxListTile(
                title: Text(day),
                value: _availability[day] ?? false,
                onChanged: (value) {
                  setState(() {
                    _availability[day] = value ?? false;
                  });
                },
              ),),
          ],
        ),
      ),
    );

  void _addImages() {
    // TODO: Implementar selección de imágenes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de imágenes en desarrollo'),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final listing = ListingModel(
        id: '',
        title: _title,
        description: _description,
        category: _category,
        pricePerHour: _pricePerHour,
        hourlyPrice: _pricePerHour, // Same as pricePerHour
        capacity: 1, // Default capacity
        location: LocationData(
          lat: 0,
          lng: 0,
          address: 'Dirección por defecto',
          city: 'Ciudad',
        ), // Default LocationData
        amenities: _amenities,
        // images: _images, // Parameter not available
        // availability: _availability, // Parameter not available
        hostId: '', // Se asignará en el provider
        // isActive: true, // Parameter not available
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await context.read<ListingProvider>().createListing(listing);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listado creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear el listado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}