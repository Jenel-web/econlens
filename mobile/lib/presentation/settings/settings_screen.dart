import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _receiveAll = true;
  bool _criticalAlerts = true;
  bool _regularUpdates = true;
  bool _generalNews = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Notification Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Receive all notifications'),
            subtitle: const Text('Tumanggap ng lahat ng mahahalagang balita at update.'),
            value: _receiveAll,
            onChanged: (val) {
              setState(() {
                _receiveAll = val;
                if (val) {
                  _criticalAlerts = true;
                  _regularUpdates = true;
                  _generalNews = true;
                }
              });
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
            child: Text(
              'Severity Filter',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Critical Alerts'),
            subtitle: const Text('Mga balitang may malaking epekto sa bansa tulad ng biglaang taas-presyo ng gasolina, krisis sa kuryente, o malawakang sakuna sa ekonomiya. Ito ay nangangailangan ng agarang atensyon.'),
            value: _criticalAlerts,
            onChanged: (val) => setState(() => _criticalAlerts = val),
          ),
          SwitchListTile(
            title: const Text('Regular Updates'),
            subtitle: const Text('Regular na update tungkol sa inflation rate, palitan ng piso (USD to PHP), at mga bagong polisiya ng gobyerno na makakaapekto sa iyong pang-araw-araw na budget.'),
            value: _regularUpdates,
            onChanged: (val) => setState(() => _regularUpdates = val),
          ),
          SwitchListTile(
            title: const Text('General News'),
            subtitle: const Text('Pangkalahatang balita tungkol sa merkado, tips sa pag-iipon, at mga kwentong pang-ekonomiya na magandang malaman ngunit hindi kailangang basahin agad.'),
            value: _generalNews,
            onChanged: (val) => setState(() => _generalNews = val),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Developer',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text('Developer Options'),
            subtitle: const Text('Check backend connection'),
            leading: const Icon(Icons.developer_mode),
            onTap: () {
              context.push('/dev/backend-check');
            },
          ),
        ],
      ),
    );
  }
}
