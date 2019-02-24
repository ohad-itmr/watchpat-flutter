import 'dart:async';
import 'dart:io';
import 'package:my_pat/app/model/api/file_system_provider.dart';

class FileBloc {
  final filesProvider = FileSystemProvider();
  File _localFile;

  Stream<List<int>> get localFile => _localFile.openRead();

  Future<void> allocateSpace() async {
    await filesProvider.allocateSpace();
  }

  Future<void> createStartFiles() async {
    await filesProvider.init();
  }

  FileBloc() {
    init();
  }

  init() async {
    _localFile = await filesProvider.localDataFile;
    await createStartFiles();
    await allocateSpace();
  }

  dispose() {}
}
