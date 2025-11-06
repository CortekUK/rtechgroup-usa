-- Clear all demo data while preserving database structure
-- Delete in order to respect foreign key constraints

-- Clear reminder and event data
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'reminder_logs') THEN
    DELETE FROM reminder_logs;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'reminder_events') THEN
    DELETE FROM reminder_events;
  END IF;
END $$;

-- Clear P&L entries
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'pnl_entries') THEN
    DELETE FROM pnl_entries;
  END IF;
END $$;

-- Clear payment applications and payments
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payment_applications') THEN
    DELETE FROM payment_applications;
  END IF;
END $$;
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payments') THEN
    DELETE FROM payments;
  END IF;
END $$;

-- Clear ledger entries
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ledger_entries') THEN
    DELETE FROM ledger_entries;
  END IF;
END $$;

-- Clear fine files and fines
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

-- Clear customer documents
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'customer_documents') THEN
    DELETE FROM customer_documents;
  END IF;
END $$;

-- Clear plates
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'plates') THEN
    DELETE FROM plates;
  END IF;
END $$;

-- Clear rentals
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'rentals') THEN
    DELETE FROM rentals;
  END IF;
END $$;

-- Clear customers and vehicles
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

-- Clear users (if any demo users exist)
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'users') THEN
    DELETE FROM users;
  END IF;
END $$;

-- Reset reminder settings to default
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'reminder_settings') THEN
    DELETE FROM reminder_settings;
  END IF;
END $$;

-- Reset any sequences/counters if needed
-- (Postgres will automatically handle UUID generation)

-- Verify all tables are empty
DO $$
DECLARE
    table_name text;
    row_count integer;
BEGIN
    FOR table_name IN 
        SELECT t.table_name 
        FROM information_schema.tables t 
        WHERE t.table_schema = 'public' 
        AND t.table_type = 'BASE TABLE'
        AND t.table_name NOT LIKE 'view_%'
        AND t.table_name NOT LIKE 'v_%'
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', table_name) INTO row_count;
        IF row_count > 0 THEN
            RAISE NOTICE 'Table % still has % rows', table_name, row_count;
        ELSE
            RAISE NOTICE 'Table % is now empty', table_name;
        END IF;
    END LOOP;
END $$;