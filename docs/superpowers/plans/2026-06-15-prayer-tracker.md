# Prayer Tracker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (\`- [ ]\`) syntax for tracking.

**Goal:** Membangun fitur pelacakan salat harian (Tracker) agar pengguna bisa mencatat salat yang sudah dilakukan dan melihat statistik mingguan.

**Architecture:** Mengikuti Clean Architecture (Feature-First). Data disimpan di Hive box \`tracker_box\`. Logic perhitungan statistik berada di Domain layer.

**Tech Stack:** Flutter, Riverpod, Hive.

---

### Task 1: Domain Layer - Entity & Repository Interface

**Files:**
- Create: \`lib/features/tracker/domain/entities/prayer_log_entity.dart\`
- Create: \`lib/features/tracker/domain/repositories/tracker_repository.dart\`

- [ ] **Step 1: Define PrayerLogEntity**

\`\`\`dart
class PrayerLogEntity {
  const PrayerLogEntity({
    required this.date,
    required this.prayers,
  });
  final DateTime date;
  final Map<String, bool> prayers;

  PrayerLogEntity copyWith({Map<String, bool>? prayers}) {
    return PrayerLogEntity(
      date: date,
      prayers: prayers ?? this.prayers,
    );
  }
}
\`\`\`

- [ ] **Step 2: Define TrackerRepository interface**

\`\`\`dart
import '../entities/prayer_log_entity.dart';

abstract class TrackerRepository {
  Future<PrayerLogEntity> getLogByDate(DateTime date);
  Future<void> updatePrayerStatus(DateTime date, String prayerKey, bool isDone);
  Future<List<PrayerLogEntity>> getWeeklyLogs(DateTime endDate);
}
\`\`\`

### Task 2: Data Layer - Implementation

**Files:**
- Create: \`lib/features/tracker/data/models/prayer_log_dto.dart\`
- Create: \`lib/features/tracker/data/datasources/tracker_local_data_source.dart\`
- Create: \`lib/features/tracker/data/repositories/tracker_repository_impl.dart\`

- [ ] **Step 1: Implement TrackerLocalDataSourceImpl using Hive box \`tracker_box\`**
- [ ] **Step 2: Implement TrackerRepositoryImpl**

### Task 3: Presentation Layer - Tracker Provider

**Files:**
- Create: \`lib/features/tracker/presentation/providers/tracker_provider.dart\`

- [ ] **Step 1: Create TrackerNotifier (StateNotifier)**
- [ ] **Step 2: Expose trackerProvider**

### Task 4: UI - Integration into Home Screen

**Files:**
- Modify: \`lib/features/home/presentation/screens/home_screen.dart\`

- [ ] **Step 1: Add Prayer Tracker section with Checkboxes for today's prayers**
