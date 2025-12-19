import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trivy/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsNotifier Tests', () {
    Future<ProviderContainer> createContainer(
      Map<String, Object> initialValues,
    ) async {
      // Atur nilai mock awal untuk SharedPreferences
      SharedPreferences.setMockInitialValues(initialValues);

      final container = ProviderContainer();

      container.read(settingsProvider);

      await Future.delayed(Duration.zero);

      return container;
    }

    test('State awal harus false jika SharedPreferences kosong', () async {
      final container = await createContainer({});

      final isExpert = container.read(settingsProvider);

      expect(isExpert, false);

      container.dispose();
    });

    test(
      'State awal harus true jika SharedPreferences diatur ke true',
      () async {
        final container = await createContainer({'expertMode': true});

        final isExpert = container.read(settingsProvider);

        expect(isExpert, true);

        container.dispose();
      },
    );

    test(
      'setExpertMode(true) harus memperbarui state dan SharedPreferences',
      () async {
        final container = await createContainer({'expertMode': false});

        expect(container.read(settingsProvider), false);

        await container.read(settingsProvider.notifier).setExpertMode(true); //

        expect(container.read(settingsProvider), true);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('expertMode'), true);

        container.dispose();
      },
    );

    test(
      'setExpertMode(false) harus memperbarui state dan SharedPreferences',
      () async {
        final container = await createContainer({'expertMode': true});

        expect(container.read(settingsProvider), true);

        await container.read(settingsProvider.notifier).setExpertMode(false); //

        expect(container.read(settingsProvider), false);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('expertMode'), false);

        container.dispose();
      },
    );
  });
}
