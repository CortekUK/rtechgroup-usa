-- Remove ALL data from the database for complete reset

-- Delete all transactional data first (already done but ensuring completeness)
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payment_applications') THEN
    DELETE FROM payment_applications;
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
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'fine_files') THEN
    DELETE FROM fine_files;
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
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payments') THEN
    DELETE FROM payments;
  END IF;
END $$;

-- Delete customer-related data
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'customer_documents') THEN
    DELETE FROM customer_documents;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'customers') THEN
    DELETE FROM customers;
  END IF;
END $$;

-- Delete vehicle-related data
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'plates') THEN
    DELETE FROM plates;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'vehicles') THEN
    DELETE FROM vehicles;
  END IF;
END $$;

-- Delete user-related data (keep system admin if exists)
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'login_attempts') THEN
    DELETE FROM login_attempts;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
    DELETE FROM users WHERE username != 'admin';
  END IF;
END $$;

-- Delete reminder settings
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'reminder_settings') THEN
    DELETE FROM reminder_settings;
  END IF;
END $$;

-- Reset any sequences/counters if needed
-- This ensures clean slate for testing