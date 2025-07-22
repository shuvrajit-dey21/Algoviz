Widget _buildCategoryCard(
  BuildContext context, {
  required String title,
  required String description,
  required IconData icon,
  required Color color,
  required VoidCallback onTap,
}) {
  return Card(
    // ... existing card styling ...
    child: InkWell(
      onTap: onTap, // This will use the passed onTap function
      // ... existing card content ...
    ),
  );
} 