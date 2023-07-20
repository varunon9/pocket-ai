class PocketAiAd {
  final String? description;
  final String? id;
  final String? navlink;
  final String? squareIconUrl;
  final String? title;
  final int? index;
  final String? backgroundColor;
  final String? contentColor;
  final bool? visible;

  PocketAiAd(
      {this.description,
      this.id,
      this.navlink,
      this.squareIconUrl,
      this.title,
      this.index,
      this.backgroundColor,
      this.contentColor,
      this.visible});

  factory PocketAiAd.fromJson(Map<String, dynamic> jsonData) {
    return PocketAiAd(
      description: jsonData['description'] as String?,
      id: jsonData['id'] as String?,
      navlink: jsonData['navlink'] as String?,
      squareIconUrl: jsonData['squareIconUrl'] as String?,
      title: jsonData['title'] as String?,
      index: jsonData['index'] as int?,
      backgroundColor: jsonData['backgroundColor'] as String?,
      contentColor: jsonData['contentColor'] as String?,
      visible: jsonData['visible'] as bool?,
    );
  }

  dynamic toJson() => {
        'description': description,
        'id': id,
        'navlink': navlink,
        'squareIconUrl': squareIconUrl,
        'title': title,
        'index': index,
        'backgroundColor': backgroundColor,
        'contentColor': contentColor,
        'visible': visible
      };

  @override
  String toString() {
    return toJson().toString();
  }
}
