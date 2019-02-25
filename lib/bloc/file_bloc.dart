import 'dart:async';
import 'dart:io';
import 'package:my_pat/app/model/api/file_system_provider.dart';
import 'package:my_pat/bloc/bloc_base.dart';

class FileBloc extends BlocBase{
  final filesProvider = FileSystemProvider();
  File _localFile;

  get localFileRead => _localFile.openRead;
  get localFileWrite => _localFile.openWrite;

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
  }

  dispose() {}
}
