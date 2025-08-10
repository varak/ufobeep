import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ufobeep/models/chat_message.dart';
import 'package:ufobeep/widgets/chat/message_bubble.dart';
import 'package:ufobeep/widgets/chat/moderation_badge.dart';

void main() {
  group('Moderation System Integration Tests', () {
    late ChatMessage baseMessage;

    setUp(() {
      baseMessage = ChatMessage(
        id: 'test-message',
        alertId: 'test-alert',
        senderId: 'test-sender',
        senderDisplayName: 'Test User',
        content: 'This is test message content',
        createdAt: DateTime.now(),
      );
    });

    testWidgets('displays normal message without moderation', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: baseMessage),
          ),
        ),
      );

      expect(find.text('This is test message content'), findsOneWidget);
      expect(find.byType(ModerationBadge), findsNothing);
      expect(find.byType(RedactedContentPlaceholder), findsNothing);
    });

    testWidgets('displays warning badge for flagged message', (WidgetTester tester) async {
      final flaggedMessage = baseMessage.copyWith(
        moderation: const ModerationState(
          action: ModerationAction.warn,
          reason: 'Potentially inappropriate language',
          moderatorName: 'ModBot',
          flags: ['inappropriate'],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: flaggedMessage),
          ),
        ),
      );

      expect(find.text('This is test message content'), findsOneWidget);
      expect(find.byType(ModerationBadge), findsOneWidget);
      expect(find.text('WARN'), findsOneWidget);
    });

    testWidgets('hides content for soft-hidden message', (WidgetTester tester) async {
      final hiddenMessage = baseMessage.copyWith(
        moderation: const ModerationState(
          action: ModerationAction.softHide,
          reason: 'Off-topic discussion',
          moderatorName: 'Human Moderator',
          canShowOriginal: true,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: hiddenMessage),
          ),
        ),
      );

      expect(find.text('This is test message content'), findsNothing);
      expect(find.text('Content Hidden'), findsOneWidget);
      expect(find.byType(ModerationBadge), findsOneWidget);
      expect(find.byType(RevealContentButton), findsOneWidget);
    });

    testWidgets('can reveal soft-hidden content', (WidgetTester tester) async {
      final hiddenMessage = baseMessage.copyWith(
        moderation: const ModerationState(
          action: ModerationAction.softHide,
          reason: 'Flagged for review',
          canShowOriginal: true,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: hiddenMessage),
          ),
        ),
      );

      expect(find.text('This is test message content'), findsNothing);
      expect(find.text('Show original'), findsOneWidget);

      // Tap to reveal content
      await tester.tap(find.byType(RevealContentButton));
      await tester.pump();

      expect(find.text('This is test message content'), findsOneWidget);
      expect(find.text('Hide original'), findsOneWidget);
    });

    testWidgets('displays redacted placeholder for redacted message', (WidgetTester tester) async {
      final redactedMessage = baseMessage.copyWith(
        moderation: const ModerationState(
          action: ModerationAction.redact,
          reason: 'Contains personal information',
          moderatorName: 'Privacy Bot',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: redactedMessage),
          ),
        ),
      );

      expect(find.text('This is test message content'), findsNothing);
      expect(find.text('Content Redacted'), findsOneWidget);
      expect(find.text('Contains personal information'), findsOneWidget);
      expect(find.byType(RedactedContentPlaceholder), findsOneWidget);
      expect(find.byType(RevealContentButton), findsNothing); // Cannot reveal redacted
    });

    testWidgets('hides hard-deleted message completely', (WidgetTester tester) async {
      final deletedMessage = baseMessage.copyWith(
        moderation: const ModerationState(
          action: ModerationAction.delete,
          reason: 'Severe policy violation',
          moderatorName: 'Admin',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: deletedMessage),
          ),
        ),
      );

      expect(find.byType(MessageBubble), findsOneWidget);
      expect(find.text('This is test message content'), findsNothing);
      expect(find.text('Content Redacted'), findsNothing);
      expect(find.byType(ModerationBadge), findsNothing);
      // Message should render as SizedBox.shrink()
    });

    testWidgets('shows moderation details when badge tapped', (WidgetTester tester) async {
      final moderatedMessage = baseMessage.copyWith(
        moderation: const ModerationState(
          action: ModerationAction.warn,
          reason: 'Automated flag for spam patterns',
          moderatorName: 'SpamBot',
          flags: ['spam', 'offtopic'],
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: moderatedMessage),
          ),
        ),
      );

      expect(find.byType(ModerationDetails), findsNothing);
      
      // Tap the moderation badge
      await tester.tap(find.byType(ModerationBadge));
      await tester.pump();

      expect(find.byType(ModerationDetails), findsOneWidget);
      expect(find.text('Moderation Action'), findsOneWidget);
      expect(find.text('Content flagged'), findsOneWidget);
      expect(find.text('Automated flag for spam patterns'), findsOneWidget);
      expect(find.text('SpamBot'), findsOneWidget);
      expect(find.text('spam, offtopic'), findsOneWidget);
    });

    testWidgets('can close moderation details', (WidgetTester tester) async {
      final moderatedMessage = baseMessage.copyWith(
        moderation: const ModerationState(
          action: ModerationAction.softHide,
          reason: 'Under review',
          moderatorName: 'ReviewBot',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(message: moderatedMessage),
          ),
        ),
      );

      // Open details
      await tester.tap(find.byType(ModerationBadge));
      await tester.pump();
      expect(find.byType(ModerationDetails), findsOneWidget);

      // Close details
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      expect(find.byType(ModerationDetails), findsNothing);
    });

    testWidgets('shows correct moderation badge colors and icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                MessageBubble(
                  message: baseMessage.copyWith(
                    moderation: const ModerationState(action: ModerationAction.warn),
                  ),
                ),
                MessageBubble(
                  message: baseMessage.copyWith(
                    moderation: const ModerationState(action: ModerationAction.softHide),
                  ),
                ),
                MessageBubble(
                  message: baseMessage.copyWith(
                    moderation: const ModerationState(action: ModerationAction.redact),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Check that different moderation actions have appropriate icons
      expect(find.byIcon(Icons.warning_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.block_outlined), findsOneWidget);
    });

    group('ModerationState Model Tests', () {
      test('correctly identifies moderation states', () {
        const unmoderated = ModerationState();
        expect(unmoderated.isModerated, isFalse);
        expect(unmoderated.isSoftHidden, isFalse);
        expect(unmoderated.isRedacted, isFalse);

        const warned = ModerationState(action: ModerationAction.warn);
        expect(warned.isModerated, isTrue);
        expect(warned.isWarned, isTrue);

        const softHidden = ModerationState(action: ModerationAction.softHide);
        expect(softHidden.isModerated, isTrue);
        expect(softHidden.isSoftHidden, isTrue);

        const redacted = ModerationState(action: ModerationAction.redact);
        expect(redacted.isModerated, isTrue);
        expect(redacted.isRedacted, isTrue);

        const deleted = ModerationState(action: ModerationAction.delete);
        expect(deleted.isModerated, isTrue);
        expect(deleted.isHardDeleted, isTrue);
      });

      test('provides correct action text', () {
        expect(const ModerationState().actionText, equals(''));
        expect(const ModerationState(action: ModerationAction.warn).actionText, equals('Content flagged'));
        expect(const ModerationState(action: ModerationAction.softHide).actionText, equals('Content hidden'));
        expect(const ModerationState(action: ModerationAction.redact).actionText, equals('Content redacted'));
        expect(const ModerationState(action: ModerationAction.delete).actionText, equals('Content removed'));
      });
    });

    group('ModerationFlag Extensions', () {
      test('provides display names', () {
        expect(ModerationFlag.spam.displayName, equals('Spam'));
        expect(ModerationFlag.harassment.displayName, equals('Harassment'));
        expect(ModerationFlag.inappropriate.displayName, equals('Inappropriate Content'));
        expect(ModerationFlag.offtopic.displayName, equals('Off Topic'));
        expect(ModerationFlag.misinformation.displayName, equals('Misinformation'));
        expect(ModerationFlag.violence.displayName, equals('Violence/Threats'));
        expect(ModerationFlag.copyright.displayName, equals('Copyright'));
        expect(ModerationFlag.other.displayName, equals('Other'));
      });

      test('provides descriptions', () {
        expect(ModerationFlag.spam.description, contains('Repetitive'));
        expect(ModerationFlag.harassment.description, contains('bullying'));
        expect(ModerationFlag.inappropriate.description, contains('suitable'));
        expect(ModerationFlag.offtopic.description, contains('relevant'));
        expect(ModerationFlag.misinformation.description, contains('False'));
        expect(ModerationFlag.violence.description, contains('Violent'));
        expect(ModerationFlag.copyright.description, contains('copyrighted'));
        expect(ModerationFlag.other.description, contains('policy'));
      });
    });
  });
}