import '../entities/letter.dart';

abstract class LetterRepository {
  List<Letter> getLettersByLanguage(String language);
  List<String> getAvailableLanguages();
}
