import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SignatureScreen extends StatefulWidget {
  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final controller = SignatureController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tanda Tangan")),
      body: Column(
        children: [
          Expanded(
            child: Signature(
              controller: controller,
              backgroundColor: Colors.grey[200]!,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => controller.clear(),
                child: Text("Clear"),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () async {
                  final data = await controller.toPngBytes();
                  Navigator.pop(context, data);
                },
                child: Text("Simpan"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
