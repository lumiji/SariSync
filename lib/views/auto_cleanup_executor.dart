import 'package:sarisync/services/local_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AutoCleanupExecutor {
  static Future<void> run() async {
    final enabled = await LocalStorageService.getAutoCleanupEnabled();
    if (!enabled) return;

    final schedule = await LocalStorageService.getCleanupSchedule(); // weekly / monthly
    final lastCleanup = await LocalStorageService.getLastCleanupDate();

    final now = DateTime.now();
    final difference = lastCleanup != null ? now.difference(lastCleanup).inDays : null;

    bool shouldCleanup = false;
    if (schedule == "weekly" && (difference == null || difference >= 7)) {
      shouldCleanup = true;
    } else if (schedule == "monthly" && (difference == null || difference >= 30)) {
      shouldCleanup = true;
    }

    if (shouldCleanup) {
      await _cleanAllCollections();
      await LocalStorageService.saveLastCleanupDate();
    }
  }

  static Future<void> _cleanAllCollections() async {
    await _deleteAll("inventory");
    await _deleteAll("History");
    await _deleteAll("ledger");
    await _deleteAll("receipts");
    await _deleteAll("dailySales");
   

  }

  static Future<void> _deleteAll(String collectionPath) async {
    final snapshots = await FirebaseFirestore.instance.collection(collectionPath).get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}
