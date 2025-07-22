ListTile(
  leading: const Icon(Icons.settings),
  title: const Text('Settings'),
  onTap: () {
    Navigator.pushNamed(context, '/settings');
  },
), 