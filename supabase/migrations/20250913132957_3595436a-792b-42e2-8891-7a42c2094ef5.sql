-- Complete data cleanup for fresh start

-- Delete in order to respect foreign key constraints

-- 1. Delete payment applications first
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payment_applications') THEN
    DELETE FROM payment_applications;
  END IF;
END $$;

-- 2. Delete reminder events and logs
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

-- 3. Delete file attachments
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

-- 4. Delete P&L entries (business data)
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'pnl_entries') THEN
    DELETE FROM pnl_entries;
  END IF;
END $$;

-- 5. Delete payments
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payments') THEN
    DELETE FROM payments;
  END IF;
END $$;

-- 6. Delete ledger entries
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ledger_entries') THEN
    DELETE FROM ledger_entries;
  END IF;
END $$;

-- 7. Delete fines
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'fines') THEN
    DELETE FROM fines;
  END IF;
END $$;

-- 8. Delete rentals
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'rentals') THEN
    DELETE FROM rentals;
  END IF;
END $$;

-- 9. Delete plates
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'plates') THEN
    DELETE FROM plates;
  END IF;
END $$;

-- 10. Delete customers
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'customers') THEN
    DELETE FROM customers;
  END IF;
END $$;

-- 11. Delete vehicles
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'vehicles') THEN
    DELETE FROM vehicles;
  END IF;
END $$;

-- Keep system tables: users, reminder_settings, login_attempts
-- These contain system configuration and user accounts