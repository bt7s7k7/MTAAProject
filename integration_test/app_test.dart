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
    // Services are only loaded once, since the application is not reset between tests
    await ServiceLoader.loadServices();
  });

  tearDown(() async {
    // This is the only relevant global state that is used by tests, so it is reset after
    // each test, for isolation
    if (AuthAdapter.instance.token != null) {
      await AuthAdapter.instance.logOut();
    }
  });

  group("Authentication", () {
    testWidgets("login", (tester) async {
      router.goNamed("Login");

      await tester.pumpWidget(const App(skipInitialization: true));
      await tester.pumpAndSettle();

      // Enter login credentials
      var emailField = find.widgetWithText(TextField, "Email").expectFoundOne();
      await tester.enterText(emailField, "joy@example.com");

      var passwordField =
          find.widgetWithText(TextField, "Password").expectFoundOne();
      await tester.enterText(passwordField, "12345");

      // Click login button
      var loginButton =
          find.widgetWithText(FilledButton, "Login").expectFoundOne();
      await tester.tap(loginButton);

      // Wait for the home screen to be shown, that means login was successful
      var profileButton =
          find.widgetWithIcon(IconButton, Icons.account_circle_outlined);
      await waitFor(tester, profileButton);

      // Test if user data was loaded correctly
      expect(AuthAdapter.instance.user, isNotNull);
      expect(AuthAdapter.instance.user!.email, "joy@example.com");

      // Check if user data is shown correctly
      await tester.tap(profileButton);

      await tester.pumpAndSettle();
      find.textContaining(RegExp(r"Joy Johns"));

      await AuthAdapter.instance.logOut();
      // Check if log out correctly erased user credentials
      expect(AuthAdapter.instance.token, isNull);
    });
  });

  group("Friends", () {
    testWidgets("add friend", (tester) async {
      // Start as user A
      await AuthAdapter.instance.login("joy@example.com", "12345");
      router.goNamed("Home");
      await tester.pumpWidget(const App(skipInitialization: true));
      await tester.pumpAndSettle();

      {
        // Goto friends page
        router.goNamed("Friends");
        await tester.pumpAndSettle();

        // Goto add friends page
        var addFriendsButton =
            find.widgetWithIcon(IconButton, Icons.add).expectFoundOne();
        await tester.tap(addFriendsButton);
        await tester.pumpAndSettle();

        // Enter user B name into search bar
        var searchBar =
            find.widgetWithText(TextField, "Search").expectFoundOne();
        await tester.enterText(searchBar, "Kale");

        // Find user B in list and click add friend
        var kaleItem = find.widgetWithText(ListTile, "Kale Rosenbaum");
        await waitFor(tester,
            kaleItem); // Waiting for backend to return the search results
        var addButton = find
            .descendant(of: kaleItem, matching: find.byType(FilledButton))
            .expectFoundOne();
        await tester.tap(addButton);
        await tester.pumpAndSettle();
      }

      // Restart as user B
      await AuthAdapter.instance.logOut();
      await AuthAdapter.instance.login("kale@example.com", "12345");
      router.goNamed("Home");
      await tester.pumpWidget(const App(skipInitialization: true));
      await tester.pumpAndSettle();

      {
        // Goto friends page
        router.goNamed("Friends");
        await tester.pumpAndSettle();

        // Find invite for user A and click accept
        var joyItem = find.widgetWithText(ListTile, "Joy Johns");
        await waitFor(
            tester, joyItem); // Waiting for backend to return invitations
        var acceptButton = find
            .descendant(
                of: joyItem,
                matching: find.widgetWithIcon(IconButton, Icons.check))
            .expectFoundOne();
        await tester.tap(acceptButton);
        // Wait until invitation disappears
        await waitFor(tester, acceptButton, invert: true);

        // Wait until new friend appears
        await waitFor(tester, joyItem);
        joyItem.expectFoundOne();
      }
    });
  });
}
