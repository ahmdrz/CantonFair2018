import 'dart:io' as Io;
import 'package:image/image.dart';

void thumbnail(src, dst) async {  
  Image image = decodeImage(new Io.File(src).readAsBytesSync());
  Image thumbnail = copyResize(image, 120);
  new Io.File(dst).writeAsBytesSync(encodeJpg(thumbnail));
}
