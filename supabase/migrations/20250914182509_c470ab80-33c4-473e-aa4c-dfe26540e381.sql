-- Fix RLS policies for reminder_actions table to allow authenticated users to insert action logs
DROP POLICY IF EXISTS "Enable all operations for authenticated users - reminder_action" ON reminder_actions;

DROP POLICY IF EXISTS "Allow authenticated users to insert reminder actions" ON reminder_actions;
CREATE POLICY "Allow authenticated users to insert reminder actions" 
ON reminder_actions 
FOR INSERT 
WITH CHECK (true);

DROP POLICY IF EXISTS "Allow authenticated users to read reminder actions" ON reminder_actions;
CREATE POLICY "Allow authenticated users to read reminder actions" 
ON reminder_actions 
FOR SELECT 
USING (true);

DROP POLICY IF EXISTS "Allow authenticated users to update reminder actions" ON reminder_actions;
CREATE POLICY "Allow authenticated users to update reminder actions" 
ON reminder_actions 
FOR UPDATE 
USING (true);

DROP POLICY IF EXISTS "Allow authenticated users to delete reminder actions" ON reminder_actions;
CREATE POLICY "Allow authenticated users to delete reminder actions" 
ON reminder_actions 
FOR DELETE 
USING (true);