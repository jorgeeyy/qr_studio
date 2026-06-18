import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_studio/models/qr_create_type.dart';

class CreateTypeNotifier extends Notifier<QrCreateType> {
  @override
  QrCreateType build() => QrCreateType.website;

  void update(QrCreateType type) => state = type;
}

final createTypeProvider =
    NotifierProvider<CreateTypeNotifier, QrCreateType>(CreateTypeNotifier.new);
