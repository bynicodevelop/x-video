import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;
import 'package:x_video_ai/controllers/category_controller.dart';
import 'package:x_video_ai/controllers/category_list_controller.dart';
import 'package:x_video_ai/models/category_model.dart';

class CategoryFormElement extends ConsumerStatefulWidget {
  final String keyword;
  final Function(CategoryModel) onCategorySelected;

  const CategoryFormElement({
    required this.keyword,
    required this.onCategorySelected,
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CategoryFormElementState();
}

class _CategoryFormElementState extends ConsumerState<CategoryFormElement> {
  bool showTextField = false;

  List<CategoryModel> filteredCategories = [];

  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    Future.microtask(
      () async {
        final categoryListController =
            ref.read(categoryListControllerProvider.notifier);

        await categoryListController.loadCategories();
        filteredCategories = categoryListController.categories;

        _focusNode.requestFocus();
      },
    );

    // Ajouter un listener pour filtrer les catégories
    _textEditingController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Fonction pour filtrer les catégories en fonction de l'entrée utilisateur
  void _filterCategories() {
    setState(() {
      final query = _textEditingController.text.trim().toLowerCase();
      final categoryListController =
          ref.read(categoryListControllerProvider.notifier);

      if (query.isEmpty) {
        filteredCategories = categoryListController.categories;
      } else {
        filteredCategories = categoryListController.categories
            .where((category) =>
                _matchesPattern(removeDiacritics(category.name), query))
            .toList();
      }
    });
  }

  String removeDiacritics(String str) {
    return unorm.nfd(str).replaceAll(RegExp(r'[\u0300-\u036f]'), '');
  }

  bool _matchesPattern(String word, String pattern) {
    final regExpPattern = pattern.split('').join('.*');
    final regExp = RegExp(regExpPattern);
    return regExp.hasMatch(word);
  }

  Future<void> _createNewCategory(String categoryName) async {
    final categoryListController =
        ref.read(categoryListControllerProvider.notifier);

    await ref.read(categoryControllerProvider.notifier).createCategory(
          categoryName,
        );

    await categoryListController.loadCategories();

    setState(() {
      _textEditingController.clear();
      filteredCategories = categoryListController.categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    const heigthSize = 90.0;
    final categoryListController =
        ref.read(categoryListControllerProvider.notifier);
    ref.watch(categoryListControllerProvider);

    return Stack(
      children: [
        if (categoryListController.categories.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              top: heigthSize,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: filteredCategories.isNotEmpty ? 10 : 40,
                ),
                filteredCategories.isNotEmpty
                    ? ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];

                          return ListTile(
                            title: Text(
                              "${category.name} (${category.videos.length})",
                            ),
                            onTap: () => widget.onCategorySelected(category),
                          );
                        },
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                // TODO: Add to translation
                                text: 'Aucune catégorie trouvée ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium, // Style normal
                                children: [
                                  TextSpan(
                                    text: '"${_textEditingController.text}"',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextButton(
                              onPressed: () => _createNewCategory(
                                _textEditingController.text,
                              ),
                              child:
                                  // TODO: Add to translation
                                  const Text('Créer cette nouvelle catégorie'),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        // Champ de texte pour la recherche (sticky)
        Container(
          constraints: const BoxConstraints(
            minHeight: heigthSize,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ref
                      .read(categoryListControllerProvider.notifier)
                      .categories
                      .isNotEmpty
                  ? TextField(
                      focusNode: _focusNode,
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        // TODO: Add to translation
                        labelText: 'Rechercher une catégorie',
                        suffixIcon: _textEditingController.text.isEmpty
                            ? const Icon(Icons.search)
                            : IconButton(
                                onPressed: () => _textEditingController.clear(),
                                icon: const Icon(Icons.clear),
                              ),
                      ),
                    )
                  : TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        // TODO: Add to translation
                        labelText: 'Créer une catégorie',
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _createNewCategory(
                              _textEditingController.text,
                            ), // Créer une nouvelle catégorie
                          ),
                        ),
                      ),
                    ),
              const SizedBox(
                height: 10,
              ),
              Text.rich(
                TextSpan(
                    // TODO: Add keyword to the text
                    text: "Cette partie est associée au mot-clé : ",
                    style: Theme.of(context).textTheme.bodySmall!,
                    children: [
                      TextSpan(
                        text: widget.keyword,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ]),
              )
            ],
          ),
        ),
      ],
    );
  }
}
