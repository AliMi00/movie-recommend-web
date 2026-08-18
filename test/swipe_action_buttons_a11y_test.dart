import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinejo_frontend/data/models/movie_model.dart';
import 'package:cinejo_frontend/features/discovery/widgets/swipe_action_buttons.dart';

void main() {
  testWidgets('Like/Dislike/Super Like buttons expose real semantic labels', (
    tester,
  ) async {
    // The icon alone carries no meaning to a screen reader — these buttons
    // previously had no accessible name at all despite being the app's
    // primary interaction.
    final handle = tester.ensureSemantics();

    final actions = <UserInteraction>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SwipeActionButtons(onAction: actions.add)),
      ),
    );

    expect(find.bySemanticsLabel('Dislike'), findsOneWidget);
    expect(find.bySemanticsLabel('Like'), findsOneWidget);
    expect(find.bySemanticsLabel('Super like'), findsOneWidget);

    // The label must sit on a real tappable node, not just decorative text.
    await tester.tap(find.bySemanticsLabel('Like'));
    expect(actions, [UserInteraction.liked]);

    handle.dispose();
  });
}
