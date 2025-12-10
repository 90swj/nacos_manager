import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nacos Client'**
  String get appTitle;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @addConnection.
  ///
  /// In en, this message translates to:
  /// **'Add Connection'**
  String get addConnection;

  /// No description provided for @connectionName.
  ///
  /// In en, this message translates to:
  /// **'Connection Name'**
  String get connectionName;

  /// No description provided for @connectionUrl.
  ///
  /// In en, this message translates to:
  /// **'Connection Url'**
  String get connectionUrl;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed'**
  String get loginFailed;

  /// No description provided for @noConnectionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No connection available'**
  String get noConnectionAvailable;

  /// No description provided for @failedToLoadConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Failed to load configuration'**
  String get failedToLoadConfiguration;

  /// No description provided for @inputTags.
  ///
  /// In en, this message translates to:
  /// **'Press Enter after entering the tag'**
  String get inputTags;

  /// No description provided for @fileType.
  ///
  /// In en, this message translates to:
  /// **'File Type'**
  String get fileType;

  /// No description provided for @selectFileType.
  ///
  /// In en, this message translates to:
  /// **'Select File Type'**
  String get selectFileType;

  /// No description provided for @advancedQuery.
  ///
  /// In en, this message translates to:
  /// **'Advanced Query'**
  String get advancedQuery;

  /// No description provided for @configManagement.
  ///
  /// In en, this message translates to:
  /// **'Config Management'**
  String get configManagement;

  /// No description provided for @serviceDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Service Discovery'**
  String get serviceDiscovery;

  /// No description provided for @namespace.
  ///
  /// In en, this message translates to:
  /// **'Namespace'**
  String get namespace;

  /// No description provided for @addNamespace.
  ///
  /// In en, this message translates to:
  /// **'Add Namespace'**
  String get addNamespace;

  /// No description provided for @editNamespace.
  ///
  /// In en, this message translates to:
  /// **'Edit Namespace'**
  String get editNamespace;

  /// No description provided for @public.
  ///
  /// In en, this message translates to:
  /// **'public'**
  String get public;

  /// No description provided for @config.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get config;

  /// No description provided for @addConfig.
  ///
  /// In en, this message translates to:
  /// **'Add Config'**
  String get addConfig;

  /// No description provided for @editConfig.
  ///
  /// In en, this message translates to:
  /// **'Edit Config'**
  String get editConfig;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @space.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get space;

  /// No description provided for @spaceName.
  ///
  /// In en, this message translates to:
  /// **'Space Name'**
  String get spaceName;

  /// No description provided for @spaceDesc.
  ///
  /// In en, this message translates to:
  /// **'Space Description'**
  String get spaceDesc;

  /// No description provided for @searchServiceName.
  ///
  /// In en, this message translates to:
  /// **'Search Service Name'**
  String get searchServiceName;

  /// No description provided for @searchGroup.
  ///
  /// In en, this message translates to:
  /// **'Search Group'**
  String get searchGroup;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'tags'**
  String get tags;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get appName;

  /// No description provided for @fileContent.
  ///
  /// In en, this message translates to:
  /// **'File Content'**
  String get fileContent;

  /// No description provided for @instances.
  ///
  /// In en, this message translates to:
  /// **'Instances'**
  String get instances;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @unhealthy.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy'**
  String get unhealthy;

  /// No description provided for @cluster.
  ///
  /// In en, this message translates to:
  /// **'Cluster'**
  String get cluster;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @clone.
  ///
  /// In en, this message translates to:
  /// **'Clone'**
  String get clone;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export(Copy)'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserved;

  /// No description provided for @confirmDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get confirmDeletion;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteWarning.
  ///
  /// In en, this message translates to:
  /// **'It cannot be restored after deletion'**
  String get deleteWarning;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @updateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Update Success'**
  String get updateSuccess;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update Failed'**
  String get updateFailed;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Delete Success'**
  String get deleteSuccess;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete Failed'**
  String get deleteFailed;

  /// No description provided for @pushSuccess.
  ///
  /// In en, this message translates to:
  /// **'Push Success'**
  String get pushSuccess;

  /// No description provided for @pushFailed.
  ///
  /// In en, this message translates to:
  /// **'Push Failed'**
  String get pushFailed;

  /// No description provided for @jsonFormatError.
  ///
  /// In en, this message translates to:
  /// **'JSON Format Error'**
  String get jsonFormatError;

  /// No description provided for @ipPortNotEditable.
  ///
  /// In en, this message translates to:
  /// **'IP and Port are not editable'**
  String get ipPortNotEditable;

  /// No description provided for @metadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata (JSON):'**
  String get metadata;

  /// No description provided for @multiEnvironmentManagement.
  ///
  /// In en, this message translates to:
  /// **'Multi-environment management'**
  String get multiEnvironmentManagement;

  /// No description provided for @addEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Add Environment'**
  String get addEnvironment;

  /// No description provided for @editEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Edit Environment'**
  String get editEnvironment;

  /// No description provided for @remark.
  ///
  /// In en, this message translates to:
  /// **'Alias (example: development)'**
  String get remark;

  /// No description provided for @pleaseCheckNetworkOrAccount.
  ///
  /// In en, this message translates to:
  /// **'Please Check Network Or Account'**
  String get pleaseCheckNetworkOrAccount;

  /// No description provided for @addEnvPrompt.
  ///
  /// In en, this message translates to:
  /// **'Click the lower right corner to add a Nacos server'**
  String get addEnvPrompt;

  /// No description provided for @deleteDataIdFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting the configuration'**
  String get deleteDataIdFailed;

  /// No description provided for @addConfigPrompt.
  ///
  /// In en, this message translates to:
  /// **'Data ID and Group cannot be empty'**
  String get addConfigPrompt;

  /// No description provided for @cloneConfigPrompt.
  ///
  /// In en, this message translates to:
  /// **'Note: Cloning configuration to'**
  String get cloneConfigPrompt;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @pasted.
  ///
  /// In en, this message translates to:
  /// **'Pasted'**
  String get pasted;

  /// No description provided for @filtering.
  ///
  /// In en, this message translates to:
  /// **'Filtering'**
  String get filtering;

  /// No description provided for @allConfigurations.
  ///
  /// In en, this message translates to:
  /// **'All configurations'**
  String get allConfigurations;

  /// No description provided for @noConfigurationsOrLoadingFailed.
  ///
  /// In en, this message translates to:
  /// **'No Configurations Or Loading Failed'**
  String get noConfigurationsOrLoadingFailed;

  /// No description provided for @exportingConfigurationFailed.
  ///
  /// In en, this message translates to:
  /// **'Exporting configuration failed'**
  String get exportingConfigurationFailed;

  /// No description provided for @initPageFailed.
  ///
  /// In en, this message translates to:
  /// **'Page initialization failed, please try again'**
  String get initPageFailed;

  /// No description provided for @pushConfigFailed.
  ///
  /// In en, this message translates to:
  /// **'An error occurred when publishing the configuration'**
  String get pushConfigFailed;

  /// No description provided for @ip.
  ///
  /// In en, this message translates to:
  /// **'IP'**
  String get ip;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
