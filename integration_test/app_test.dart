import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:integration_test/integration_test.dart";
import "package:mtaa_project/app/app.dart";
import "package:mtaa_project/app/router.dart";
import "package:mtaa_project/auth/auth_adapter.dart";
import "package:mtaa_project/offline_mode/offline_service.dart";
import "package:mtaa_project/services/service_loader.dart";
import "package:mtaa_project/services/update_service.dart";
import "package:mtaa_project/settings/settings.dart";

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
      await UpdateService.instance.updateConnection();
      OfflineService.instance.setOnlineState(true);
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

  group("Activity", () {
    testWidgets("create activity", (tester) async {
      // Start as user A
      await AuthAdapter.instance.login("joy@example.com", "12345");
      router.goNamed("Home");
      await tester.pumpWidget(const App(skipInitialization: true));
      await tester.pumpAndSettle();

      router.goNamed("Recording");
      await tester.pumpAndSettle();

      // Open activity permission popup
      var stepCounterPerm =
          find.widgetWithText(Card, "Step counting").expectFoundOne();
      var stepCounterPermGrant = find
          .descendant(of: stepCounterPerm, matching: find.byType(FilledButton))
          .expectFoundOne();
      await tester.tap(stepCounterPermGrant);
      // Wait for the card to disappear, meaning user has granted permission
      await waitFor(tester, stepCounterPerm, invert: true);

      // Open location popup
      var locationPerm = find.widgetWithText(Card, "Location").expectFoundOne();
      var locationPermGrant = find
          .descendant(of: locationPerm, matching: find.byType(FilledButton))
          .expectFoundOne();
      await tester.tap(locationPermGrant);
      // Wait for the card to disappear, meaning user has granted permission
      await waitFor(tester, locationPerm, invert: true);

      router.goNamed("Home");
      await tester.pumpAndSettle();
      router.goNamed("Recording");
      await tester.pumpAndSettle();

      // Wait until location found
      var locationSearching = find.textContaining("Searching...");
      await waitFor(tester, locationSearching, invert: true);

      // Press begin
      var beginButton =
          find.widgetWithText(FilledButton, "Begin").expectFoundOne();
      await tester.tap(beginButton);
      await tester.pumpAndSettle();

      // Wait some time
      await tester.pump(const Duration(milliseconds: 1500));

      // Press finish
      var finishButton = find.widgetWithText(FilledButton, "Finish");
      await tester.tap(finishButton);
      await tester.pumpAndSettle();

      // Go home
      router.goNamed("Home");
      await tester.pumpAndSettle();

      // Verify the activity was saved
      var activityView = find.widgetWithText(ListTile, "Recording");
      await waitFor(tester, activityView);
    });

    testWidgets("like friend activity", (tester) async {
      // Login as user B
      await AuthAdapter.instance.login("kale@example.com", "12345");
      await UpdateService.instance
          .updateConnection(); // Ensure websocket connection is created
      router.goNamed("Home");
      await tester.pumpWidget(const App(skipInitialization: true));
      await tester.pumpAndSettle();

      // Verify user A activity is shown
      var userAActivity = find.widgetWithText(ListTile, "Recording");
      await waitFor(tester, userAActivity);

      // Like activity
      var likeButton = find
          .descendant(
            of: userAActivity,
            matching: find.widgetWithIcon(IconButton, Icons.thumb_up_outlined),
          )
          .expectFoundOne();
      await tester.tap(likeButton);

      // Verify activity liked
      var likedButton = find.descendant(
        of: userAActivity,
        matching: find.widgetWithIcon(IconButton, Icons.thumb_up),
      );
      await waitFor(tester, likedButton);

      // Verify like count is 1
      find
          .descendant(of: userAActivity, matching: find.textContaining("1"))
          .expectFoundOne();
    });

    testWidgets("delete activity", (tester) async {
      // Start as user A
      await AuthAdapter.instance.login("joy@example.com", "12345");
      await UpdateService.instance
          .updateConnection(); // Ensure websocket connection is created
      router.goNamed("Home");
      await tester.pumpWidget(const App(skipInitialization: true));
      await tester.pumpAndSettle();

      // Verify user A activity is shown
      var activityEntry = find.widgetWithText(ListTile, "Recording");
      await waitFor(tester, activityEntry);
      // Open activity page
      await tester.tap(activityEntry);
      await tester.pumpAndSettle();

      // Delete activity
      var deleteButton =
          find.widgetWithIcon(IconButton, Icons.delete).expectFoundOne();
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      // Confirm deletion in pupup
      var deleteConfirmation = find.widgetWithText(TextButton, "Delete");
      await tester.tap(deleteConfirmation);
      await tester.pumpAndSettle();

      // Wait for home screen and verify that the activity is not there
      await waitFor(tester, find.textContaining("steps"));
      activityEntry.reset();
      expect(activityEntry, findsNothing);
    });
  });

  group("Settings", () {
    testWidgets("set theme", (tester) async {
      // Start as user A
      await AuthAdapter.instance.login("joy@example.com", "12345");
      router.goNamed("Profile");
      await tester.pumpWidget(const App(skipInitialization: true));
      await tester.pumpAndSettle();

      var darkThemeEntry =
          find.widgetWithText(ListTile, "Dark theme").expectFoundOne();
      var darkThemeCheckbox = find
          .descendant(of: darkThemeEntry, matching: find.byType(Checkbox))
          .expectFoundOne();
      await tester.tap(darkThemeCheckbox);
      await tester.pumpAndSettle();

      expect(Settings.instance.darkTheme.getValue(), isTrue);
      await Settings.instance.darkTheme.setValue(false);
      await tester.pumpAndSettle();
    });

    testWidgets("set language", (tester) async {
      // Start as user A
      await AuthAdapter.instance.login("joy@example.com", "12345");
      router.goNamed("Profile");
      await tester.pumpWidget(const App(skipInitialization: true));
      await tester.pumpAndSettle();

      var languageEntry =
          find.widgetWithText(ListTile, "Language").expectFoundOne();
      var languageDropdown = find
          .descendant(
            of: languageEntry,
            matching: find.byType(DropdownButton<String>),
          )
          .expectFoundOne();
      await tester.tap(languageDropdown);
      await tester.pumpAndSettle();

      var slovakLanguage =
          find.widgetWithText(DropdownMenuItem<String>, "Slovenský");
      await tester.tap(slovakLanguage);
      await tester.pumpAndSettle();

      find.widgetWithText(ListTile, "Jazyk").expectFoundOne();

      expect(Settings.instance.language.getValue(), "sk");
      await Settings.instance.language.setValue("en");
      await tester.pumpAndSettle();
    });
  });
}
