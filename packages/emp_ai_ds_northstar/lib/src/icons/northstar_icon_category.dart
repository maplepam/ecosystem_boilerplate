/// Northstar icon library groups (Figma **Component: Icons** sheet).
enum NorthstarIconCategory {
  arrows,
  userInterface,
  realTime,
  processFolder,
  chat,
  statistics,
  content,
  calendar,
  direction,
  multimedia,
  shipping,
  weather,
  cloud,
  linking,
  social,
  bomList,
  science,
  other,
}

extension NorthstarIconCategoryCatalog on NorthstarIconCategory {
  /// Section title in the icon catalog.
  String get catalogTitle {
    return switch (this) {
      NorthstarIconCategory.arrows => 'Arrows',
      NorthstarIconCategory.userInterface => 'User interface',
      NorthstarIconCategory.realTime => 'Real time',
      NorthstarIconCategory.processFolder => 'Process folder',
      NorthstarIconCategory.chat => 'Chat',
      NorthstarIconCategory.statistics => 'Statistics',
      NorthstarIconCategory.content => 'Content',
      NorthstarIconCategory.calendar => 'Calendar',
      NorthstarIconCategory.direction => 'Direction',
      NorthstarIconCategory.multimedia => 'Multimedia',
      NorthstarIconCategory.shipping => 'Shipping & delivery',
      NorthstarIconCategory.weather => 'Weather',
      NorthstarIconCategory.cloud => 'Cloud',
      NorthstarIconCategory.linking => 'Linking',
      NorthstarIconCategory.social => 'Social media',
      NorthstarIconCategory.bomList => 'BOM list',
      NorthstarIconCategory.science => 'Science',
      NorthstarIconCategory.other => 'Other',
    };
  }

  /// Sort order in the catalog (Figma column flow).
  int get catalogOrder {
    return switch (this) {
      NorthstarIconCategory.arrows => 0,
      NorthstarIconCategory.userInterface => 1,
      NorthstarIconCategory.realTime => 2,
      NorthstarIconCategory.processFolder => 3,
      NorthstarIconCategory.chat => 4,
      NorthstarIconCategory.statistics => 5,
      NorthstarIconCategory.content => 6,
      NorthstarIconCategory.calendar => 7,
      NorthstarIconCategory.direction => 8,
      NorthstarIconCategory.multimedia => 9,
      NorthstarIconCategory.shipping => 10,
      NorthstarIconCategory.weather => 11,
      NorthstarIconCategory.cloud => 12,
      NorthstarIconCategory.linking => 13,
      NorthstarIconCategory.social => 14,
      NorthstarIconCategory.bomList => 15,
      NorthstarIconCategory.science => 16,
      NorthstarIconCategory.other => 99,
    };
  }
}
