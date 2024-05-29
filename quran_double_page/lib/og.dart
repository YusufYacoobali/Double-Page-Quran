import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Viewer Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyPDFViewer(),
    );
  }
}

class MyPDFViewer extends StatefulWidget {
  @override
  _MyPDFViewerState createState() => _MyPDFViewerState();
}

class _MyPDFViewerState extends State<MyPDFViewer> {
  late Future<String> pdfPathFuture;

  @override
  void initState() {
    super.initState();
    pdfPathFuture = loadPDFFromAsset('assets/quran_source_v.pdf');
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<String> loadPDFFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    print('PDF loaded successfully: ${tempFile.path}');
    return tempFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          final bool isPortrait = orientation == Orientation.portrait;
          final String assetPath = isPortrait
              ? 'assets/quran_source_v.pdf'
              : 'assets/quran_source_double_close.pdf';

          // Update the pdfPathFuture based on orientation change
          pdfPathFuture = loadPDFFromAsset(assetPath);

          return FutureBuilder<String>(
            future: pdfPathFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading PDF: ${snapshot.error}'),
                );
              } else {
                final String pdfPath = snapshot.data!;
                print('Displaying PDF: $pdfPath');

                return PDFView(
                  filePath: pdfPath,
                  swipeHorizontal: true,
                  fitPolicy: isPortrait ? FitPolicy.WIDTH : FitPolicy.HEIGHT,
                  onError: (error) {
                    print('PDF loading error: $error');
                  },
                  onPageError: (page, error) {
                    print('Error on page $page: $error');
                  },
                  onViewCreated: (PDFViewController controller) {
                    print('PDF loading successful!');
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
