import 'package:agnts_api/agnts_api.dart';

/// One editable route row: a host, domain or range, and its ports as typed.
typedef RouteRow = ({String target, String ports});

/// Route rows to the API's routes: a "/" makes a CIDR, anything else a
/// host; ports split on commas and spaces, the invalid ones dropped.
List<NetworkRoute> toRoutes(List<RouteRow> rows) => [
      for (final r in rows)
        if (r.target.trim().isNotEmpty) _route(r),
    ];

NetworkRoute _route(RouteRow r) {
  final target = r.target.trim();
  final ports = [
    for (final p in r.ports.split(RegExp(r'[,\s]+')))
      if ((int.tryParse(p) ?? 0) > 0) int.parse(p),
  ];
  final cidr = target.contains('/');
  return NetworkRoute(host: cidr ? null : target, cidr: cidr ? target : null, ports: ports.isEmpty ? null : ports);
}

/// A saved network's routes back to editable rows.
List<RouteRow> fromRoutes(List<NetworkRoute> routes) => [
      for (final r in routes) (target: r.host ?? r.cidr ?? '', ports: (r.ports ?? const []).join(', ')),
    ];

/// Routes as one line: "gitlab.corp.local :443, 10.20.0.0/16".
String routeText(List<NetworkRoute> routes) =>
    routes.map((r) => (r.host ?? r.cidr ?? '') + ((r.ports?.isNotEmpty ?? false) ? ' :${r.ports!.join(' :')}' : '')).join(', ');

/// A docker container name per network, so one machine can run links for several.
String linkContainerName(String name) {
  final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  return slug.isEmpty ? 'agnts-link' : 'agnts-link-$slug';
}

/// The command that runs agnts-link inside the network.
String linkCommand({required String name, required String linkUrl, required String token, required List<NetworkRoute> routes}) {
  final allow = routes.map((r) => r.host ?? r.cidr ?? '').where((x) => x.isNotEmpty).toList();
  return [
    'docker run -d --restart unless-stopped --name ${linkContainerName(name)} -p 8080:8080 \\',
    '  -e AGNTS_LINK_URL=$linkUrl \\',
    '  -e AGNTS_LINK_TOKEN=${token.isEmpty ? '<token>' : token} \\',
    '  -e AGNTS_LINK_ALLOW=${allow.isEmpty ? 'gitlab.corp.local,10.20.0.0/16' : allow.join(',')} \\',
    '  registry.agnts.uz/agnts-link:latest',
  ].join('\n');
}

String kindName(PrivateNetworkKindEnum k) => switch (k) {
      PrivateNetworkKindEnum.connector => 'agnts-link',
      PrivateNetworkKindEnum.wireguard => 'WireGuard',
      PrivateNetworkKindEnum.openvpn => 'OpenVPN',
    };

/// "512 B", "1.5 KB", "2.0 MB".
String byteText(int n) => n < 1024
    ? '$n B'
    : n < 1 << 20
        ? '${(n / 1024).toStringAsFixed(1)} KB'
        : '${(n / (1 << 20)).toStringAsFixed(1)} MB';
