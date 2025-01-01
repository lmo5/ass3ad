import '../../domain/repositories/letter_repository.dart';
import '../../domain/entities/letter.dart';

class LetterRepositoryImpl implements LetterRepository {
  final Map<String, List<Letter>> _lettersByLanguage = {
    'English': [
      Letter(imagePath: 'lib/assets/english/A.png', name: 'A', language: 'English'),
      Letter(imagePath: 'lib/assets/english/B.png', name: 'B', language: 'English'),
    ],
    'Arabic': [
      Letter(imagePath: 'lib/assets/arabic/alif.png', name: 'أ', language: 'Arabic'),
      Letter(imagePath: 'lib/assets/arabic/ba.png', name: 'ب', language: 'Arabic'),
    ],
  };

  @override
  List<Letter> getLettersByLanguage(String language) => _lettersByLanguage[language] ?? [];

  @override
  List<String> getAvailableLanguages() => _lettersByLanguage.keys.toList();
}
