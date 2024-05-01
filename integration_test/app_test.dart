import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:mtaa_project/app/app.dart";
import "package:mtaa_project/app/router.dart";
import "package:mtaa_project/auth/auth_adapter.dart";
import "package:mtaa_project/services/service_loader.dart";

import "test_support.dart";

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ServiceLoader.loadServices();
  });

  group("Authentication", () {
    testWidgets("login", (tester) async {
      router.goNamed("Login");

      await tester.pumpWidget(const App(skipInitialization: true));
      await tester.pumpAndSettle();

      var emailField = find.widgetWithText(TextField, "Email").expectFoundOne();
      await tester.enterText(emailField, "joy@example.com");

      var passwordField =
          find.widgetWithText(TextField, "Password").expectFoundOne();
      await tester.enterText(passwordField, "12345");

      var loginButton =
          find.widgetWithText(FilledButton, "Login").expectFoundOne();
      await tester.tap(loginButton);

      await tester.pumpAndSettle();

      expect(AuthAdapter.instance.user, isNotNull);
      expect(AuthAdapter.instance.user!.email, "joy@example.com");

      var profileButton = find
          .widgetWithIcon(IconButton, Icons.account_circle_outlined)
          .expectFoundOne();
      await tester.tap(profileButton);

      await tester.pumpAndSettle();
      find.textContaining(RegExp(r"Joy Johns"));

      await AuthAdapter.instance.logOut();
      expect(AuthAdapter.instance.token, isNull);
    });

    testWidgets("profile", (tester) async {
      await AuthAdapter.instance.login("joy@example.com", "12345");

      router.goNamed("Profile");

      await tester.pumpWidget(const App(skipInitialization: true));
      await tester.pumpAndSettle();

      find.textContaining(RegExp(r"Joy Johns"));

      await AuthAdapter.instance.logOut();
      expect(AuthAdapter.instance.token, isNull);
    });
  });

  group("Friends", () {
    testWidgets("add friend", (tester) async {
      await AuthAdapter.instance.login("joy@example.com", "12345");

      router.goNamed("Home");
      await tester.pumpWidget(const App(skipInitialization: true));
      await tester.pumpAndSettle();

      {
        router.goNamed("Friends");
        await tester.pumpAndSettle();

        var addFriendsButton =
            find.widgetWithIcon(IconButton, Icons.add).expectFoundOne();
        await tester.tap(addFriendsButton);
        await tester.pumpAndSettle();

        var searchBar =
            find.widgetWithText(TextField, "Search").expectFoundOne();
        await tester.enterText(searchBar, "Kale");
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        var kaleItem =
            find.widgetWithText(ListTile, "Kale Rosenbaum").expectFoundOne();
        var addButton = find
            .descendant(of: kaleItem, matching: find.byType(FilledButton))
            .expectFoundOne();
        await tester.tap(addButton);
        await tester.pumpAndSettle();

        var backButton = find.widgetWithIcon(IconButton, Icons.chevron_left);
        await tester.tap(backButton);
        await tester.pumpAndSettle();
      }

      await AuthAdapter.instance.logOut();
      await AuthAdapter.instance.login("kale@example.com", "12345");

      router.goNamed("Home");
      await tester.pumpWidget(const App(skipInitialization: true));
      await tester.pumpAndSettle();

      {
        router.goNamed("Friends");
        await tester.pumpAndSettle();

        var joyItem = find.widgetWithText(ListTile, "Joy Johns");
        await waitFor(tester, joyItem);

        var acceptButton = find
            .descendant(
                of: joyItem,
                matching: find.widgetWithIcon(IconButton, Icons.check))
            .expectFoundOne();
        await tester.tap(acceptButton);

        await Future.delayed(const Duration(milliseconds: 100));
        await tester.pumpAndSettle();

        find.widgetWithText(ListTile, "Joy Johns").expectFoundOne();
      }
    });
  });
}
