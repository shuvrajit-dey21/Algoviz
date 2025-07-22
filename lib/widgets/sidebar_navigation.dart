ListTile(
  leading: const Icon(Icons.help_outline),
  title: const Text('Help Center'),
  selected: currentRoute == '/help-center',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpCenterPage()),
    );
  },
), 