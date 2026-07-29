// ContentTypeChip: a selectable chip representing a ContentType.

import 'package:flutter/material.dart';

import '../../core/constants/content_type.dart';
import '../../core/extensions/build_context.dart';

class ContentTypeChip extends StatelessWidget {
  const ContentTypeChip({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final ContentType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: FilterChip(
        label: Text(_label(context, type)),
        selected: selected,
        onSelected: (_) => onTap(),
        avatar: Icon(_icon(type), size: 18),
        showCheckmark: false,
      ),
    );
  }

  String _label(BuildContext context, ContentType type) {
    final l10n = context.l10n;
    switch (type) {
      case ContentType.plainText: return l10n.contentType_plainText;
      case ContentType.url: return l10n.contentType_url;
      case ContentType.email: return l10n.contentType_email;
      case ContentType.phone: return l10n.contentType_phone;
      case ContentType.sms: return l10n.contentType_sms;
      case ContentType.wifi: return l10n.contentType_wifi;
      case ContentType.vcard: return l10n.contentType_vcard;
      case ContentType.calendarEvent: return l10n.contentType_calendarEvent;
      case ContentType.geo: return l10n.contentType_geo;
      case ContentType.crypto: return l10n.contentType_crypto;
      case ContentType.social: return l10n.contentType_social;
      case ContentType.appStore: return l10n.contentType_appStore;
      case ContentType.product: return l10n.contentType_product;
      case ContentType.isbn: return l10n.contentType_isbn;
      case ContentType.upc: return l10n.contentType_upc;
      case ContentType.ean: return l10n.contentType_ean;
      case ContentType.code128: return l10n.contentType_code128;
      case ContentType.code39: return l10n.contentType_code39;
      case ContentType.codabar: return l10n.contentType_codabar;
      case ContentType.itf: return l10n.contentType_itf;
      case ContentType.pdf417: return l10n.contentType_pdf417;
      case ContentType.dataMatrix: return l10n.contentType_dataMatrix;
      case ContentType.aztec: return l10n.contentType_aztec;
      case ContentType.gs1: return l10n.contentType_gs1;
      case ContentType.custom: return l10n.contentType_custom;
      case ContentType.clipboard: return l10n.contentType_clipboard;
    }
  }

  IconData _icon(ContentType type) {
    switch (type) {
      case ContentType.plainText: return Icons.text_fields;
      case ContentType.url: return Icons.language;
      case ContentType.email: return Icons.email;
      case ContentType.phone: return Icons.phone;
      case ContentType.sms: return Icons.sms;
      case ContentType.wifi: return Icons.wifi;
      case ContentType.vcard: return Icons.contact_page;
      case ContentType.calendarEvent: return Icons.event;
      case ContentType.geo: return Icons.location_on;
      case ContentType.crypto: return Icons.currency_bitcoin;
      case ContentType.social: return Icons.share;
      case ContentType.appStore: return Icons.shop;
      case ContentType.product: return Icons.inventory_2;
      case ContentType.isbn: return Icons.book;
      case ContentType.upc: return Icons.barcode_reader;
      case ContentType.ean: return Icons.barcode_reader;
      case ContentType.code128: return Icons.qr_code;
      case ContentType.code39: return Icons.qr_code;
      case ContentType.codabar: return Icons.qr_code;
      case ContentType.itf: return Icons.qr_code;
      case ContentType.pdf417: return Icons.qr_code_2;
      case ContentType.dataMatrix: return Icons.qr_code_2;
      case ContentType.aztec: return Icons.qr_code_2;
      case ContentType.gs1: return Icons.qr_code;
      case ContentType.custom: return Icons.edit;
      case ContentType.clipboard: return Icons.content_paste;
    }
  }
}
