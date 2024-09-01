final List<RegExp> regex = [
  RegExp(r'\t'), // Remplace uniquement les tabulations
  RegExp(r'<iframe.*?<\/iframe>', caseSensitive: false), // Supprime les iframes
  RegExp(r'\s{2,}'), // Remplace les espaces multiples par un seul espace
  RegExp(r'\n{2,}'), // Remplace les retours à la ligne multiples par un seul
];

String cleanContentFromHtml(String content) {
  String cleanedContent = content;

  for (final reg in regex) {
    if (reg.pattern == r'\n{2,}') {
      cleanedContent = cleanedContent.replaceAll(
        reg,
        '\n',
      );
    } else {
      cleanedContent = cleanedContent.replaceAll(
        reg,
        ' ',
      );
    }
  }

  return cleanedContent.trim();
}
