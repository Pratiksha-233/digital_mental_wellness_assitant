import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';
import 'camera_capture_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final TextEditingController _nameController;
  late final TextEditingController _photoController;
  late final AnimationController _bgCtrl;
  String? _localPhotoPath;
  Uint8List? _photoBytes;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? (user?.email?.split('@').first ?? ''));
    _photoController = TextEditingController(text: user?.photoURL ?? '');
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat(reverse: true);

    // Load saved overrides
    ProfileService.getDisplayName().then((name) {
      if (name != null && name.trim().isNotEmpty && mounted) {
        setState(() => _nameController.text = name);
      }
    });
    ProfileService.getPhotoPath().then((path) {
      if (mounted) setState(() => _localPhotoPath = path);
    });
    ProfileService.getPhotoBytesB64().then((b64) {
      if (b64 != null && b64.isNotEmpty && mounted) {
        try {
          setState(() => _photoBytes = base64Decode(b64));
        } catch (_) {}
      }
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
    if (user == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3))),
        child: Row(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.person_outline, size: 16, color: Colors.grey),
          SizedBox(width: 6),
          Text('Guest', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: const [
        Icon(Icons.check_circle, size: 16, color: Colors.green),
        SizedBox(width: 6),
        Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final localName = _nameController.text.trim();
    final headerName = localName.isNotEmpty ? localName : (user?.displayName ?? (user?.email?.split('@').first ?? 'User'));
    final email = user?.email ?? 'Guest (local profile)';
    final initials = headerName.trim().isNotEmpty
        ? headerName.trim().split(RegExp(r"\\s+")).map((s) => s.isNotEmpty ? s[0].toUpperCase() : '').take(2).join()
        : (email.isNotEmpty ? email[0].toUpperCase() : 'U');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final nav = Navigator.of(context);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              nav.pushNamedAndRemoveUntil('/login', (_) => false);
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(Colors.white, Colors.teal.shade50, t)!,
                        Color.lerp(Colors.white, Colors.purple.shade50, 1 - t)!,
                      ],
                    ),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 3))],
                  ),
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
                        Text(headerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
                              setState(() {
                                _localPhotoPath = x.path;
                                _photoBytes = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('Capture from camera'),
                          onPressed: () async {
                            final bytes = await Navigator.push<Uint8List?>(context, MaterialPageRoute(builder: (_) => const CameraCaptureScreen()));
                            if (bytes != null && bytes.isNotEmpty) {
                              setState(() {
                                _photoBytes = bytes;
                                _localPhotoPath = null;
                                _photoController.clear();
                              });
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
                        if (_photoBytes != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Clear captured'),
                              onPressed: () => setState(() => _photoBytes = null),
                            ),
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
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              final name = _nameController.text.trim();
                              if (name.isNotEmpty) {
                                await ProfileService.setDisplayName(name);
                              }
                              if (_localPhotoPath != null && _localPhotoPath!.isNotEmpty) {
                                await ProfileService.setPhotoPath(_localPhotoPath!);
                                await ProfileService.setPhotoBytesB64('');
                              } else if (_photoBytes != null && _photoBytes!.isNotEmpty) {
                                await ProfileService.setPhotoBytesB64(base64Encode(_photoBytes!));
                              }
                              await ProfileService.setLastSavedNow();
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
                              messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
                              setState(() {});
                            } catch (e) {
                              if (!mounted) return;
                              messenger.showSnackBar(SnackBar(content: Text('Update failed: $e')));
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

  ImageProvider? _photoImageProvider(User? user) {
    final url = _photoController.text.trim();
    if (_photoBytes != null && _photoBytes!.isNotEmpty) {
      return MemoryImage(_photoBytes!);
    }
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
