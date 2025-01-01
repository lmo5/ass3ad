import '../entities/letter.dart';
import './letter_repository.dart';

class LetterRepositoryImpl implements LetterRepository {
  @override
  List<Letter> getLettersByLanguage(String language) {
    if (language == 'English') {
      return [
        Letter(name: 'A', unicode: 'A'),
        Letter(name: 'B', unicode: 'B'),
        // Add more letters
      ];
    } else if (language == 'Arabic') {
      return [
        Letter(name: 'Alif', unicode: 'ا'),
        Letter(name: 'Ba', unicode: 'ب'),
        // Add more letters
      ];
    }
    return [];
  }

  @override
  List<String> getAvailableLanguages() {
    return ['English', 'Arabic']; // Add more languages as needed
  }
}