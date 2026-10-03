import '../../../../config/theme/theme_typography.dart';
import '../../../../config/theme/widgets/layout/cross_column_track_plan.dart';
import '../../../../config/theme/widgets/layout/page_track_layout_matrix.dart';
import '../../../../config/theme/widgets/layout/resolved_track_layout_matrix.dart';
import '../../../../features/settings/presentation/layout/message_history_coverage_track_occupants.dart';
import '../../../../features/sidebar_utilities/application/sidebar_cassette_spec/payloads/settings_top_menu_cassette_payload.dart';
import '../../../../features/sidebar_utilities/application/sidebar_cassette_spec/widget_builders/settings_top_menu_widget.dart';
import '../../../../features/sidebar_utilities/domain/sidebar_utilities_constants.dart';

const messageHistoryCoveragePageTrackIds = [TrackId.trackA];

/// One resolved Message History Coverage composition.
///
/// Only Track A is shared: the Settings menu and center title are peers. Both
/// columns resume their feature-owned native flow below it.
final class MessageHistoryCoveragePageTrackComposition {
  const MessageHistoryCoveragePageTrackComposition({
    required this.matrix,
    required this.resolvedMatrix,
  });

  final PageTrackLayoutMatrix<TrackOccupant> matrix;
  final ResolvedTrackLayoutMatrix resolvedMatrix;
}

MessageHistoryCoveragePageTrackComposition
composeMessageHistoryCoveragePageTrackLayout({
  required PresentationConstraints presentationConstraints,
  required ThemeTypography typography,
  bool resetMessageDataActionAvailable = true,
}) {
  final settingsOccupants = messageHistoryCoverageTrackOccupants(
    typography: typography,
  );
  final matrix = buildMessageHistoryCoveragePageTrackLayoutMatrix(
    sidebarSettingsMenu: SettingsTopMenuTrackOccupant(
      payload: buildSettingsTopMenuCassettePayload(
        cassetteIndex: 0,
        persistentContextActionId: SettingsMenuActionId.messageHistoryCoverage,
        resetMessageDataActionAvailable: resetMessageDataActionAvailable,
      ),
      selectedValueStyle: typography.controlValue,
    ),
    centerTitle: settingsOccupants.title,
  );

  return MessageHistoryCoveragePageTrackComposition(
    matrix: matrix,
    resolvedMatrix: ResolvedTrackLayoutMatrix.resolve(
      matrix: matrix,
      constraints: presentationConstraints,
    ),
  );
}

PageTrackLayoutMatrix<TrackOccupant>
buildMessageHistoryCoveragePageTrackLayoutMatrix({
  required TrackOccupant sidebarSettingsMenu,
  required TrackOccupant centerTitle,
}) {
  return PageTrackLayoutMatrix<TrackOccupant>(
    trackIds: messageHistoryCoveragePageTrackIds,
    columnIds: TrackColumnId.values,
    cells: [
      MatrixCell<TrackOccupant>.occupied(
        cellId: const CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column1,
        ),
        occupant: sidebarSettingsMenu,
        alignment: TrackCellAlignment.center,
        debugLabel: 'Settings menu',
      ),
      MatrixCell<TrackOccupant>.occupied(
        cellId: const CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column2,
        ),
        occupant: centerTitle,
        alignment: TrackCellAlignment.center,
        debugLabel: 'Message History Coverage title',
      ),
      const MatrixCell<TrackOccupant>.empty(
        cellId: CellId(
          trackId: TrackId.trackA,
          columnId: TrackColumnId.column3,
        ),
      ),
    ],
  );
}
