-- Clean up duplicate P&L entries for initial fees
-- Keep entries with source_ref (created by trigger) and remove those without
DO $$
BEGIN
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'public' AND tablename = 'pnl_entries') THEN
    DELETE FROM pnl_entries 
WHERE category = 'Initial Fees' 
  AND reference IS NOT NULL 
  AND source_ref IS NULL;
  END IF;
END $$;