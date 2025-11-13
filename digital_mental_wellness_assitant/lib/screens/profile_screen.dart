import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _photoController;
  late final AnimationController _bgCtrl;
  String? _localPhotoPath; // from gallery or saved

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? (user?.email?.split('@').first ?? ''));
    _photoController = TextEditingController(text: user?.photoURL ?? '');
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat(reverse: true);
    // Load locally saved overrides
    ProfileService.getDisplayName().then((name) {
      if (name != null && name.trim().isNotEmpty && mounted) {
        setState(() => _nameController.text = name);
      }
    });
    ProfileService.getPhotoPath().then((path) {
      if (mounted) setState(() => _localPhotoPath = path);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoController.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  Widget _statusChip(User? user) {
    final creation = user?.metadata.creationTime;
    final lastSignIn = user?.metadata.lastSignInTime;
    String label = 'Active';
    Color color = Colors.green;
    final now = DateTime.now();
    if (creation != null && now.difference(creation).inDays < 3) {
      label = 'New';
      color = Colors.blue;
    } else if (lastSignIn != null && now.difference(lastSignIn).inDays > 2) {
      label = 'Returning';
      color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(label == 'Active' ? Icons.check_circle : (label == 'New' ? Icons.fiber_new : Icons.refresh), size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final resolvedName = user?.displayName ?? (user?.email?.split('@').first ?? 'User');
    final email = user?.email ?? 'no-email';
    final created = user?.metadata.creationTime?.toLocal().toString().split(' ').first ?? '-';
    final lastSeen = user?.metadata.lastSignInTime?.toLocal().toString().split(' ').first ?? '-';
    final initials = resolvedName.trim().isNotEmpty
        ? resolvedName.trim().split(RegExp(r"\s+")).map((s) => s.isNotEmpty ? s[0].toUpperCase() : '').take(2).join()
        : (email.isNotEmpty ? email[0].toUpperCase() : 'U');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          )
        ],
      ),
      body: AnimatedBuilder(
        animation: _bgCtrl,
        builder: (context, _) {
          final t = _bgCtrl.value;
          final c1 = Color.lerp(Colors.teal.shade50, Colors.blue.shade50, t)!;
          final c2 = Color.lerp(Colors.white, Colors.teal.shade100, 1 - t)!;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [c1, c2]),
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 3))]),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.purple.shade100,
                      backgroundImage: _photoImageProvider(user),
                      child: _photoImageProvider(user) == null ? Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)) : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(resolvedName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(color: Colors.black54)),
                      ]),
                    ),
                    _statusChip(user),
                  ]),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Account Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _kv('User ID', user?.uid ?? '-'),
                      _kv('Member since', created),
                      _kv('Last seen', lastSeen),
                      _kv('Email verified', (user?.emailVerified ?? false) ? 'Yes' : 'No'),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Edit Profile', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Display name', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _photoController,
                        decoration: const InputDecoration(labelText: 'Photo URL (optional)', prefixIcon: Icon(Icons.link), border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      Row(children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Pick from gallery'),
                          onPressed: () async {
                            final picker = ImagePicker();
                            final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, imageQuality: 85);
                            if (x != null) {
                              setState(() => _localPhotoPath = x.path);
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        if (_localPhotoPath != null)
                          OutlinedButton.icon(
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Remove photo'),
                            onPressed: () => setState(() => _localPhotoPath = null),
                          ),
                      ]),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                          icon: const Icon(Icons.save_alt),
                          label: const Text('Save Changes'),
                          onPressed: () async {
                            try {
                              final name = _nameController.text.trim();
                              if (name.isNotEmpty) {
                                await ProfileService.setDisplayName(name);
                              }
                              if (_localPhotoPath != null && _localPhotoPath!.isNotEmpty) {
                                await ProfileService.setPhotoPath(_localPhotoPath!);
                              }
                              final u = FirebaseAuth.instance.currentUser;
                              if (u != null) {
                                if (name.isNotEmpty) {
                                  await u.updateDisplayName(name);
                                }
                                final url = _photoController.text.trim();
                                if (url.isNotEmpty) {
                                  await u.updatePhotoURL(url);
                                }
                                await u.reload();
                              }
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
                              setState(() {});
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
                            }
                          },
                        ),
                      )
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(children: [
        SizedBox(width: 140, child: Text(k, style: const TextStyle(color: Colors.black54))),
        Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
    );
  }

  ImageProvider? _photoImageProvider(User? user) {
    final url = _photoController.text.trim();
    if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
      return NetworkImage(url);
    }
    if (_localPhotoPath != null && _localPhotoPath!.isNotEmpty) {
      final file = File(_localPhotoPath!);
      if (file.existsSync()) return FileImage(file);
    }
    final uUrl = user?.photoURL;
    if (uUrl != null && uUrl.isNotEmpty) return NetworkImage(uUrl);
    return null;
  }
}
