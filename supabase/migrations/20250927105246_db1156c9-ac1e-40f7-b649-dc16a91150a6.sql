-- Clean up all test data in correct order to handle foreign key constraints

-- Delete payment applications first
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payment_applications') THEN
    DELETE FROM payment_applications;
  END IF;
END $$;

-- Delete reminder related data
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
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'reminder_actions') THEN
    DELETE FROM reminder_actions;
  END IF;
END $$;

-- Delete financial entries
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

-- Delete payments
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payments') THEN
    DELETE FROM payments;
  END IF;
END $$;

-- Delete authority payments and fines
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'authority_payments') THEN
    DELETE FROM authority_payments;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'fines') THEN
    DELETE FROM fines;
  END IF;
END $$;

-- Delete vehicle related data
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'vehicle_events') THEN
    DELETE FROM vehicle_events;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'vehicle_expenses') THEN
    DELETE FROM vehicle_expenses;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'vehicle_files') THEN
    DELETE FROM vehicle_files;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'service_records') THEN
    DELETE FROM service_records;
  END IF;
END $$;

-- Delete insurance related data
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'insurance_documents') THEN
    DELETE FROM insurance_documents;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'insurance_policies') THEN
    DELETE FROM insurance_policies;
  END IF;
END $$;

-- Delete customer documents
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'customer_documents') THEN
    DELETE FROM customer_documents;
  END IF;
END $$;

-- Delete plates
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'plates') THEN
    DELETE FROM plates;
  END IF;
END $$;

-- Delete rentals
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'rentals') THEN
    DELETE FROM rentals;
  END IF;
END $$;

-- Delete vehicles and customers last
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'vehicles') THEN
    DELETE FROM vehicles;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'customers') THEN
    DELETE FROM customers;
  END IF;
END $$;

-- Reset any sequences or counters if needed
-- Note: UUIDs don't use sequences, so no need to reset those