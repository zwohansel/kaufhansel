// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  static m0(emailAddress) => "Wir haben dir eine E-Mail an ${emailAddress} geschickt... folge dem Aktivierungs-Link, dann kannst du dich anmelden.";

  static m1(userName) => "Schade ${userName}, dass du dein Benutzerkonto löschen willst";

  static m2(username) => "${username}, was willst du ändern?";

  static m3(email) => "Deine Email-Adresse: ${email}";

  static m4(itemName) => "${itemName} konnte nicht hinzugefügt werden... ist das schon Zensur?";

  static m5(itemName) => "${itemName} konnte nicht gelöscht werden...";

  static m6(frontendVersion, backendVersion) => "Du verwendest vom Kaufhansel immer noch die Version ${frontendVersion} ???\n\nDie ist doch schon viel zu alt. Hol dir die neue und viel bessere Version \$${backendVersion} von";

  static m7(itemName) => "${itemName} konnte nicht verschoben werden...";

  static m8(itemName) => "Findet der Server ${itemName} doof oder hast du kein Internet?";

  static m9(shoppingListName) => "Alle Kategorien in ${shoppingListName} wurden entfernt.";

  static m10(shoppingListName) => "Alle Häckchen in ${shoppingListName} wurden entfernt.";

  static m11(userName) => "Was ist ${userName} für ein Hansel?";

  static m12(shoppingListName) => "Möchtest du wirklich alle Elemente aus ${shoppingListName} unwiederbringlich entfernen?";

  static m13(shoppingListName) => "Möchtest du ${shoppingListName} wirklich für immer und unwiederbringlich löschen?";

  static m14(roleName) => "Du bist der einzige ${roleName} der Liste. Wenn du die Liste löschst, können auch die anderen Hansel mit denen du die Liste teilst nicht mehr darauf zugreifen.";

  static m15(roleName) => "Es gibt noch andere ${roleName} in der Liste, daher kannst du sie nicht löschen. Wenn du die Liste verlässt, können die anderen Hansel weiterhin darauf zugreifen.";

  static m16(shoppingListName) => "Alle Elemente in ${shoppingListName} wurden entfernt.";

  static m17(email) => "Wir haben eine Einladung an ${email} geschickt.";

  static m18(userName, shoppingListName) => "Möchtest du ${userName} wirklich von ${shoppingListName} entfernen?";

  static m19(email) => "Hast du dich vertippt? Diese Emailadresse kennen wir noch nicht.\n\nOder möchtest du, dass wir an ${email} eine Einladung schicken?\nWenn sich der Hansel registriert, hat er Zugriff auf diese Liste.";

  static m20(email) => "Wer ist ${email} ???";

  static m21(version) => "Version ${version} ist verfügbar";

  static m22(roleName) => "Hier bist du ${roleName}:";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "activationLinkSent" : m0,
    "appSettingsAboutTitle" : MessageLookupByLibrary.simpleMessage("Über die App"),
    "appSettingsAccountDeletedEmoji" : MessageLookupByLibrary.simpleMessage("👋"),
    "appSettingsAccountDeletedText" : MessageLookupByLibrary.simpleMessage("Wir haben alle deine Daten gelöscht. Tschüss!"),
    "appSettingsDeleteAccount" : MessageLookupByLibrary.simpleMessage("Ich will mein Benutzerkonto löschen..."),
    "appSettingsDeleteAccountConfirmationText" : MessageLookupByLibrary.simpleMessage("Dein Benutzerkonto wird endgültig und unwiederbringlich gelöscht.\n\nAlle Einkaufslisten, die du nicht geteilt hast, werden gelöscht. Alle Einkaufslisten, bei denen du der einzige Chefhansel bist, werden gelöscht und andere Hansel daraus entfernt. Du wirst aus allen Einkaufslisten entfernt, bei denen du nicht der einzige Chefhansel bist.\n\nWillst du das wirklich?"),
    "appSettingsDeleteAccountConfirmationTextTitle" : m1,
    "appSettingsDeleteAccountNo" : MessageLookupByLibrary.simpleMessage("Nein, doch nicht"),
    "appSettingsDeleteAccountYes" : MessageLookupByLibrary.simpleMessage("Ja, lösch mich!"),
    "appSettingsLogOut" : MessageLookupByLibrary.simpleMessage("Ich will mich mal kurz abmelden"),
    "appSettingsTitle" : m2,
    "appSettingsYourEmail" : m3,
    "appTitle" : MessageLookupByLibrary.simpleMessage("Kaufhansel"),
    "buttonBackToLogin" : MessageLookupByLibrary.simpleMessage("Zurück zur Anmeldung"),
    "buttonForward" : MessageLookupByLibrary.simpleMessage("Weiter"),
    "buttonLogin" : MessageLookupByLibrary.simpleMessage("Anmelden"),
    "buttonPasswordChange" : MessageLookupByLibrary.simpleMessage("Kenwort ändern"),
    "buttonPasswordForgotten" : MessageLookupByLibrary.simpleMessage("Kennwort vergessen"),
    "buttonPasswordReset" : MessageLookupByLibrary.simpleMessage("Kennwort zurücksetzen"),
    "buttonPasswordResetCode" : MessageLookupByLibrary.simpleMessage("Wiederherstellungs-Code eingeben"),
    "buttonRegister" : MessageLookupByLibrary.simpleMessage("Registrieren"),
    "cancel" : MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "categoryChooseOne" : MessageLookupByLibrary.simpleMessage("Wähle eine Kategorie"),
    "categoryCreateNew" : MessageLookupByLibrary.simpleMessage("Neue Kategorie"),
    "categoryNone" : MessageLookupByLibrary.simpleMessage("Keine"),
    "close" : MessageLookupByLibrary.simpleMessage("Schließen"),
    "dontCare" : MessageLookupByLibrary.simpleMessage("Egal"),
    "downloadLink" : MessageLookupByLibrary.simpleMessage("https://zwohansel.de/kaufhansel/download"),
    "downloadLinkPromotion" : MessageLookupByLibrary.simpleMessage("Die Downloads gibts hier: "),
    "emailAlreadyInUse" : MessageLookupByLibrary.simpleMessage("Nimm eine andere"),
    "emailHint" : MessageLookupByLibrary.simpleMessage("Email-Adresse"),
    "emailInvalid" : MessageLookupByLibrary.simpleMessage("Gib eine gültige Email-Adresse ein"),
    "exceptionAddItemFailed" : m4,
    "exceptionCantChangeAdminRole" : MessageLookupByLibrary.simpleMessage("Einmal Chefhansel, immer Chefhansel. Daran kannst du nichts mehr ändern."),
    "exceptionCantFindOtherUser" : MessageLookupByLibrary.simpleMessage("Hast du dich vertippt oder können wir den Hansel nicht finden?"),
    "exceptionConnectionTimeout" : MessageLookupByLibrary.simpleMessage("Schläft der Server oder ist das Internet zu langsam?\nJedenfalls hat das alles viel zu lange gedauert."),
    "exceptionDeleteItemFailed" : m5,
    "exceptionDeleteListFailed" : MessageLookupByLibrary.simpleMessage("Kann die Liste nicht gelöscht werden oder hast du kein Internet?"),
    "exceptionFatal" : MessageLookupByLibrary.simpleMessage("Jetzt ist der Kaufhansel abgestürzt."),
    "exceptionGeneralComputerSays" : MessageLookupByLibrary.simpleMessage("Haben wir einen Fehler eingebaut oder hast du etwas falsch gemacht?\nComputer sagt: "),
    "exceptionGeneralFeatureNotAvailable" : MessageLookupByLibrary.simpleMessage("Das funktioniert im Moment noch nicht."),
    "exceptionGeneralServerSleeping" : MessageLookupByLibrary.simpleMessage("Schläft der Server noch oder hast du kein Internet?"),
    "exceptionGeneralServerTooLazy" : MessageLookupByLibrary.simpleMessage("Ist der Server zu faul oder hast du kein Internet?"),
    "exceptionGeneralTryAgainLater" : MessageLookupByLibrary.simpleMessage("Das hat nicht geklappt. Probier es später noch einmal."),
    "exceptionIncompatibleVersion" : m6,
    "exceptionLogOutFailed" : MessageLookupByLibrary.simpleMessage("Die Abmeldung hat nicht funktioniert..."),
    "exceptionMoveItemFailed" : m7,
    "exceptionNoInternet" : MessageLookupByLibrary.simpleMessage("Haben wir den Server heruntergefahren oder bist du nicht mit dem Internet verbunden?"),
    "exceptionNoInternetDidNotWork" : MessageLookupByLibrary.simpleMessage("Das hat nicht funktioniert. Hast du kein Internet?"),
    "exceptionRegistrationFailedTryAgainLater" : MessageLookupByLibrary.simpleMessage("Wollen wir nicht, dass du dich registrierst oder hast du etwas falsch gemacht?\nProbiere es einfach später nochmal."),
    "exceptionRenameItemFailed" : m8,
    "exceptionResetPassword" : MessageLookupByLibrary.simpleMessage("Das hat nicht geklappt.\n\nStimmt die Email-Adresse?\nIst der Wiederherstellungs-Code richtig? \nHast du ein vernünftiges Passwort gewählt?\nDenk auch daran, dass der Wiederherstellungs-Code nur eine Stunde gültig ist."),
    "exceptionSendListInvitationFailed" : MessageLookupByLibrary.simpleMessage("Das Verschicken der Einladungs-Email hat leider nicht geklappt. Ruf den Hansel doch einfach mal an."),
    "exceptionUpdateCheckFailed" : MessageLookupByLibrary.simpleMessage("Hast du kein Internet oder ist der Server nicht erreichbar?\nSo können wir jedenfalls nicht prüfen, ob dein Kaufhansel noch aktuell ist!"),
    "exceptionWrongCredentials" : MessageLookupByLibrary.simpleMessage("Haben wir Deinen Account gelöscht oder hast Du Deine Zugangsdaten vergessen?"),
    "important" : MessageLookupByLibrary.simpleMessage("Achtung!"),
    "invitationCodeEmpty" : MessageLookupByLibrary.simpleMessage("Gib deinen Einladungs-Code ein"),
    "invitationCodeGenerate" : MessageLookupByLibrary.simpleMessage("Einladungs-Code generieren"),
    "invitationCodeGenerating" : MessageLookupByLibrary.simpleMessage("Code wird generiert"),
    "invitationCodeHint" : MessageLookupByLibrary.simpleMessage("Einladungs-Code"),
    "invitationCodeInvalid" : MessageLookupByLibrary.simpleMessage("Der Code stimmt nicht"),
    "invitationCodeRequestDistributionMessage" : MessageLookupByLibrary.simpleMessage("Schicke anderen Hanseln diesen Code, damit sie sich beim Kaufhansel registrieren können."),
    "invitationCodeShareMessage" : MessageLookupByLibrary.simpleMessage("Werde mit diesem Code zum Kaufhansel! Lade dir den Kaufhansel von https://zwohansel.de/kaufhansel/download runter."),
    "listSettingsAddUserToListEmailAddressHint" : MessageLookupByLibrary.simpleMessage("Email-Adresse vom Hansel"),
    "listSettingsAllCategoriesCleared" : m9,
    "listSettingsAllItemsUnchecked" : m10,
    "listSettingsChangeUserRole" : m11,
    "listSettingsClearAllCategories" : MessageLookupByLibrary.simpleMessage("Alle Kategorien entfernen"),
    "listSettingsClearList" : MessageLookupByLibrary.simpleMessage("Liste leeren..."),
    "listSettingsClearListConfirmationText" : m12,
    "listSettingsDangerZoneTitle" : MessageLookupByLibrary.simpleMessage("Gefahrenzone"),
    "listSettingsDeleteList" : MessageLookupByLibrary.simpleMessage("Liste löschen..."),
    "listSettingsDeleteListConfirmationText" : m13,
    "listSettingsLeaveExplanationOnlyAdmin" : m14,
    "listSettingsLeaveExplanationOtherAdminsPresent" : m15,
    "listSettingsLeaveList" : MessageLookupByLibrary.simpleMessage("Liste verlassen..."),
    "listSettingsListCleared" : m16,
    "listSettingsListInvitationSent" : m17,
    "listSettingsRemoveUserFromList" : m18,
    "listSettingsSendListInvitationNo" : MessageLookupByLibrary.simpleMessage("Jetzt nicht"),
    "listSettingsSendListInvitationText" : m19,
    "listSettingsSendListInvitationTitle" : m20,
    "listSettingsSendListInvitationYes" : MessageLookupByLibrary.simpleMessage("Ja, gerne!"),
    "listSettingsShareWithOther" : MessageLookupByLibrary.simpleMessage("Mit einem weiteren Hansel teilen"),
    "listSettingsShareWithOtherInfo" : MessageLookupByLibrary.simpleMessage("Wenn du nichts änderst, kann der neue Hansel Dinge hinzufügen und entfernen, er darf Haken setzen und entfernen. Er ist ein Schreibhansel."),
    "listSettingsSharingWith" : MessageLookupByLibrary.simpleMessage("Du teilst die Liste mit"),
    "listSettingsSharingWithSelf" : MessageLookupByLibrary.simpleMessage("Dir"),
    "listSettingsUncheckAllItems" : MessageLookupByLibrary.simpleMessage("Alle Häckchen entfernen"),
    "manShrugging" : MessageLookupByLibrary.simpleMessage("🤷‍♂️"),
    "newerVersionAvailable" : m21,
    "ok" : MessageLookupByLibrary.simpleMessage("Ok"),
    "okImmediately" : MessageLookupByLibrary.simpleMessage("Mach ich sofort"),
    "passwordChangeSuccess" : MessageLookupByLibrary.simpleMessage("Du hast dein Kennwort erfolgreich geändert."),
    "passwordConfirmationHint" : MessageLookupByLibrary.simpleMessage("Kennwort bestätigen"),
    "passwordConfirmationInvalid" : MessageLookupByLibrary.simpleMessage("Gib dein Kennwort nochmal ein"),
    "passwordEmpty" : MessageLookupByLibrary.simpleMessage("Gib dein Kennwort richtig ein"),
    "passwordHint" : MessageLookupByLibrary.simpleMessage("Kennwort"),
    "passwordInvalid" : MessageLookupByLibrary.simpleMessage("Denk dir was besseres aus"),
    "passwordNewConfirmationHint" : MessageLookupByLibrary.simpleMessage("Neues Kennwort bestätigen"),
    "passwordNewConfirmationInvalid" : MessageLookupByLibrary.simpleMessage("Gib dein neues Kennwort nochmal ein"),
    "passwordNewHint" : MessageLookupByLibrary.simpleMessage("Neues Kennwort"),
    "passwordResetCodeHint" : MessageLookupByLibrary.simpleMessage("Wiederherstellungs-Code"),
    "passwordResetCodeInvalid" : MessageLookupByLibrary.simpleMessage("Gib den Wiederherstellungs-Code ein"),
    "passwordResetInfo" : MessageLookupByLibrary.simpleMessage("Falls du beim Kaufhansel registriert bist, haben wir dir eine Email mit einem Wiederherstellungs-Code geschickt. Gib den Code hier ein, um dein Kennwort zurückzusetzen."),
    "passwordToShort" : MessageLookupByLibrary.simpleMessage("Mindestens 8 Zeichen"),
    "refresh" : MessageLookupByLibrary.simpleMessage("Aktualisieren"),
    "registrationSuccessful" : MessageLookupByLibrary.simpleMessage("Deine Registrierung ist abgeschlossen. Du kannst dich nun mit deiner Email-Adresse und deinem Passwort anmelden."),
    "roleAdminDescription" : MessageLookupByLibrary.simpleMessage("Darf alles: Dinge hinzufügen und entfernen, Haken setzen und entfernen. Darf neue Hansel zur Liste hinzufügen.\nEinmal Chefhansel, immer Chefhansel: diese Rolle kannst du nicht mehr ändern"),
    "roleAdminName" : MessageLookupByLibrary.simpleMessage("Chefhansel"),
    "roleCheckOnlyDescription" : MessageLookupByLibrary.simpleMessage("Darf Haken setzen und entfernen"),
    "roleCheckOnlyName" : MessageLookupByLibrary.simpleMessage("Kaufhansel"),
    "roleReadOnlyDescription" : MessageLookupByLibrary.simpleMessage("Darf die Liste anschauen, aber nix ändern"),
    "roleReadOnlyName" : MessageLookupByLibrary.simpleMessage("Guckhansel"),
    "roleReadWriteDescription" : MessageLookupByLibrary.simpleMessage("Darf Dinge hinzufügen und entfernen, darf Haken setzen und entfernen"),
    "roleReadWriteName" : MessageLookupByLibrary.simpleMessage("Schreibhansel"),
    "roleYoursRoleName" : m22,
    "settings" : MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "shoppingListCreateNew" : MessageLookupByLibrary.simpleMessage("Neue Liste"),
    "shoppingListEmpty" : MessageLookupByLibrary.simpleMessage("🌽🥦🧀"),
    "shoppingListEmptyText" : MessageLookupByLibrary.simpleMessage("Du hast noch keine Einkaufsliste.\nIm Menü oben rechts kannst du neue Listen anlegen."),
    "shoppingListError" : MessageLookupByLibrary.simpleMessage("Oh nein! Haben wir Deine Einkaufslisten etwa verlegt?"),
    "shoppingListFilterAlreadyInCart" : MessageLookupByLibrary.simpleMessage("Was ist schon im Einkaufswagen"),
    "shoppingListFilterNeeded" : MessageLookupByLibrary.simpleMessage("Was muss ich noch kaufen"),
    "shoppingListModeEditing" : MessageLookupByLibrary.simpleMessage("Editiermodus"),
    "shoppingListModeShopping" : MessageLookupByLibrary.simpleMessage("Einkaufsmodus"),
    "shoppingListNeededHint" : MessageLookupByLibrary.simpleMessage("Suchen oder hinzufügen"),
    "thatsJustHowItIs" : MessageLookupByLibrary.simpleMessage("Ist dann halt schon so..."),
    "tryAgain" : MessageLookupByLibrary.simpleMessage("Nochmal versuchen"),
    "userNameHint" : MessageLookupByLibrary.simpleMessage("Nutzername"),
    "userNameInvalid" : MessageLookupByLibrary.simpleMessage("Gib einen Nutzernamen ein"),
    "zwoHanselGithubLink" : MessageLookupByLibrary.simpleMessage("https://github.com/zwohansel"),
    "zwoHanselGithubLinkInfo" : MessageLookupByLibrary.simpleMessage("ZwoHansel auf GitHub"),
    "zwoHanselKaufhanselGithubLink" : MessageLookupByLibrary.simpleMessage("https://github.com/zwohansel/kaufhansel"),
    "zwoHanselKaufhanselGithubLinkInfo" : MessageLookupByLibrary.simpleMessage("Der Kaufhansel auf GitHub"),
    "zwoHanselPageLink" : MessageLookupByLibrary.simpleMessage("https://zwohansel.de"),
    "zwoHanselPageLinkInfo" : MessageLookupByLibrary.simpleMessage("Mehr über die Entwickler auf zwohansel.de"),
    "zwoHanselPageLinkText" : MessageLookupByLibrary.simpleMessage("zwohansel.de")
  };
}
