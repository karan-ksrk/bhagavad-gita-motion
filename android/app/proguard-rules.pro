# Release shrinking rules (D-145).
#
# Play Asset Delivery uses WorkManager, which opens its Room database by
# reflection (WorkDatabase_Impl no-arg constructor). R8 full mode in
# AGP 9 removes that constructor; keep generated Room databases.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
