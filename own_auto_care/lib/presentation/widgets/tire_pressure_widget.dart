import 'package:flutter/material.dart';
import 'package:own_auto_care/domain/entities/tire_pressure_configuration.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';
import 'package:own_auto_care/presentation/theme/app_theme.dart';

class TirePressureWidget extends StatefulWidget {
  final List<TirePressureConfiguration> initialConfigurations;
  final Function(List<TirePressureConfiguration>) onChanged;
  final bool isEditing;

  const TirePressureWidget({
    super.key,
    required this.initialConfigurations,
    required this.onChanged,
    this.isEditing = true,
  });

  @override
  State<TirePressureWidget> createState() => _TirePressureWidgetState();
}

class _TirePressureWidgetState extends State<TirePressureWidget> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<TirePressureConfiguration> _configurations;

  // Default templates if none provided
  static const _defaultConfigs = ['Standard', 'ECO', 'Loaded'];

  @override
  void initState() {
    super.initState();
    _initConfigurations();
    _tabController = TabController(length: _configurations.length, vsync: this);
  }

  void _initConfigurations() {
    if (widget.initialConfigurations.isNotEmpty) {
      _configurations = List.from(widget.initialConfigurations);
    } else {
      // Initialize with defaults if empty
      _configurations = _defaultConfigs
          .map((name) => TirePressureConfiguration(name: name, front: 0.0, rear: 0.0))
          .toList();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updatePressure(int index, double? front, double? rear) {
    setState(() {
      final current = _configurations[index];
      _configurations[index] = current.copyWith(
        front: front,
        rear: rear,
      );
    });
    widget.onChanged(_configurations);
  }

  String _getLocalizedConfigName(BuildContext context, String name) {
    final l10n = AppLocalizations.of(context)!;
    switch (name) {
      case 'Standard':
        return l10n.tirePressureConfigStandard ?? 'Standard';
      case 'ECO':
        return l10n.tirePressureConfigEco ?? 'ECO';
      case 'Loaded':
        return l10n.tirePressureConfigLoaded ?? 'Loaded';
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If not editing and no configs, show nothing or placeholder
    if (!widget.isEditing && _configurations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Configuration Tabs
        Container(
          height: 40,
          margin: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorSize: TabBarIndicatorSize.label,
                    dividerColor: Colors.transparent,
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    onTap: (index) {
                      // Optional: Handle tap if needed
                    },
                    tabs: _configurations.map((config) {
                      return GestureDetector(
                        onLongPress: widget.isEditing
                            ? () => _showRenameConfigDialog(context, config)
                            : null,
                        child: Tab(text: _getLocalizedConfigName(context, config.name)),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (widget.isEditing) ...[
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () {
                    // Edit the currently selected configuration
                    final currentIndex = _tabController.index;
                    if (currentIndex >= 0 && currentIndex < _configurations.length) {
                      _showRenameConfigDialog(context, _configurations[currentIndex]);
                    }
                  },
                  icon: const Icon(Icons.edit),
                  color: AppColors.textSecondary,
                  tooltip: AppLocalizations.of(context)!.renameTirePressureConfigTitle,
                ),
                IconButton(
                  onPressed: () => _showAddConfigDialog(context),
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.primary,
                  tooltip: AppLocalizations.of(context)!.addTirePressureConfigTitle,
                ),
              ],
            ],
          ),
        ),

        // Car Visualization and Inputs
        SizedBox(
          height: widget.isEditing ? 220 : 120, // Smaller height for read-only
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(), // Prevent swipe to avoid conflict
            children: _configurations.asMap().entries.map((entry) {
              final index = entry.key;
              final config = entry.value;
              return _buildPressureView(index, config);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddConfigDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    String newName = '';
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addTirePressureConfigTitle),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.configNameLabel,
            hintText: 'e.g. Sport, Off-road',
          ),
          onChanged: (value) => newName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (newName.isNotEmpty) {
                setState(() {
                  _configurations.add(TirePressureConfiguration(
                    name: newName,
                    front: 0.0,
                    rear: 0.0,
                  ));
                  // Re-initialize controller with new length
                  _tabController.dispose();
                  _tabController = TabController(
                    length: _configurations.length,
                    vsync: this,
                    initialIndex: _configurations.length - 1, // Switch to new tab
                  );
                });
                widget.onChanged(_configurations);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  Future<void> _showRenameConfigDialog(BuildContext context, TirePressureConfiguration config) async {
    final l10n = AppLocalizations.of(context)!;
    String newName = config.name;
    final index = _configurations.indexOf(config);
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameTirePressureConfigTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              controller: TextEditingController(text: _getLocalizedConfigName(context, config.name)),
              decoration: InputDecoration(
                labelText: l10n.configNameLabel,
              ),
              onChanged: (value) => newName = value,
            ),
            if (_configurations.length > 1) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () async {
                    // Confirm delete
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.delete),
                        content: Text(l10n.deleteConfigConfirmation),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: Text(l10n.delete),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      setState(() {
                         _configurations.removeAt(index);
                         // Re-initialize controller
                         _tabController.dispose();
                         _tabController = TabController(
                           length: _configurations.length,
                           vsync: this,
                           initialIndex: 0, // Reset to first
                         );
                      });
                      widget.onChanged(_configurations);
                      if (context.mounted) Navigator.pop(context); // Close rename dialog
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                ),
              ),
            ],
            if (_configurations.length <= 1)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  l10n.cannotDeleteLastConfig,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (newName.isNotEmpty && newName != config.name) {
                setState(() {
                  _configurations[index] = config.copyWith(name: newName);
                });
                widget.onChanged(_configurations);
                Navigator.pop(context);
              }
            },
            child: Text(l10n.rename),
          ),
        ],
      ),
    );
  }

  Widget _buildPressureView(int index, TirePressureConfiguration config) {
    // Compact read-only mode
    if (!widget.isEditing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Front pressure
            Flexible(
              child: _buildCompactPressureDisplay(
                context,
                label: AppLocalizations.of(context)!.frontTirePressureLabel,
                value: config.front,
              ),
            ),
            // Mini car icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: CustomPaint(
                size: const Size(50, 90),
                painter: CarSilhouettePainter(color: AppColors.textSecondary.withOpacity(0.2)),
              ),
            ),
            // Rear pressure
            Flexible(
              child: _buildCompactPressureDisplay(
                context,
                label: AppLocalizations.of(context)!.rearTirePressureLabel,
                value: config.rear,
              ),
            ),
          ],
        ),
      );
    }

    // Full editing mode
    return Stack(
      children: [
        // Car Silhouette
        Center(
          child: CustomPaint(
            size: const Size(120, 220),
            painter: CarSilhouettePainter(color: AppColors.textSecondary.withOpacity(0.2)),
          ),
        ),

        // Front Pressure Input
        Positioned(
          top: 30,
          left: 0,
          right: 0,
          child: Center(
            child: _buildPressureInput(
              context,
              label: AppLocalizations.of(context)!.frontTirePressureLabel, // 'Front Tire Pressure',
              value: config.front,
              onChanged: (val) => _updatePressure(index, val, config.rear),
            ),
          ),
        ),

        // Rear Pressure Input
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Center(
            child: _buildPressureInput(
              context,
              label: AppLocalizations.of(context)!.rearTirePressureLabel, // 'Rear Tire Pressure',
              value: config.rear,
              onChanged: (val) => _updatePressure(index, config.front, val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactPressureDisplay(BuildContext context, {required String label, required double value}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        Text(
          'bar',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _buildPressureInput(
    BuildContext context, {
    required String label,
    required double value,
    required Function(double?) onChanged,
  }) {
    if (!widget.isEditing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            Text(
              'bar',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 80,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        initialValue: value == 0.0 ? '' : value.toString(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface.withOpacity(0.9),
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
          ),
          hintText: '0.0',
          suffixText: 'bar',
          counterText: '',
        ),
        onChanged: (val) {
          if (val.isEmpty) {
            onChanged(0.0);
            return;
          }
           // Handle both comma and dot decimals
          final normalized = val.replaceAll(',', '.');
          final number = double.tryParse(normalized);
          if (number != null) {
            onChanged(number);
          }
        },
      ),
    );
  }
}

class CarSilhouettePainter extends CustomPainter {
  final Color color;

  CarSilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Simplified top-down car shape
    // Front bumper
    path.moveTo(w * 0.2, h * 0.15);
    path.quadraticBezierTo(w * 0.5, h * 0.05, w * 0.8, h * 0.15);
    
    // Right side
    path.lineTo(w * 0.9, h * 0.3); // Front wheel arch start
    path.quadraticBezierTo(w * 0.95, h * 0.35, w * 0.9, h * 0.4); // Wheel arch
    path.lineTo(w * 0.9, h * 0.7); // Body
    path.quadraticBezierTo(w * 0.95, h * 0.75, w * 0.9, h * 0.8); // Rear wheel arch
    
    // Rear bumper
    path.lineTo(w * 0.8, h * 0.95);
    path.quadraticBezierTo(w * 0.5, h * 1.0, w * 0.2, h * 0.95);
    
    // Left side
    path.lineTo(w * 0.1, h * 0.8); // Rear wheel arch
    path.quadraticBezierTo(w * 0.05, h * 0.75, w * 0.1, h * 0.7);
    path.lineTo(w * 0.1, h * 0.4);
    path.quadraticBezierTo(w * 0.05, h * 0.35, w * 0.1, h * 0.3);
    
    path.close();

    // Windshield
    final windshield = Path();
    windshield.moveTo(w * 0.2, h * 0.25);
    windshield.quadraticBezierTo(w * 0.5, h * 0.2, w * 0.8, h * 0.25);
    windshield.lineTo(w * 0.75, h * 0.35);
    windshield.quadraticBezierTo(w * 0.5, h * 0.32, w * 0.25, h * 0.35);
    windshield.close();

    // Rear window
    final rearWindow = Path();
    rearWindow.moveTo(w * 0.25, h * 0.7);
    rearWindow.quadraticBezierTo(w * 0.5, h * 0.68, w * 0.75, h * 0.7);
    rearWindow.lineTo(w * 0.7, h * 0.85);
    rearWindow.quadraticBezierTo(w * 0.5, h * 0.88, w * 0.3, h * 0.85);
    rearWindow.close();

    canvas.drawPath(path, borderPaint);
    
    // Light fill
    canvas.drawPath(windshield, paint..color = color.withOpacity(0.3));
    canvas.drawPath(rearWindow, paint..color = color.withOpacity(0.3));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
