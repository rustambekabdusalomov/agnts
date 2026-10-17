import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agnts_api/agnts_api.dart';

import '../../core/api.dart';
import '../../l10n/app_localizations.dart';
import '../../theme.dart';
import '../../widgets/common.dart';
import '../../widgets/ui.dart';
import '../repos/manage_widgets.dart';
import 'network_logic.dart';
import 'networks_screen.dart';

/// Add or edit one private network: the tunnel, the routes that go through
/// it and its CA bundle. A new agnts-link stays open after saving so its
/// token (shown once) and run command can be copied (PrivateNetworkEditor).
class NetworkEditor extends ConsumerStatefulWidget {
  const NetworkEditor({super.key, required this.network, required this.linkUrl});
  final PrivateNetwork? network;
  final String linkUrl;

  @override
  ConsumerState<NetworkEditor> createState() => _NetworkEditorState();
}

class _NetworkEditorState extends ConsumerState<NetworkEditor> {
  PrivateNetwork? _current;
  final _name = TextEditingController();
  var _kind = PrivateNetworkInputKindEnum.connector;
  bool _enabled = true;
  final _config = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _ca = TextEditingController();
  bool _caTouched = false;
  final _targets = <TextEditingController>[];
  final _ports = <TextEditingController>[];
  String _error = '';
  String _token = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load(widget.network);
  }

  @override
  void dispose() {
    for (final c in [_name, _config, _username, _password, _ca, ..._targets, ..._ports]) {
      c.dispose();
    }
    super.dispose();
  }

  void _load(PrivateNetwork? n) {
    _current = n;
    _name.text = n?.name ?? '';
    _kind = switch (n?.kind) {
      PrivateNetworkKindEnum.wireguard => PrivateNetworkInputKindEnum.wireguard,
      PrivateNetworkKindEnum.openvpn => PrivateNetworkInputKindEnum.openvpn,
      _ => PrivateNetworkInputKindEnum.connector,
    };
    _enabled = n?.enabled ?? true;
    for (final c in [..._targets, ..._ports]) {
      c.dispose();
    }
    _targets.clear();
    _ports.clear();
    final rows = n == null || n.routes.isEmpty ? [(target: '', ports: '')] : fromRoutes(n.routes);
    for (final r in rows) {
      _targets.add(TextEditingController(text: r.target));
      _ports.add(TextEditingController(text: r.ports));
    }
    _config.clear();
    _username.clear();
    _password.clear();
    _ca.clear();
    _caTouched = false;
    _error = '';
  }

  bool get _keepsConfig => _current != null && _current!.kind.value == _kind.value && _kind != PrivateNetworkInputKindEnum.connector;

  List<NetworkRoute> get _routes => toRoutes([for (var i = 0; i < _targets.length; i++) (target: _targets[i].text, ports: _ports[i].text)]);

  Future<void> _save() async {
    final l = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l.mmanageFillAll);
      return;
    }
    final body = PrivateNetworkInput(
      name: _name.text.trim(),
      kind: _kind,
      enabled: _enabled,
      routes: _routes,
      config: _config.text.trim().isEmpty ? null : _config.text,
      username: _kind == PrivateNetworkInputKindEnum.openvpn ? _username.text : null,
      password: _kind == PrivateNetworkInputKindEnum.openvpn && _password.text.isNotEmpty ? _password.text : null,
      caPem: _caTouched ? _ca.text : null,
    );
    setState(() {
      _busy = true;
      _error = '';
    });
    try {
      final api = ref.read(apiProvider)!.getNetworkApi();
      final id = _current?.id;
      final r = (id == null
              ? await api.createPrivateNetwork(privateNetworkInput: body)
              : await api.updatePrivateNetwork(networkId: id, privateNetworkInput: body))
          .data!;
      ref.invalidate(networksProvider);
      ref.invalidate(networkActivityProvider);
      if (!mounted) return;
      showSnack(context, l.networkSaved(r.network.name));
      if (r.token != null) {
        // Stay open: the token is shown only now.
        setState(() {
          _load(r.network);
          _token = r.token!;
        });
        return;
      }
      Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(e, l.commonError));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rotate() async {
    final l = AppLocalizations.of(context);
    final id = _current?.id;
    if (id == null) return;
    if (!await confirmAction(context, title: l.networkRotate, message: l.networkRotateConfirm, confirmLabel: l.networkRotate)) return;
    try {
      final r = (await ref.read(apiProvider)!.getNetworkApi().rotateLinkToken(networkId: id)).data!;
      ref.invalidate(networksProvider);
      if (mounted) setState(() => _token = r.token);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(e, l.commonError));
    }
  }

  String _kindHelp(AppLocalizations l) => switch (_kind) {
        PrivateNetworkInputKindEnum.connector => l.networkKindHelp_connector,
        PrivateNetworkInputKindEnum.wireguard => l.networkKindHelp_wireguard,
        PrivateNetworkInputKindEnum.openvpn => l.networkKindHelp_openvpn,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = Agnts.of(context);
    final wg = _kind == PrivateNetworkInputKindEnum.wireguard;
    final cur = _current;
    final mono = TextStyle(fontFamily: AgntsFonts.mono, fontSize: 12.5, color: c.ink);
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SheetTitle(cur?.name ?? l.networkAddTitle, sub: l.networkEditorSub),
      Flexible(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ManageField(
              label: l.networkName,
              help: l.networkNameHelp,
              child: ManageInput(controller: _name, hint: l.networkNamePlaceholder, maxLength: 60),
            ),
            ManageField(
              label: l.networkKind,
              help: _kindHelp(l),
              child: Segmented<PrivateNetworkInputKindEnum>(
                full: true,
                options: [
                  (PrivateNetworkInputKindEnum.connector, 'agnts-link'),
                  (PrivateNetworkInputKindEnum.wireguard, 'WireGuard'),
                  (PrivateNetworkInputKindEnum.openvpn, 'OpenVPN'),
                ],
                value: _kind,
                onChanged: (k) => setState(() => _kind = k),
              ),
            ),
            SwitchLine(title: l.networkEnabled, value: _enabled, onChanged: (v) => setState(() => _enabled = v)),
            const SizedBox(height: 10),
            if (_kind != PrivateNetworkInputKindEnum.connector)
              ManageField(
                label: wg ? l.networkConfigWg : l.networkConfigOvpn,
                help: [
                  if (_keepsConfig && cur?.summary != null) l.networkSavedConfig(cur!.summary!),
                  wg ? l.networkConfigWgHelp : l.networkConfigOvpnHelp,
                ].join('\n'),
                child: ManageInput(
                  controller: _config,
                  mono: true,
                  minLines: 6,
                  maxLines: 12,
                  hint: wg ? '[Interface]\nPrivateKey = …\nAddress = 10.8.0.2/32\n\n[Peer]\nPublicKey = …\nEndpoint = vpn.example.com:51820' : 'client\ndev tun\nremote vpn.example.com 1194',
                ),
              ),
            if (_kind == PrivateNetworkInputKindEnum.openvpn) ...[
              ManageField(label: l.networkUsername, child: ManageInput(controller: _username, maxLength: 256)),
              ManageField(
                label: l.networkPassword,
                child: ManageInput(controller: _password, obscure: true, hint: _keepsConfig ? l.networkPasswordKeep : null, maxLength: 256),
              ),
            ],
            ManageField(
              label: l.networkRoutes,
              help: l.networkRoutesHelp,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                for (var i = 0; i < _targets.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Expanded(flex: 3, child: ManageInput(controller: _targets[i], mono: true, hint: l.networkRouteTarget)),
                      const SizedBox(width: 8),
                      Expanded(flex: 2, child: ManageInput(controller: _ports[i], mono: true, hint: '80, 443')),
                      IconButton(
                        tooltip: l.networkRemoveRoute,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(() {
                          _targets.removeAt(i).dispose();
                          _ports.removeAt(i).dispose();
                        }),
                      ),
                    ]),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton(
                    onPressed: () => setState(() {
                      _targets.add(TextEditingController());
                      _ports.add(TextEditingController());
                    }),
                    child: Text(l.networkAddRoute),
                  ),
                ),
                const SizedBox(height: 8),
                HelpBox(l.networkBlastRadius, tone: Tone.warn),
              ]),
            ),
            ManageField(
              label: l.networkCa,
              help: l.networkCaHelp,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (cur?.ca != null && !_caTouched)
                  Row(children: [
                    Expanded(
                      child: Text(
                        l.networkCaSaved(cur!.ca!.subjects.join(', '), MaterialLocalizations.of(context).formatShortDate(cur.ca!.notAfter.toLocal())),
                        style: TextStyle(fontSize: 13, color: c.ink3),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _caTouched = true;
                        _ca.clear();
                      }),
                      child: Text(l.networkCaRemove),
                    ),
                  ]),
                ManageInput(
                  controller: _ca,
                  mono: true,
                  minLines: 3,
                  maxLines: 8,
                  hint: '-----BEGIN CERTIFICATE-----',
                  onChanged: (_) => _caTouched = true,
                ),
              ]),
            ),
            if (_kind == PrivateNetworkInputKindEnum.connector && cur?.kind == PrivateNetworkKindEnum.connector)
              ManageField(
                label: l.networkLinkTitle,
                help: l.networkLinkHooks,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(l.networkLinkHelp, style: TextStyle(fontSize: 13, color: c.ink3)),
                  const SizedBox(height: 8),
                  if (_token.isNotEmpty) ...[
                    CopyLine(l.networkToken, _token),
                    Text(l.networkTokenOnce, style: TextStyle(fontSize: 13, color: c.warnInk)),
                    const SizedBox(height: 8),
                  ],
                  Builder(builder: (_) {
                    final cmd = linkCommand(name: cur!.name, linkUrl: widget.linkUrl, token: _token, routes: _routes);
                    return Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 2, 8),
                      decoration: BoxDecoration(color: c.hover, borderRadius: BorderRadius.circular(10)),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: SelectableText(cmd, style: mono)),
                        CopyButton(cmd),
                      ]),
                    );
                  }),
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerLeft, child: OutlinedButton(onPressed: _rotate, child: Text(l.networkRotate))),
                ]),
              ),
            if (_error.isNotEmpty) ErrorLine(_error),
          ]),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Row(children: [
          Expanded(
            child: OutlinedButton(onPressed: () => Navigator.pop(context), child: Text(_token.isNotEmpty ? l.networkDone : l.formCancel)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(cur != null ? l.formSave : l.networkAddSubmit),
            ),
          ),
        ]),
      ),
    ]);
  }
}
