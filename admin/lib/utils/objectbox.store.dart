import 'dart:io';
import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../entities/category.entity.dart';
import '../entities/condition.entity.dart';
import '../entities/interaction.entity.dart';
import '../entities/item.entity.dart';
import '../entities/plan.entity.dart';
import '../entities/review.entity.dart';
import '../entities/symptom.entity.dart';
import '../entities/user.entity.dart';
import '../objectbox.g.dart';

/// Provides access to the ObjectBox Store throughout the app.
/// Create this in the apps main function.
class ObjectBox {
  /// The Store of this app.
  late final Store _store;

  /// A Box of notes.
  late final Box<Items> _itemBox;
  late final Box<Categories> _categoryBox;
  late final Box<Conditions> _conditionBox;
  late final Box<Symptoms> _symptomBox;
  late final Box<Plans> _planBox;
  late final Box<Interactions> _interactionBox;
  late final Box<User> _userBox;
  late final Box<Reviews> _reviewBox;

  ObjectBox._create(this._store) {
    _itemBox = Box<Items>(_store);
    _categoryBox = Box <Categories>(_store);
    _conditionBox = Box <Conditions>(_store);
    _symptomBox = Box <Symptoms>(_store);
    _planBox = Box <Plans>(_store);
    _reviewBox = Box <Reviews>(_store);
    _userBox = Box <User>(_store);
    _interactionBox = Box<Interactions>(_store);


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
  Stream<List<Plans>> getPlans() {
    final builder = _planBox.query();
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  Future<void> updateCategory(Categories updatedCategory) {
    return _categoryBox.putAsync(updatedCategory);
  }

  Stream<List<Symptoms>> getSymptoms() {
    final builder = _symptomBox.query();
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  Future<void> addSymptom(String name, String description,
      List<String> complications, List<String> causes) {
    return _symptomBox.putAsync(Symptoms(
        name: name,
        description: description,
        complications: complications,
        causes: causes
    ));
  }

  Future<void> updateSymptom(Symptoms updatedSymptom) {
    return _symptomBox.putAsync(updatedSymptom);
  }

  Future<void> editSymptom(int id, String newName, String newDescription,
      List<String> newComplications, List<String> newCauses) {
    final symptom = _symptomBox.get(id);
    if (symptom != null) {
      symptom.name = newName;
      symptom.description = newDescription;
      symptom.complications = newComplications;
      symptom.causes = newCauses;
      return _symptomBox.putAsync(symptom);
    }
    return Future.value();
  }
  Stream<List<User>> getUsers() {
    final builder = _userBox.query();

    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
  Future<void> removeReview(int id) => _reviewBox.removeAsync(id);
  Stream<List<Reviews>> getReviews() {
    final builder = _reviewBox.query();
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }
  Future<void> removeSymptom(int id) => _symptomBox.removeAsync(id);

  Future<void> removeUser(int id) => _userBox.removeAsync(id);

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

  Future<void> addCondition(String name, String description,
      List<String> complications, List<String> causes) {
    return _conditionBox.putAsync(Conditions(
        name: name,
        description: description,
        complications: complications,
        causes: causes
    ));
  }

  Future<void> updateCondition(Conditions updatedCondition) {
    return _conditionBox.putAsync(updatedCondition);
  }

  Future<void> editCondition(int id, String newName, String newDescription,
      List<String> newComplications, List<String> newCauses) {
    final condition = _conditionBox.get(id);
    if (condition != null) {
      condition.name = newName;
      condition.description = newDescription;
      condition.complications = newComplications;
      condition.causes = newCauses;
      return _conditionBox.putAsync(condition);
    }
    return Future.value();
  }

  Future<void> removeCondition(int id) => _conditionBox.removeAsync(id);


  Future<void> addPlan(String name, String instructions, String dosage,
      String precautions, String references,
      String? item, String? condition, String? symptom) {
    return _planBox.putAsync(Plans(
        name: name,
        instructions: instructions,
        dosage: dosage,
        precautions: precautions,
        references: references));
  }

  Future<void> updatePlan(Plans updatedPlan) {
    return _planBox.putAsync(updatedPlan);
  }

  Future<void> editPlan(int id, String newName, String newInstructions,
      String newDosage, String newPrecautions, String newReferences) {
    final plan = _planBox.get(id);
    if (plan != null) {
      plan.name = newName;
      plan.instructions = newInstructions;
      plan.dosage = newDosage;
      plan.precautions = newPrecautions;
      plan.references = newReferences;
      return _planBox.putAsync(plan);
    }
    return Future.value();
  }

  Future<void> removePlan(int id) => _planBox.removeAsync(id);

  Stream<List<Items>> getItems() {
    final builder = _itemBox.query();
    return builder
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  Future<void> updateItem(Items updatedItem) {
    return _itemBox.putAsync(updatedItem);
  }

  Future<void> updateInteraction(Interactions updatedInteraction) {
    return _interactionBox.putAsync(updatedInteraction);
  }


  Future<void> editCategory(int id, String newName) {
    final category = _categoryBox.get(id);
    if (category != null) {
      category.name = newName;
      return _categoryBox.putAsync(category);
    }
    return Future.value();
  }

  Future<void> editItem(int id, String newName, String newAlsoCalled,
      String newUses, String newCaution, String newConsumerInfo,
      String newReference) {
    final item = _itemBox.get(id);
    if (item != null) {
      item.name = newName;
      item.alsoCalled = newAlsoCalled;
      item.uses = newUses;
      item.caution = newCaution;
      item.conscientiousConsumerInformation = newConsumerInfo;
      item.references = newReference;
      return _itemBox.putAsync(item);
    }
    return Future.value();
  }


  /*Future<void> updateInteraction(int id, String newDescription) {
    final interaction = _interactionBox.get(id);
    if (interaction != null) {
      interaction.description = newDescription;
      return _interactionBox.putAsync(interaction);
    }
    return Future.value();
  }*/

  Future<void> addInteraction(String name) =>
      _interactionBox.putAsync(Interactions(description: ''));

  Future<void> addCategory(String name) =>
      _categoryBox.putAsync(Categories(name: ''));

  Future<void> addItem(String name, String alsoCalled, String uses,
      String caution, String consumerinfo, String reference,
      [String? category]) {
    return _itemBox.putAsync(Items(
    name: name,
        alsoCalled: alsoCalled,
        uses: uses,
        caution: caution,
        conscientiousConsumerInformation: consumerinfo,
        references: reference));
  }


  Future<void> removeCategory(int id) => _categoryBox.removeAsync(id);

  Future<void> removeItem(int id) => _itemBox.removeAsync(id);

  Future<void> removeInteraction(int id) => _interactionBox.removeAsync(id);


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
}
