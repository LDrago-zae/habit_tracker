import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker/themes/theme_provider.dart';
import 'package:provider/provider.dart' show Provider;

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Settings',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            title: const Text('Dark Mode'),
            trailing: CupertinoSwitch(
              value:
                  Provider.of<ThemeProvider>(
                    context,
                  ).isDarkMode, // Use isDarkMode getter
              onChanged: (value) {
                Provider.of<ThemeProvider>(
                  context,
                  listen: false,
                ).toggleTheme(); // Correct toggleTheme call
              },
            ),
          ),
        ],
      ),
    );
  }
}
