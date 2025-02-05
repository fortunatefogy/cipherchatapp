import 'package:encrypt/encrypt.dart';

class EncryptionUtil {
  static final Key _key = Key.fromUtf8('1234567890123456'); // 16-byte key
  static final IV _iv = IV.fromUtf8('1234567890123456'); // 16-byte IV
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
