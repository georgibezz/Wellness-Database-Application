import 'package:objectbox/objectbox.dart';
import 'plan.entity.dart';

@Sync()
@Entity()
class Symptoms{
  @Id()
  int id = 0;

  @Property()
  String name;

  @Property()
  String description;

  @Property()
  List<String> causes;

  @Property()
  List<String> complications;

  @Transient()
  bool isSelected = false; // Add this line

  @Backlink('symptom')
  final plan = ToMany<Plans>();


  Symptoms({
    required this.name,
    required this.description,
    required this.complications,
    required this.causes,
  });
}
