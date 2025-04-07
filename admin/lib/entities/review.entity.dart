import 'package:objectbox/objectbox.dart';
import 'plan.entity.dart';
import 'user.entity.dart';

@Sync()
@Entity()
class Reviews{
  @Id()
  int id = 0;

  @Property()
  String rating;

  @Property()
  String comment;


  final plan = ToOne<Plans>();
  final user = ToOne<User>();

  Reviews({
    required this.rating,
    required this.comment,
  });
}