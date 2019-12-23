import '../screens/out_barcode_page.dart';
import '../screens/in_barcode_page.dart';
import '../screens/candidate_page.dart';

typedef T Constructor<T>();

final Map<String, Constructor<Object>> _constructors = <String, Constructor<Object>>{};

void register<T>(Constructor<T> constructor) {
  _constructors[T.toString()] = constructor;
}

class ClassBuilder {
  static void registerClasses() {
    register<InBarcodePage>(() => InBarcodePage());
    register<OutBarcodePage>(() => OutBarcodePage());
    register<Candidate_page>(() => Candidate_page());
  }

  static dynamic fromString(String type) {
    return _constructors[type]();
  }
}
