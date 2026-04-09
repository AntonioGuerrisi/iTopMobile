class AppStrings {
  // General
  static const appTitle = 'iTop Mobile';
  static const ticketAssetManagement = 'Ticket & Asset Management';
  static const error = 'Error';
  static const loading = 'Loading...';
  static const retry = 'Retry';
  static const cancel = 'Cancel';
  static const confirm = 'Confirm';

  // Login screen
  static const login = 'Login';
  static const loginFailed = 'Login failed';
  static const iTopServerUrl = 'iTop Server URL';
  static const serverUrlHint = 'https://itop.example.com';
  static const enterServerUrl = 'Enter the server URL';
  static const secureUrlRequirement =
      'URL must start with https:// (secure connection)';
  static const username = 'Username';
  static const enterUsername = 'Enter username';
  static const password = 'Password';
  static const enterPassword = 'Enter password';
  static const rememberMe = 'Remember me';
  static const resetCertificatePin = 'Reset certificate pin';
  static const certificatePinResetMessage =
      'Certificate pin reset. Please try login again.';

  // Home screen
  static const tickets = 'Tickets';
  static const assets = 'Assets';
  static const settings = 'Settings';

  // Settings
  static const version = 'Version';
  static const build = 'Build';
  static const server = 'Server';
  static const apiITop = 'iTop API';
  static const apiVersion = 'REST JSON v1.3';
  static const signOut = 'Sign out';
  static const confirmSignOut = 'Are you sure you want to sign out?';

  // Ticket list
  static const searchTickets = 'Search tickets...';
  static const showAllTickets = 'Show all tickets';
  static const myTicketsOnly = 'My tickets only';
  static const period = 'Period';
  static const sort = 'Sort';
  static const allTickets = 'All tickets';
  static const loadingTickets = 'Loading tickets...';
  static const noTicketsFound = 'No tickets found';
  static const myTickets = 'My tickets';
  static const ticketCountSuffix = ' tickets';

  // Asset list
  static const searchAssets = 'Search assets...';
  static const filterByType = 'Filter by type';
  static const all = 'All';
  static const filter = 'Filter';
  static const noneFound = 'No items found';
  static const noAssetsFound = 'No assets found';
  static const assetsCountSuffix = ' assets';
  static const selectedFilter = 'Filter:';
  static const selectFilterType = 'Select a type';

  // Asset detail
  static const generalInformation = 'General Information';
  static const hardware = 'Hardware';
  static const location = 'Location';
  static const description = 'Description';
  static const additionalDetails = 'Additional Details';
  static const organization = 'Organization';
  static const type = 'Type';
  static const status = 'Status';
  static const criticality = 'Criticality';
  static const brand = 'Brand';
  static const model = 'Model';
  static const serialNumber = 'Serial Number';
  static const assetNumber = 'Asset Number';
  static const locationName = 'Location';
  static const inProductionSince = 'In production since';

  // Ticket detail
  static const details = 'Details';
  static const ticketDetails = 'Ticket Details';
  static const actions = 'Actions';
  static const publicLog = 'Public';
  static const privateLog = 'Private';
  static const activityLog = 'Activity';
  static const noDescriptionAvailable = 'No description available';
  static const noLogsAvailable = 'No logs available';
  static const noLogsWithFilters = 'No logs match the selected filters';
  static const showLogs = 'Logs';
  static const addToLog = 'Add to Log';
  static const changeStatus = 'Change Status';
  static const currentStatus = 'Current status:';
  static const visibleToRequester = 'Visible to requester';
  static const visibleToInternalTeam = 'Visible only to the internal team';
  static const assign = 'Assign';
  static const resolve = 'Resolve';
  static const pending = 'Pending';
  static const reassign = 'Reassign';
  static const close = 'Close';
  static const reopen = 'Reopen';
  static const resolveTicket = 'Resolve Ticket';
  static const ticketResolvedSuccessfully = 'Ticket resolved successfully!';
  static const ticketAssignedSuccessfully = 'Ticket assigned successfully!';
  static const ticketReassignedSuccessfully = 'Ticket reassigned successfully!';
  static const mandatoryComment = 'Comment is required';
  static const publicLogTitle = 'Public Log';
  static const privateLogTitle = 'Private Log';
  static const writeLogMessage = 'Write a log message...';
  static const addLog = 'Send';
  static const addLogDialogTitle = 'Add Log Entry';
  static const assignTeam = 'Team *';
  static const assignAgent = 'Agent *';
  static const selectTeam = 'Select a team';
  static const selectAgent = 'Select an agent';
  static const selectTeamFirst = 'Select a team first';
  static const assignTicket = 'Assign Ticket';
  static const assigningTicket = 'Assigning...';
  static const selectService = 'Select a service';
  static const selectSubcategory = 'Select subcategory';
  static const noSubcategories = 'No subcategories';
  static const service = 'Service *';
  static const subcategory = 'Service Subcategory *';
  static const solutionDescription = 'Solution Description *';
  static const solutionHint = 'Describe the applied solution...';
  static const enterSolutionDescription = 'Enter the solution description';
  static const saving = 'Saving...';
  static const ticketClosedMessage = 'Ticket closed successfully!';
  static const ticketReopenedMessage = 'Ticket reopened successfully!';

  // Log filters
  static const publicLabel = 'Public';
  static const privateLabel = 'Private';
  static const activityLabel = 'Activity';

  // Ticket field labels
  static const requester = 'Requester';
  static const team = 'Team';
  static const agent = 'Agent';
  static const origin = 'Origin';
  static const priority = 'Priority';
  static const urgency = 'Urgency';
  static const impact = 'Impact';
  static const opening = 'Opening';
  static const lastUpdate = 'Last update';
  static const closure = 'Closure';
  static const classification = 'Classification';
  static const dates = 'Dates';
  static const resolution = 'Resolution';

  // Ticket statuses
  static const allStatuses = 'All';
  static const newStatus = 'New';
  static const assignedStatus = 'Assigned';
  static const pendingStatus = 'Pending';
  static const resolvedStatus = 'Resolved';
  static const closedStatus = 'Closed';

  // Team and service forms
  static const pendingReasonTitle = 'Pending';
  static const pendingReasonLabel = 'Describe the reason for pending:';
  static const pendingReasonHint = 'Reason...';
  static const confirmPending = 'Confirm';

  static const confirmActionTitle = 'Confirm:';
  static const wantToAction = 'Do you want to {action} ticket {ref}?';
  static const commentLabel = 'Comment *';
  static const commentHint = 'Enter a comment...';

  // Model labels
  static const ticketCreated = 'Ticket created';
  static const pluginActionExecuted = 'Plugin action executed';
  static const attachmentAdded = 'Attachment added:';
  static const attributeUpdated = 'Updated';

  // Service / provider errors
  static const connectionError = 'Connection error:';
  static const insecureConnection = 'Insecure connection: URL must use HTTPS.';
  static const apiUnknownError = 'Unknown iTop API error';
}
