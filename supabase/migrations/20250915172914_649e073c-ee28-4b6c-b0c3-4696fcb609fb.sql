-- Clear all existing MOT and TAX reminders to remove duplicates
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'reminders') THEN
    DELETE FROM reminders WHERE rule_code LIKE 'MOT_%' OR rule_code LIKE 'TAX_%';
  END IF;
END $$;

-- Also clear any immobiliser reminders to start fresh
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'reminders') THEN
    DELETE FROM reminders WHERE rule_code LIKE 'IMM_%';
  END IF;
END $$;