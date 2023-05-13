/// Environment variables and shared app constants.
abstract class Constants {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pjmmfyhifblvbqgnllfc.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBqbW1meWhpZmJsdmJxZ25sbGZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODIzODQzODMsImV4cCI6MTk5Nzk2MDM4M30.uqz2wJg5Tf6g3_b3uIad1IE9CDJx8sjhudreHCjgJWA',
  );
}
