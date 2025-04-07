import 'dart:io';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:september_twenty_nine_user/entities/user.entity.dart';
import '../entities/category.entity.dart';
import '../entities/condition.entity.dart';
import '../entities/interaction.entity.dart';
import '../entities/item.entity.dart';
import '../entities/plan.entity.dart';
import '../entities/review.entity.dart';
import '../entities/symptom.entity.dart';
import '../objectbox.g.dart';

/// Provides access to the ObjectBox Store throughout the app.
/// Create this in the apps main function.
class ObjectBox {
  static ObjectBox? _instance;

  static Future<ObjectBox> getInstance() async {
    if (_instance == null) {
      _instance = await ObjectBox.create();
    }
    return _instance!;
  }
  Box<User> getUserBox() {
    return _userBox;
  }
  Box<Reviews> getReviewBox() {
    return _reviewBox;
  }
  Box<Plans> getPlanBox() {
    return _planBox;
  }
  /// The Store of this app.
  late final Store _store;

  /// A Box of notes.
  late final Box<Items> _itemBox;
  late final Box<Categories> _categoryBox;
  late final Box<Conditions> _conditionBox;
  late final Box<Reviews> _reviewBox;
  late final Box<Symptoms> _symptomBox;
  late final Box<Plans> _planBox;
  late final Box<User> _userBox;
  late final Box<Interactions> _interactionBox;

  ObjectBox._create(this._store) {
    _itemBox = Box<Items>(_store);
    _categoryBox = Box <Categories>(_store);
    _conditionBox = Box <Conditions>(_store);
    _symptomBox = Box <Symptoms>(_store);
    _planBox = Box <Plans>(_store);
    _reviewBox = Box <Reviews>(_store);
    _interactionBox = Box<Interactions>(_store);
    _userBox = Box<User>(_store);

    // TODO configure actual sync server address and authentication
    // For configuration and docs, see objectbox/lib/src/sync.dart
    // 10.0.2.2 is your host PC if an app is run in an Android emulator.
    // 127.0.0.1 is your host PC if an app is run in an iOS simulator.
    final syncServerIp = Platform.isAndroid
        ? '137.158.109.230'
        : '137.158.109.230';
    final syncClient =
    Sync.client(_store, 'ws://$syncServerIp:9999', SyncCredentials.none());
    syncClient.start();
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    final store = await openStore(
        directory: p.join(
            (await getApplicationDocumentsDirectory()).path,
            "wellness database"));
    return ObjectBox._create(store);
  }


  Stream<List<Categories>> getCategories() {
    final builder = _categoryBox.query();
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
  Stream<List<User>> getUsers() {
    final builder = _userBox.query();
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
  Future<void> addUser(String name, String email, String password) {
    return _userBox.putAsync(User(
        name: name,
        email: email,
        passwordHash: password,));
  }
  Future<void> addReview(String rating, String comment, int userId) async {
    final review = Reviews(
      rating: rating,
      comment: comment,
    );

    final user = _userBox.get(userId);

    if (user != null) {
      review.user.target = user;
      await _reviewBox.put(review);  // Save the review after setting the user target.
    }
  }

  Stream<List<Reviews>> getReviews() {
    final builder = _reviewBox.query();
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
  Future<void> removeReview(int id) => _reviewBox.removeAsync(id);

  Future<void> updatePlan(Plans updatedPlan) {
    return _planBox.putAsync(updatedPlan);
  }
  Stream<List<Symptoms>> getSymptoms() {
    final builder = _symptomBox.query();
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
  Stream<List<Interactions>> getInteractions() {
    final builder = _interactionBox.query();

    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
  Stream<List<Conditions>> getConditions() {
    final builder = _conditionBox.query();
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
  Stream<List<Plans>> getPlans() {
    final builder = _planBox.query();
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }


  Stream<List<Items>> getItems() {
    final builder = _itemBox.query();
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  Stream<List<Items>> getItemsFilteredBy(int categoryId) {
    final builder = _itemBox.query(Items_.category.equals(categoryId));
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
  Stream<List<Plans>> getPlanByItem(int itemId) {
    final builder = _planBox.query(Plans_.item.equals(itemId));
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
  Stream<List<Plans>> getPlansForCondition(int conditionId) {
    final builder = _planBox.query(Plans_.condition.equals(conditionId));
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
  Stream<Items> getItemForPlan(int planId) {
    final builder = _itemBox.query(Items_.id.equals(planId));
    return builder
        .watch(triggerImmediately: true)
        .map((query) {
      final items = query.find();
      if (items.isNotEmpty) {
        return items.first;
      } else {
        throw Exception('Item not found');
      }
    });
  }


  Interactions? findInteractionByItems(int id, int id2) {
    final interactions = _interactionBox
        .getAll(); // Assuming getAll() fetches all interactions
    for (Interactions interaction in interactions) {
      var itemIds = interaction.items.map((item) => item.id).toList();
      // Check if both item IDs are present in the current interaction
      if (itemIds.contains(id) && itemIds.contains(id2)) {
        return interaction;
      }
    }
  }

  // Get Plans by Condition and Category
  Future<List<Plans>> getPlansByConditionAndCategory(int conditionId, int categoryId) async {
    final plansBox = _store.box<Plans>();
    final itemsBox = _store.box<Items>();

    // Fetch all plans and items first
    final allPlans = plansBox.getAll();
    final allItems = itemsBox.getAll();

    return allPlans.where((plan) {
      final condition = plan.condition.target;
      final item = plan.item.target;

      return condition != null && condition.id == conditionId &&
          item != null && item.category.target?.id == categoryId;
    }).toList();
  }


  Future<List<Plans>> getPlansBySymptomAndCategory(int symptomId, int categoryId) async {
    final plansBox = _store.box<Plans>();
    final itemsBox = _store.box<Items>();

    // Fetch all plans and items first
    final allPlans = plansBox.getAll();
    final allItems = itemsBox.getAll();

    return allPlans.where((plan) {
      final symptom = plan.symptom.target;
      final item = plan.item.target;

      return symptom != null && symptom.id == symptomId &&
          item != null && item.category.target?.id == categoryId;
    }).toList();
  }

 /* Future<List<String>> fetchRemedyPlans(int conditionId) async {
    // Replace the following lines with your ObjectBox fetching logic

    final box = Store._box<Plans>();
    final plansQuery = box.query(Plans_.condition.equals(conditionId)).build();
    final plans = plansQuery.find();

    // Extracting plan names and returning them as a List<String>
    return plans.map((plan) => plan.name).toList();
  }*/

}
