import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Kaufhansel'**
  String get appTitle;

  /// No description provided for @downloadLink.
  ///
  /// In de, this message translates to:
  /// **'https://zwohansel.de/kaufhansel/download'**
  String get downloadLink;

  /// No description provided for @downloadLinkPromotion.
  ///
  /// In de, this message translates to:
  /// **'Die Downloads gibts hier: '**
  String get downloadLinkPromotion;

  /// No description provided for @zwoHanselPageLink.
  ///
  /// In de, this message translates to:
  /// **'https://zwohansel.de'**
  String get zwoHanselPageLink;

  /// No description provided for @zwoHanselPageLinkText.
  ///
  /// In de, this message translates to:
  /// **'zwohansel.de'**
  String get zwoHanselPageLinkText;

  /// No description provided for @zwoHanselPageLinkInfo.
  ///
  /// In de, this message translates to:
  /// **'Mehr über die Entwickler auf zwohansel.de'**
  String get zwoHanselPageLinkInfo;

  /// No description provided for @zwoHanselKaufhanselGithubLink.
  ///
  /// In de, this message translates to:
  /// **'https://github.com/zwohansel/kaufhansel'**
  String get zwoHanselKaufhanselGithubLink;

  /// No description provided for @zwoHanselKaufhanselGithubLinkInfo.
  ///
  /// In de, this message translates to:
  /// **'Der Kaufhansel-Quellcode auf GitHub'**
  String get zwoHanselKaufhanselGithubLinkInfo;

  /// No description provided for @zwoHanselKaufhanselLandingPageLink.
  ///
  /// In de, this message translates to:
  /// **'https://zwohansel.de/kaufhansel'**
  String get zwoHanselKaufhanselLandingPageLink;

  /// No description provided for @zwoHanselKaufhanselLandingPageLinkInfo.
  ///
  /// In de, this message translates to:
  /// **'Der Kaufhansel im Internet'**
  String get zwoHanselKaufhanselLandingPageLinkInfo;

  /// No description provided for @manShrugging.
  ///
  /// In de, this message translates to:
  /// **'🤷‍♂️'**
  String get manShrugging;

  /// No description provided for @thatsJustHowItIs.
  ///
  /// In de, this message translates to:
  /// **'Ist dann halt schon so...'**
  String get thatsJustHowItIs;

  /// No description provided for @important.
  ///
  /// In de, this message translates to:
  /// **'Achtung!'**
  String get important;

  /// No description provided for @ok.
  ///
  /// In de, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In de, this message translates to:
  /// **'Ja'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In de, this message translates to:
  /// **'Nein'**
  String get no;

  /// No description provided for @cancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In de, this message translates to:
  /// **'Schließen'**
  String get close;

  /// No description provided for @dontCare.
  ///
  /// In de, this message translates to:
  /// **'Egal'**
  String get dontCare;

  /// No description provided for @okImmediately.
  ///
  /// In de, this message translates to:
  /// **'Mach ich sofort'**
  String get okImmediately;

  /// No description provided for @tryAgain.
  ///
  /// In de, this message translates to:
  /// **'Nochmal versuchen'**
  String get tryAgain;

  /// No description provided for @refresh.
  ///
  /// In de, this message translates to:
  /// **'Auffrischen'**
  String get refresh;

  /// No description provided for @general.
  ///
  /// In de, this message translates to:
  /// **'Allgemein'**
  String get general;

  /// No description provided for @appSettings.
  ///
  /// In de, this message translates to:
  /// **'App-Einstellungen'**
  String get appSettings;

  /// No description provided for @listSettings.
  ///
  /// In de, this message translates to:
  /// **'Mehr Listeneinstellungen...'**
  String get listSettings;

  /// No description provided for @willLoginAgain.
  ///
  /// In de, this message translates to:
  /// **'Ok... Ich melde mich gerne neu an.'**
  String get willLoginAgain;

  /// No description provided for @privacyPolicy.
  ///
  /// In de, this message translates to:
  /// **'Datenschutzerklärung'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyLink.
  ///
  /// In de, this message translates to:
  /// **'https://zwohansel.de/kaufhansel/privacy_de.html'**
  String get privacyPolicyLink;

  /// No description provided for @disclaimer.
  ///
  /// In de, this message translates to:
  /// **'Haftungsausschluss'**
  String get disclaimer;

  /// No description provided for @disclaimerLink.
  ///
  /// In de, this message translates to:
  /// **'https://zwohansel.de/kaufhansel/disclaimer.html'**
  String get disclaimerLink;

  /// No description provided for @registrationConsentFirstPart.
  ///
  /// In de, this message translates to:
  /// **'Ich habe die '**
  String get registrationConsentFirstPart;

  /// No description provided for @registrationConsentMiddlePart.
  ///
  /// In de, this message translates to:
  /// **' zur Kenntnis genommen und stimme dem '**
  String get registrationConsentMiddlePart;

  /// No description provided for @registrationConsentLastPart.
  ///
  /// In de, this message translates to:
  /// **' zu.'**
  String get registrationConsentLastPart;

  /// No description provided for @roleAdminName.
  ///
  /// In de, this message translates to:
  /// **'Chefhansel'**
  String get roleAdminName;

  /// No description provided for @roleAdminDescription.
  ///
  /// In de, this message translates to:
  /// **'Darf alles: Dinge hinzufügen und entfernen, Haken setzen und entfernen. Darf neue Hansel zur Liste hinzufügen.\nEinmal Chefhansel, immer Chefhansel: diese Rolle kannst du nicht mehr ändern'**
  String get roleAdminDescription;

  /// No description provided for @roleReadWriteName.
  ///
  /// In de, this message translates to:
  /// **'Schreibhansel'**
  String get roleReadWriteName;

  /// No description provided for @roleReadWriteDescription.
  ///
  /// In de, this message translates to:
  /// **'Darf Dinge hinzufügen und entfernen, darf Haken setzen und entfernen'**
  String get roleReadWriteDescription;

  /// No description provided for @roleReadWriteWhatIsIt.
  ///
  /// In de, this message translates to:
  /// **'Was ist ein Schreibhansel?'**
  String get roleReadWriteWhatIsIt;

  /// No description provided for @roleCheckOnlyName.
  ///
  /// In de, this message translates to:
  /// **'Kaufhansel'**
  String get roleCheckOnlyName;

  /// No description provided for @roleCheckOnlyDescription.
  ///
  /// In de, this message translates to:
  /// **'Darf Haken setzen und entfernen'**
  String get roleCheckOnlyDescription;

  /// No description provided for @roleReadOnlyName.
  ///
  /// In de, this message translates to:
  /// **'Guckhansel'**
  String get roleReadOnlyName;

  /// No description provided for @roleReadOnlyDescription.
  ///
  /// In de, this message translates to:
  /// **'Darf die Liste anschauen, aber nix ändern'**
  String get roleReadOnlyDescription;

  /// No description provided for @rolesWhich.
  ///
  /// In de, this message translates to:
  /// **'Welche Rollen gibt es?'**
  String get rolesWhich;

  /// No description provided for @emailHint.
  ///
  /// In de, this message translates to:
  /// **'Email-Adresse'**
  String get emailHint;

  /// No description provided for @emailInvalid.
  ///
  /// In de, this message translates to:
  /// **'Gib eine gültige Email-Adresse ein'**
  String get emailInvalid;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In de, this message translates to:
  /// **'Nimm eine andere'**
  String get emailAlreadyInUse;

  /// No description provided for @passwordHint.
  ///
  /// In de, this message translates to:
  /// **'Kennwort'**
  String get passwordHint;

  /// No description provided for @passwordEmpty.
  ///
  /// In de, this message translates to:
  /// **'Gib dein Kennwort richtig ein'**
  String get passwordEmpty;

  /// No description provided for @passwordToShort.
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen'**
  String get passwordToShort;

  /// No description provided for @passwordInvalid.
  ///
  /// In de, this message translates to:
  /// **'Denk dir was besseres aus'**
  String get passwordInvalid;

  /// No description provided for @passwordConfirmationHint.
  ///
  /// In de, this message translates to:
  /// **'Kennwort bestätigen'**
  String get passwordConfirmationHint;

  /// No description provided for @passwordConfirmationInvalid.
  ///
  /// In de, this message translates to:
  /// **'Gib dein Kennwort nochmal ein'**
  String get passwordConfirmationInvalid;

  /// No description provided for @passwordResetInfo.
  ///
  /// In de, this message translates to:
  /// **'Gib hier den Wiederherstellungs-Code ein den wir an deine Email Adresse geschickt haben, um dein Kennwort zurückzusetzen.'**
  String get passwordResetInfo;

  /// No description provided for @passwordResetCodeHint.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellungs-Code'**
  String get passwordResetCodeHint;

  /// No description provided for @passwordResetCodeInvalid.
  ///
  /// In de, this message translates to:
  /// **'Gib den Wiederherstellungs-Code ein'**
  String get passwordResetCodeInvalid;

  /// No description provided for @passwordNewHint.
  ///
  /// In de, this message translates to:
  /// **'Neues Kennwort'**
  String get passwordNewHint;

  /// No description provided for @passwordNewConfirmationHint.
  ///
  /// In de, this message translates to:
  /// **'Neues Kennwort bestätigen'**
  String get passwordNewConfirmationHint;

  /// No description provided for @passwordNewConfirmationInvalid.
  ///
  /// In de, this message translates to:
  /// **'Gib dein neues Kennwort nochmal ein'**
  String get passwordNewConfirmationInvalid;

  /// No description provided for @passwordChangeSuccess.
  ///
  /// In de, this message translates to:
  /// **'Du hast dein Kennwort erfolgreich geändert.'**
  String get passwordChangeSuccess;

  /// No description provided for @invitationCodeHint.
  ///
  /// In de, this message translates to:
  /// **'Einladungs-Code'**
  String get invitationCodeHint;

  /// No description provided for @invitationCodeEmpty.
  ///
  /// In de, this message translates to:
  /// **'Gib deinen Einladungs-Code ein'**
  String get invitationCodeEmpty;

  /// No description provided for @invitationCodeInvalid.
  ///
  /// In de, this message translates to:
  /// **'Der Code stimmt nicht'**
  String get invitationCodeInvalid;

  /// No description provided for @invitationCodeGenerate.
  ///
  /// In de, this message translates to:
  /// **'Einladungs-Code generieren'**
  String get invitationCodeGenerate;

  /// No description provided for @invitationCodeGenerating.
  ///
  /// In de, this message translates to:
  /// **'Code wird generiert'**
  String get invitationCodeGenerating;

  /// No description provided for @invitationCodeShareMessage.
  ///
  /// In de, this message translates to:
  /// **'Werde mit diesem Code zum Kaufhansel! Lade dir den Kaufhansel von https://zwohansel.de/kaufhansel/download runter.'**
  String get invitationCodeShareMessage;

  /// No description provided for @invitationCodeRequestDistributionMessage.
  ///
  /// In de, this message translates to:
  /// **'Schicke anderen Hanseln diesen Code, damit sie sich beim Kaufhansel registrieren können.'**
  String get invitationCodeRequestDistributionMessage;

  /// No description provided for @activationLinkSent.
  ///
  /// In de, this message translates to:
  /// **'Wir haben dir eine E-Mail an {emailAddress} geschickt... folge dem Aktivierungs-Link, dann kannst du dich anmelden.'**
  String activationLinkSent(Object emailAddress);

  /// No description provided for @registrationSuccessful.
  ///
  /// In de, this message translates to:
  /// **'Deine Registrierung ist abgeschlossen. Du kannst dich nun mit deiner Email-Adresse und deinem Passwort anmelden.'**
  String get registrationSuccessful;

  /// No description provided for @userNameHint.
  ///
  /// In de, this message translates to:
  /// **'Nutzername'**
  String get userNameHint;

  /// No description provided for @userNameInvalid.
  ///
  /// In de, this message translates to:
  /// **'Gib einen Nutzernamen ein'**
  String get userNameInvalid;

  /// No description provided for @buttonLogin.
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get buttonLogin;

  /// No description provided for @buttonRegister.
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get buttonRegister;

  /// No description provided for @buttonPasswordForgotten.
  ///
  /// In de, this message translates to:
  /// **'Kennwort vergessen'**
  String get buttonPasswordForgotten;

  /// No description provided for @buttonPasswordReset.
  ///
  /// In de, this message translates to:
  /// **'Kennwort zurücksetzen'**
  String get buttonPasswordReset;

  /// No description provided for @buttonPasswordChange.
  ///
  /// In de, this message translates to:
  /// **'Kenwort ändern'**
  String get buttonPasswordChange;

  /// No description provided for @buttonNext.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get buttonNext;

  /// No description provided for @buttonBackToLogin.
  ///
  /// In de, this message translates to:
  /// **'Zurück zur Anmeldung'**
  String get buttonBackToLogin;

  /// No description provided for @buttonPasswordResetCode.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellungs-Code eingeben'**
  String get buttonPasswordResetCode;

  /// No description provided for @newerVersionAvailable.
  ///
  /// In de, this message translates to:
  /// **'Version {version} ist verfügbar'**
  String newerVersionAvailable(Object version);

  /// No description provided for @newerVersionAvailableObligatoryUpdate.
  ///
  /// In de, this message translates to:
  /// **'Es hat sich viel getan. Damit dein Kaufhansel weiterhin funktioniert, musst du diese Aktualisierung installieren. Mehr Infos findest du, wenn du auf den Link zum Herunterladen klickst, oder im Play Store.'**
  String get newerVersionAvailableObligatoryUpdate;

  /// No description provided for @shoppingListMyLists.
  ///
  /// In de, this message translates to:
  /// **'Meine Listen'**
  String get shoppingListMyLists;

  /// No description provided for @shoppingListEmpty.
  ///
  /// In de, this message translates to:
  /// **'🌽🥦🧀'**
  String get shoppingListEmpty;

  /// No description provided for @shoppingListEmptyText.
  ///
  /// In de, this message translates to:
  /// **'Du hast noch keine Einkaufsliste.\nIm Menü oben rechts kannst du neue Listen anlegen.'**
  String get shoppingListEmptyText;

  /// No description provided for @shoppingListError.
  ///
  /// In de, this message translates to:
  /// **'Oh nein! Haben wir Deine Einkaufslisten etwa verlegt?'**
  String get shoppingListError;

  /// No description provided for @shoppingListNotPresent.
  ///
  /// In de, this message translates to:
  /// **'Jedenfalls können wir die Liste {listName} nicht finden.'**
  String shoppingListNotPresent(Object listName);

  /// No description provided for @shoppingListOpenOther.
  ///
  /// In de, this message translates to:
  /// **'Andere Liste öffnen'**
  String get shoppingListOpenOther;

  /// No description provided for @shoppingListCreateNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Liste...'**
  String get shoppingListCreateNew;

  /// No description provided for @shoppingListCreateNewTitle.
  ///
  /// In de, this message translates to:
  /// **'Neue Liste anlegen'**
  String get shoppingListCreateNewTitle;

  /// No description provided for @shoppingListCreateNewConfirm.
  ///
  /// In de, this message translates to:
  /// **'Anlegen'**
  String get shoppingListCreateNewConfirm;

  /// No description provided for @shoppingListCreateNewEnterNameHint.
  ///
  /// In de, this message translates to:
  /// **'Gib einen Namen ein'**
  String get shoppingListCreateNewEnterNameHint;

  /// No description provided for @shoppingListFilterTitle.
  ///
  /// In de, this message translates to:
  /// **'Filter'**
  String get shoppingListFilterTitle;

  /// No description provided for @shoppingListFilterNone.
  ///
  /// In de, this message translates to:
  /// **'Kein Filter'**
  String get shoppingListFilterNone;

  /// No description provided for @shoppingListFilterNeeded.
  ///
  /// In de, this message translates to:
  /// **'Was muss ich noch kaufen'**
  String get shoppingListFilterNeeded;

  /// No description provided for @shoppingListFilterAlreadyInCart.
  ///
  /// In de, this message translates to:
  /// **'Was ist schon im Einkaufswagen'**
  String get shoppingListFilterAlreadyInCart;

  /// No description provided for @shoppingListModeTitle.
  ///
  /// In de, this message translates to:
  /// **'Modus'**
  String get shoppingListModeTitle;

  /// No description provided for @shoppingListModeDefault.
  ///
  /// In de, this message translates to:
  /// **'Guck-Modus'**
  String get shoppingListModeDefault;

  /// No description provided for @shoppingListModeShopping.
  ///
  /// In de, this message translates to:
  /// **'Einkaufs-Modus'**
  String get shoppingListModeShopping;

  /// No description provided for @shoppingListModeEditing.
  ///
  /// In de, this message translates to:
  /// **'Editier-Modus'**
  String get shoppingListModeEditing;

  /// No description provided for @createOrSearchHint.
  ///
  /// In de, this message translates to:
  /// **'Suchen oder hinzufügen'**
  String get createOrSearchHint;

  /// No description provided for @itemRename.
  ///
  /// In de, this message translates to:
  /// **'Umbenennen'**
  String get itemRename;

  /// No description provided for @itemRemove.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get itemRemove;

  /// No description provided for @categoryChooseOne.
  ///
  /// In de, this message translates to:
  /// **'Wähle eine Kategorie'**
  String get categoryChooseOne;

  /// No description provided for @categoryNone.
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get categoryNone;

  /// No description provided for @categoryCreateNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Kategorie'**
  String get categoryCreateNew;

  /// No description provided for @roleYoursRoleName.
  ///
  /// In de, this message translates to:
  /// **'Hier bist du {roleName}:'**
  String roleYoursRoleName(Object roleName);

  /// No description provided for @appSettingsTitle.
  ///
  /// In de, this message translates to:
  /// **'{username}, was willst du ändern?'**
  String appSettingsTitle(Object username);

  /// No description provided for @appSettingsYourEmail.
  ///
  /// In de, this message translates to:
  /// **'Deine Email-Adresse: {email}'**
  String appSettingsYourEmail(Object email);

  /// No description provided for @appSettingsLogOut.
  ///
  /// In de, this message translates to:
  /// **'Ich will mich mal kurz abmelden'**
  String get appSettingsLogOut;

  /// No description provided for @appSettingsDeleteAccount.
  ///
  /// In de, this message translates to:
  /// **'Ich will mein Benutzerkonto löschen...'**
  String get appSettingsDeleteAccount;

  /// No description provided for @appSettingsDeleteAccountConfirmationTextTitle.
  ///
  /// In de, this message translates to:
  /// **'Schade {userName}, dass du dein Benutzerkonto löschen willst'**
  String appSettingsDeleteAccountConfirmationTextTitle(Object userName);

  /// No description provided for @appSettingsDeleteAccountConfirmationText.
  ///
  /// In de, this message translates to:
  /// **'Dein Benutzerkonto wird endgültig und unwiederbringlich gelöscht.\n\nAlle Einkaufslisten, die du nicht geteilt hast, werden gelöscht. Alle Einkaufslisten, bei denen du der einzige Chefhansel bist, werden gelöscht und andere Hansel daraus entfernt. Du wirst aus allen Einkaufslisten entfernt, bei denen du nicht der einzige Chefhansel bist.\n\nWillst du das wirklich?'**
  String get appSettingsDeleteAccountConfirmationText;

  /// No description provided for @appSettingsDeleteAccountYes.
  ///
  /// In de, this message translates to:
  /// **'Ja, lösch mich!'**
  String get appSettingsDeleteAccountYes;

  /// No description provided for @appSettingsDeleteAccountNo.
  ///
  /// In de, this message translates to:
  /// **'Nein, doch nicht'**
  String get appSettingsDeleteAccountNo;

  /// No description provided for @appSettingsAccountDeletedEmoji.
  ///
  /// In de, this message translates to:
  /// **'👋'**
  String get appSettingsAccountDeletedEmoji;

  /// No description provided for @appSettingsAccountDeletedText.
  ///
  /// In de, this message translates to:
  /// **'Wir haben alle deine Daten gelöscht. Tschüss!'**
  String get appSettingsAccountDeletedText;

  /// No description provided for @appSettingsAboutTitle.
  ///
  /// In de, this message translates to:
  /// **'Über die App'**
  String get appSettingsAboutTitle;

  /// No description provided for @listSettingsUncheckItems.
  ///
  /// In de, this message translates to:
  /// **'Häkchen entfernen...'**
  String get listSettingsUncheckItems;

  /// No description provided for @listSettingsUncheckItemsTitle.
  ///
  /// In de, this message translates to:
  /// **'Welche Häkchen möchtest du entfernen?'**
  String get listSettingsUncheckItemsTitle;

  /// No description provided for @manageCategories.
  ///
  /// In de, this message translates to:
  /// **'Kategorien bearbeiten...'**
  String get manageCategories;

  /// No description provided for @manageCategoriesTitle.
  ///
  /// In de, this message translates to:
  /// **'Kategorien bearbeiten'**
  String get manageCategoriesTitle;

  /// No description provided for @manageCategoriesCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie:'**
  String get manageCategoriesCategory;

  /// No description provided for @manageCategoriesAction.
  ///
  /// In de, this message translates to:
  /// **'Aktion:'**
  String get manageCategoriesAction;

  /// No description provided for @manageCategoriesWhich.
  ///
  /// In de, this message translates to:
  /// **'Welche denn?'**
  String get manageCategoriesWhich;

  /// No description provided for @manageCategoriesUncheckAll.
  ///
  /// In de, this message translates to:
  /// **'Alle Häkchen entfernen'**
  String get manageCategoriesUncheckAll;

  /// No description provided for @manageCategoriesUncheckCategory.
  ///
  /// In de, this message translates to:
  /// **'Häkchen in der Kategorie {category} entfernen'**
  String manageCategoriesUncheckCategory(Object category);

  /// No description provided for @manageCategoriesRemoveChecked.
  ///
  /// In de, this message translates to:
  /// **'Alle abgehakten Dinge löschen'**
  String get manageCategoriesRemoveChecked;

  /// No description provided for @manageCategoriesRemoveCheckedFromCategory.
  ///
  /// In de, this message translates to:
  /// **'Alle abgehakten Dinge aus der Kategorie {category} löschen'**
  String manageCategoriesRemoveCheckedFromCategory(Object category);

  /// No description provided for @manageCategoriesRemoveCategories.
  ///
  /// In de, this message translates to:
  /// **'Alle Kategorien entfernen'**
  String get manageCategoriesRemoveCategories;

  /// No description provided for @manageCategoriesRemoveCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie {category} entfernen'**
  String manageCategoriesRemoveCategory(Object category);

  /// No description provided for @manageCategoriesRenameCategory.
  ///
  /// In de, this message translates to:
  /// **'Kategorie {category} umbenennen...'**
  String manageCategoriesRenameCategory(Object category);

  /// No description provided for @manageCategoriesRenameCategoryDialogTitle.
  ///
  /// In de, this message translates to:
  /// **'Kategorie umbenennen'**
  String get manageCategoriesRenameCategoryDialogTitle;

  /// No description provided for @listSettingsClearList.
  ///
  /// In de, this message translates to:
  /// **'Liste leeren...'**
  String get listSettingsClearList;

  /// No description provided for @listSettingsClearListConfirmationText.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du wirklich alle Elemente aus {shoppingListName} unwiederbringlich entfernen?'**
  String listSettingsClearListConfirmationText(Object shoppingListName);

  /// No description provided for @listSettingsListCleared.
  ///
  /// In de, this message translates to:
  /// **'Alle Elemente in {shoppingListName} wurden entfernt.'**
  String listSettingsListCleared(Object shoppingListName);

  /// No description provided for @listSettingsSharingWithSelf.
  ///
  /// In de, this message translates to:
  /// **'Dir'**
  String get listSettingsSharingWithSelf;

  /// No description provided for @listSettingsSharingWith.
  ///
  /// In de, this message translates to:
  /// **'Du teilst die Liste mit'**
  String get listSettingsSharingWith;

  /// No description provided for @listSettingsShareWithOther.
  ///
  /// In de, this message translates to:
  /// **'Mit einem weiteren Hansel teilen'**
  String get listSettingsShareWithOther;

  /// No description provided for @listSettingsShareWithOtherInfo.
  ///
  /// In de, this message translates to:
  /// **'Neue Hansel werden als Schreibhansel hinzugefügt: sie können Dinge hinzufügen und entfernen; Dinge abhaken und Haken entfernen. Das kannst ändern, nachdem der neue Hansel in der Liste ist.'**
  String get listSettingsShareWithOtherInfo;

  /// No description provided for @listSettingsAddUserToListEmailAddressHint.
  ///
  /// In de, this message translates to:
  /// **'Email-Adresse vom Hansel'**
  String get listSettingsAddUserToListEmailAddressHint;

  /// No description provided for @listSettingsChangeUserRole.
  ///
  /// In de, this message translates to:
  /// **'Was ist {userName} für ein Hansel?'**
  String listSettingsChangeUserRole(Object userName);

  /// No description provided for @listSettingsSendListInvitationTitle.
  ///
  /// In de, this message translates to:
  /// **'Wer ist {email} ???'**
  String listSettingsSendListInvitationTitle(Object email);

  /// No description provided for @listSettingsSendListInvitationText.
  ///
  /// In de, this message translates to:
  /// **'Hast du dich vertippt? Diese Emailadresse kennen wir noch nicht.\n\nOder möchtest du, dass wir an {email} eine Einladung schicken?\nWenn sich der Hansel registriert, hat er Zugriff auf diese Liste.'**
  String listSettingsSendListInvitationText(Object email);

  /// No description provided for @listSettingsSendListInvitationYes.
  ///
  /// In de, this message translates to:
  /// **'Ja, gerne!'**
  String get listSettingsSendListInvitationYes;

  /// No description provided for @listSettingsSendListInvitationNo.
  ///
  /// In de, this message translates to:
  /// **'Jetzt nicht'**
  String get listSettingsSendListInvitationNo;

  /// No description provided for @listSettingsListInvitationSent.
  ///
  /// In de, this message translates to:
  /// **'Wir haben eine Einladung an {email} geschickt.'**
  String listSettingsListInvitationSent(Object email);

  /// No description provided for @listSettingsRemoveUserFromList.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du {userName} wirklich von {shoppingListName} entfernen?'**
  String listSettingsRemoveUserFromList(
      Object userName, Object shoppingListName);

  /// No description provided for @listSettingsDangerZoneTitle.
  ///
  /// In de, this message translates to:
  /// **'Gefahrenzone'**
  String get listSettingsDangerZoneTitle;

  /// No description provided for @listSettingsLeaveList.
  ///
  /// In de, this message translates to:
  /// **'Liste verlassen...'**
  String get listSettingsLeaveList;

  /// No description provided for @listSettingsLeaveExplanationOnlyAdmin.
  ///
  /// In de, this message translates to:
  /// **'Du bist der einzige {roleName} der Liste. Wenn du die Liste löschst, können auch die anderen Hansel mit denen du die Liste teilst nicht mehr darauf zugreifen.'**
  String listSettingsLeaveExplanationOnlyAdmin(Object roleName);

  /// No description provided for @listSettingsLeaveExplanationOtherAdminsPresent.
  ///
  /// In de, this message translates to:
  /// **'Es gibt noch andere {roleName} in der Liste, daher kannst du sie nicht löschen. Wenn du die Liste verlässt, können die anderen Hansel weiterhin darauf zugreifen.'**
  String listSettingsLeaveExplanationOtherAdminsPresent(Object roleName);

  /// No description provided for @listSettingsDeleteList.
  ///
  /// In de, this message translates to:
  /// **'Liste löschen...'**
  String get listSettingsDeleteList;

  /// No description provided for @listSettingsDeleteListConfirmationText.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du {shoppingListName} wirklich für immer und unwiederbringlich löschen?'**
  String listSettingsDeleteListConfirmationText(Object shoppingListName);

  /// No description provided for @listSettingsLeaveListConfirmationText.
  ///
  /// In de, this message translates to:
  /// **'Möchtest du {shoppingListName} wirklich verlassen?'**
  String listSettingsLeaveListConfirmationText(Object shoppingListName);

  /// No description provided for @exceptionFatal.
  ///
  /// In de, this message translates to:
  /// **'Jetzt ist der Kaufhansel abgestürzt.'**
  String get exceptionFatal;

  /// No description provided for @exceptionGeneralTryAgainLater.
  ///
  /// In de, this message translates to:
  /// **'Das hat nicht geklappt. Probier es später noch einmal.'**
  String get exceptionGeneralTryAgainLater;

  /// No description provided for @exceptionGeneralServerSleeping.
  ///
  /// In de, this message translates to:
  /// **'Schläft der Server noch oder hast du kein Internet?'**
  String get exceptionGeneralServerSleeping;

  /// No description provided for @exceptionGeneralServerTooLazy.
  ///
  /// In de, this message translates to:
  /// **'Ist der Server zu faul oder hast du kein Internet?'**
  String get exceptionGeneralServerTooLazy;

  /// No description provided for @exceptionGeneralComputerSays.
  ///
  /// In de, this message translates to:
  /// **'Haben wir einen Fehler eingebaut oder hast du etwas falsch gemacht?\nComputer sagt: '**
  String get exceptionGeneralComputerSays;

  /// No description provided for @exceptionGeneralFeatureNotAvailable.
  ///
  /// In de, this message translates to:
  /// **'Das funktioniert im Moment noch nicht.'**
  String get exceptionGeneralFeatureNotAvailable;

  /// No description provided for @exceptionRegistrationFailedTryAgainLater.
  ///
  /// In de, this message translates to:
  /// **'Wollen wir nicht, dass du dich registrierst oder hast du etwas falsch gemacht?\nProbiere es einfach später nochmal.'**
  String get exceptionRegistrationFailedTryAgainLater;

  /// No description provided for @exceptionResetPassword.
  ///
  /// In de, this message translates to:
  /// **'Das hat nicht geklappt.\n\nStimmt die Email-Adresse?\nIst der Wiederherstellungs-Code richtig? \nHast du ein vernünftiges Passwort gewählt?\nDenk auch daran, dass der Wiederherstellungs-Code nur eine Stunde gültig ist.'**
  String get exceptionResetPassword;

  /// No description provided for @exceptionWrongCredentials.
  ///
  /// In de, this message translates to:
  /// **'Haben wir Deinen Account gelöscht oder hast Du Deine Zugangsdaten vergessen?'**
  String get exceptionWrongCredentials;

  /// No description provided for @exceptionNoInternet.
  ///
  /// In de, this message translates to:
  /// **'Haben wir den Server heruntergefahren oder bist du nicht mit dem Internet verbunden?'**
  String get exceptionNoInternet;

  /// No description provided for @exceptionNoInternetDidNotWork.
  ///
  /// In de, this message translates to:
  /// **'Das hat nicht funktioniert. Hast du kein Internet?'**
  String get exceptionNoInternetDidNotWork;

  /// No description provided for @exceptionUpdateCheckFailed.
  ///
  /// In de, this message translates to:
  /// **'Hast du kein Internet oder ist der Server nicht erreichbar?\nSo können wir jedenfalls nicht prüfen, ob dein Kaufhansel noch aktuell ist!'**
  String get exceptionUpdateCheckFailed;

  /// No description provided for @exceptionConnectionTimeout.
  ///
  /// In de, this message translates to:
  /// **'Schläft der Server oder ist das Internet zu langsam?\nJedenfalls hat das alles viel zu lange gedauert.'**
  String get exceptionConnectionTimeout;

  /// No description provided for @exceptionIncompatibleVersion.
  ///
  /// In de, this message translates to:
  /// **'Du verwendest vom Kaufhansel immer noch die Version {frontendVersion} ???\n\nDie ist doch schon viel zu alt. Hol dir die neue und viel bessere Version \${backendVersion} von'**
  String exceptionIncompatibleVersion(
      Object frontendVersion, Object backendVersion);

  /// No description provided for @exceptionRenameItemFailed.
  ///
  /// In de, this message translates to:
  /// **'Findet der Server {itemName} doof oder hast du kein Internet?'**
  String exceptionRenameItemFailed(Object itemName);

  /// No description provided for @exceptionAddItemFailed.
  ///
  /// In de, this message translates to:
  /// **'{itemName} konnte nicht hinzugefügt werden... ist das schon Zensur?'**
  String exceptionAddItemFailed(Object itemName);

  /// No description provided for @exceptionDeleteItemFailed.
  ///
  /// In de, this message translates to:
  /// **'{itemName} konnte nicht gelöscht werden...'**
  String exceptionDeleteItemFailed(Object itemName);

  /// No description provided for @exceptionMoveItemFailed.
  ///
  /// In de, this message translates to:
  /// **'Das Element konnte nicht verschoben werden...'**
  String get exceptionMoveItemFailed;

  /// No description provided for @exceptionCantChangeAdminRole.
  ///
  /// In de, this message translates to:
  /// **'Einmal Chefhansel, immer Chefhansel. Daran kannst du nichts mehr ändern.'**
  String get exceptionCantChangeAdminRole;

  /// No description provided for @exceptionCantFindOtherUser.
  ///
  /// In de, this message translates to:
  /// **'Hast du dich vertippt oder können wir den Hansel nicht finden?'**
  String get exceptionCantFindOtherUser;

  /// No description provided for @exceptionSendListInvitationFailed.
  ///
  /// In de, this message translates to:
  /// **'Das Verschicken der Einladungs-Email hat leider nicht geklappt. Ruf den Hansel doch einfach mal an.'**
  String get exceptionSendListInvitationFailed;

  /// No description provided for @exceptionDeleteListFailed.
  ///
  /// In de, this message translates to:
  /// **'Kann die Liste nicht gelöscht werden oder hast du kein Internet?'**
  String get exceptionDeleteListFailed;

  /// No description provided for @exceptionLogOutFailed.
  ///
  /// In de, this message translates to:
  /// **'Die Abmeldung hat nicht funktioniert...'**
  String get exceptionLogOutFailed;

  /// No description provided for @exceptionListCreationFailed.
  ///
  /// In de, this message translates to:
  /// **'Ist der Speicher voll oder hast du einen Fehler beim Anlegen der Liste gemacht?'**
  String get exceptionListCreationFailed;

  /// No description provided for @exceptionUnAuthenticated.
  ///
  /// In de, this message translates to:
  /// **'Das hat nicht funktioniert. Sieht so aus als ob deine Sitzung abgelaufen ist.'**
  String get exceptionUnAuthenticated;

  /// No description provided for @exceptionUnknown.
  ///
  /// In de, this message translates to:
  /// **'Irgendetwas ist schiefgelaufen ({exception})'**
  String exceptionUnknown(Object exception);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
