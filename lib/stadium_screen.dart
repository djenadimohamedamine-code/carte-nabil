import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StadiumScreen extends StatefulWidget {
  const StadiumScreen({super.key});

  @override
  State<StadiumScreen> createState() => _StadiumScreenState();
}

class _StadiumScreenState extends State<StadiumScreen> {
  // --- TIFO STATE ---
  bool _isTifoActive = false;
  bool _tifoColorToggle = false;
  Timer? _tifoTimer;

  // --- AUDIO STATE ---
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingId;
  bool _isPlaying = false;
  bool _isUploading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  Future<void> _checkAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    final pseudo = prefs.getString('user_pseudo') ?? '';
    if (mounted) {
      // Si le pseudo contient "admin" (insensible à la casse) ou est exactement "admin"
      setState(() {
        _isAdmin = pseudo.trim().toLowerCase() == 'admin';
      });
    }
  }

  void _toggleTifo() {
    if (_isTifoActive) {
      _tifoTimer?.cancel();
      setState(() {
        _isTifoActive = false;
        _tifoColorToggle = false;
      });
    } else {
      setState(() => _isTifoActive = true);
      _tifoTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
        setState(() {
          _tifoColorToggle = !_tifoColorToggle;
        });
      });
    }
  }

  Future<void> _playChant(String id, String url) async {
    if (_playingId == id) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
      return;
    }

    if (url.isNotEmpty) {
      setState(() {
        _playingId = id;
        _position = Duration.zero;
        _duration = Duration.zero;
      });
      await _audioPlayer.play(UrlSource(url));
    }
  }

  Future<void> _uploadChant() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isUploading = true);
        
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        
        // Let user name the chant
        String chantName = fileName;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            final TextEditingController nameCtrl = TextEditingController(text: fileName.split('.').first);
            return AlertDialog(
              title: const Text('Nom du chant'),
              content: TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: "Ex: Ila Assima"),
              ),
              actions: [
                TextButton(
                  onPressed: () { chantName = nameCtrl.text.trim(); Navigator.pop(context); },
                  child: const Text('Valider'),
                )
              ],
            );
          }
        );

        if (chantName.isEmpty) chantName = "Chant sans nom";

        // Upload to Storage
        final ref = _storage.ref().child('chants/${DateTime.now().millisecondsSinceEpoch}_$fileName');
        final uploadTask = await ref.putFile(file);
        final url = await uploadTask.ref.getDownloadURL();

        // Save to Firestore
        await _firestore.collection('chants').add({
          'title': chantName,
          'url': url,
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chant envoye avec succes !')));
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  Future<void> _deleteChant(String id, String url) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer ce chant definitivement ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      )
    ) ?? false;

    if (confirm) {
      if (_playingId == id) {
        await _audioPlayer.stop();
        setState(() => _playingId = null);
      }
      await _firestore.collection('chants').doc(id).delete();
      try {
        await _storage.refFromURL(url).delete();
      } catch (e) {
        print('Cleanup storage error: $e');
      }
    }
  }

  @override
  void dispose() {
    _tifoTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: _isTifoActive 
          ? (_tifoColorToggle ? Theme.of(context).colorScheme.primary : Colors.black)
          : Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            // --- TIFO SECTION ---
            Container(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.stadium,
                    size: 80,
                    color: _isTifoActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Mode Stade",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _isTifoActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _toggleTifo,
                    icon: Icon(_isTifoActive ? Icons.stop : Icons.flash_on),
                    label: Text(_isTifoActive ? "Arreter le Tifo" : "Lancer le Tifo (Stade)"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: _isTifoActive ? Colors.white : Theme.of(context).colorScheme.primary,
                      foregroundColor: _isTifoActive ? Colors.black : Colors.white,
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            
            if (_isUploading) const LinearProgressIndicator(),

            // --- CHANTS SECTION ---
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _isTifoActive ? Colors.transparent : Theme.of(context).cardColor.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: _isTifoActive ? [] : [
                    const BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.music_note, color: _isTifoActive ? Colors.white : Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 10),
                              Text(
                                "Boite a Chants",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: _isTifoActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          if (!_isTifoActive && _isAdmin)
                            IconButton(
                              icon: const Icon(Icons.upload_file),
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: _isUploading ? null : _uploadChant,
                              tooltip: 'Ajouter un MP3',
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('chants').orderBy('timestamp', descending: true).snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                          
                          final docs = snapshot.data?.docs ?? [];
                          
                          if (docs.isEmpty) {
                            return Center(
                              child: Text(
                                'Aucun chant enregistre.\nAppuyez sur l\'icone upload pour en ajouter.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: _isTifoActive ? Colors.white70 : Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final String id = doc.id;
                              final String title = data['title'] ?? 'Chant inconnu';
                              final String url = data['url'] ?? '';
                              
                              final isThisPlaying = _playingId == id;
                              
                              return Column(
                                children: [
                                  ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isThisPlaying ? Colors.green.withOpacity(0.2) : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                      child: Icon(
                                        isThisPlaying&&_isPlaying ? Icons.multitrack_audio : Icons.music_video, 
                                        color: isThisPlaying ? Colors.green : Theme.of(context).colorScheme.primary
                                      ),
                                    ),
                                    title: Text(
                                      title, 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _isTifoActive ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                      )
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isThisPlaying && _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                                            size: 36,
                                          ),
                                          color: isThisPlaying && _isPlaying ? Colors.green : Theme.of(context).colorScheme.primary,
                                          onPressed: () => _playChant(id, url),
                                        ),
                                        if (!_isTifoActive && _isAdmin)
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                            onPressed: () => _deleteChant(id, url),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isThisPlaying && !_isTifoActive)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                      child: Row(
                                        children: [
                                          Text(
                                              "${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}",
                                              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface)
                                          ),
                                          Expanded(
                                            child: Slider(
                                              activeColor: Theme.of(context).colorScheme.primary,
                                              min: 0,
                                              max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0,
                                              value: _position.inSeconds.toDouble() <= (_duration.inSeconds.toDouble()>0?_duration.inSeconds.toDouble():1.0) ? _position.inSeconds.toDouble() : 0.0,
                                              onChanged: (value) async {
                                                await _audioPlayer.seek(Duration(seconds: value.toInt()));
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
