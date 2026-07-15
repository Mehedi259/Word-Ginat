/// Helper class to map words to their dictionary images
class ImageMapper {
  // Map of word names to their image file names
  static const Map<String, String> _wordImageMap = {
    'doll': 'doll.jpg',
    'drafting board': 'drafting_board.jpg',
    'drawnwork': 'drawnwork.jpg',
    'dressing case': 'dressing_case.jpg',
    'dumplings': 'dumplings.jpg',
    'duvet': 'duvet.jpg',
    'edible fruit': 'edible_fruit.jpg',
    'educator': 'educator.jpg',
    'eft': 'eft.png',
    'egg': 'egg.jpg',
    'elastoplast': 'elastoplast.jpg',
    'eruca sativa': 'eruca_sativa.jpg',
    'eruca vesicaria sativa': 'eruca_vesicaria_sativa.jpg',
    'etui': 'etui.jpg',
    'eucalyptus viminalis': 'eucalyptus_viminalis.jpg',
    'eyepatch': 'eyepatch.jpg',
    'face towel': 'face_towel.jpg',
    'facial tissue': 'facial_tissue.jpg',
    'figurine': 'figurine.jpg',
    'filly': 'filly.png',
    'fishing pole': 'fishing_pole.jpg',
    'fishing rod': 'fishing_rod.jpg',
    'floweret': 'floweret.png',
    'fluff': 'fluff.jpg',
    'french chalk': 'french_chalk.jpg',
    'french pancake': 'french_pancake.jpg',
    'frisbee': 'frisbee.jpg',
    'galosh': 'galosh.jpg',
    'gameboard': 'gameboard.jpg',
    'garden rocket': 'garden_rocket.jpg',
    'gean': 'gean.jpg',
    'gecko': 'gecko.jpg',
    'genus bombus': 'genus_bombus.jpg',
    'gift shop': 'gift_shop.jpg',
    'green tea': 'green_tea.jpg',
    'gripsack': 'gripsack.jpg',
    'guidebook': 'guidebook.jpg',
    'gym mat': 'gym_mat.png',
    'gym suit': 'gym_suit.jpg',
    'hand drill': 'hand_drill.jpg',
    'handkerchief': 'handkerchief.jpg',
    'harris tweed': 'harris_tweed.jpg',
    'headdress': 'headdress.jpg',
    'headgear': 'headgear.jpg',
    'hoecake': 'hoecake.jpg',
    'hognose snake': 'hognose_snake.jpg',
    'hopscotch': 'hopscotch.jpg',
    'horse blanket': 'horse_blanket.jpg',
    'hula hoop': 'hula_hoop.jpg',
    'hyla arenicolor': 'hyla_arenicolor.jpg',
    'ice lolly': 'ice_lolly.jpg',
    'illicium anisatum': 'illicium_anisatum.jpg',
    'indicatoridae': 'indicatoridae.jpg',
    'infant school': 'infant_school.jpg',
    'ingot': 'ingot.png',
    'inner tube': 'inner_tube.jpg',
    'insulator': 'insulator.jpg',
    'ironing board': 'ironing_board.jpg',
    'italian greyhound': 'italian_greyhound.jpg',
    'jaconet': 'jaconet.png',
    'japanese maple': 'japanese_maple.jpg',
    'jump seat': 'jump_seat.jpg',
    'texture': 'texture.jpg',
    'tiger cub': 'tiger_cub.jpg',
    'tissue paper': 'tissue_paper.jpg',
    'toothbrush': 'toothbrush.jpg',
    'topee': 'topee.jpg',
    'toy': 'toy.jpg',
    'toy spaniel': 'toy_spaniel.jpg',
    'toyshop': 'toyshop.jpg',
    'trampoline': 'trampoline.jpg',
    'travel iron': 'travel_iron.jpg',
    'treble recorder': 'treble_recorder.jpg',
    'tree house': 'tree_house.jpg',
  };

  /// Get the image path for a given word
  /// Returns null if no image exists for this word
  static String? getImagePath(String word) {
    final normalizedWord = word.toLowerCase().trim();
    final fileName = _wordImageMap[normalizedWord];
    
    if (fileName != null) {
      return 'assets/dictionary_images/$fileName';
    }
    
    return null;
  }

  /// Check if an image exists for a given word
  static bool hasImage(String word) {
    final normalizedWord = word.toLowerCase().trim();
    return _wordImageMap.containsKey(normalizedWord);
  }

  /// Get all words that have images
  static List<String> getWordsWithImages() {
    return _wordImageMap.keys.toList();
  }

  /// Get the count of available images
  static int get imageCount => _wordImageMap.length;
}
