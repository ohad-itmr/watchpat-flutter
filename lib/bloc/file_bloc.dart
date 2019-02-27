import 'dart:async';
import 'dart:io';
import 'package:my_pat/app/model/api/response.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_pat/app/model/api/file_system_provider.dart';
import 'package:my_pat/bloc/helpers/bloc_base.dart';

class FileBloc extends BlocBase {
  final filesProvider = FileSystemProvider();
  BehaviorSubject<File> _localFileSubject = BehaviorSubject<File>();

  Observable<File> get localFile => _localFileSubject.stream;

  Stream<Response> allocateSpace() {
    return filesProvider.allocateSpace().asStream();
  }

  Stream<Response> createStartFiles() {
    return filesProvider.init().asStream();
  }

  FileBloc() {
    filesProvider.localDataFile.asStream().listen((file) => _localFileSubject.add(file));
  }

  Observable<Response> init() {
    print('[FileBloc INIT]');
    return Observable.combineLatest2(allocateSpace(), createStartFiles(), (Response as, Response cf) {
      print('as ${as.success}');
      print('cf ${cf.success}');
      return Response(success: true);
    });
  }

  dispose() {
    _localFileSubject.close();
  }
}
