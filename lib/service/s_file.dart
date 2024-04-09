import 'dart:io';

import 'package:elbe/elbe.dart';
import 'package:elbe/util/m_data.dart';
import 'package:file_picker/file_picker.dart';

class PrintFile extends DataModel {
  final String name;
  final String type;
  final String path;

  PrintFile({
    required this.name,
    required this.type,
    required this.path,
  });

  @override
  get map => {
        'name': name,
        'type': type,
        'path': path,
      };

  IconData get icon {
    switch (type) {
      case 'pdf':
        return Icons.fileText;
      case 'txt':
        return Icons.fileType;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.fileImage;
      default:
        return Icons.file;
    }
  }
}

class FileService {
  static FileService i = FileService._();
  FileService._();

  Future<PrintFile?> userPick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'jpg', 'jpeg', 'png', 'gif']);

    if (result == null) return null;
    return PrintFile(
      name: result.files.single.name,
      type: result.files.single.extension ?? '',
      path: result.files.single.path ?? '',
    );
  }
}
