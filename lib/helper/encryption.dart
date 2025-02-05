import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EncryptionUtil {
  // Fetch the key and IV from the environment file
  static final Key _key = Key.fromUtf8(dotenv.env['ENCRYPTION_KEY'] ?? 'default_key123456'); // Default value if not set
  static final IV _iv = IV.fromUtf8(dotenv.env['ENCRYPTION_IV'] ?? 'default_iv123456'); // Default value if not set
  static final Encrypter _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  static String encrypt(String text) {
    return _encrypter.encrypt(text, iv: _iv).base64;
  }

  static String decrypt(String encryptedText) {
    try {
      return _encrypter.decrypt64(encryptedText, iv: _iv);
    } catch (e) {
      return "Decryption Error"; // Handle error gracefully
    }
  }
}
