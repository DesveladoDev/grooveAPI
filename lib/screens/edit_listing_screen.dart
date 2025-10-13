import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:salas_beats/config/routes.dart';
import 'package:salas_beats/models/listing_model.dart';
import 'package:salas_beats/providers/listing_provider.dart';
import 'package:salas_beats/widgets/common/loading_widget.dart';

class EditListingScreen extends StatefulWidget {
  
  const EditListingScreen({
    required this.listingId, super.key,
  });
  final String listingId;

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('listingId', listingId));
  }
}

class _EditListingScreenState extends State<EditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  ListingModel? _listing;
  
  // Form data
  late String _title;
  late String _description;
  late String _category;
  late double _pricePerHour;
  late String _location;
  late List<String> _amenities;
  late List<String> _images;
  late Map<String, bool> _availability;

  @override
  void initState() {
    super.initState();
    _loadListing();
  }

  Future<void> _loadListing() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final listing = await context.read<ListingProvider>().getListingById(widget.listingId);
      if (listing != null) {
        setState(() {
          _listing = listing;
          _title = listing.title;
          _description = listing.description;
          _category = listing.category ?? '';
          _pricePerHour = listing.pricePerHour ?? 0.0;
          // _location = listing.location; // location not available in ListingModel
          _amenities = List.from(listing.amenities);
          // _images = List.from(listing.images); // images not available in ListingModel
          // _availability = Map.from(listing.availability); // availability not available in listing
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar el listado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_listing == null) {
      return const Scaffold(
        body: LoadingWidget(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Listado'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateListing,
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
                  const SizedBox(height: 24),
                  _buildStatusSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

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
              initialValue: _title,
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
              initialValue: _category,
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
              initialValue: _description,
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
              initialValue: _location,
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
              initialValue: _pricePerHour.toString(),
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
            const Text('Configura tu disponibilidad:'),
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

  Widget _buildStatusSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado del Listado',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Listado activo'),
              subtitle: const Text('Los usuarios pueden ver y reservar este espacio'),
              value: _listing?.isActive ?? true,
              onChanged: (value) {
                setState(() {
                  // _listing = _listing?.copyWith(isActive: value); // isActive parameter not available
                });
              },
            ),
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

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedListing = _listing!.copyWith(
        title: _title,
        description: _description,
        category: _category,
        pricePerHour: _pricePerHour,
        // location: _location, // Type mismatch - expecting LocationData
        amenities: _amenities,
        // images: _images, // Parameter not available
        // availability: _availability, // Parameter not available
        updatedAt: DateTime.now(),
      );

      await context.read<ListingProvider>().updateListing(updatedListing);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listado actualizado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el listado: $e'),
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