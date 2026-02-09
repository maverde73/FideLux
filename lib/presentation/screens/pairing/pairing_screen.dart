import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../providers/crypto_providers.dart';
import '../../providers/pairing_providers.dart';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  // MobileScannerController controller = MobileScannerController(); 
  // Should handle disposing/pausing.

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pairing'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My QR', icon: Icon(Icons.qr_code)),
              Tab(text: 'Scan', icon: Icon(Icons.camera_alt)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _MyQRView(),
            _ScanQRView(),
          ],
        ),
      ),
    );
  }
}

class _MyQRView extends ConsumerWidget {
  const _MyQRView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleAsync = ref.watch(myRoleProvider);

    return roleAsync.when(
      data: (role) {
        if (role == null) return const Center(child: Text("Identity not found. Generate one first."));
        
        final pairingDataFuture = ref.read(generatePairingQrProvider).call(role);
        
        return FutureBuilder(
          future: pairingDataFuture,
          builder: (context, qrSnapshot) {
            if (qrSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!qrSnapshot.hasData || qrSnapshot.data == null) {
               return const Center(child: Text("Error generating QR data"));
            }

            final data = qrSnapshot.data!;
            final qrContent = data.toQrString();

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("I am a ${role.name}", style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  QrImageView(
                    data: qrContent,
                    version: QrVersions.auto,
                    size: 280.0,
                    backgroundColor: Colors.white, 
                  ),
                  const SizedBox(height: 20),
                  const Text("Have the peer scan this code."),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _ScanQRView extends ConsumerStatefulWidget {
  const _ScanQRView();

  @override
  ConsumerState<_ScanQRView> createState() => _ScanQRViewState();
}

class _ScanQRViewState extends ConsumerState<_ScanQRView> {
  bool _hasPermission = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() => _isProcessing = true);

    try {
      final role = await ref.read(myRoleProvider.future);
      if (role == null) throw Exception("Identity not found. Generate one first.");

      await ref.read(processPairingQrProvider).call(
        qrData: code,
        myRole: role,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Pairing Successful! Peer Key Saved.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Pairing Failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Center(
        child: ElevatedButton(
          onPressed: _checkPermission,
          child: const Text("Grant Camera Permission"),
        ),
      );
    }

    return MobileScanner(
      onDetect: _onDetect,
    );
  }
}
