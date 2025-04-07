import 'package:objectbox/objectbox.dart';
import 'condition.entity.dart';
import 'item.entity.dart';
import 'review.entity.dart';
import 'symptom.entity.dart';
import 'user.entity.dart';

@Sync()
@Entity()
class Plans{
  @Id()
  int id = 0;

  @Property()
  String name;

  @Property()
  String instructions;

  @Property()
  String dosage;

  @Property()
  String precautions;

  @Property()
  String references;

  @Transient()
  bool isSelected = false; // Add this line

  @Backlink('plan')
  final review = ToMany<Reviews>();
  final user = ToMany<User>();

  final item = ToOne<Items>();
  final condition = ToOne<Conditions>();
  final symptom = ToOne<Symptoms>();

  Plans({
    required this.name,
    required this.instructions,
    required this.dosage,
    required this.precautions,
    required this.references,
  });
}
