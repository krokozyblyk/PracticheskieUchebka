const apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080/api',
);

const apiConnectTimeout = Duration(seconds: 10);

const apiReceiveTimeout = Duration(seconds: 15);

const sessionIdleSeconds = int.fromEnvironment(
  'SESSION_IDLE_SECONDS',
  defaultValue: 180,
);

const sessionWarningSeconds = int.fromEnvironment(
  'SESSION_WARNING_SECONDS',
  defaultValue: 30,
);

const sessionMaxSeconds = int.fromEnvironment(
  'SESSION_MAX_SECONDS',
  defaultValue: 3600,
);
