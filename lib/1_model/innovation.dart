import 'dart:typed_data';
import 'package:fhws_innovations/1_model/student_object.dart';

class Innovation {
  final Uint8List uniqueInnovationHash;
  final BigInt votingCount;
  final Student creator;
  late String title;
  late String description;
  bool isVoted;

  Innovation({
    required this.uniqueInnovationHash,
    required this.votingCount,
    required this.creator,
    required this.title,
    required this.isVoted,
    required this.description,
  });

  @override
  String toString() {
    return 'Innovation{uniqueInnovationHash: $uniqueInnovationHash, votingCount: $votingCount, creator: $creator, title: $title, description: $description}';
  }
}
