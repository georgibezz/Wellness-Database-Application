import 'package:objectbox/objectbox.dart';
import 'plan.entity.dart';
import 'review.entity.dart';

@Sync()
@Entity()
class User {
  @Id()
  int id=0;

  @Property()
  String name;

  @Property()
  String email;

  @Property()
  String passwordHash;


  final review = ToMany<Reviews>();
  final plan = ToMany<Plans>();

  User({
    required this.name,
    required this.email,
    required this.passwordHash,
  });
}