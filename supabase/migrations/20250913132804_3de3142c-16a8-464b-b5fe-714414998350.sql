-- Clean up test data for fresh testing

-- Delete payment applications first (foreign key dependencies)
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payment_applications') THEN
    DELETE FROM payment_applications 
WHERE payment_id IN (
  SELECT id FROM payments 
  WHERE customer_id = '6bc27fd4-89ab-4cd2-a0d8-7dc1d1809995'
);
  END IF;
END $$;

-- Delete payments for the test customer
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payments') THEN
    DELETE FROM payments 
WHERE customer_id = '6bc27fd4-89ab-4cd2-a0d8-7dc1d1809995';
  END IF;
END $$;

-- Delete ledger entries for the test customer
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ledger_entries') THEN
    DELETE FROM ledger_entries 
WHERE customer_id = '6bc27fd4-89ab-4cd2-a0d8-7dc1d1809995';
  END IF;
END $$;

-- Delete PnL entries for the test vehicle (except acquisition cost)
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'pnl_entries') THEN
    DELETE FROM pnl_entries 
WHERE vehicle_id = 'fb34f191-a698-4b26-bf8d-66d19e4c6001' 
  AND category != 'Acquisition';
  END IF;
END $$;

-- Delete test rentals
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'rentals') THEN
    DELETE FROM rentals 
WHERE customer_id = '6bc27fd4-89ab-4cd2-a0d8-7dc1d1809995';
  END IF;
END $$;

-- Reset vehicle status back to Available
UPDATE vehicles 
SET status = 'Available' 
WHERE id = 'fb34f191-a698-4b26-bf8d-66d19e4c6001';