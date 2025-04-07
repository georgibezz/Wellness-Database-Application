import 'package:objectbox/objectbox.dart';

import 'category.entity.dart';
import 'interaction.entity.dart';
import 'plan.entity.dart';

@Sync()
@Entity()
class Items{
  @Id()
  int id = 0;

  @Property()
  String name;

  @Property()
  String alsoCalled;

  @Property()
  String uses;

  @Property()
  String caution;

  @Property()
  String conscientiousConsumerInformation;

  @Property()
  String references;

  @Transient()
  bool isSelected = false; // Add this line

  final category = ToOne<Categories>();
  @Backlink('item')
  final plan = ToMany<Plans>();
  final interaction = ToMany<Interactions>();



  Items({
    required this.name,
    required this.alsoCalled,
    required this.uses,
    required this.caution,
    required this.conscientiousConsumerInformation,
    required this.references,
  });
}
