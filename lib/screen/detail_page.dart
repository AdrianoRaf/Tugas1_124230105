// lib/screen/detail_page.dart
import 'package:flutter/material.dart';
import 'package:olah_data/models/game_store_model.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPage extends StatefulWidget {
  final GameStore game;
  const DetailPage({super.key, required this.game});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _isLaunching = false;

  Future<void> _launchUrl() async {
    final link = widget.game.linkStore.trim();
    if (link.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No link available')));
      return;
    }

    final uri = Uri.parse(link);
    setState(() => _isLaunching = true);
    try {
      final can = await canLaunchUrl(uri);
      if (!can) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open link')));
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLaunching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      appBar: AppBar(
        title: Text(game.name),
        backgroundColor: Colors.blueGrey[200],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 220,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: game.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final url = game.imageUrls[index];
                  return Container(
                    width: 340,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 209, 231, 241),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          url,
                          width: 340,
                          fit: BoxFit.fitWidth,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              width: 340,
                              color: Colors.blueGrey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stack) {
                            return Container(
                              width: 340,
                              color: Colors.blueGrey[300],
                              child: const Icon(Icons.broken_image, size: 48),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            Text(
              game.name,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('Release: ${game.releaseDate}'),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: game.tags.map((t) => Chip(label: Text(t))).toList(),
            ),

            const SizedBox(height: 16),
            Text('About', style: textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(game.about),

            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLaunching ? null : _launchUrl,
                  icon: _isLaunching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.open_in_new),
                  label: Text(_isLaunching ? 'Opening...' : 'Open Store'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Text('Price: ${game.price}'),
            const SizedBox(height: 8),
            Text('Reviews: ${game.reviewAverage} (${game.reviewCount})'),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
