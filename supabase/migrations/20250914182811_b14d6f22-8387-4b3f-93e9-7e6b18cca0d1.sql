-- First, let's see what policies exist and then update them properly
-- Drop existing policies that might conflict
DROP POLICY IF EXISTS "Allow all users to update reminders" ON reminders;
DROP POLICY IF EXISTS "Allow all users to delete reminders" ON reminders;  
DROP POLICY IF EXISTS "Allow all users to insert reminders" ON reminders;
DROP POLICY IF EXISTS "Allow authenticated users to update reminders" ON reminders;
DROP POLICY IF EXISTS "Allow authenticated users to delete reminders" ON reminders;
DROP POLICY IF EXISTS "Allow authenticated users to insert reminders" ON reminders;

-- Create new policies that allow anonymous access for demo purposes
DROP POLICY IF EXISTS "Enable all operations for all users - reminders update" ON reminders;
CREATE POLICY "Enable all operations for all users - reminders update" 
ON reminders 
FOR UPDATE 
USING (true) 
WITH CHECK (true);

DROP POLICY IF EXISTS "Enable all operations for all users - reminders delete" ON reminders;
CREATE POLICY "Enable all operations for all users - reminders delete" 
ON reminders 
FOR DELETE 
USING (true);

DROP POLICY IF EXISTS "Enable all operations for all users - reminders insert" ON reminders;
CREATE POLICY "Enable all operations for all users - reminders insert" 
ON reminders 
FOR INSERT 
WITH CHECK (true);