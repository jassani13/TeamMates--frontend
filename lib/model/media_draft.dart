import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
class MediaDraft {
  final String kind; // 'image' or 'file'
  final XFile? image; // if kind == 'image'
  final PlatformFile? file; // if kind == 'file'
  final String name; // filename for display

  MediaDraft.image(this.image)
      : kind = 'image',
        file = null,
        name = image?.name ?? 'image';

  MediaDraft.file(this.file)
      : kind = 'file',
        image = null,
        name = file?.name ?? 'document';
}

class MediaPreviewResult {
  final bool confirmed;
  final String caption; // optional; if you don’t use captions server-side, you can ignore
  MediaPreviewResult({required this.confirmed, this.caption = ''});
}