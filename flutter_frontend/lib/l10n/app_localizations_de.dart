// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Kaufhansel';

  @override
  String get downloadLink => 'https://zwohansel.de/kaufhansel/download';

  @override
  String get downloadLinkPromotion => 'Die Downloads gibts hier: ';

  @override
  String get zwoHanselPageLink => 'https://zwohansel.de';

  @override
  String get zwoHanselPageLinkText => 'zwohansel.de';

  @override
  String get zwoHanselPageLinkInfo =>
      'Mehr über die Entwickler auf zwohansel.de';

  @override
  String get zwoHanselKaufhanselGithubLink =>
      'https://github.com/zwohansel/kaufhansel';

  @override
  String get zwoHanselKaufhanselGithubLinkInfo =>
      'Der Kaufhansel-Quellcode auf GitHub';

  @override
  String get zwoHanselKaufhanselLandingPageLink =>
      'https://zwohansel.de/kaufhansel';

  @override
  String get zwoHanselKaufhanselLandingPageLinkInfo =>
      'Der Kaufhansel im Internet';

  @override
  String get manShrugging => '🤷‍♂️';

  @override
  String get thatsJustHowItIs => 'Ist dann halt schon so...';

  @override
  String get important => 'Achtung!';

  @override
  String get ok => 'Ok';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get close => 'Schließen';

  @override
  String get dontCare => 'Egal';

  @override
  String get okImmediately => 'Mach ich sofort';

  @override
  String get tryAgain => 'Nochmal versuchen';

  @override
  String get refresh => 'Auffrischen';

  @override
  String get general => 'Allgemein';

  @override
  String get appSettings => 'App-Einstellungen';

  @override
  String get listSettings => 'Mehr Listeneinstellungen...';

  @override
  String get willLoginAgain => 'Ok... Ich melde mich gerne neu an.';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get privacyPolicyLink =>
      'https://zwohansel.de/kaufhansel/privacy_de.html';

  @override
  String get disclaimer => 'Haftungsausschluss';

  @override
  String get disclaimerLink =>
      'https://zwohansel.de/kaufhansel/disclaimer.html';

  @override
  String get registrationConsentFirstPart => 'Ich habe die ';

  @override
  String get registrationConsentMiddlePart =>
      ' zur Kenntnis genommen und stimme dem ';

  @override
  String get registrationConsentLastPart => ' zu.';

  @override
  String get roleAdminName => 'Chefhansel';

  @override
  String get roleAdminDescription =>
      'Darf alles: Dinge hinzufügen und entfernen, Haken setzen und entfernen. Darf neue Hansel zur Liste hinzufügen.\nEinmal Chefhansel, immer Chefhansel: diese Rolle kannst du nicht mehr ändern';

  @override
  String get roleReadWriteName => 'Schreibhansel';

  @override
  String get roleReadWriteDescription =>
      'Darf Dinge hinzufügen und entfernen, darf Haken setzen und entfernen';

  @override
  String get roleReadWriteWhatIsIt => 'Was ist ein Schreibhansel?';

  @override
  String get roleCheckOnlyName => 'Kaufhansel';

  @override
  String get roleCheckOnlyDescription => 'Darf Haken setzen und entfernen';

  @override
  String get roleReadOnlyName => 'Guckhansel';

  @override
  String get roleReadOnlyDescription =>
      'Darf die Liste anschauen, aber nix ändern';

  @override
  String get rolesWhich => 'Welche Rollen gibt es?';

  @override
  String get emailHint => 'Email-Adresse';

  @override
  String get emailInvalid => 'Gib eine gültige Email-Adresse ein';

  @override
  String get emailAlreadyInUse => 'Nimm eine andere';

  @override
  String get passwordHint => 'Kennwort';

  @override
  String get passwordEmpty => 'Gib dein Kennwort richtig ein';

  @override
  String get passwordToShort => 'Mindestens 8 Zeichen';

  @override
  String get passwordInvalid => 'Denk dir was besseres aus';

  @override
  String get passwordConfirmationHint => 'Kennwort bestätigen';

  @override
  String get passwordConfirmationInvalid => 'Gib dein Kennwort nochmal ein';

  @override
  String get passwordResetInfo =>
      'Gib hier den Wiederherstellungs-Code ein den wir an deine Email Adresse geschickt haben, um dein Kennwort zurückzusetzen.';

  @override
  String get passwordResetCodeHint => 'Wiederherstellungs-Code';

  @override
  String get passwordResetCodeInvalid => 'Gib den Wiederherstellungs-Code ein';

  @override
  String get passwordNewHint => 'Neues Kennwort';

  @override
  String get passwordNewConfirmationHint => 'Neues Kennwort bestätigen';

  @override
  String get passwordNewConfirmationInvalid =>
      'Gib dein neues Kennwort nochmal ein';

  @override
  String get passwordChangeSuccess =>
      'Du hast dein Kennwort erfolgreich geändert.';

  @override
  String get invitationCodeHint => 'Einladungs-Code';

  @override
  String get invitationCodeEmpty => 'Gib deinen Einladungs-Code ein';

  @override
  String get invitationCodeInvalid => 'Der Code stimmt nicht';

  @override
  String get invitationCodeGenerate => 'Einladungs-Code generieren';

  @override
  String get invitationCodeGenerating => 'Code wird generiert';

  @override
  String get invitationCodeShareMessage =>
      'Werde mit diesem Code zum Kaufhansel! Lade dir den Kaufhansel von https://zwohansel.de/kaufhansel/download runter.';

  @override
  String get invitationCodeRequestDistributionMessage =>
      'Schicke anderen Hanseln diesen Code, damit sie sich beim Kaufhansel registrieren können.';

  @override
  String activationLinkSent(Object emailAddress) {
    return 'Wir haben dir eine E-Mail an $emailAddress geschickt... folge dem Aktivierungs-Link, dann kannst du dich anmelden.';
  }

  @override
  String get registrationSuccessful =>
      'Deine Registrierung ist abgeschlossen. Du kannst dich nun mit deiner Email-Adresse und deinem Passwort anmelden.';

  @override
  String get userNameHint => 'Nutzername';

  @override
  String get userNameInvalid => 'Gib einen Nutzernamen ein';

  @override
  String get buttonLogin => 'Anmelden';

  @override
  String get buttonRegister => 'Registrieren';

  @override
  String get buttonPasswordForgotten => 'Kennwort vergessen';

  @override
  String get buttonPasswordReset => 'Kennwort zurücksetzen';

  @override
  String get buttonPasswordChange => 'Kenwort ändern';

  @override
  String get buttonNext => 'Weiter';

  @override
  String get buttonBackToLogin => 'Zurück zur Anmeldung';

  @override
  String get buttonPasswordResetCode => 'Wiederherstellungs-Code eingeben';

  @override
  String newerVersionAvailable(Object version) {
    return 'Version $version ist verfügbar';
  }

  @override
  String get newerVersionAvailableObligatoryUpdate =>
      'Es hat sich viel getan. Damit dein Kaufhansel weiterhin funktioniert, musst du diese Aktualisierung installieren. Mehr Infos findest du, wenn du auf den Link zum Herunterladen klickst, oder im Play Store.';

  @override
  String get shoppingListMyLists => 'Meine Listen';

  @override
  String get shoppingListEmpty => '🌽🥦🧀';

  @override
  String get shoppingListEmptyText =>
      'Du hast noch keine Einkaufsliste.\nIm Menü oben rechts kannst du neue Listen anlegen.';

  @override
  String get shoppingListError =>
      'Oh nein! Haben wir Deine Einkaufslisten etwa verlegt?';

  @override
  String shoppingListNotPresent(Object listName) {
    return 'Jedenfalls können wir die Liste $listName nicht finden.';
  }

  @override
  String get shoppingListOpenOther => 'Andere Liste öffnen';

  @override
  String get shoppingListCreateNew => 'Neue Liste...';

  @override
  String get shoppingListCreateNewTitle => 'Neue Liste anlegen';

  @override
  String get shoppingListCreateNewConfirm => 'Anlegen';

  @override
  String get shoppingListCreateNewEnterNameHint => 'Gib einen Namen ein';

  @override
  String get shoppingListFilterTitle => 'Filter';

  @override
  String get shoppingListFilterNone => 'Kein Filter';

  @override
  String get shoppingListFilterNeeded => 'Was muss ich noch kaufen';

  @override
  String get shoppingListFilterAlreadyInCart =>
      'Was ist schon im Einkaufswagen';

  @override
  String get shoppingListModeTitle => 'Modus';

  @override
  String get shoppingListModeDefault => 'Guck-Modus';

  @override
  String get shoppingListModeShopping => 'Einkaufs-Modus';

  @override
  String get shoppingListModeEditing => 'Editier-Modus';

  @override
  String get createOrSearchHint => 'Suchen oder hinzufügen';

  @override
  String get itemRename => 'Umbenennen';

  @override
  String get itemRemove => 'Löschen';

  @override
  String get categoryChooseOne => 'Wähle eine Kategorie';

  @override
  String get categoryNone => 'Keine';

  @override
  String get categoryCreateNew => 'Neue Kategorie';

  @override
  String roleYoursRoleName(Object roleName) {
    return 'Hier bist du $roleName:';
  }

  @override
  String appSettingsTitle(Object username) {
    return '$username, was willst du ändern?';
  }

  @override
  String appSettingsYourEmail(Object email) {
    return 'Deine Email-Adresse: $email';
  }

  @override
  String get appSettingsLogOut => 'Ich will mich mal kurz abmelden';

  @override
  String get appSettingsDeleteAccount =>
      'Ich will mein Benutzerkonto löschen...';

  @override
  String appSettingsDeleteAccountConfirmationTextTitle(Object userName) {
    return 'Schade $userName, dass du dein Benutzerkonto löschen willst';
  }

  @override
  String get appSettingsDeleteAccountConfirmationText =>
      'Dein Benutzerkonto wird endgültig und unwiederbringlich gelöscht.\n\nAlle Einkaufslisten, die du nicht geteilt hast, werden gelöscht. Alle Einkaufslisten, bei denen du der einzige Chefhansel bist, werden gelöscht und andere Hansel daraus entfernt. Du wirst aus allen Einkaufslisten entfernt, bei denen du nicht der einzige Chefhansel bist.\n\nWillst du das wirklich?';

  @override
  String get appSettingsDeleteAccountYes => 'Ja, lösch mich!';

  @override
  String get appSettingsDeleteAccountNo => 'Nein, doch nicht';

  @override
  String get appSettingsAccountDeletedEmoji => '👋';

  @override
  String get appSettingsAccountDeletedText =>
      'Wir haben alle deine Daten gelöscht. Tschüss!';

  @override
  String get appSettingsAboutTitle => 'Über die App';

  @override
  String get listSettingsUncheckItems => 'Häkchen entfernen...';

  @override
  String get listSettingsUncheckItemsTitle =>
      'Welche Häkchen möchtest du entfernen?';

  @override
  String get manageCategories => 'Kategorien bearbeiten...';

  @override
  String get manageCategoriesTitle => 'Kategorien bearbeiten';

  @override
  String get manageCategoriesCategory => 'Kategorie:';

  @override
  String get manageCategoriesAction => 'Aktion:';

  @override
  String get manageCategoriesWhich => 'Welche denn?';

  @override
  String get manageCategoriesUncheckAll => 'Alle Häkchen entfernen';

  @override
  String manageCategoriesUncheckCategory(Object category) {
    return 'Häkchen in der Kategorie $category entfernen';
  }

  @override
  String get manageCategoriesRemoveChecked => 'Alle abgehakten Dinge löschen';

  @override
  String manageCategoriesRemoveCheckedFromCategory(Object category) {
    return 'Alle abgehakten Dinge aus der Kategorie $category löschen';
  }

  @override
  String get manageCategoriesRemoveCategories => 'Alle Kategorien entfernen';

  @override
  String manageCategoriesRemoveCategory(Object category) {
    return 'Kategorie $category entfernen';
  }

  @override
  String manageCategoriesRenameCategory(Object category) {
    return 'Kategorie $category umbenennen...';
  }

  @override
  String get manageCategoriesRenameCategoryDialogTitle =>
      'Kategorie umbenennen';

  @override
  String get listSettingsClearList => 'Liste leeren...';

  @override
  String listSettingsClearListConfirmationText(Object shoppingListName) {
    return 'Möchtest du wirklich alle Elemente aus $shoppingListName unwiederbringlich entfernen?';
  }

  @override
  String listSettingsListCleared(Object shoppingListName) {
    return 'Alle Elemente in $shoppingListName wurden entfernt.';
  }

  @override
  String get listSettingsSharingWithSelf => 'Dir';

  @override
  String get listSettingsSharingWith => 'Du teilst die Liste mit';

  @override
  String get listSettingsShareWithOther => 'Mit einem weiteren Hansel teilen';

  @override
  String get listSettingsShareWithOtherInfo =>
      'Neue Hansel werden als Schreibhansel hinzugefügt: sie können Dinge hinzufügen und entfernen; Dinge abhaken und Haken entfernen. Das kannst ändern, nachdem der neue Hansel in der Liste ist.';

  @override
  String get listSettingsAddUserToListEmailAddressHint =>
      'Email-Adresse vom Hansel';

  @override
  String listSettingsChangeUserRole(Object userName) {
    return 'Was ist $userName für ein Hansel?';
  }

  @override
  String listSettingsSendListInvitationTitle(Object email) {
    return 'Wer ist $email ???';
  }

  @override
  String listSettingsSendListInvitationText(Object email) {
    return 'Hast du dich vertippt? Diese Emailadresse kennen wir noch nicht.\n\nOder möchtest du, dass wir an $email eine Einladung schicken?\nWenn sich der Hansel registriert, hat er Zugriff auf diese Liste.';
  }

  @override
  String get listSettingsSendListInvitationYes => 'Ja, gerne!';

  @override
  String get listSettingsSendListInvitationNo => 'Jetzt nicht';

  @override
  String listSettingsListInvitationSent(Object email) {
    return 'Wir haben eine Einladung an $email geschickt.';
  }

  @override
  String listSettingsRemoveUserFromList(
      Object userName, Object shoppingListName) {
    return 'Möchtest du $userName wirklich von $shoppingListName entfernen?';
  }

  @override
  String get listSettingsDangerZoneTitle => 'Gefahrenzone';

  @override
  String get listSettingsLeaveList => 'Liste verlassen...';

  @override
  String listSettingsLeaveExplanationOnlyAdmin(Object roleName) {
    return 'Du bist der einzige $roleName der Liste. Wenn du die Liste löschst, können auch die anderen Hansel mit denen du die Liste teilst nicht mehr darauf zugreifen.';
  }

  @override
  String listSettingsLeaveExplanationOtherAdminsPresent(Object roleName) {
    return 'Es gibt noch andere $roleName in der Liste, daher kannst du sie nicht löschen. Wenn du die Liste verlässt, können die anderen Hansel weiterhin darauf zugreifen.';
  }

  @override
  String get listSettingsDeleteList => 'Liste löschen...';

  @override
  String listSettingsDeleteListConfirmationText(Object shoppingListName) {
    return 'Möchtest du $shoppingListName wirklich für immer und unwiederbringlich löschen?';
  }

  @override
  String listSettingsLeaveListConfirmationText(Object shoppingListName) {
    return 'Möchtest du $shoppingListName wirklich verlassen?';
  }

  @override
  String get exceptionFatal => 'Jetzt ist der Kaufhansel abgestürzt.';

  @override
  String get exceptionGeneralTryAgainLater =>
      'Das hat nicht geklappt. Probier es später noch einmal.';

  @override
  String get exceptionGeneralServerSleeping =>
      'Schläft der Server noch oder hast du kein Internet?';

  @override
  String get exceptionGeneralServerTooLazy =>
      'Ist der Server zu faul oder hast du kein Internet?';

  @override
  String get exceptionGeneralComputerSays =>
      'Haben wir einen Fehler eingebaut oder hast du etwas falsch gemacht?\nComputer sagt: ';

  @override
  String get exceptionGeneralFeatureNotAvailable =>
      'Das funktioniert im Moment noch nicht.';

  @override
  String get exceptionRegistrationFailedTryAgainLater =>
      'Wollen wir nicht, dass du dich registrierst oder hast du etwas falsch gemacht?\nProbiere es einfach später nochmal.';

  @override
  String get exceptionResetPassword =>
      'Das hat nicht geklappt.\n\nStimmt die Email-Adresse?\nIst der Wiederherstellungs-Code richtig? \nHast du ein vernünftiges Passwort gewählt?\nDenk auch daran, dass der Wiederherstellungs-Code nur eine Stunde gültig ist.';

  @override
  String get exceptionWrongCredentials =>
      'Haben wir Deinen Account gelöscht oder hast Du Deine Zugangsdaten vergessen?';

  @override
  String get exceptionNoInternet =>
      'Haben wir den Server heruntergefahren oder bist du nicht mit dem Internet verbunden?';

  @override
  String get exceptionNoInternetDidNotWork =>
      'Das hat nicht funktioniert. Hast du kein Internet?';

  @override
  String get exceptionUpdateCheckFailed =>
      'Hast du kein Internet oder ist der Server nicht erreichbar?\nSo können wir jedenfalls nicht prüfen, ob dein Kaufhansel noch aktuell ist!';

  @override
  String get exceptionConnectionTimeout =>
      'Schläft der Server oder ist das Internet zu langsam?\nJedenfalls hat das alles viel zu lange gedauert.';

  @override
  String exceptionIncompatibleVersion(
      Object frontendVersion, Object backendVersion) {
    return 'Du verwendest vom Kaufhansel immer noch die Version $frontendVersion ???\n\nDie ist doch schon viel zu alt. Hol dir die neue und viel bessere Version \$$backendVersion von';
  }

  @override
  String exceptionRenameItemFailed(Object itemName) {
    return 'Findet der Server $itemName doof oder hast du kein Internet?';
  }

  @override
  String exceptionAddItemFailed(Object itemName) {
    return '$itemName konnte nicht hinzugefügt werden... ist das schon Zensur?';
  }

  @override
  String exceptionDeleteItemFailed(Object itemName) {
    return '$itemName konnte nicht gelöscht werden...';
  }

  @override
  String get exceptionMoveItemFailed =>
      'Das Element konnte nicht verschoben werden...';

  @override
  String get exceptionCantChangeAdminRole =>
      'Einmal Chefhansel, immer Chefhansel. Daran kannst du nichts mehr ändern.';

  @override
  String get exceptionCantFindOtherUser =>
      'Hast du dich vertippt oder können wir den Hansel nicht finden?';

  @override
  String get exceptionSendListInvitationFailed =>
      'Das Verschicken der Einladungs-Email hat leider nicht geklappt. Ruf den Hansel doch einfach mal an.';

  @override
  String get exceptionDeleteListFailed =>
      'Kann die Liste nicht gelöscht werden oder hast du kein Internet?';

  @override
  String get exceptionLogOutFailed => 'Die Abmeldung hat nicht funktioniert...';

  @override
  String get exceptionListCreationFailed =>
      'Ist der Speicher voll oder hast du einen Fehler beim Anlegen der Liste gemacht?';

  @override
  String get exceptionUnAuthenticated =>
      'Das hat nicht funktioniert. Sieht so aus als ob deine Sitzung abgelaufen ist.';

  @override
  String exceptionUnknown(Object exception) {
    return 'Irgendetwas ist schiefgelaufen ($exception)';
  }
}
