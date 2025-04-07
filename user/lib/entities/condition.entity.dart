import 'package:objectbox/objectbox.dart';

import 'plan.entity.dart';

@Sync()
@Entity()
class Conditions{
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

  @Backlink('condition')
  final plan = ToMany<Plans>();


  Conditions({
    required this.name,
    required this.description,
    required this.complications,
    required this.causes,
  });
}
