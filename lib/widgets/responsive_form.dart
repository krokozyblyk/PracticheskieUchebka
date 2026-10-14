import 'package:flutter/material.dart';

class ResponsiveForm extends StatelessWidget {
  const ResponsiveForm({
    super.key,
    required this.children,
    this.formKey,
    this.maxWidth = 440,
  });

  final List<Widget> children;
  final GlobalKey<FormState>? formKey;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
