import 'dart:io';
import 'package:image_picker/image_picker.dart';
/**
 * 카메라 또는 갤러리를 통해 사진을 가져올 수 있다.
 * File 변수에 해당 함수의 리턴값을 받아준다.
 */
class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  static Future<File?> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    return pickedFile != null ? File(pickedFile.path) : null;
  }
}
