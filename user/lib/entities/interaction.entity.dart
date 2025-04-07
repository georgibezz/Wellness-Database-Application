import 'package:objectbox/objectbox.dart';
import 'item.entity.dart';

@Sync()
@Entity()
class Interactions{
  @Id()
  int id = 0;

  @Property()
  String description;

  @Backlink('interaction')
  final items = ToMany<Items>();

  Interactions({
    required this.description,
  });
}