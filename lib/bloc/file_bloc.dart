import 'dart:io';
import 'dart:async';
import 'package:my_pat/api/response.dart';
import 'package:my_pat/utility/log/log.dart';
import 'package:rxdart/rxdart.dart';
import 'package:my_pat/api/file_system_provider.dart';
import 'package:my_pat/bloc/helpers/bloc_base.dart';
import 'package:my_pat/generated/i18n.dart';

class FileBloc extends BlocBase {
  S lang;

  final filesProvider = FileSystemProvider();
  BehaviorSubject<File> _localFileSubject = BehaviorSubject<File>();

  Observable<File> get localFile => _localFileSubject.stream;

  Stream<Response> allocateSpace() {
    return filesProvider.allocateSpace().asStream();
  }

  Stream<Response> createStartFiles() {
    return filesProvider.init().asStream();
  }

  FileBloc(s) {
    lang = s;
    filesProvider.localDataFile.asStream().listen((file) => _localFileSubject.add(file));
  }

  Observable<Response> init() {
    Log.info('[FileBloc INIT]');
    return Observable.combineLatest2(allocateSpace(), createStartFiles(),
        (Response as, Response cf) {
      if (as.success == true && cf.success == true) {
        return Response(success: true);
      }
      return Response(
        success: false,
        error: lang.insufficient_storage_space_on_smartphone,
      );
    });
  }

  dispose() {
    _localFileSubject.close();
  }
}
