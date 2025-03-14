import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/providers_user/property_provider.dart';
import '../../common/services_user/property_service.dart';
import '../components/forms/post_property/steps/post_property_form.dart';

class PostPropertyScreen extends StatelessWidget {
  const PostPropertyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PropertyProvider>(
          create: (_) => PropertyProvider(),
        ),
        Provider<PropertyServiceUser>(
          create: (_) => PropertyServiceUser(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post a Property'),
        ),
        body: const PostPropertyForm(),
      ),
    );
  }
}
