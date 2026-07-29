// CustomizationPanel: full design controls for QR codes.
// Exposes: foreground/background colors, gradient, module shape, eye shape,
// error correction, size, margin, transparent background, border radius,
// palette presets, logo picker.

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/qr_style.dart';
import '../../../core/extensions/build_context.dart';
import '../../../domain/entities/qr_design.dart';

class CustomizationPanel extends StatelessWidget {
  const CustomizationPanel({
    super.key,
    required this.design,
    required this.onChanged,
  });

  final QrDesign design;
  final ValueChanged<QrDesign> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Built-in palette presets.
        _SectionTitle(text: context.l10n.customization_palette),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: QrPalettes.presets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final p = QrPalettes.presets[i];
              final selected = design.foregroundColor == p.fg &&
                  design.backgroundColor == p.bg;
              return GestureDetector(
                onTap: () => onChanged(design.applyPreset(i)),
                child: Container(
                  width: 56,
                  decoration: BoxDecoration(
                    color: Color(p.bg),
                    border: Border.all(
                      color: selected
                          ? context.colors.primary
                          : context.colors.outline,
                      width: selected ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(p.fg),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Colors.
        _SectionTitle(text: context.l10n.customization_foregroundColor),
        const SizedBox(height: 8),
        Row(
          children: [
            _ColorPickerButton(
              color: Color(design.foregroundColor),
              onPicked: (c) =>
                  onChanged(design.copyWith(foregroundColor: c.value)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '#${design.foregroundColor.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                style: context.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _SectionTitle(text: context.l10n.customization_backgroundColor),
        const SizedBox(height: 8),
        Row(
          children: [
            _ColorPickerButton(
              color: Color(design.backgroundColor),
              onPicked: (c) =>
                  onChanged(design.copyWith(backgroundColor: c.value)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '#${design.backgroundColor.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                style: context.textTheme.bodyMedium,
              ),
            ),
            Switch(
              value: design.transparentBackground,
              onChanged: (v) => onChanged(
                  design.copyWith(transparentBackground: v),),
            ),
            Text(context.l10n.customization_transparentBg),
          ],
        ),
        const SizedBox(height: 24),

        // Gradient.
        SwitchListTile(
          title: Text(context.l10n.customization_gradient),
          value: design.useGradient,
          onChanged: (v) => onChanged(design.copyWith(useGradient: v)),
        ),
        if (design.useGradient) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              _ColorPickerButton(
                color: Color(design.gradientStart),
                onPicked: (c) =>
                    onChanged(design.copyWith(gradientStart: c.value)),
              ),
              const SizedBox(width: 8),
              _ColorPickerButton(
                color: Color(design.gradientEnd),
                onPicked: (c) =>
                    onChanged(design.copyWith(gradientEnd: c.value)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<GradientDirection>(
                  initialValue: design.gradientDirection,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: GradientDirection.values
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d.label),
                          ),)
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      onChanged(design.copyWith(gradientDirection: v));
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],

        // Module shape.
        _SectionTitle(text: context.l10n.customization_moduleShape),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ModuleShape.values.map((s) {
            return ChoiceChip(
              label: Text(s.label),
              selected: design.moduleShape == s,
              onSelected: (_) =>
                  onChanged(design.copyWith(moduleShape: s)),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Eye shape.
        _SectionTitle(text: context.l10n.customization_eyeShape),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: EyeShape.values.map((s) {
            return ChoiceChip(
              label: Text(s.label),
              selected: design.eyeShape == s,
              onSelected: (_) =>
                  onChanged(design.copyWith(eyeShape: s)),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Error correction.
        _SectionTitle(text: context.l10n.customization_errorCorrection),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ErrorCorrectionLevel.values.map((e) {
            return ChoiceChip(
              label: Text(e.label),
              selected: design.errorCorrection == e,
              onSelected: (_) =>
                  onChanged(design.copyWith(errorCorrection: e)),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Size.
        _SectionTitle(text: context.l10n.customization_size),
        const SizedBox(height: 8),
        Slider(
          value: design.size.toDouble(),
          min: 128,
          max: 2048,
          divisions: 31,
          label: design.size.toString(),
          onChanged: (v) => onChanged(design.copyWith(size: v.toInt())),
        ),
        const SizedBox(height: 16),

        // Margin.
        _SectionTitle(text: context.l10n.customization_margin),
        const SizedBox(height: 8),
        Slider(
          value: design.margin.toDouble(),
          min: 0,
          max: 16,
          divisions: 16,
          label: design.margin.toString(),
          onChanged: (v) => onChanged(design.copyWith(margin: v.toInt())),
        ),
        const SizedBox(height: 16),

        // Border radius.
        _SectionTitle(text: context.l10n.customization_borderRadius),
        const SizedBox(height: 8),
        Slider(
          value: design.borderRadius,
          min: 0,
          max: 32,
          divisions: 32,
          label: design.borderRadius.toStringAsFixed(1),
          onChanged: (v) => onChanged(design.copyWith(borderRadius: v)),
        ),
        const SizedBox(height: 24),

        // Logo.
        _SectionTitle(text: context.l10n.customization_logo),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: () async {
                final picker = ImagePicker();
                final xfile =
                    await picker.pickImage(source: ImageSource.gallery);
                if (xfile != null) {
                  onChanged(design.copyWith(logoPath: xfile.path));
                }
              },
              icon: const Icon(Icons.add_photo_alternate),
              label: Text(context.l10n.action_addLogo),
            ),
            if (design.logoPath != null) ...[
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () =>
                    onChanged(design.copyWith(clearLogo: true)),
                icon: const Icon(Icons.delete_outline),
                label: Text(context.l10n.action_removeLogo),
              ),
            ],
          ],
        ),
        if (design.logoPath != null) ...[
          const SizedBox(height: 8),
          Text(
            'Logo size: ${(design.logoSizeRatio * 100).toInt()}%',
            style: context.textTheme.bodySmall,
          ),
          Slider(
            value: design.logoSizeRatio,
            min: 0.05,
            max: 0.35,
            divisions: 30,
            label: '${(design.logoSizeRatio * 100).toInt()}%',
            onChanged: (v) => onChanged(design.copyWith(logoSizeRatio: v)),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: context.colors.onSurface,
      ),
    );
  }
}

class _ColorPickerButton extends StatelessWidget {
  const _ColorPickerButton({
    required this.color,
    required this.onPicked,
  });

  final Color color;
  final ValueChanged<Color> onPicked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // Simple color dialog — pick from preset swatches.
        final picked = await showDialog<Color>(
          context: context,
          builder: (ctx) => _ColorSwatchDialog(initial: color),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
      ),
    );
  }
}

class _ColorSwatchDialog extends StatelessWidget {
  const _ColorSwatchDialog({required this.initial});
  final Color initial;

  static const _swatches = <Color>[
    Color(0xFF000000), Color(0xFFFFFFFF),
    Color(0xFFE53935), Color(0xFFD81B60),
    Color(0xFF8E24AA), Color(0xFF5E35B1),
    Color(0xFF3949AB), Color(0xFF1E88E5),
    Color(0xFF039BE5), Color(0xFF00ACC1),
    Color(0xFF00897B), Color(0xFF43A047),
    Color(0xFF7CB342), Color(0xFFC0CA33),
    Color(0xFFFDD835), Color(0xFFFFB300),
    Color(0xFFFB8C00), Color(0xFFF4511E),
    Color(0xFF6D4C41), Color(0xFF757575),
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _swatches.map((c) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(c),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: Border.all(
                  color: c == initial
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
      ],
    );
  }
}
