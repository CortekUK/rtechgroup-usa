-- Clean up the specific test data that's causing the unique constraint violation
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payment_applications') THEN
    DELETE FROM payment_applications WHERE payment_id IN (
  SELECT id FROM payments WHERE customer_id = 'd8671806-e8c9-4a25-b072-9490c50e9616'
);
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payments') THEN
    DELETE FROM payments WHERE customer_id = 'd8671806-e8c9-4a25-b072-9490c50e9616';
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ledger_entries') THEN
    DELETE FROM ledger_entries WHERE customer_id = 'd8671806-e8c9-4a25-b072-9490c50e9616';
  END IF;
END $$;

DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'rentals') THEN
    DELETE FROM rentals WHERE customer_id = 'd8671806-e8c9-4a25-b072-9490c50e9616';
  END IF;
END $$;