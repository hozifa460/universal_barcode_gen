// StructuredInputForms: per-content-type structured input widgets.
// Returns a BarcodeContent via onChanged when the user fills out the form.

import 'package:flutter/material.dart';

import '../../../core/constants/content_type.dart';
import '../../../core/extensions/build_context.dart';
import '../../../domain/entities/barcode_content.dart';

class StructuredInputForm extends StatefulWidget {
  const StructuredInputForm({
    super.key,
    required this.contentType,
    required this.onChanged,
  });

  final ContentType contentType;
  final ValueChanged<BarcodeContent> onChanged;

  @override
  State<StructuredInputForm> createState() => _StructuredInputFormState();
}

class _StructuredInputFormState extends State<StructuredInputForm> {
  @override
  Widget build(BuildContext context) {
    switch (widget.contentType) {
      case ContentType.wifi:
        return _WifiForm(onChanged: (s) => widget.onChanged(
              BarcodeContent(type: ContentType.wifi, raw: s.encode(), structured: s),
            ),);
      case ContentType.vcard:
        return _VCardForm(onChanged: (s) => widget.onChanged(
              BarcodeContent(type: ContentType.vcard, raw: s.encode(), structured: s),
            ),);
      case ContentType.calendarEvent:
        return _CalendarForm(onChanged: (s) => widget.onChanged(
              BarcodeContent(type: ContentType.calendarEvent, raw: s.encode(), structured: s),
            ),);
      case ContentType.geo:
        return _GeoForm(onChanged: (s) => widget.onChanged(
              BarcodeContent(type: ContentType.geo, raw: s.encode(), structured: s),
            ),);
      case ContentType.sms:
        return _SmsForm(onChanged: (s) => widget.onChanged(
              BarcodeContent(type: ContentType.sms, raw: s.encode(), structured: s),
            ),);
      case ContentType.email:
        return _EmailForm(onChanged: (s) => widget.onChanged(
              BarcodeContent(type: ContentType.email, raw: s.encode(), structured: s),
            ),);
      case ContentType.crypto:
        return _CryptoForm(onChanged: (s) => widget.onChanged(
              BarcodeContent(type: ContentType.crypto, raw: s.encode(), structured: s),
            ),);
      case ContentType.social:
        return _SocialForm(onChanged: (s) => widget.onChanged(
              BarcodeContent(type: ContentType.social, raw: s.encode(), structured: s),
            ),);
      case ContentType.appStore:
        return _AppStoreForm(onChanged: (s) => widget.onChanged(
              BarcodeContent(type: ContentType.appStore, raw: s.encode(), structured: s),
            ),);
      default:
        return const SizedBox.shrink();
    }
  }
}

// ---------------------------------------------------------------------------
// Shared field widget
// ---------------------------------------------------------------------------

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.onChanged,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.hint,
  });
  final String label;
  final ValueChanged<String> onChanged;
  final TextInputType keyboardType;
  final int maxLines;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wi-Fi
// ---------------------------------------------------------------------------

class _WifiForm extends StatefulWidget {
  const _WifiForm({required this.onChanged});
  final ValueChanged<WifiPayload> onChanged;

  @override
  State<_WifiForm> createState() => _WifiFormState();
}

class _WifiFormState extends State<_WifiForm> {
  String ssid = '';
  String password = '';
  WifiEncryption encryption = WifiEncryption.wpa;
  bool hidden = false;

  void _emit() {
    widget.onChanged(WifiPayload(
      ssid: ssid,
      password: password,
      encryption: encryption,
      hidden: hidden,
    ),);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Field(
          label: context.l10n.wifi_ssid,
          onChanged: (v) { ssid = v; _emit(); },
        ),
        _Field(
          label: context.l10n.wifi_password,
          onChanged: (v) { password = v; _emit(); },
        ),
        DropdownButtonFormField<WifiEncryption>(
          initialValue: encryption,
          decoration: InputDecoration(labelText: context.l10n.wifi_encryption),
          items: WifiEncryption.values.map((e) => DropdownMenuItem(
            value: e,
            child: Text(e.value),
          ),).toList(),
          onChanged: (v) {
            if (v != null) { encryption = v; _emit(); }
          },
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(context.l10n.wifi_hidden),
          value: hidden,
          onChanged: (v) { hidden = v; _emit(); },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// vCard
// ---------------------------------------------------------------------------

class _VCardForm extends StatefulWidget {
  const _VCardForm({required this.onChanged});
  final ValueChanged<VCardPayload> onChanged;

  @override
  State<_VCardForm> createState() => _VCardFormState();
}

class _VCardFormState extends State<_VCardForm> {
  String firstName = '';
  String lastName = '';
  String? phone;
  String? email;
  String? organization;
  String? title;
  String? url;
  String? address;

  void _emit() {
    widget.onChanged(VCardPayload(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      organization: organization,
      title: title,
      url: url,
      address: address,
    ),);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _Field(label: context.l10n.vcard_firstName,
                onChanged: (v) { firstName = v; _emit(); },),),
            const SizedBox(width: 8),
            Expanded(child: _Field(label: context.l10n.vcard_lastName,
                onChanged: (v) { lastName = v; _emit(); },),),
          ],
        ),
        _Field(label: context.l10n.vcard_phone,
            keyboardType: TextInputType.phone,
            onChanged: (v) { phone = v; _emit(); },),
        _Field(label: context.l10n.vcard_email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) { email = v; _emit(); },),
        _Field(label: context.l10n.vcard_organization,
            onChanged: (v) { organization = v; _emit(); },),
        _Field(label: context.l10n.vcard_title,
            onChanged: (v) { title = v; _emit(); },),
        _Field(label: context.l10n.vcard_url,
            keyboardType: TextInputType.url,
            onChanged: (v) { url = v; _emit(); },),
        _Field(label: context.l10n.vcard_address,
            maxLines: 2,
            onChanged: (v) { address = v; _emit(); },),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar
// ---------------------------------------------------------------------------

class _CalendarForm extends StatefulWidget {
  const _CalendarForm({required this.onChanged});
  final ValueChanged<CalendarPayload> onChanged;

  @override
  State<_CalendarForm> createState() => _CalendarFormState();
}

class _CalendarFormState extends State<_CalendarForm> {
  String title = '';
  DateTime start = DateTime.now();
  DateTime end = DateTime.now().add(const Duration(hours: 1));
  String? location;
  String? description;

  void _emit() {
    widget.onChanged(CalendarPayload(
      title: title,
      start: start,
      end: end,
      location: location,
      description: description,
    ),);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Field(label: context.l10n.calendar_title,
            onChanged: (v) { title = v; _emit(); },),
        ListTile(
          title: Text(context.l10n.calendar_start),
          subtitle: Text(start.toString()),
          trailing: const Icon(Icons.event),
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: start,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (d != null) { start = d; _emit(); setState(() {}); }
          },
        ),
        ListTile(
          title: Text(context.l10n.calendar_end),
          subtitle: Text(end.toString()),
          trailing: const Icon(Icons.event),
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: end,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (d != null) { end = d; _emit(); setState(() {}); }
          },
        ),
        _Field(label: context.l10n.calendar_location,
            onChanged: (v) { location = v; _emit(); },),
        _Field(label: context.l10n.calendar_description,
            maxLines: 3,
            onChanged: (v) { description = v; _emit(); },),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Geo
// ---------------------------------------------------------------------------

class _GeoForm extends StatefulWidget {
  const _GeoForm({required this.onChanged});
  final ValueChanged<GeoPayload> onChanged;

  @override
  State<_GeoForm> createState() => _GeoFormState();
}

class _GeoFormState extends State<_GeoForm> {
  String latStr = '';
  String lngStr = '';

  void _emit() {
    final lat = double.tryParse(latStr);
    final lng = double.tryParse(lngStr);
    if (lat != null && lng != null) {
      widget.onChanged(GeoPayload(latitude: lat, longitude: lng));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Field(label: context.l10n.geo_latitude,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            onChanged: (v) { latStr = v; _emit(); },),
        _Field(label: context.l10n.geo_longitude,
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            onChanged: (v) { lngStr = v; _emit(); },),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SMS
// ---------------------------------------------------------------------------

class _SmsForm extends StatefulWidget {
  const _SmsForm({required this.onChanged});
  final ValueChanged<SmsPayload> onChanged;

  @override
  State<_SmsForm> createState() => _SmsFormState();
}

class _SmsFormState extends State<_SmsForm> {
  String phone = '';
  String message = '';

  void _emit() {
    widget.onChanged(SmsPayload(phone: phone, message: message));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Field(label: context.l10n.contentType_phone,
            keyboardType: TextInputType.phone,
            onChanged: (v) { phone = v; _emit(); },),
        _Field(label: context.l10n.contentType_sms,
            maxLines: 3,
            onChanged: (v) { message = v; _emit(); },),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Email
// ---------------------------------------------------------------------------

class _EmailForm extends StatefulWidget {
  const _EmailForm({required this.onChanged});
  final ValueChanged<EmailPayload> onChanged;

  @override
  State<_EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends State<_EmailForm> {
  String address = '';
  String? subject;
  String? body;

  void _emit() {
    widget.onChanged(EmailPayload(address: address, subject: subject, body: body));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Field(label: context.l10n.contentType_email,
            keyboardType: TextInputType.emailAddress,
            onChanged: (v) { address = v; _emit(); },),
        _Field(label: context.l10n.calendar_description,
            onChanged: (v) { subject = v; _emit(); },),
        _Field(label: context.l10n.calendar_description,
            maxLines: 4,
            onChanged: (v) { body = v; _emit(); },),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Crypto
// ---------------------------------------------------------------------------

class _CryptoForm extends StatefulWidget {
  const _CryptoForm({required this.onChanged});
  final ValueChanged<CryptoPayload> onChanged;

  @override
  State<_CryptoForm> createState() => _CryptoFormState();
}

class _CryptoFormState extends State<_CryptoForm> {
  CryptoCoin coin = CryptoCoin.bitcoin;
  String address = '';
  String? amountStr;

  void _emit() {
    final amount = double.tryParse(amountStr ?? '');
    widget.onChanged(CryptoPayload(coin: coin, address: address, amount: amount));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<CryptoCoin>(
          initialValue: coin,
          decoration: InputDecoration(labelText: context.l10n.crypto_coin),
          items: CryptoCoin.values.map((c) => DropdownMenuItem(
            value: c,
            child: Text(c.label),
          ),).toList(),
          onChanged: (v) {
            if (v != null) { coin = v; _emit(); }
          },
        ),
        _Field(label: context.l10n.crypto_address,
            onChanged: (v) { address = v; _emit(); },),
        _Field(label: context.l10n.crypto_amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) { amountStr = v; _emit(); },),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Social
// ---------------------------------------------------------------------------

class _SocialForm extends StatefulWidget {
  const _SocialForm({required this.onChanged});
  final ValueChanged<SocialPayload> onChanged;

  @override
  State<_SocialForm> createState() => _SocialFormState();
}

class _SocialFormState extends State<_SocialForm> {
  SocialPlatform platform = SocialPlatform.website;
  String username = '';

  void _emit() {
    widget.onChanged(SocialPayload(platform: platform, username: username));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<SocialPlatform>(
          initialValue: platform,
          decoration: InputDecoration(labelText: context.l10n.social_platform),
          items: SocialPlatform.values.map((p) => DropdownMenuItem(
            value: p,
            child: Text(p.label),
          ),).toList(),
          onChanged: (v) {
            if (v != null) { platform = v; _emit(); }
          },
        ),
        _Field(label: context.l10n.social_username,
            onChanged: (v) { username = v; _emit(); },),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// App Store
// ---------------------------------------------------------------------------

class _AppStoreForm extends StatefulWidget {
  const _AppStoreForm({required this.onChanged});
  final ValueChanged<AppStorePayload> onChanged;

  @override
  State<_AppStoreForm> createState() => _AppStoreFormState();
}

class _AppStoreFormState extends State<_AppStoreForm> {
  String? appleId;
  String? googlePackage;

  void _emit() {
    widget.onChanged(AppStorePayload(appleId: appleId, googlePackage: googlePackage));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Field(label: context.l10n.appStore_appleId,
            keyboardType: TextInputType.number,
            onChanged: (v) { appleId = v; _emit(); },),
        _Field(label: context.l10n.appStore_googlePackage,
            onChanged: (v) { googlePackage = v; _emit(); },),
      ],
    );
  }
}
