// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values

class AppLocalizations {
  AppLocalizations();
  
  static AppLocalizations current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<AppLocalizations> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      AppLocalizations.current = AppLocalizations();
      
      return AppLocalizations.current;
    });
  } 

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// `Kaufhansel`
  String get appTitle {
    return Intl.message(
      'Kaufhansel',
      name: 'appTitle',
      desc: '',
      args: [],
    );
  }

  /// `https://zwohansel.de/kaufhansel/download`
  String get downloadLink {
    return Intl.message(
      'https://zwohansel.de/kaufhansel/download',
      name: 'downloadLink',
      desc: '',
      args: [],
    );
  }

  /// `Die Downloads gibts hier: `
  String get downloadLinkPromotion {
    return Intl.message(
      'Die Downloads gibts hier: ',
      name: 'downloadLinkPromotion',
      desc: '',
      args: [],
    );
  }

  /// `https://zwohansel.de`
  String get zwoHanselPageLink {
    return Intl.message(
      'https://zwohansel.de',
      name: 'zwoHanselPageLink',
      desc: '',
      args: [],
    );
  }

  /// `zwohansel.de`
  String get zwoHanselPageLinkText {
    return Intl.message(
      'zwohansel.de',
      name: 'zwoHanselPageLinkText',
      desc: '',
      args: [],
    );
  }

  /// `Mehr über die Entwickler auf zwohansel.de`
  String get zwoHanselPageLinkInfo {
    return Intl.message(
      'Mehr über die Entwickler auf zwohansel.de',
      name: 'zwoHanselPageLinkInfo',
      desc: '',
      args: [],
    );
  }

  /// `https://github.com/zwohansel/kaufhansel`
  String get zwoHanselKaufhanselGithubLink {
    return Intl.message(
      'https://github.com/zwohansel/kaufhansel',
      name: 'zwoHanselKaufhanselGithubLink',
      desc: '',
      args: [],
    );
  }

  /// `Der Kaufhansel-Quellcode auf GitHub`
  String get zwoHanselKaufhanselGithubLinkInfo {
    return Intl.message(
      'Der Kaufhansel-Quellcode auf GitHub',
      name: 'zwoHanselKaufhanselGithubLinkInfo',
      desc: '',
      args: [],
    );
  }

  /// `https://zwohansel.de/kaufhansel`
  String get zwoHanselKaufhanselLandingPageLink {
    return Intl.message(
      'https://zwohansel.de/kaufhansel',
      name: 'zwoHanselKaufhanselLandingPageLink',
      desc: '',
      args: [],
    );
  }

  /// `Der Kaufhansel im Internet`
  String get zwoHanselKaufhanselLandingPageLinkInfo {
    return Intl.message(
      'Der Kaufhansel im Internet',
      name: 'zwoHanselKaufhanselLandingPageLinkInfo',
      desc: '',
      args: [],
    );
  }

  /// `🤷‍♂️`
  String get manShrugging {
    return Intl.message(
      '🤷‍♂️',
      name: 'manShrugging',
      desc: '',
      args: [],
    );
  }

  /// `Ist dann halt schon so...`
  String get thatsJustHowItIs {
    return Intl.message(
      'Ist dann halt schon so...',
      name: 'thatsJustHowItIs',
      desc: '',
      args: [],
    );
  }

  /// `Achtung!`
  String get important {
    return Intl.message(
      'Achtung!',
      name: 'important',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Ja`
  String get yes {
    return Intl.message(
      'Ja',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `Nein`
  String get no {
    return Intl.message(
      'Nein',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `Abbrechen`
  String get cancel {
    return Intl.message(
      'Abbrechen',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Schließen`
  String get close {
    return Intl.message(
      'Schließen',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Egal`
  String get dontCare {
    return Intl.message(
      'Egal',
      name: 'dontCare',
      desc: '',
      args: [],
    );
  }

  /// `Mach ich sofort`
  String get okImmediately {
    return Intl.message(
      'Mach ich sofort',
      name: 'okImmediately',
      desc: '',
      args: [],
    );
  }

  /// `Nochmal versuchen`
  String get tryAgain {
    return Intl.message(
      'Nochmal versuchen',
      name: 'tryAgain',
      desc: '',
      args: [],
    );
  }

  /// `Auffrischen`
  String get refresh {
    return Intl.message(
      'Auffrischen',
      name: 'refresh',
      desc: '',
      args: [],
    );
  }

  /// `Allgemein`
  String get general {
    return Intl.message(
      'Allgemein',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `App-Einstellungen`
  String get appSettings {
    return Intl.message(
      'App-Einstellungen',
      name: 'appSettings',
      desc: '',
      args: [],
    );
  }

  /// `Mehr Listeneinstellungen...`
  String get listSettings {
    return Intl.message(
      'Mehr Listeneinstellungen...',
      name: 'listSettings',
      desc: '',
      args: [],
    );
  }

  /// `Datenschutzerklärung`
  String get privacyPolicy {
    return Intl.message(
      'Datenschutzerklärung',
      name: 'privacyPolicy',
      desc: '',
      args: [],
    );
  }

  /// `https://zwohansel.de/kaufhansel/privacy_de.html`
  String get privacyPolicyLink {
    return Intl.message(
      'https://zwohansel.de/kaufhansel/privacy_de.html',
      name: 'privacyPolicyLink',
      desc: '',
      args: [],
    );
  }

  /// `Haftungsausschluss`
  String get disclaimer {
    return Intl.message(
      'Haftungsausschluss',
      name: 'disclaimer',
      desc: '',
      args: [],
    );
  }

  /// `https://zwohansel.de/kaufhansel/disclaimer.html`
  String get disclaimerLink {
    return Intl.message(
      'https://zwohansel.de/kaufhansel/disclaimer.html',
      name: 'disclaimerLink',
      desc: '',
      args: [],
    );
  }

  /// `Ich habe die `
  String get registrationConsentFirstPart {
    return Intl.message(
      'Ich habe die ',
      name: 'registrationConsentFirstPart',
      desc: '',
      args: [],
    );
  }

  /// ` zur Kenntnis genommen und stimme dem `
  String get registrationConsentMiddlePart {
    return Intl.message(
      ' zur Kenntnis genommen und stimme dem ',
      name: 'registrationConsentMiddlePart',
      desc: '',
      args: [],
    );
  }

  /// ` zu.`
  String get registrationConsentLastPart {
    return Intl.message(
      ' zu.',
      name: 'registrationConsentLastPart',
      desc: '',
      args: [],
    );
  }

  /// `Chefhansel`
  String get roleAdminName {
    return Intl.message(
      'Chefhansel',
      name: 'roleAdminName',
      desc: '',
      args: [],
    );
  }

  /// `Darf alles: Dinge hinzufügen und entfernen, Haken setzen und entfernen. Darf neue Hansel zur Liste hinzufügen.\nEinmal Chefhansel, immer Chefhansel: diese Rolle kannst du nicht mehr ändern`
  String get roleAdminDescription {
    return Intl.message(
      'Darf alles: Dinge hinzufügen und entfernen, Haken setzen und entfernen. Darf neue Hansel zur Liste hinzufügen.\nEinmal Chefhansel, immer Chefhansel: diese Rolle kannst du nicht mehr ändern',
      name: 'roleAdminDescription',
      desc: '',
      args: [],
    );
  }

  /// `Schreibhansel`
  String get roleReadWriteName {
    return Intl.message(
      'Schreibhansel',
      name: 'roleReadWriteName',
      desc: '',
      args: [],
    );
  }

  /// `Darf Dinge hinzufügen und entfernen, darf Haken setzen und entfernen`
  String get roleReadWriteDescription {
    return Intl.message(
      'Darf Dinge hinzufügen und entfernen, darf Haken setzen und entfernen',
      name: 'roleReadWriteDescription',
      desc: '',
      args: [],
    );
  }

  /// `Was ist ein Schreibhansel?`
  String get roleReadWriteWhatIsIt {
    return Intl.message(
      'Was ist ein Schreibhansel?',
      name: 'roleReadWriteWhatIsIt',
      desc: '',
      args: [],
    );
  }

  /// `Kaufhansel`
  String get roleCheckOnlyName {
    return Intl.message(
      'Kaufhansel',
      name: 'roleCheckOnlyName',
      desc: '',
      args: [],
    );
  }

  /// `Darf Haken setzen und entfernen`
  String get roleCheckOnlyDescription {
    return Intl.message(
      'Darf Haken setzen und entfernen',
      name: 'roleCheckOnlyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Guckhansel`
  String get roleReadOnlyName {
    return Intl.message(
      'Guckhansel',
      name: 'roleReadOnlyName',
      desc: '',
      args: [],
    );
  }

  /// `Darf die Liste anschauen, aber nix ändern`
  String get roleReadOnlyDescription {
    return Intl.message(
      'Darf die Liste anschauen, aber nix ändern',
      name: 'roleReadOnlyDescription',
      desc: '',
      args: [],
    );
  }

  /// `Welche Rollen gibt es?`
  String get rolesWhich {
    return Intl.message(
      'Welche Rollen gibt es?',
      name: 'rolesWhich',
      desc: '',
      args: [],
    );
  }

  /// `Email-Adresse`
  String get emailHint {
    return Intl.message(
      'Email-Adresse',
      name: 'emailHint',
      desc: '',
      args: [],
    );
  }

  /// `Gib eine gültige Email-Adresse ein`
  String get emailInvalid {
    return Intl.message(
      'Gib eine gültige Email-Adresse ein',
      name: 'emailInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Nimm eine andere`
  String get emailAlreadyInUse {
    return Intl.message(
      'Nimm eine andere',
      name: 'emailAlreadyInUse',
      desc: '',
      args: [],
    );
  }

  /// `Kennwort`
  String get passwordHint {
    return Intl.message(
      'Kennwort',
      name: 'passwordHint',
      desc: '',
      args: [],
    );
  }

  /// `Gib dein Kennwort richtig ein`
  String get passwordEmpty {
    return Intl.message(
      'Gib dein Kennwort richtig ein',
      name: 'passwordEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Mindestens 8 Zeichen`
  String get passwordToShort {
    return Intl.message(
      'Mindestens 8 Zeichen',
      name: 'passwordToShort',
      desc: '',
      args: [],
    );
  }

  /// `Denk dir was besseres aus`
  String get passwordInvalid {
    return Intl.message(
      'Denk dir was besseres aus',
      name: 'passwordInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Kennwort bestätigen`
  String get passwordConfirmationHint {
    return Intl.message(
      'Kennwort bestätigen',
      name: 'passwordConfirmationHint',
      desc: '',
      args: [],
    );
  }

  /// `Gib dein Kennwort nochmal ein`
  String get passwordConfirmationInvalid {
    return Intl.message(
      'Gib dein Kennwort nochmal ein',
      name: 'passwordConfirmationInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Gib hier den Wiederherstellungs-Code ein den wir an deine Email Adresse geschickt haben, um dein Kennwort zurückzusetzen.`
  String get passwordResetInfo {
    return Intl.message(
      'Gib hier den Wiederherstellungs-Code ein den wir an deine Email Adresse geschickt haben, um dein Kennwort zurückzusetzen.',
      name: 'passwordResetInfo',
      desc: '',
      args: [],
    );
  }

  /// `Wiederherstellungs-Code`
  String get passwordResetCodeHint {
    return Intl.message(
      'Wiederherstellungs-Code',
      name: 'passwordResetCodeHint',
      desc: '',
      args: [],
    );
  }

  /// `Gib den Wiederherstellungs-Code ein`
  String get passwordResetCodeInvalid {
    return Intl.message(
      'Gib den Wiederherstellungs-Code ein',
      name: 'passwordResetCodeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Neues Kennwort`
  String get passwordNewHint {
    return Intl.message(
      'Neues Kennwort',
      name: 'passwordNewHint',
      desc: '',
      args: [],
    );
  }

  /// `Neues Kennwort bestätigen`
  String get passwordNewConfirmationHint {
    return Intl.message(
      'Neues Kennwort bestätigen',
      name: 'passwordNewConfirmationHint',
      desc: '',
      args: [],
    );
  }

  /// `Gib dein neues Kennwort nochmal ein`
  String get passwordNewConfirmationInvalid {
    return Intl.message(
      'Gib dein neues Kennwort nochmal ein',
      name: 'passwordNewConfirmationInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Du hast dein Kennwort erfolgreich geändert.`
  String get passwordChangeSuccess {
    return Intl.message(
      'Du hast dein Kennwort erfolgreich geändert.',
      name: 'passwordChangeSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Einladungs-Code`
  String get invitationCodeHint {
    return Intl.message(
      'Einladungs-Code',
      name: 'invitationCodeHint',
      desc: '',
      args: [],
    );
  }

  /// `Gib deinen Einladungs-Code ein`
  String get invitationCodeEmpty {
    return Intl.message(
      'Gib deinen Einladungs-Code ein',
      name: 'invitationCodeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Der Code stimmt nicht`
  String get invitationCodeInvalid {
    return Intl.message(
      'Der Code stimmt nicht',
      name: 'invitationCodeInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Einladungs-Code generieren`
  String get invitationCodeGenerate {
    return Intl.message(
      'Einladungs-Code generieren',
      name: 'invitationCodeGenerate',
      desc: '',
      args: [],
    );
  }

  /// `Code wird generiert`
  String get invitationCodeGenerating {
    return Intl.message(
      'Code wird generiert',
      name: 'invitationCodeGenerating',
      desc: '',
      args: [],
    );
  }

  /// `Werde mit diesem Code zum Kaufhansel! Lade dir den Kaufhansel von https://zwohansel.de/kaufhansel/download runter.`
  String get invitationCodeShareMessage {
    return Intl.message(
      'Werde mit diesem Code zum Kaufhansel! Lade dir den Kaufhansel von https://zwohansel.de/kaufhansel/download runter.',
      name: 'invitationCodeShareMessage',
      desc: '',
      args: [],
    );
  }

  /// `Schicke anderen Hanseln diesen Code, damit sie sich beim Kaufhansel registrieren können.`
  String get invitationCodeRequestDistributionMessage {
    return Intl.message(
      'Schicke anderen Hanseln diesen Code, damit sie sich beim Kaufhansel registrieren können.',
      name: 'invitationCodeRequestDistributionMessage',
      desc: '',
      args: [],
    );
  }

  /// `Wir haben dir eine E-Mail an {emailAddress} geschickt... folge dem Aktivierungs-Link, dann kannst du dich anmelden.`
  String activationLinkSent(Object emailAddress) {
    return Intl.message(
      'Wir haben dir eine E-Mail an $emailAddress geschickt... folge dem Aktivierungs-Link, dann kannst du dich anmelden.',
      name: 'activationLinkSent',
      desc: '',
      args: [emailAddress],
    );
  }

  /// `Deine Registrierung ist abgeschlossen. Du kannst dich nun mit deiner Email-Adresse und deinem Passwort anmelden.`
  String get registrationSuccessful {
    return Intl.message(
      'Deine Registrierung ist abgeschlossen. Du kannst dich nun mit deiner Email-Adresse und deinem Passwort anmelden.',
      name: 'registrationSuccessful',
      desc: '',
      args: [],
    );
  }

  /// `Nutzername`
  String get userNameHint {
    return Intl.message(
      'Nutzername',
      name: 'userNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Gib einen Nutzernamen ein`
  String get userNameInvalid {
    return Intl.message(
      'Gib einen Nutzernamen ein',
      name: 'userNameInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Anmelden`
  String get buttonLogin {
    return Intl.message(
      'Anmelden',
      name: 'buttonLogin',
      desc: '',
      args: [],
    );
  }

  /// `Registrieren`
  String get buttonRegister {
    return Intl.message(
      'Registrieren',
      name: 'buttonRegister',
      desc: '',
      args: [],
    );
  }

  /// `Kennwort vergessen`
  String get buttonPasswordForgotten {
    return Intl.message(
      'Kennwort vergessen',
      name: 'buttonPasswordForgotten',
      desc: '',
      args: [],
    );
  }

  /// `Kennwort zurücksetzen`
  String get buttonPasswordReset {
    return Intl.message(
      'Kennwort zurücksetzen',
      name: 'buttonPasswordReset',
      desc: '',
      args: [],
    );
  }

  /// `Kenwort ändern`
  String get buttonPasswordChange {
    return Intl.message(
      'Kenwort ändern',
      name: 'buttonPasswordChange',
      desc: '',
      args: [],
    );
  }

  /// `Weiter`
  String get buttonNext {
    return Intl.message(
      'Weiter',
      name: 'buttonNext',
      desc: '',
      args: [],
    );
  }

  /// `Zurück zur Anmeldung`
  String get buttonBackToLogin {
    return Intl.message(
      'Zurück zur Anmeldung',
      name: 'buttonBackToLogin',
      desc: '',
      args: [],
    );
  }

  /// `Wiederherstellungs-Code eingeben`
  String get buttonPasswordResetCode {
    return Intl.message(
      'Wiederherstellungs-Code eingeben',
      name: 'buttonPasswordResetCode',
      desc: '',
      args: [],
    );
  }

  /// `Version {version} ist verfügbar`
  String newerVersionAvailable(Object version) {
    return Intl.message(
      'Version $version ist verfügbar',
      name: 'newerVersionAvailable',
      desc: '',
      args: [version],
    );
  }

  /// `Es hat sich viel getan. Damit dein Kaufhansel weiterhin funktioniert, musst du diese Aktualisierung installieren. Mehr Infos findest du, wenn du auf den Link zum Herunterladen klickst, oder im Play Store.`
  String get newerVersionAvailableObligatoryUpdate {
    return Intl.message(
      'Es hat sich viel getan. Damit dein Kaufhansel weiterhin funktioniert, musst du diese Aktualisierung installieren. Mehr Infos findest du, wenn du auf den Link zum Herunterladen klickst, oder im Play Store.',
      name: 'newerVersionAvailableObligatoryUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Meine Listen`
  String get shoppingListMyLists {
    return Intl.message(
      'Meine Listen',
      name: 'shoppingListMyLists',
      desc: '',
      args: [],
    );
  }

  /// `🌽🥦🧀`
  String get shoppingListEmpty {
    return Intl.message(
      '🌽🥦🧀',
      name: 'shoppingListEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Du hast noch keine Einkaufsliste.\nIm Menü oben rechts kannst du neue Listen anlegen.`
  String get shoppingListEmptyText {
    return Intl.message(
      'Du hast noch keine Einkaufsliste.\nIm Menü oben rechts kannst du neue Listen anlegen.',
      name: 'shoppingListEmptyText',
      desc: '',
      args: [],
    );
  }

  /// `Oh nein! Haben wir Deine Einkaufslisten etwa verlegt?`
  String get shoppingListError {
    return Intl.message(
      'Oh nein! Haben wir Deine Einkaufslisten etwa verlegt?',
      name: 'shoppingListError',
      desc: '',
      args: [],
    );
  }

  /// `Neue Liste...`
  String get shoppingListCreateNew {
    return Intl.message(
      'Neue Liste...',
      name: 'shoppingListCreateNew',
      desc: '',
      args: [],
    );
  }

  /// `Neue Liste anlegen`
  String get shoppingListCreateNewTitle {
    return Intl.message(
      'Neue Liste anlegen',
      name: 'shoppingListCreateNewTitle',
      desc: '',
      args: [],
    );
  }

  /// `Anlegen`
  String get shoppingListCreateNewConfirm {
    return Intl.message(
      'Anlegen',
      name: 'shoppingListCreateNewConfirm',
      desc: '',
      args: [],
    );
  }

  /// `Gib einen Namen ein`
  String get shoppingListCreateNewEnterNameHint {
    return Intl.message(
      'Gib einen Namen ein',
      name: 'shoppingListCreateNewEnterNameHint',
      desc: '',
      args: [],
    );
  }

  /// `Suchen oder hinzufügen`
  String get shoppingListNeededHint {
    return Intl.message(
      'Suchen oder hinzufügen',
      name: 'shoppingListNeededHint',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get shoppingListFilterTitle {
    return Intl.message(
      'Filter',
      name: 'shoppingListFilterTitle',
      desc: '',
      args: [],
    );
  }

  /// `Kein Filter`
  String get shoppingListFilterNone {
    return Intl.message(
      'Kein Filter',
      name: 'shoppingListFilterNone',
      desc: '',
      args: [],
    );
  }

  /// `Was muss ich noch kaufen`
  String get shoppingListFilterNeeded {
    return Intl.message(
      'Was muss ich noch kaufen',
      name: 'shoppingListFilterNeeded',
      desc: '',
      args: [],
    );
  }

  /// `Was ist schon im Einkaufswagen`
  String get shoppingListFilterAlreadyInCart {
    return Intl.message(
      'Was ist schon im Einkaufswagen',
      name: 'shoppingListFilterAlreadyInCart',
      desc: '',
      args: [],
    );
  }

  /// `Modus`
  String get shoppingListModeTitle {
    return Intl.message(
      'Modus',
      name: 'shoppingListModeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Guck-Modus`
  String get shoppingListModeDefault {
    return Intl.message(
      'Guck-Modus',
      name: 'shoppingListModeDefault',
      desc: '',
      args: [],
    );
  }

  /// `Einkaufs-Modus`
  String get shoppingListModeShopping {
    return Intl.message(
      'Einkaufs-Modus',
      name: 'shoppingListModeShopping',
      desc: '',
      args: [],
    );
  }

  /// `Editier-Modus`
  String get shoppingListModeEditing {
    return Intl.message(
      'Editier-Modus',
      name: 'shoppingListModeEditing',
      desc: '',
      args: [],
    );
  }

  /// `Wähle eine Kategorie`
  String get categoryChooseOne {
    return Intl.message(
      'Wähle eine Kategorie',
      name: 'categoryChooseOne',
      desc: '',
      args: [],
    );
  }

  /// `Keine`
  String get categoryNone {
    return Intl.message(
      'Keine',
      name: 'categoryNone',
      desc: '',
      args: [],
    );
  }

  /// `Neue Kategorie`
  String get categoryCreateNew {
    return Intl.message(
      'Neue Kategorie',
      name: 'categoryCreateNew',
      desc: '',
      args: [],
    );
  }

  /// `Hier bist du {roleName}:`
  String roleYoursRoleName(Object roleName) {
    return Intl.message(
      'Hier bist du $roleName:',
      name: 'roleYoursRoleName',
      desc: '',
      args: [roleName],
    );
  }

  /// `{username}, was willst du ändern?`
  String appSettingsTitle(Object username) {
    return Intl.message(
      '$username, was willst du ändern?',
      name: 'appSettingsTitle',
      desc: '',
      args: [username],
    );
  }

  /// `Deine Email-Adresse: {email}`
  String appSettingsYourEmail(Object email) {
    return Intl.message(
      'Deine Email-Adresse: $email',
      name: 'appSettingsYourEmail',
      desc: '',
      args: [email],
    );
  }

  /// `Ich will mich mal kurz abmelden`
  String get appSettingsLogOut {
    return Intl.message(
      'Ich will mich mal kurz abmelden',
      name: 'appSettingsLogOut',
      desc: '',
      args: [],
    );
  }

  /// `Ich will mein Benutzerkonto löschen...`
  String get appSettingsDeleteAccount {
    return Intl.message(
      'Ich will mein Benutzerkonto löschen...',
      name: 'appSettingsDeleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Schade {userName}, dass du dein Benutzerkonto löschen willst`
  String appSettingsDeleteAccountConfirmationTextTitle(Object userName) {
    return Intl.message(
      'Schade $userName, dass du dein Benutzerkonto löschen willst',
      name: 'appSettingsDeleteAccountConfirmationTextTitle',
      desc: '',
      args: [userName],
    );
  }

  /// `Dein Benutzerkonto wird endgültig und unwiederbringlich gelöscht.\n\nAlle Einkaufslisten, die du nicht geteilt hast, werden gelöscht. Alle Einkaufslisten, bei denen du der einzige Chefhansel bist, werden gelöscht und andere Hansel daraus entfernt. Du wirst aus allen Einkaufslisten entfernt, bei denen du nicht der einzige Chefhansel bist.\n\nWillst du das wirklich?`
  String get appSettingsDeleteAccountConfirmationText {
    return Intl.message(
      'Dein Benutzerkonto wird endgültig und unwiederbringlich gelöscht.\n\nAlle Einkaufslisten, die du nicht geteilt hast, werden gelöscht. Alle Einkaufslisten, bei denen du der einzige Chefhansel bist, werden gelöscht und andere Hansel daraus entfernt. Du wirst aus allen Einkaufslisten entfernt, bei denen du nicht der einzige Chefhansel bist.\n\nWillst du das wirklich?',
      name: 'appSettingsDeleteAccountConfirmationText',
      desc: '',
      args: [],
    );
  }

  /// `Ja, lösch mich!`
  String get appSettingsDeleteAccountYes {
    return Intl.message(
      'Ja, lösch mich!',
      name: 'appSettingsDeleteAccountYes',
      desc: '',
      args: [],
    );
  }

  /// `Nein, doch nicht`
  String get appSettingsDeleteAccountNo {
    return Intl.message(
      'Nein, doch nicht',
      name: 'appSettingsDeleteAccountNo',
      desc: '',
      args: [],
    );
  }

  /// `👋`
  String get appSettingsAccountDeletedEmoji {
    return Intl.message(
      '👋',
      name: 'appSettingsAccountDeletedEmoji',
      desc: '',
      args: [],
    );
  }

  /// `Wir haben alle deine Daten gelöscht. Tschüss!`
  String get appSettingsAccountDeletedText {
    return Intl.message(
      'Wir haben alle deine Daten gelöscht. Tschüss!',
      name: 'appSettingsAccountDeletedText',
      desc: '',
      args: [],
    );
  }

  /// `Über die App`
  String get appSettingsAboutTitle {
    return Intl.message(
      'Über die App',
      name: 'appSettingsAboutTitle',
      desc: '',
      args: [],
    );
  }

  /// `Alle Häkchen entfernen...`
  String get listSettingsUncheckAllItems {
    return Intl.message(
      'Alle Häkchen entfernen...',
      name: 'listSettingsUncheckAllItems',
      desc: '',
      args: [],
    );
  }

  /// `Möchtest du wirklich alle Häkchen entfernen?`
  String get listSettingsUncheckAllItemsConfirmationText {
    return Intl.message(
      'Möchtest du wirklich alle Häkchen entfernen?',
      name: 'listSettingsUncheckAllItemsConfirmationText',
      desc: '',
      args: [],
    );
  }

  /// `Alle Kategorien entfernen...`
  String get listSettingsClearAllCategories {
    return Intl.message(
      'Alle Kategorien entfernen...',
      name: 'listSettingsClearAllCategories',
      desc: '',
      args: [],
    );
  }

  /// `Möchtest du wirklich alle Kategorien entfernen?`
  String get listSettingsClearAllCategoriesConfirmationText {
    return Intl.message(
      'Möchtest du wirklich alle Kategorien entfernen?',
      name: 'listSettingsClearAllCategoriesConfirmationText',
      desc: '',
      args: [],
    );
  }

  /// `Liste leeren...`
  String get listSettingsClearList {
    return Intl.message(
      'Liste leeren...',
      name: 'listSettingsClearList',
      desc: '',
      args: [],
    );
  }

  /// `Möchtest du wirklich alle Elemente aus {shoppingListName} unwiederbringlich entfernen?`
  String listSettingsClearListConfirmationText(Object shoppingListName) {
    return Intl.message(
      'Möchtest du wirklich alle Elemente aus $shoppingListName unwiederbringlich entfernen?',
      name: 'listSettingsClearListConfirmationText',
      desc: '',
      args: [shoppingListName],
    );
  }

  /// `Alle Elemente in {shoppingListName} wurden entfernt.`
  String listSettingsListCleared(Object shoppingListName) {
    return Intl.message(
      'Alle Elemente in $shoppingListName wurden entfernt.',
      name: 'listSettingsListCleared',
      desc: '',
      args: [shoppingListName],
    );
  }

  /// `Dir`
  String get listSettingsSharingWithSelf {
    return Intl.message(
      'Dir',
      name: 'listSettingsSharingWithSelf',
      desc: '',
      args: [],
    );
  }

  /// `Du teilst die Liste mit`
  String get listSettingsSharingWith {
    return Intl.message(
      'Du teilst die Liste mit',
      name: 'listSettingsSharingWith',
      desc: '',
      args: [],
    );
  }

  /// `Mit einem weiteren Hansel teilen`
  String get listSettingsShareWithOther {
    return Intl.message(
      'Mit einem weiteren Hansel teilen',
      name: 'listSettingsShareWithOther',
      desc: '',
      args: [],
    );
  }

  /// `Neue Hansel werden als Schreibhansel hinzugefügt: sie können Dinge hinzufügen und entfernen; Dinge abhaken und Haken entfernen. Das kannst ändern, nachdem der neue Hansel in der Liste ist.`
  String get listSettingsShareWithOtherInfo {
    return Intl.message(
      'Neue Hansel werden als Schreibhansel hinzugefügt: sie können Dinge hinzufügen und entfernen; Dinge abhaken und Haken entfernen. Das kannst ändern, nachdem der neue Hansel in der Liste ist.',
      name: 'listSettingsShareWithOtherInfo',
      desc: '',
      args: [],
    );
  }

  /// `Email-Adresse vom Hansel`
  String get listSettingsAddUserToListEmailAddressHint {
    return Intl.message(
      'Email-Adresse vom Hansel',
      name: 'listSettingsAddUserToListEmailAddressHint',
      desc: '',
      args: [],
    );
  }

  /// `Was ist {userName} für ein Hansel?`
  String listSettingsChangeUserRole(Object userName) {
    return Intl.message(
      'Was ist $userName für ein Hansel?',
      name: 'listSettingsChangeUserRole',
      desc: '',
      args: [userName],
    );
  }

  /// `Wer ist {email} ???`
  String listSettingsSendListInvitationTitle(Object email) {
    return Intl.message(
      'Wer ist $email ???',
      name: 'listSettingsSendListInvitationTitle',
      desc: '',
      args: [email],
    );
  }

  /// `Hast du dich vertippt? Diese Emailadresse kennen wir noch nicht.\n\nOder möchtest du, dass wir an {email} eine Einladung schicken?\nWenn sich der Hansel registriert, hat er Zugriff auf diese Liste.`
  String listSettingsSendListInvitationText(Object email) {
    return Intl.message(
      'Hast du dich vertippt? Diese Emailadresse kennen wir noch nicht.\n\nOder möchtest du, dass wir an $email eine Einladung schicken?\nWenn sich der Hansel registriert, hat er Zugriff auf diese Liste.',
      name: 'listSettingsSendListInvitationText',
      desc: '',
      args: [email],
    );
  }

  /// `Ja, gerne!`
  String get listSettingsSendListInvitationYes {
    return Intl.message(
      'Ja, gerne!',
      name: 'listSettingsSendListInvitationYes',
      desc: '',
      args: [],
    );
  }

  /// `Jetzt nicht`
  String get listSettingsSendListInvitationNo {
    return Intl.message(
      'Jetzt nicht',
      name: 'listSettingsSendListInvitationNo',
      desc: '',
      args: [],
    );
  }

  /// `Wir haben eine Einladung an {email} geschickt.`
  String listSettingsListInvitationSent(Object email) {
    return Intl.message(
      'Wir haben eine Einladung an $email geschickt.',
      name: 'listSettingsListInvitationSent',
      desc: '',
      args: [email],
    );
  }

  /// `Möchtest du {userName} wirklich von {shoppingListName} entfernen?`
  String listSettingsRemoveUserFromList(Object userName, Object shoppingListName) {
    return Intl.message(
      'Möchtest du $userName wirklich von $shoppingListName entfernen?',
      name: 'listSettingsRemoveUserFromList',
      desc: '',
      args: [userName, shoppingListName],
    );
  }

  /// `Gefahrenzone`
  String get listSettingsDangerZoneTitle {
    return Intl.message(
      'Gefahrenzone',
      name: 'listSettingsDangerZoneTitle',
      desc: '',
      args: [],
    );
  }

  /// `Liste verlassen...`
  String get listSettingsLeaveList {
    return Intl.message(
      'Liste verlassen...',
      name: 'listSettingsLeaveList',
      desc: '',
      args: [],
    );
  }

  /// `Du bist der einzige {roleName} der Liste. Wenn du die Liste löschst, können auch die anderen Hansel mit denen du die Liste teilst nicht mehr darauf zugreifen.`
  String listSettingsLeaveExplanationOnlyAdmin(Object roleName) {
    return Intl.message(
      'Du bist der einzige $roleName der Liste. Wenn du die Liste löschst, können auch die anderen Hansel mit denen du die Liste teilst nicht mehr darauf zugreifen.',
      name: 'listSettingsLeaveExplanationOnlyAdmin',
      desc: '',
      args: [roleName],
    );
  }

  /// `Es gibt noch andere {roleName} in der Liste, daher kannst du sie nicht löschen. Wenn du die Liste verlässt, können die anderen Hansel weiterhin darauf zugreifen.`
  String listSettingsLeaveExplanationOtherAdminsPresent(Object roleName) {
    return Intl.message(
      'Es gibt noch andere $roleName in der Liste, daher kannst du sie nicht löschen. Wenn du die Liste verlässt, können die anderen Hansel weiterhin darauf zugreifen.',
      name: 'listSettingsLeaveExplanationOtherAdminsPresent',
      desc: '',
      args: [roleName],
    );
  }

  /// `Liste löschen...`
  String get listSettingsDeleteList {
    return Intl.message(
      'Liste löschen...',
      name: 'listSettingsDeleteList',
      desc: '',
      args: [],
    );
  }

  /// `Möchtest du {shoppingListName} wirklich für immer und unwiederbringlich löschen?`
  String listSettingsDeleteListConfirmationText(Object shoppingListName) {
    return Intl.message(
      'Möchtest du $shoppingListName wirklich für immer und unwiederbringlich löschen?',
      name: 'listSettingsDeleteListConfirmationText',
      desc: '',
      args: [shoppingListName],
    );
  }

  /// `Möchtest du {shoppingListName} wirklich verlassen?`
  String listSettingsLeaveListConfirmationText(Object shoppingListName) {
    return Intl.message(
      'Möchtest du $shoppingListName wirklich verlassen?',
      name: 'listSettingsLeaveListConfirmationText',
      desc: '',
      args: [shoppingListName],
    );
  }

  /// `Jetzt ist der Kaufhansel abgestürzt.`
  String get exceptionFatal {
    return Intl.message(
      'Jetzt ist der Kaufhansel abgestürzt.',
      name: 'exceptionFatal',
      desc: '',
      args: [],
    );
  }

  /// `Das hat nicht geklappt. Probier es später noch einmal.`
  String get exceptionGeneralTryAgainLater {
    return Intl.message(
      'Das hat nicht geklappt. Probier es später noch einmal.',
      name: 'exceptionGeneralTryAgainLater',
      desc: '',
      args: [],
    );
  }

  /// `Schläft der Server noch oder hast du kein Internet?`
  String get exceptionGeneralServerSleeping {
    return Intl.message(
      'Schläft der Server noch oder hast du kein Internet?',
      name: 'exceptionGeneralServerSleeping',
      desc: '',
      args: [],
    );
  }

  /// `Ist der Server zu faul oder hast du kein Internet?`
  String get exceptionGeneralServerTooLazy {
    return Intl.message(
      'Ist der Server zu faul oder hast du kein Internet?',
      name: 'exceptionGeneralServerTooLazy',
      desc: '',
      args: [],
    );
  }

  /// `Haben wir einen Fehler eingebaut oder hast du etwas falsch gemacht?\nComputer sagt: `
  String get exceptionGeneralComputerSays {
    return Intl.message(
      'Haben wir einen Fehler eingebaut oder hast du etwas falsch gemacht?\nComputer sagt: ',
      name: 'exceptionGeneralComputerSays',
      desc: '',
      args: [],
    );
  }

  /// `Das funktioniert im Moment noch nicht.`
  String get exceptionGeneralFeatureNotAvailable {
    return Intl.message(
      'Das funktioniert im Moment noch nicht.',
      name: 'exceptionGeneralFeatureNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Wollen wir nicht, dass du dich registrierst oder hast du etwas falsch gemacht?\nProbiere es einfach später nochmal.`
  String get exceptionRegistrationFailedTryAgainLater {
    return Intl.message(
      'Wollen wir nicht, dass du dich registrierst oder hast du etwas falsch gemacht?\nProbiere es einfach später nochmal.',
      name: 'exceptionRegistrationFailedTryAgainLater',
      desc: '',
      args: [],
    );
  }

  /// `Das hat nicht geklappt.\n\nStimmt die Email-Adresse?\nIst der Wiederherstellungs-Code richtig? \nHast du ein vernünftiges Passwort gewählt?\nDenk auch daran, dass der Wiederherstellungs-Code nur eine Stunde gültig ist.`
  String get exceptionResetPassword {
    return Intl.message(
      'Das hat nicht geklappt.\n\nStimmt die Email-Adresse?\nIst der Wiederherstellungs-Code richtig? \nHast du ein vernünftiges Passwort gewählt?\nDenk auch daran, dass der Wiederherstellungs-Code nur eine Stunde gültig ist.',
      name: 'exceptionResetPassword',
      desc: '',
      args: [],
    );
  }

  /// `Haben wir Deinen Account gelöscht oder hast Du Deine Zugangsdaten vergessen?`
  String get exceptionWrongCredentials {
    return Intl.message(
      'Haben wir Deinen Account gelöscht oder hast Du Deine Zugangsdaten vergessen?',
      name: 'exceptionWrongCredentials',
      desc: '',
      args: [],
    );
  }

  /// `Haben wir den Server heruntergefahren oder bist du nicht mit dem Internet verbunden?`
  String get exceptionNoInternet {
    return Intl.message(
      'Haben wir den Server heruntergefahren oder bist du nicht mit dem Internet verbunden?',
      name: 'exceptionNoInternet',
      desc: '',
      args: [],
    );
  }

  /// `Das hat nicht funktioniert. Hast du kein Internet?`
  String get exceptionNoInternetDidNotWork {
    return Intl.message(
      'Das hat nicht funktioniert. Hast du kein Internet?',
      name: 'exceptionNoInternetDidNotWork',
      desc: '',
      args: [],
    );
  }

  /// `Hast du kein Internet oder ist der Server nicht erreichbar?\nSo können wir jedenfalls nicht prüfen, ob dein Kaufhansel noch aktuell ist!`
  String get exceptionUpdateCheckFailed {
    return Intl.message(
      'Hast du kein Internet oder ist der Server nicht erreichbar?\nSo können wir jedenfalls nicht prüfen, ob dein Kaufhansel noch aktuell ist!',
      name: 'exceptionUpdateCheckFailed',
      desc: '',
      args: [],
    );
  }

  /// `Schläft der Server oder ist das Internet zu langsam?\nJedenfalls hat das alles viel zu lange gedauert.`
  String get exceptionConnectionTimeout {
    return Intl.message(
      'Schläft der Server oder ist das Internet zu langsam?\nJedenfalls hat das alles viel zu lange gedauert.',
      name: 'exceptionConnectionTimeout',
      desc: '',
      args: [],
    );
  }

  /// `Du verwendest vom Kaufhansel immer noch die Version {frontendVersion} ???\n\nDie ist doch schon viel zu alt. Hol dir die neue und viel bessere Version ${backendVersion} von`
  String exceptionIncompatibleVersion(Object frontendVersion, Object backendVersion) {
    return Intl.message(
      'Du verwendest vom Kaufhansel immer noch die Version $frontendVersion ???\n\nDie ist doch schon viel zu alt. Hol dir die neue und viel bessere Version \$$backendVersion von',
      name: 'exceptionIncompatibleVersion',
      desc: '',
      args: [frontendVersion, backendVersion],
    );
  }

  /// `Findet der Server {itemName} doof oder hast du kein Internet?`
  String exceptionRenameItemFailed(Object itemName) {
    return Intl.message(
      'Findet der Server $itemName doof oder hast du kein Internet?',
      name: 'exceptionRenameItemFailed',
      desc: '',
      args: [itemName],
    );
  }

  /// `{itemName} konnte nicht hinzugefügt werden... ist das schon Zensur?`
  String exceptionAddItemFailed(Object itemName) {
    return Intl.message(
      '$itemName konnte nicht hinzugefügt werden... ist das schon Zensur?',
      name: 'exceptionAddItemFailed',
      desc: '',
      args: [itemName],
    );
  }

  /// `{itemName} konnte nicht gelöscht werden...`
  String exceptionDeleteItemFailed(Object itemName) {
    return Intl.message(
      '$itemName konnte nicht gelöscht werden...',
      name: 'exceptionDeleteItemFailed',
      desc: '',
      args: [itemName],
    );
  }

  /// `{itemName} konnte nicht verschoben werden...`
  String exceptionMoveItemFailed(Object itemName) {
    return Intl.message(
      '$itemName konnte nicht verschoben werden...',
      name: 'exceptionMoveItemFailed',
      desc: '',
      args: [itemName],
    );
  }

  /// `Einmal Chefhansel, immer Chefhansel. Daran kannst du nichts mehr ändern.`
  String get exceptionCantChangeAdminRole {
    return Intl.message(
      'Einmal Chefhansel, immer Chefhansel. Daran kannst du nichts mehr ändern.',
      name: 'exceptionCantChangeAdminRole',
      desc: '',
      args: [],
    );
  }

  /// `Hast du dich vertippt oder können wir den Hansel nicht finden?`
  String get exceptionCantFindOtherUser {
    return Intl.message(
      'Hast du dich vertippt oder können wir den Hansel nicht finden?',
      name: 'exceptionCantFindOtherUser',
      desc: '',
      args: [],
    );
  }

  /// `Das Verschicken der Einladungs-Email hat leider nicht geklappt. Ruf den Hansel doch einfach mal an.`
  String get exceptionSendListInvitationFailed {
    return Intl.message(
      'Das Verschicken der Einladungs-Email hat leider nicht geklappt. Ruf den Hansel doch einfach mal an.',
      name: 'exceptionSendListInvitationFailed',
      desc: '',
      args: [],
    );
  }

  /// `Kann die Liste nicht gelöscht werden oder hast du kein Internet?`
  String get exceptionDeleteListFailed {
    return Intl.message(
      'Kann die Liste nicht gelöscht werden oder hast du kein Internet?',
      name: 'exceptionDeleteListFailed',
      desc: '',
      args: [],
    );
  }

  /// `Die Abmeldung hat nicht funktioniert...`
  String get exceptionLogOutFailed {
    return Intl.message(
      'Die Abmeldung hat nicht funktioniert...',
      name: 'exceptionLogOutFailed',
      desc: '',
      args: [],
    );
  }

  /// `Ist der Speicher voll oder hast du einen Fehler beim Anlegen der Liste gemacht?`
  String get exceptionListCreationFailed {
    return Intl.message(
      'Ist der Speicher voll oder hast du einen Fehler beim Anlegen der Liste gemacht?',
      name: 'exceptionListCreationFailed',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'de'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}