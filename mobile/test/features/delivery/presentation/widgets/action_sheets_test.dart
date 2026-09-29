import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/core/l10n/generated/app_localizations.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/action_sheets/failure_reason_dropdown.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/action_sheets/image_source_sheet.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/action_sheets/note_field.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/action_sheets/photo_proof_picker.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/action_sheets/recipient_name_field.dart';

Widget createLocalizedApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('RecipientNameField', () {
    testWidgets('renders correctly and validates minimum length',
        (tester) async {
      final formKey = GlobalKey<FormState>();
      String currentVal = '';

      await tester.pumpWidget(
        createLocalizedApp(
          Form(
            key: formKey,
            child: RecipientNameField(
              onChanged: (val) => currentVal = val,
            ),
          ),
        ),
      );

      expect(find.text('Recipient Name'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);

      // Trigger validation on empty field
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();
      expect(
        find.text('Recipient name is required (at least 2 characters)'),
        findsOneWidget,
      );

      // Enter valid name
      await tester.enterText(find.byType(TextFormField), 'Jassem');
      expect(formKey.currentState!.validate(), isTrue);
      expect(currentVal, 'Jassem');
    });
  });

  group('NoteField', () {
    testWidgets('renders label and hint and accepts text', (tester) async {
      String typed = '';
      await tester.pumpWidget(
        createLocalizedApp(
          NoteField(onChanged: (val) => typed = val),
        ),
      );

      expect(find.text('Note (Optional)'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'Gate code 4321');
      expect(typed, 'Gate code 4321');
    });
  });

  group('FailureReasonDropdown', () {
    testWidgets('renders all failure reason options', (tester) async {
      FailureReason? selectedReason;
      await tester.pumpWidget(
        createLocalizedApp(
          FailureReasonDropdown(
            onChanged: (val) => selectedReason = val,
          ),
        ),
      );

      expect(find.text('Failure Reason'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<FailureReason>), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<FailureReason>));
      await tester.pumpAndSettle();

      expect(find.text('Customer unavailable').last, findsOneWidget);
      expect(find.text('Wrong address').last, findsOneWidget);
      expect(find.text('Customer refused').last, findsOneWidget);
      expect(find.text('Damaged package').last, findsOneWidget);
      expect(find.text('Other reason').last, findsOneWidget);

      await tester.tap(find.text('Customer unavailable').last);
      await tester.pumpAndSettle();

      expect(selectedReason, FailureReason.customerUnavailable);
    });
  });

  group('PhotoProofPicker', () {
    testWidgets('renders upload box when no photo is attached', (tester) async {
      bool pickTapped = false;
      await tester.pumpWidget(
        createLocalizedApp(
          PhotoProofPicker(
            photoPath: null,
            onPickPhoto: () => pickTapped = true,
            onRemovePhoto: () {},
          ),
        ),
      );

      expect(find.text('Photo Proof'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);

      await tester.tap(find.byType(InkWell));
      expect(pickTapped, isTrue);
    });

    testWidgets('renders progress indicator when isLoading is true',
        (tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          PhotoProofPicker(
            isLoading: true,
            onPickPhoto: () {},
            onRemovePhoto: () {},
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error text when error message is provided',
        (tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          PhotoProofPicker(
            error: 'Camera permission denied',
            onPickPhoto: () {},
            onRemovePhoto: () {},
          ),
        ),
      );

      expect(find.text('Camera permission denied'), findsOneWidget);
    });
  });

  group('ImageSourceSheet', () {
    testWidgets('renders Camera and Gallery choices', (tester) async {
      await tester.pumpWidget(
        createLocalizedApp(
          const ImageSourceSheet(),
        ),
      );

      expect(find.text('Choose image source'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Photo Gallery'), findsOneWidget);
    });
  });
}
