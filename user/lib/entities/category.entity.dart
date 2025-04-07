import 'package:objectbox/objectbox.dart';
import 'item.entity.dart';

@Sync()
@Entity()
class Categories{
  @Id()
  int id = 0;

  @Property()
  String name;

  @Transient()
  bool isSelected = false; // Add this line

  @Backlink('category')
  final items = ToMany<Items>();

  Categories({
    required this.name,
  });
}
