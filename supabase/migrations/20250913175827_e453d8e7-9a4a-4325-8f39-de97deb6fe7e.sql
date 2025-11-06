-- Clean up all test data for fresh acceptance testing

-- Delete payment applications first (foreign key dependency)
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payment_applications') THEN
    DELETE FROM payment_applications 
WHERE payment_id IN (
  SELECT id FROM payments 
  WHERE customer_id = '8d10730e-8a1f-4b65-aecb-5d9f698eef2a'
);
  END IF;
END $$;

-- Delete payments
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'payments') THEN
    DELETE FROM payments 
WHERE customer_id = '8d10730e-8a1f-4b65-aecb-5d9f698eef2a';
  END IF;
END $$;

-- Delete ledger entries
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'ledger_entries') THEN
    DELETE FROM ledger_entries 
WHERE customer_id = '8d10730e-8a1f-4b65-aecb-5d9f698eef2a';
  END IF;
END $$;

-- Delete P&L entries for the test customer
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'pnl_entries') THEN
    DELETE FROM pnl_entries 
WHERE customer_id = '8d10730e-8a1f-4b65-aecb-5d9f698eef2a';
  END IF;
END $$;

-- Delete test rentals  
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'rentals') THEN
    DELETE FROM rentals 
WHERE customer_id = '8d10730e-8a1f-4b65-aecb-5d9f698eef2a';
  END IF;
END $$;

-- Also clean up any P&L entries that might reference test data by vehicle
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'pnl_entries') THEN
    DELETE FROM pnl_entries 
WHERE vehicle_id = '309ea187-8228-4711-949d-5e65ed210bbb' 
  AND category IN ('Initial Fees', 'Rental');
  END IF;
END $$;

VACUUM ANALYZE payments;
VACUUM ANALYZE ledger_entries;
VACUUM ANALYZE pnl_entries;
VACUUM ANALYZE rentals;