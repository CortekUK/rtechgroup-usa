-- Clear all operational data for testing
-- Delete in order to respect foreign key constraints

-- Clear dependent tables first
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payment_applications') THEN
    DELETE FROM payment_applications;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'authority_payments') THEN
    DELETE FROM authority_payments;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'fine_files') THEN
    DELETE FROM fine_files;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'customer_documents') THEN
    DELETE FROM customer_documents;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'reminder_events') THEN
    DELETE FROM reminder_events;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'reminder_logs') THEN
    DELETE FROM reminder_logs;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ledger_entries') THEN
    DELETE FROM ledger_entries;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'pnl_entries') THEN
    DELETE FROM pnl_entries;
  END IF;
END $$;

-- Clear main operational tables
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payments') THEN
    DELETE FROM payments;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'fines') THEN
    DELETE FROM fines;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'rentals') THEN
    DELETE FROM rentals;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'plates') THEN
    DELETE FROM plates;
  END IF;
END $$;

-- Clear customer and vehicle data
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'customers') THEN
    DELETE FROM customers;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'vehicles') THEN
    DELETE FROM vehicles;
  END IF;
END $$;

-- Clear system/admin tables
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'reminder_settings') THEN
    DELETE FROM reminder_settings;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'login_attempts') THEN
    DELETE FROM login_attempts;
  END IF;
END $$;

-- Note: Keeping users table intact for login functionality