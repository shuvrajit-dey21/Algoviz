ListTile(
  leading: const Icon(Icons.help_outline),
  title: const Text('Help Center'),
  onTap: () {
    Navigator.pushNamed(context, '/help-center');
  },
), 