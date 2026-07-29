// Template: recently-used content type shortcut for the generator screen.
import 'package:equatable/equatable.dart';

import '../../core/constants/barcode_format.dart';
import '../../core/constants/content_type.dart';

class Template extends Equatable {
  const Template({
    required this.id,
    required this.contentType,
    required this.format,
    required this.name,
    this.sampleInput,
    this.lastUsed,
  });

  factory Template.fromJson(Map<String, dynamic> json) => Template(
        id: json['id'] as String,
        contentType:
            ContentType.fromString(json['contentType'] as String? ?? 'plainText'),
        format: BarcodeFormat.fromString(json['format'] as String? ?? 'qr'),
        name: json['name'] as String,
        sampleInput: json['sampleInput'] as String?,
        lastUsed: DateTime.tryParse(json['lastUsed'] as String? ?? ''),
      );

  final String id;
  final ContentType contentType;
  final BarcodeFormat format;
  final String name;
  final String? sampleInput;
  final DateTime? lastUsed;

  Template copyWith({
    DateTime? lastUsed,
    String? sampleInput,
  }) {
    return Template(
      id: id,
      contentType: contentType,
      format: format,
      name: name,
      sampleInput: sampleInput ?? this.sampleInput,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'contentType': contentType.name,
        'format': format.name,
        'name': name,
        'sampleInput': sampleInput,
        'lastUsed': lastUsed?.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, contentType, format, name, sampleInput, lastUsed];
}

/// Built-in templates shipped with the app — quick-start shortcuts.
class BuiltInTemplates {
  BuiltInTemplates._();

  static final List<Template> all = [
    const Template(
      id: 'tpl_url',
      contentType: ContentType.url,
      format: BarcodeFormat.qr,
      name: 'Website URL',
      sampleInput: 'https://example.com',
    ),
    const Template(
      id: 'tpl_wifi',
      contentType: ContentType.wifi,
      format: BarcodeFormat.qr,
      name: 'Wi-Fi Sharing',
    ),
    const Template(
      id: 'tpl_vcard',
      contentType: ContentType.vcard,
      format: BarcodeFormat.qr,
      name: 'Business Card',
    ),
    const Template(
      id: 'tpl_text',
      contentType: ContentType.plainText,
      format: BarcodeFormat.qr,
      name: 'Plain Text',
      sampleInput: 'Hello, World!',
    ),
    const Template(
      id: 'tpl_phone',
      contentType: ContentType.phone,
      format: BarcodeFormat.qr,
      name: 'Phone Number',
      sampleInput: '+1234567890',
    ),
    const Template(
      id: 'tpl_email',
      contentType: ContentType.email,
      format: BarcodeFormat.qr,
      name: 'Email',
    ),
    const Template(
      id: 'tpl_sms',
      contentType: ContentType.sms,
      format: BarcodeFormat.qr,
      name: 'SMS',
    ),
    const Template(
      id: 'tpl_geo',
      contentType: ContentType.geo,
      format: BarcodeFormat.qr,
      name: 'Location',
    ),
    const Template(
      id: 'tpl_event',
      contentType: ContentType.calendarEvent,
      format: BarcodeFormat.qr,
      name: 'Event',
    ),
    const Template(
      id: 'tpl_ean13',
      contentType: ContentType.ean,
      format: BarcodeFormat.ean13,
      name: 'EAN-13 Product',
      sampleInput: '5901234123457',
    ),
    const Template(
      id: 'tpl_upc',
      contentType: ContentType.upc,
      format: BarcodeFormat.upcA,
      name: 'UPC-A Product',
      sampleInput: '036000291452',
    ),
    const Template(
      id: 'tpl_code128',
      contentType: ContentType.code128,
      format: BarcodeFormat.code128,
      name: 'Code 128',
      sampleInput: 'CODE128-1234',
    ),
    const Template(
      id: 'tpl_pdf417',
      contentType: ContentType.pdf417,
      format: BarcodeFormat.pdf417,
      name: 'PDF417 (Boarding Pass)',
      sampleInput: 'M1DOE/JOHN  EABC123 LHRJFK 001 123 2026-01-15',
    ),
  ];
}
