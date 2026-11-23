// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static String m0(emailAddress) =>
      "Wir haben dir eine E-Mail an ${emailAddress} geschickt... folge dem Aktivierungs-Link, dann kannst du dich anmelden.";

  static String m1(userName) =>
      "Schade ${userName}, dass du dein Benutzerkonto löschen willst";

  static String m2(username) => "${username}, was willst du ändern?";

  static String m3(email) => "Deine Email-Adresse: ${email}";

  static String m4(itemName) =>
      "${itemName} konnte nicht hinzugefügt werden... ist das schon Zensur?";

  static String m5(itemName) => "${itemName} konnte nicht gelöscht werden...";

  static String m6(frontendVersion, backendVersion) =>
      "Du verwendest vom Kaufhansel immer noch die Version ${frontendVersion} ???\n\nDie ist doch schon viel zu alt. Hol dir die neue und viel bessere Version \$${backendVersion} von";

  static String m7(itemName) =>
      "Findet der Server ${itemName} doof oder hast du kein Internet?";

  static String m8(exception) =>
      "Irgendetwas ist schiefgelaufen (${exception})";

  static String m9(userName) => "Was ist ${userName} für ein Hansel?";

  static String m10(shoppingListName) =>
      "Möchtest du wirklich alle Elemente aus ${shoppingListName} unwiederbringlich entfernen?";

  static String m11(shoppingListName) =>
      "Möchtest du ${shoppingListName} wirklich für immer und unwiederbringlich löschen?";

  static String m12(roleName) =>
      "Du bist der einzige ${roleName} der Liste. Wenn du die Liste löschst, können auch die anderen Hansel mit denen du die Liste teilst nicht mehr darauf zugreifen.";

  static String m13(roleName) =>
      "Es gibt noch andere ${roleName} in der Liste, daher kannst du sie nicht löschen. Wenn du die Liste verlässt, können die anderen Hansel weiterhin darauf zugreifen.";

  static String m14(shoppingListName) =>
      "Möchtest du ${shoppingListName} wirklich verlassen?";

  static String m15(shoppingListName) =>
      "Alle Elemente in ${shoppingListName} wurden entfernt.";

  static String m16(email) => "Wir haben eine Einladung an ${email} geschickt.";

  static String m17(userName, shoppingListName) =>
      "Möchtest du ${userName} wirklich von ${shoppingListName} entfernen?";

  static String m18(email) =>
      "Hast du dich vertippt? Diese Emailadresse kennen wir noch nicht.\n\nOder möchtest du, dass wir an ${email} eine Einladung schicken?\nWenn sich der Hansel registriert, hat er Zugriff auf diese Liste.";

  static String m19(email) => "Wer ist ${email} ???";

  static String m20(category) => "Kategorie ${category} entfernen";

  static String m21(category) =>
      "Alle abgehakten Dinge aus der Kategorie ${category} löschen";

  static String m22(category) => "Kategorie ${category} umbenennen...";

  static String m23(category) =>
      "Häkchen in der Kategorie ${category} entfernen";

  static String m24(version) => "Version ${version} ist verfügbar";

  static String m25(count) => "Aufbewahrte Änderungen: ${count}";

  static String m26(roleName) => "Hier bist du ${roleName}:";

  static String m27(listName) =>
      "Jedenfalls können wir die Liste ${listName} nicht finden.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "activationLinkSent": m0,
    "appSettings": MessageLookupByLibrary.simpleMessage("App-Einstellungen"),
    "appSettingsAboutTitle": MessageLookupByLibrary.simpleMessage(
      "Über die App",
    ),
    "appSettingsAccountDeletedEmoji": MessageLookupByLibrary.simpleMessage(
      "👋",
    ),
    "appSettingsAccountDeletedText": MessageLookupByLibrary.simpleMessage(
      "Wir haben alle deine Daten gelöscht. Tschüss!",
    ),
    "appSettingsDeleteAccount": MessageLookupByLibrary.simpleMessage(
      "Ich will mein Benutzerkonto löschen...",
    ),
    "appSettingsDeleteAccountConfirmationText":
        MessageLookupByLibrary.simpleMessage(
          "Dein Benutzerkonto wird endgültig und unwiederbringlich gelöscht.\n\nAlle Einkaufslisten, die du nicht geteilt hast, werden gelöscht. Alle Einkaufslisten, bei denen du der einzige Chefhansel bist, werden gelöscht und andere Hansel daraus entfernt. Du wirst aus allen Einkaufslisten entfernt, bei denen du nicht der einzige Chefhansel bist.\n\nWillst du das wirklich?",
        ),
    "appSettingsDeleteAccountConfirmationTextTitle": m1,
    "appSettingsDeleteAccountNo": MessageLookupByLibrary.simpleMessage(
      "Nein, doch nicht",
    ),
    "appSettingsDeleteAccountYes": MessageLookupByLibrary.simpleMessage(
      "Ja, lösch mich!",
    ),
    "appSettingsLogOut": MessageLookupByLibrary.simpleMessage(
      "Ich will mich mal kurz abmelden",
    ),
    "appSettingsTitle": m2,
    "appSettingsYourEmail": m3,
    "appTitle": MessageLookupByLibrary.simpleMessage("Kaufhansel"),
    "buttonBackToLogin": MessageLookupByLibrary.simpleMessage(
      "Zurück zur Anmeldung",
    ),
    "buttonLogin": MessageLookupByLibrary.simpleMessage("Anmelden"),
    "buttonNext": MessageLookupByLibrary.simpleMessage("Weiter"),
    "buttonPasswordChange": MessageLookupByLibrary.simpleMessage(
      "Kenwort ändern",
    ),
    "buttonPasswordForgotten": MessageLookupByLibrary.simpleMessage(
      "Kennwort vergessen",
    ),
    "buttonPasswordReset": MessageLookupByLibrary.simpleMessage(
      "Kennwort zurücksetzen",
    ),
    "buttonPasswordResetCode": MessageLookupByLibrary.simpleMessage(
      "Wiederherstellungs-Code eingeben",
    ),
    "buttonRegister": MessageLookupByLibrary.simpleMessage("Registrieren"),
    "cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "categoryChooseOne": MessageLookupByLibrary.simpleMessage(
      "Wähle eine Kategorie",
    ),
    "categoryCreateNew": MessageLookupByLibrary.simpleMessage("Neue Kategorie"),
    "categoryNone": MessageLookupByLibrary.simpleMessage("Keine"),
    "close": MessageLookupByLibrary.simpleMessage("Schließen"),
    "createOrSearchHint": MessageLookupByLibrary.simpleMessage(
      "Suchen oder hinzufügen",
    ),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Haftungsausschluss"),
    "disclaimerLink": MessageLookupByLibrary.simpleMessage(
      "https://zwohansel.de/kaufhansel/disclaimer.html",
    ),
    "dontCare": MessageLookupByLibrary.simpleMessage("Egal"),
    "downloadLink": MessageLookupByLibrary.simpleMessage(
      "https://zwohansel.de/kaufhansel/download",
    ),
    "downloadLinkPromotion": MessageLookupByLibrary.simpleMessage(
      "Die Downloads gibts hier: ",
    ),
    "emailAlreadyInUse": MessageLookupByLibrary.simpleMessage(
      "Nimm eine andere",
    ),
    "emailHint": MessageLookupByLibrary.simpleMessage("Email-Adresse"),
    "emailInvalid": MessageLookupByLibrary.simpleMessage(
      "Gib eine gültige Email-Adresse ein",
    ),
    "exceptionAddItemFailed": m4,
    "exceptionCantChangeAdminRole": MessageLookupByLibrary.simpleMessage(
      "Einmal Chefhansel, immer Chefhansel. Daran kannst du nichts mehr ändern.",
    ),
    "exceptionCantFindOtherUser": MessageLookupByLibrary.simpleMessage(
      "Hast du dich vertippt oder können wir den Hansel nicht finden?",
    ),
    "exceptionConnectionTimeout": MessageLookupByLibrary.simpleMessage(
      "Schläft der Server oder ist das Internet zu langsam?\nJedenfalls hat das alles viel zu lange gedauert.",
    ),
    "exceptionDeleteItemFailed": m5,
    "exceptionDeleteListFailed": MessageLookupByLibrary.simpleMessage(
      "Kann die Liste nicht gelöscht werden oder hast du kein Internet?",
    ),
    "exceptionFatal": MessageLookupByLibrary.simpleMessage(
      "Jetzt ist der Kaufhansel abgestürzt.",
    ),
    "exceptionGeneralComputerSays": MessageLookupByLibrary.simpleMessage(
      "Haben wir einen Fehler eingebaut oder hast du etwas falsch gemacht?\nComputer sagt: ",
    ),
    "exceptionGeneralFeatureNotAvailable": MessageLookupByLibrary.simpleMessage(
      "Das funktioniert im Moment noch nicht.",
    ),
    "exceptionGeneralServerSleeping": MessageLookupByLibrary.simpleMessage(
      "Schläft der Server noch oder hast du kein Internet?",
    ),
    "exceptionGeneralServerTooLazy": MessageLookupByLibrary.simpleMessage(
      "Ist der Server zu faul oder hast du kein Internet?",
    ),
    "exceptionGeneralTryAgainLater": MessageLookupByLibrary.simpleMessage(
      "Das hat nicht geklappt. Probier es später noch einmal.",
    ),
    "exceptionIncompatibleVersion": m6,
    "exceptionListCreationFailed": MessageLookupByLibrary.simpleMessage(
      "Ist der Speicher voll oder hast du einen Fehler beim Anlegen der Liste gemacht?",
    ),
    "exceptionLogOutFailed": MessageLookupByLibrary.simpleMessage(
      "Die Abmeldung hat nicht funktioniert...",
    ),
    "exceptionMoveItemFailed": MessageLookupByLibrary.simpleMessage(
      "Das Element konnte nicht verschoben werden...",
    ),
    "exceptionMoveItemNeedsConnection": MessageLookupByLibrary.simpleMessage(
      "Verschieben geht nur mit Internetverbindung.",
    ),
    "exceptionNoInternet": MessageLookupByLibrary.simpleMessage(
      "Haben wir den Server heruntergefahren oder bist du nicht mit dem Internet verbunden?",
    ),
    "exceptionNoInternetDidNotWork": MessageLookupByLibrary.simpleMessage(
      "Das hat nicht funktioniert. Hast du kein Internet?",
    ),
    "exceptionRegistrationFailedTryAgainLater":
        MessageLookupByLibrary.simpleMessage(
          "Wollen wir nicht, dass du dich registrierst oder hast du etwas falsch gemacht?\nProbiere es einfach später nochmal.",
        ),
    "exceptionRenameItemFailed": m7,
    "exceptionResetPassword": MessageLookupByLibrary.simpleMessage(
      "Das hat nicht geklappt.\n\nStimmt die Email-Adresse?\nIst der Wiederherstellungs-Code richtig? \nHast du ein vernünftiges Passwort gewählt?\nDenk auch daran, dass der Wiederherstellungs-Code nur eine Stunde gültig ist.",
    ),
    "exceptionSendListInvitationFailed": MessageLookupByLibrary.simpleMessage(
      "Das Verschicken der Einladungs-Email hat leider nicht geklappt. Ruf den Hansel doch einfach mal an.",
    ),
    "exceptionUnAuthenticated": MessageLookupByLibrary.simpleMessage(
      "Das hat nicht funktioniert. Sieht so aus als ob deine Sitzung abgelaufen ist.",
    ),
    "exceptionUnknown": m8,
    "exceptionUpdateCheckFailed": MessageLookupByLibrary.simpleMessage(
      "Hast du kein Internet oder ist der Server nicht erreichbar?\nSo können wir jedenfalls nicht prüfen, ob dein Kaufhansel noch aktuell ist!",
    ),
    "exceptionWrongCredentials": MessageLookupByLibrary.simpleMessage(
      "Haben wir Deinen Account gelöscht oder hast Du Deine Zugangsdaten vergessen?",
    ),
    "general": MessageLookupByLibrary.simpleMessage("Allgemein"),
    "important": MessageLookupByLibrary.simpleMessage("Achtung!"),
    "invitationCodeEmpty": MessageLookupByLibrary.simpleMessage(
      "Gib deinen Einladungs-Code ein",
    ),
    "invitationCodeGenerate": MessageLookupByLibrary.simpleMessage(
      "Einladungs-Code generieren",
    ),
    "invitationCodeGenerating": MessageLookupByLibrary.simpleMessage(
      "Code wird generiert",
    ),
    "invitationCodeHint": MessageLookupByLibrary.simpleMessage(
      "Einladungs-Code",
    ),
    "invitationCodeInvalid": MessageLookupByLibrary.simpleMessage(
      "Der Code stimmt nicht",
    ),
    "invitationCodeRequestDistributionMessage":
        MessageLookupByLibrary.simpleMessage(
          "Schicke anderen Hanseln diesen Code, damit sie sich beim Kaufhansel registrieren können.",
        ),
    "invitationCodeShareMessage": MessageLookupByLibrary.simpleMessage(
      "Werde mit diesem Code zum Kaufhansel! Lade dir den Kaufhansel von https://zwohansel.de/kaufhansel/download runter.",
    ),
    "itemRemove": MessageLookupByLibrary.simpleMessage("Löschen"),
    "itemRename": MessageLookupByLibrary.simpleMessage("Umbenennen"),
    "listSettings": MessageLookupByLibrary.simpleMessage(
      "Mehr Listeneinstellungen...",
    ),
    "listSettingsAddUserToListEmailAddressHint":
        MessageLookupByLibrary.simpleMessage("Email-Adresse vom Hansel"),
    "listSettingsChangeUserRole": m9,
    "listSettingsClearList": MessageLookupByLibrary.simpleMessage(
      "Liste leeren...",
    ),
    "listSettingsClearListConfirmationText": m10,
    "listSettingsDangerZoneTitle": MessageLookupByLibrary.simpleMessage(
      "Gefahrenzone",
    ),
    "listSettingsDeleteList": MessageLookupByLibrary.simpleMessage(
      "Liste löschen...",
    ),
    "listSettingsDeleteListConfirmationText": m11,
    "listSettingsLeaveExplanationOnlyAdmin": m12,
    "listSettingsLeaveExplanationOtherAdminsPresent": m13,
    "listSettingsLeaveList": MessageLookupByLibrary.simpleMessage(
      "Liste verlassen...",
    ),
    "listSettingsLeaveListConfirmationText": m14,
    "listSettingsListCleared": m15,
    "listSettingsListInvitationSent": m16,
    "listSettingsRemoveUserFromList": m17,
    "listSettingsSendListInvitationNo": MessageLookupByLibrary.simpleMessage(
      "Jetzt nicht",
    ),
    "listSettingsSendListInvitationText": m18,
    "listSettingsSendListInvitationTitle": m19,
    "listSettingsSendListInvitationYes": MessageLookupByLibrary.simpleMessage(
      "Ja, gerne!",
    ),
    "listSettingsShareWithOther": MessageLookupByLibrary.simpleMessage(
      "Mit einem weiteren Hansel teilen",
    ),
    "listSettingsShareWithOtherInfo": MessageLookupByLibrary.simpleMessage(
      "Neue Hansel werden als Schreibhansel hinzugefügt: sie können Dinge hinzufügen und entfernen; Dinge abhaken und Haken entfernen. Das kannst ändern, nachdem der neue Hansel in der Liste ist.",
    ),
    "listSettingsSharingWith": MessageLookupByLibrary.simpleMessage(
      "Du teilst die Liste mit",
    ),
    "listSettingsSharingWithSelf": MessageLookupByLibrary.simpleMessage("Dir"),
    "listSettingsUncheckItems": MessageLookupByLibrary.simpleMessage(
      "Häkchen entfernen...",
    ),
    "listSettingsUncheckItemsTitle": MessageLookupByLibrary.simpleMessage(
      "Welche Häkchen möchtest du entfernen?",
    ),
    "manShrugging": MessageLookupByLibrary.simpleMessage("🤷‍♂️"),
    "manageCategories": MessageLookupByLibrary.simpleMessage(
      "Kategorien bearbeiten...",
    ),
    "manageCategoriesAction": MessageLookupByLibrary.simpleMessage("Aktion:"),
    "manageCategoriesCategory": MessageLookupByLibrary.simpleMessage(
      "Kategorie:",
    ),
    "manageCategoriesRemoveCategories": MessageLookupByLibrary.simpleMessage(
      "Alle Kategorien entfernen",
    ),
    "manageCategoriesRemoveCategory": m20,
    "manageCategoriesRemoveChecked": MessageLookupByLibrary.simpleMessage(
      "Alle abgehakten Dinge löschen",
    ),
    "manageCategoriesRemoveCheckedFromCategory": m21,
    "manageCategoriesRenameCategory": m22,
    "manageCategoriesRenameCategoryDialogTitle":
        MessageLookupByLibrary.simpleMessage("Kategorie umbenennen"),
    "manageCategoriesTitle": MessageLookupByLibrary.simpleMessage(
      "Kategorien bearbeiten",
    ),
    "manageCategoriesUncheckAll": MessageLookupByLibrary.simpleMessage(
      "Alle Häkchen entfernen",
    ),
    "manageCategoriesUncheckCategory": m23,
    "manageCategoriesWhich": MessageLookupByLibrary.simpleMessage(
      "Welche denn?",
    ),
    "newerVersionAvailable": m24,
    "newerVersionAvailableObligatoryUpdate":
        MessageLookupByLibrary.simpleMessage(
          "Es hat sich viel getan. Damit dein Kaufhansel weiterhin funktioniert, musst du diese Aktualisierung installieren. Mehr Infos findest du, wenn du auf den Link zum Herunterladen klickst, oder im Play Store.",
        ),
    "no": MessageLookupByLibrary.simpleMessage("Nein"),
    "offlineMessage": MessageLookupByLibrary.simpleMessage(
      "Hups, Du hast keine Internetverbindung. Hast Du Deine Rechnung nicht bezahlt? Wir bewahren Deine Änderungen für dich auf...",
    ),
    "offlinePendingChanges": m25,
    "offlineThanks": MessageLookupByLibrary.simpleMessage("Danke Kaufhansel"),
    "offlineTooltip": MessageLookupByLibrary.simpleMessage(
      "Keine Internetverbindung",
    ),
    "ok": MessageLookupByLibrary.simpleMessage("Ok"),
    "okImmediately": MessageLookupByLibrary.simpleMessage("Mach ich sofort"),
    "passwordChangeSuccess": MessageLookupByLibrary.simpleMessage(
      "Du hast dein Kennwort erfolgreich geändert.",
    ),
    "passwordConfirmationHint": MessageLookupByLibrary.simpleMessage(
      "Kennwort bestätigen",
    ),
    "passwordConfirmationInvalid": MessageLookupByLibrary.simpleMessage(
      "Gib dein Kennwort nochmal ein",
    ),
    "passwordEmpty": MessageLookupByLibrary.simpleMessage(
      "Gib dein Kennwort richtig ein",
    ),
    "passwordHint": MessageLookupByLibrary.simpleMessage("Kennwort"),
    "passwordInvalid": MessageLookupByLibrary.simpleMessage(
      "Denk dir was besseres aus",
    ),
    "passwordNewConfirmationHint": MessageLookupByLibrary.simpleMessage(
      "Neues Kennwort bestätigen",
    ),
    "passwordNewConfirmationInvalid": MessageLookupByLibrary.simpleMessage(
      "Gib dein neues Kennwort nochmal ein",
    ),
    "passwordNewHint": MessageLookupByLibrary.simpleMessage("Neues Kennwort"),
    "passwordResetCodeHint": MessageLookupByLibrary.simpleMessage(
      "Wiederherstellungs-Code",
    ),
    "passwordResetCodeInvalid": MessageLookupByLibrary.simpleMessage(
      "Gib den Wiederherstellungs-Code ein",
    ),
    "passwordResetInfo": MessageLookupByLibrary.simpleMessage(
      "Gib hier den Wiederherstellungs-Code ein den wir an deine Email Adresse geschickt haben, um dein Kennwort zurückzusetzen.",
    ),
    "passwordToShort": MessageLookupByLibrary.simpleMessage(
      "Mindestens 8 Zeichen",
    ),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage(
      "Datenschutzerklärung",
    ),
    "privacyPolicyLink": MessageLookupByLibrary.simpleMessage(
      "https://zwohansel.de/kaufhansel/privacy_de.html",
    ),
    "refresh": MessageLookupByLibrary.simpleMessage("Auffrischen"),
    "registrationConsentFirstPart": MessageLookupByLibrary.simpleMessage(
      "Ich habe die ",
    ),
    "registrationConsentLastPart": MessageLookupByLibrary.simpleMessage(" zu."),
    "registrationConsentMiddlePart": MessageLookupByLibrary.simpleMessage(
      " zur Kenntnis genommen und stimme dem ",
    ),
    "registrationSuccessful": MessageLookupByLibrary.simpleMessage(
      "Deine Registrierung ist abgeschlossen. Du kannst dich nun mit deiner Email-Adresse und deinem Passwort anmelden.",
    ),
    "roleAdminDescription": MessageLookupByLibrary.simpleMessage(
      "Darf alles: Dinge hinzufügen und entfernen, Haken setzen und entfernen. Darf neue Hansel zur Liste hinzufügen.\nEinmal Chefhansel, immer Chefhansel: diese Rolle kannst du nicht mehr ändern",
    ),
    "roleAdminName": MessageLookupByLibrary.simpleMessage("Chefhansel"),
    "roleCheckOnlyDescription": MessageLookupByLibrary.simpleMessage(
      "Darf Haken setzen und entfernen",
    ),
    "roleCheckOnlyName": MessageLookupByLibrary.simpleMessage("Kaufhansel"),
    "roleReadOnlyDescription": MessageLookupByLibrary.simpleMessage(
      "Darf die Liste anschauen, aber nix ändern",
    ),
    "roleReadOnlyName": MessageLookupByLibrary.simpleMessage("Guckhansel"),
    "roleReadWriteDescription": MessageLookupByLibrary.simpleMessage(
      "Darf Dinge hinzufügen und entfernen, darf Haken setzen und entfernen",
    ),
    "roleReadWriteName": MessageLookupByLibrary.simpleMessage("Schreibhansel"),
    "roleReadWriteWhatIsIt": MessageLookupByLibrary.simpleMessage(
      "Was ist ein Schreibhansel?",
    ),
    "roleYoursRoleName": m26,
    "rolesWhich": MessageLookupByLibrary.simpleMessage(
      "Welche Rollen gibt es?",
    ),
    "shoppingListCreateNew": MessageLookupByLibrary.simpleMessage(
      "Neue Liste...",
    ),
    "shoppingListCreateNewConfirm": MessageLookupByLibrary.simpleMessage(
      "Anlegen",
    ),
    "shoppingListCreateNewEnterNameHint": MessageLookupByLibrary.simpleMessage(
      "Gib einen Namen ein",
    ),
    "shoppingListCreateNewTitle": MessageLookupByLibrary.simpleMessage(
      "Neue Liste anlegen",
    ),
    "shoppingListEmpty": MessageLookupByLibrary.simpleMessage("🌽🥦🧀"),
    "shoppingListEmptyText": MessageLookupByLibrary.simpleMessage(
      "Du hast noch keine Einkaufsliste.\nIm Menü oben rechts kannst du neue Listen anlegen.",
    ),
    "shoppingListError": MessageLookupByLibrary.simpleMessage(
      "Oh nein! Haben wir Deine Einkaufslisten etwa verlegt?",
    ),
    "shoppingListFilterAlreadyInCart": MessageLookupByLibrary.simpleMessage(
      "Was ist schon im Einkaufswagen",
    ),
    "shoppingListFilterNeeded": MessageLookupByLibrary.simpleMessage(
      "Was muss ich noch kaufen",
    ),
    "shoppingListFilterNone": MessageLookupByLibrary.simpleMessage(
      "Kein Filter",
    ),
    "shoppingListFilterTitle": MessageLookupByLibrary.simpleMessage("Filter"),
    "shoppingListModeDefault": MessageLookupByLibrary.simpleMessage(
      "Guck-Modus",
    ),
    "shoppingListModeEditing": MessageLookupByLibrary.simpleMessage(
      "Editier-Modus",
    ),
    "shoppingListModeShopping": MessageLookupByLibrary.simpleMessage(
      "Einkaufs-Modus",
    ),
    "shoppingListModeTitle": MessageLookupByLibrary.simpleMessage("Modus"),
    "shoppingListMyLists": MessageLookupByLibrary.simpleMessage("Meine Listen"),
    "shoppingListNotPresent": m27,
    "shoppingListOpenOther": MessageLookupByLibrary.simpleMessage(
      "Andere Liste öffnen",
    ),
    "thatsJustHowItIs": MessageLookupByLibrary.simpleMessage(
      "Ist dann halt schon so...",
    ),
    "tryAgain": MessageLookupByLibrary.simpleMessage("Nochmal versuchen"),
    "userNameHint": MessageLookupByLibrary.simpleMessage("Nutzername"),
    "userNameInvalid": MessageLookupByLibrary.simpleMessage(
      "Gib einen Nutzernamen ein",
    ),
    "willLoginAgain": MessageLookupByLibrary.simpleMessage(
      "Ok... Ich melde mich gerne neu an.",
    ),
    "yes": MessageLookupByLibrary.simpleMessage("Ja"),
    "zwoHanselKaufhanselGithubLink": MessageLookupByLibrary.simpleMessage(
      "https://github.com/zwohansel/kaufhansel",
    ),
    "zwoHanselKaufhanselGithubLinkInfo": MessageLookupByLibrary.simpleMessage(
      "Der Kaufhansel-Quellcode auf GitHub",
    ),
    "zwoHanselKaufhanselLandingPageLink": MessageLookupByLibrary.simpleMessage(
      "https://zwohansel.de/kaufhansel",
    ),
    "zwoHanselKaufhanselLandingPageLinkInfo":
        MessageLookupByLibrary.simpleMessage("Der Kaufhansel im Internet"),
    "zwoHanselPageLink": MessageLookupByLibrary.simpleMessage(
      "https://zwohansel.de",
    ),
    "zwoHanselPageLinkInfo": MessageLookupByLibrary.simpleMessage(
      "Mehr über die Entwickler auf zwohansel.de",
    ),
    "zwoHanselPageLinkText": MessageLookupByLibrary.simpleMessage(
      "zwohansel.de",
    ),
  };
}
