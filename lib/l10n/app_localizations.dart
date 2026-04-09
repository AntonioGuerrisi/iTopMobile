import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

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
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'iTop Mobile'**
  String get appTitle;

  /// No description provided for @ticketAssetManagement.
  ///
  /// In en, this message translates to:
  /// **'Ticket & Asset Management'**
  String get ticketAssetManagement;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @iTopServerUrl.
  ///
  /// In en, this message translates to:
  /// **'iTop Server URL'**
  String get iTopServerUrl;

  /// No description provided for @serverUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://itop.example.com'**
  String get serverUrlHint;

  /// No description provided for @enterServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter the server URL'**
  String get enterServerUrl;

  /// No description provided for @secureUrlRequirement.
  ///
  /// In en, this message translates to:
  /// **'URL must start with https:// (secure connection)'**
  String get secureUrlRequirement;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @resetCertificatePin.
  ///
  /// In en, this message translates to:
  /// **'Reset certificate pin'**
  String get resetCertificatePin;

  /// No description provided for @certificatePinResetMessage.
  ///
  /// In en, this message translates to:
  /// **'Certificate pin reset. Please try login again.'**
  String get certificatePinResetMessage;

  /// No description provided for @tickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// No description provided for @assets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get assets;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @build.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get build;

  /// No description provided for @server.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get server;

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

  /// No description provided for @italian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get italian;

  /// No description provided for @apiITop.
  ///
  /// In en, this message translates to:
  /// **'iTop API'**
  String get apiITop;

  /// No description provided for @apiVersion.
  ///
  /// In en, this message translates to:
  /// **'REST JSON v1.3'**
  String get apiVersion;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @confirmSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get confirmSignOut;

  /// No description provided for @searchTickets.
  ///
  /// In en, this message translates to:
  /// **'Search tickets...'**
  String get searchTickets;

  /// No description provided for @showAllTickets.
  ///
  /// In en, this message translates to:
  /// **'Show all tickets'**
  String get showAllTickets;

  /// No description provided for @myTicketsOnly.
  ///
  /// In en, this message translates to:
  /// **'My tickets only'**
  String get myTicketsOnly;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @allTickets.
  ///
  /// In en, this message translates to:
  /// **'All tickets'**
  String get allTickets;

  /// No description provided for @loadingTickets.
  ///
  /// In en, this message translates to:
  /// **'Loading tickets...'**
  String get loadingTickets;

  /// No description provided for @noTicketsFound.
  ///
  /// In en, this message translates to:
  /// **'No tickets found'**
  String get noTicketsFound;

  /// No description provided for @myTickets.
  ///
  /// In en, this message translates to:
  /// **'My tickets'**
  String get myTickets;

  /// No description provided for @ticketCountSuffix.
  ///
  /// In en, this message translates to:
  /// **' tickets'**
  String get ticketCountSuffix;

  /// No description provided for @searchAssets.
  ///
  /// In en, this message translates to:
  /// **'Search assets...'**
  String get searchAssets;

  /// No description provided for @filterByType.
  ///
  /// In en, this message translates to:
  /// **'Filter by type'**
  String get filterByType;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @noneFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noneFound;

  /// No description provided for @noAssetsFound.
  ///
  /// In en, this message translates to:
  /// **'No assets found'**
  String get noAssetsFound;

  /// No description provided for @assetsCountSuffix.
  ///
  /// In en, this message translates to:
  /// **' assets'**
  String get assetsCountSuffix;

  /// No description provided for @selectedFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter:'**
  String get selectedFilter;

  /// No description provided for @selectFilterType.
  ///
  /// In en, this message translates to:
  /// **'Select a type'**
  String get selectFilterType;

  /// No description provided for @generalInformation.
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get generalInformation;

  /// No description provided for @hardware.
  ///
  /// In en, this message translates to:
  /// **'Hardware'**
  String get hardware;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @additionalDetails.
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get additionalDetails;

  /// No description provided for @organization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organization;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @criticality.
  ///
  /// In en, this message translates to:
  /// **'Criticality'**
  String get criticality;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get serialNumber;

  /// No description provided for @assetNumber.
  ///
  /// In en, this message translates to:
  /// **'Asset Number'**
  String get assetNumber;

  /// No description provided for @locationName.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationName;

  /// No description provided for @inProductionSince.
  ///
  /// In en, this message translates to:
  /// **'In production since'**
  String get inProductionSince;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @ticketDetails.
  ///
  /// In en, this message translates to:
  /// **'Ticket Details'**
  String get ticketDetails;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @publicLog.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicLog;

  /// No description provided for @privateLog.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateLog;

  /// No description provided for @activityLog.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityLog;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// No description provided for @noLogsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No logs available'**
  String get noLogsAvailable;

  /// No description provided for @noLogsWithFilters.
  ///
  /// In en, this message translates to:
  /// **'No logs match the selected filters'**
  String get noLogsWithFilters;

  /// No description provided for @showLogs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get showLogs;

  /// No description provided for @addToLog.
  ///
  /// In en, this message translates to:
  /// **'Add to Log'**
  String get addToLog;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change Status'**
  String get changeStatus;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current status:'**
  String get currentStatus;

  /// No description provided for @visibleToRequester.
  ///
  /// In en, this message translates to:
  /// **'Visible to requester'**
  String get visibleToRequester;

  /// No description provided for @visibleToInternalTeam.
  ///
  /// In en, this message translates to:
  /// **'Visible only to the internal team'**
  String get visibleToInternalTeam;

  /// No description provided for @assign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// No description provided for @resolve.
  ///
  /// In en, this message translates to:
  /// **'Resolve'**
  String get resolve;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @reassign.
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get reassign;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @reopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// No description provided for @resolveTicket.
  ///
  /// In en, this message translates to:
  /// **'Resolve Ticket'**
  String get resolveTicket;

  /// No description provided for @ticketResolvedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ticket resolved successfully!'**
  String get ticketResolvedSuccessfully;

  /// No description provided for @ticketAssignedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ticket assigned successfully!'**
  String get ticketAssignedSuccessfully;

  /// No description provided for @ticketReassignedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Ticket reassigned successfully!'**
  String get ticketReassignedSuccessfully;

  /// No description provided for @mandatoryComment.
  ///
  /// In en, this message translates to:
  /// **'Comment is required'**
  String get mandatoryComment;

  /// No description provided for @publicLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Public Log'**
  String get publicLogTitle;

  /// No description provided for @privateLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Private Log'**
  String get privateLogTitle;

  /// No description provided for @writeLogMessage.
  ///
  /// In en, this message translates to:
  /// **'Write a log message...'**
  String get writeLogMessage;

  /// No description provided for @addLog.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get addLog;

  /// No description provided for @addLogDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Log Entry'**
  String get addLogDialogTitle;

  /// No description provided for @assignTeam.
  ///
  /// In en, this message translates to:
  /// **'Team *'**
  String get assignTeam;

  /// No description provided for @assignAgent.
  ///
  /// In en, this message translates to:
  /// **'Agent *'**
  String get assignAgent;

  /// No description provided for @selectTeam.
  ///
  /// In en, this message translates to:
  /// **'Select a team'**
  String get selectTeam;

  /// No description provided for @selectAgent.
  ///
  /// In en, this message translates to:
  /// **'Select an agent'**
  String get selectAgent;

  /// No description provided for @selectTeamFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a team first'**
  String get selectTeamFirst;

  /// No description provided for @assignTicket.
  ///
  /// In en, this message translates to:
  /// **'Assign Ticket'**
  String get assignTicket;

  /// No description provided for @assigningTicket.
  ///
  /// In en, this message translates to:
  /// **'Assigning...'**
  String get assigningTicket;

  /// No description provided for @selectService.
  ///
  /// In en, this message translates to:
  /// **'Select a service'**
  String get selectService;

  /// No description provided for @selectSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Select subcategory'**
  String get selectSubcategory;

  /// No description provided for @noSubcategories.
  ///
  /// In en, this message translates to:
  /// **'No subcategories'**
  String get noSubcategories;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service *'**
  String get service;

  /// No description provided for @subcategory.
  ///
  /// In en, this message translates to:
  /// **'Service Subcategory *'**
  String get subcategory;

  /// No description provided for @solutionDescription.
  ///
  /// In en, this message translates to:
  /// **'Solution Description *'**
  String get solutionDescription;

  /// No description provided for @solutionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the applied solution...'**
  String get solutionHint;

  /// No description provided for @enterSolutionDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the solution description'**
  String get enterSolutionDescription;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @publicLabel.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicLabel;

  /// No description provided for @privateLabel.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateLabel;

  /// No description provided for @activityLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityLabel;

  /// No description provided for @requester.
  ///
  /// In en, this message translates to:
  /// **'Requester'**
  String get requester;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @agent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get agent;

  /// No description provided for @origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get origin;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @urgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get urgency;

  /// No description provided for @impact.
  ///
  /// In en, this message translates to:
  /// **'Impact'**
  String get impact;

  /// No description provided for @opening.
  ///
  /// In en, this message translates to:
  /// **'Opening'**
  String get opening;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last update'**
  String get lastUpdate;

  /// No description provided for @closure.
  ///
  /// In en, this message translates to:
  /// **'Closure'**
  String get closure;

  /// No description provided for @classification.
  ///
  /// In en, this message translates to:
  /// **'Classification'**
  String get classification;

  /// No description provided for @dates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get dates;

  /// No description provided for @resolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get resolution;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allStatuses;

  /// No description provided for @newStatus.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newStatus;

  /// No description provided for @assignedStatus.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assignedStatus;

  /// No description provided for @pendingStatus.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingStatus;

  /// No description provided for @resolvedStatus.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolvedStatus;

  /// No description provided for @closedStatus.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closedStatus;

  /// No description provided for @pendingReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingReasonTitle;

  /// No description provided for @pendingReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Describe the reason for pending:'**
  String get pendingReasonLabel;

  /// No description provided for @pendingReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Reason...'**
  String get pendingReasonHint;

  /// No description provided for @confirmPending.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirmPending;

  /// No description provided for @confirmActionTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm:'**
  String get confirmActionTitle;

  /// No description provided for @wantToAction.
  ///
  /// In en, this message translates to:
  /// **'Do you want to {action} ticket {ref}?'**
  String wantToAction(Object action, Object ref);

  /// No description provided for @commentLabel.
  ///
  /// In en, this message translates to:
  /// **'Comment *'**
  String get commentLabel;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a comment...'**
  String get commentHint;
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
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
