import 'dart:io';
import 'package:anymex/stubs/extension_stubs.dart';
import 'package:anymex/controllers/settings/settings.dart';
import 'package:anymex/screens/settings/sub_settings/widgets/repo_dialog.dart';
import 'package:anymex/widgets/common/custom_tiles.dart';
import 'package:anymex/widgets/common/glow.dart';
import 'package:anymex/widgets/custom_widgets/custom_expansion_tile.dart';
import 'package:anymex/widgets/helper/platform_builder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class SettingsExtensions extends StatefulWidget {
  const SettingsExtensions({super.key});

  @override
  State<SettingsExtensions> createState() => _SettingsExtensionsState();
}

class _SettingsExtensionsState extends State<SettingsExtensions> {
  final settings = Get.find<Settings>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Glow(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: getResponsiveValue(context,
                mobileValue: const EdgeInsets.fromLTRB(10.0, 50.0, 10.0, 20.0),
                desktopValue:
                    const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainer
                            .withOpacity(0.5),
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 10),
                    const Text("Extensions",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnymexExpansionTile(
                        initialExpanded: true,
                        title: 'Extensions',
                        content: Column(
                          children: [
                            CustomTile(
                              icon: HugeIcons.strokeRoundedGithub,
                              title: 'Github Repo',
                              description: "Add github repo for extensions",
                              onTap: () => const GitHubRepoDialog(
                                type: ItemType.anime,
                                extType: ExtensionType.mangayomi,
                              ).show(context: context),
                            ),
                          ],
                        )),
                    if (Platform.isAndroid)
                      AnymexExpansionTile(
                          initialExpanded: true,
                          title: 'Android Extensions',
                          content: Column(
                            children: [
                              CustomTile(
                                icon: HugeIcons.strokeRoundedGithub,
                                title: 'Github Repo',
                                description: "Add github repo for android extensions",
                                onTap: () => const GitHubRepoDialog(
                                  type: ItemType.anime,
                                  extType: ExtensionType.aniyomi,
                                ).show(context: context),
                              ),
                            ],
                          )),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}