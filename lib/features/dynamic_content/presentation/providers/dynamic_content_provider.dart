import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_am/features/dynamic_content/data/services/dynamic_content_service.dart';
import 'package:kids_am/features/dynamic_content/domain/models/content_bundle.dart';
import 'package:kids_am/features/stories/presentation/providers/stories_provider.dart';
import 'package:kids_am/features/video_library/presentation/providers/video_library_provider.dart';

class DynamicContentState {
  final int localVersion;
  final bool isSyncing;
  final String? lastSyncDate;
  final String? statusMessage;
  final ContentBundle? currentBundle;

  const DynamicContentState({
    this.localVersion = 1,
    this.isSyncing = false,
    this.lastSyncDate,
    this.statusMessage,
    this.currentBundle,
  });

  DynamicContentState copyWith({
    int? localVersion,
    bool? isSyncing,
    String? lastSyncDate,
    String? statusMessage,
    ContentBundle? currentBundle,
  }) {
    return DynamicContentState(
      localVersion: localVersion ?? this.localVersion,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncDate: lastSyncDate ?? this.lastSyncDate,
      statusMessage: statusMessage ?? this.statusMessage,
      currentBundle: currentBundle ?? this.currentBundle,
    );
  }
}

class DynamicContentNotifier extends Notifier<DynamicContentState> {
  @override
  DynamicContentState build() {
    _init();
    return const DynamicContentState();
  }

  Future<void> _init() async {
    final version = await DynamicContentService.getLocalBundleVersion();
    final lastSync = await DynamicContentService.getLastSyncDate();
    final bundle = await DynamicContentService.loadActiveBundle();

    state = state.copyWith(
      localVersion: version,
      lastSyncDate: lastSync,
      currentBundle: bundle,
    );
  }

  /// Sincroniza el contenido dinámico en caliente desde la nube sin descargar APK
  Future<DynamicContentResult> syncContent({bool force = false}) async {
    state = state.copyWith(isSyncing: true, statusMessage: 'Sincronizando contenido...');

    final result = await DynamicContentService.syncFromCloud(force: force);

    if (result.hasUpdate && result.bundle != null) {
      state = state.copyWith(
        localVersion: result.version,
        isSyncing: false,
        lastSyncDate: DateTime.now().toIso8601String(),
        statusMessage: result.message,
        currentBundle: result.bundle,
      );

      // Notificar a los proveedores en caliente
      if (result.bundle!.stories.isNotEmpty) {
        ref.read(storiesProvider.notifier).updateStoriesList(result.bundle!.stories);
      }
      if (result.bundle!.videos.isNotEmpty) {
        ref.read(videoLibraryProvider.notifier).syncWithOTAVideos(result.bundle!.videos);
      }
    } else {
      state = state.copyWith(
        isSyncing: false,
        statusMessage: result.message,
      );
    }

    return result;
  }
}

final dynamicContentProvider =
    NotifierProvider<DynamicContentNotifier, DynamicContentState>(
  DynamicContentNotifier.new,
);
