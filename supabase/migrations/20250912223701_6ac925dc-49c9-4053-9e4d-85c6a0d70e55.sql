-- Phase 1: Drop existing tables and recreate with new schema
DROP TABLE IF EXISTS payment_applications CASCADE;
DROP TABLE IF EXISTS pnl_entries CASCADE; 
DROP TABLE IF EXISTS ledger_entries CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS p_l CASCADE;
DROP TABLE IF EXISTS ledger CASCADE;
DROP TABLE IF EXISTS rentals CASCADE;
DROP TABLE IF EXISTS vehicles CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- Customers table with new schema
CREATE TABLE customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type text CHECK (type IN ('Individual','Company')) NOT NULL,
  name text NOT NULL,
  email text,
  phone text,
  whatsapp_opt_in boolean DEFAULT false,
  status text DEFAULT 'Active',
  created_at timestamptz DEFAULT now()
);

-- Vehicles table with new schema  
CREATE TABLE vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  reg text UNIQUE NOT NULL,
  make text,
  model text,
  colour text,
  acquisition_type text CHECK (acquisition_type IN ('Purchase','Finance','Lease','Other')),
  purchase_price numeric(12,2),
  acquisition_date date,
  status text DEFAULT 'Available',
  created_at timestamptz DEFAULT now()
);

-- Rentals table with new schema
CREATE TABLE rentals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid REFERENCES customers(id),
  vehicle_id uuid REFERENCES vehicles(id),
  start_date date NOT NULL,
  end_date date,
  monthly_amount numeric(12,2) NOT NULL,
  schedule text CHECK (schedule IN ('Monthly','BiMonthly','Custom')) DEFAULT 'Monthly',
  status text DEFAULT 'Active',
  created_at timestamptz DEFAULT now()
);

-- Ledger entries (canonical accounting)
CREATE TABLE ledger_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid REFERENCES customers(id),
  rental_id uuid REFERENCES rentals(id),
  vehicle_id uuid REFERENCES vehicles(id),
  entry_date date NOT NULL,
  type text CHECK (type IN ('Charge','Payment','Refund')) NOT NULL,
  category text CHECK (category IN ('Rental','Fine','Service','Fee','Other')) NOT NULL,
  amount numeric(12,2) NOT NULL,
  due_date date,
  remaining_amount numeric(12,2) NOT NULL DEFAULT 0
);

-- Payment receipts
CREATE TABLE payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id uuid REFERENCES customers(id) NOT NULL,
  rental_id uuid REFERENCES rentals(id),
  vehicle_id uuid REFERENCES vehicles(id),
  amount numeric(12,2) NOT NULL,
  payment_date date NOT NULL,
  method text,
  payment_type text CHECK (payment_type IN ('Rental','InitialFee','Fine','Other')) NOT NULL
);

-- Payment allocations
CREATE TABLE payment_applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  payment_id uuid REFERENCES payments(id) ON DELETE CASCADE,
  charge_entry_id uuid REFERENCES ledger_entries(id) ON DELETE CASCADE,
  amount_applied numeric(12,2) NOT NULL
);

-- P&L entries
CREATE TABLE pnl_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  vehicle_id uuid REFERENCES vehicles(id),
  entry_date date NOT NULL,
  side text CHECK (side IN ('Revenue','Cost')) NOT NULL,
  category text,
  amount numeric(12,2) NOT NULL,
  source_ref text
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS ix_ledger_rental_due ON ledger_entries(rental_id, type, due_date);
CREATE INDEX IF NOT EXISTS ix_ledger_vehicle ON ledger_entries(vehicle_id, type, category);
CREATE INDEX IF NOT EXISTS ix_payments_rental_date ON payments(rental_id, payment_date);
CREATE INDEX IF NOT EXISTS ix_pnl_vehicle_date ON pnl_entries(vehicle_id, entry_date, side);

-- Enable RLS
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;
ALTER TABLE rentals ENABLE ROW LEVEL SECURITY;
ALTER TABLE ledger_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE pnl_entries ENABLE ROW LEVEL SECURITY;

-- RLS Policies (allow all for authenticated users for now)
DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON customers;
CREATE POLICY "Allow all operations for authenticated users" ON customers FOR ALL USING (true);
DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON vehicles;
CREATE POLICY "Allow all operations for authenticated users" ON vehicles FOR ALL USING (true);
DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON rentals;
CREATE POLICY "Allow all operations for authenticated users" ON rentals FOR ALL USING (true);
DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON ledger_entries;
CREATE POLICY "Allow all operations for authenticated users" ON ledger_entries FOR ALL USING (true);
DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON payments;
CREATE POLICY "Allow all operations for authenticated users" ON payments FOR ALL USING (true);
DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON payment_applications;
CREATE POLICY "Allow all operations for authenticated users" ON payment_applications FOR ALL USING (true);
DROP POLICY IF EXISTS "Allow all operations for authenticated users" ON pnl_entries;
CREATE POLICY "Allow all operations for authenticated users" ON pnl_entries FOR ALL USING (true);

-- Business Logic Functions

-- Post acquisition costs to P&L
DROP FUNCTION IF EXISTS pnl_post_acquisition();

CREATE OR REPLACE FUNCTION pnl_post_acquisition(v_id uuid)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO pnl_entries(vehicle_id, entry_date, side, category, amount, source_ref)
  SELECT id, acquisition_date, 'Cost', 'Acquisition', purchase_price, id::text
  FROM vehicles v
  WHERE v.id = v_id AND v.purchase_price IS NOT NULL AND v.acquisition_date IS NOT NULL
  ON CONFLICT DO NOTHING;
$$;

-- Create rental charge
DROP FUNCTION IF EXISTS rental_create_charge();

CREATE OR REPLACE FUNCTION rental_create_charge(r_id uuid, due date, amt numeric)
RETURNS uuid LANGUAGE plpgsql AS $$
DECLARE 
  rc record; 
  cid uuid;
BEGIN
  SELECT * INTO rc FROM rentals WHERE id = r_id;
  INSERT INTO ledger_entries(customer_id, rental_id, vehicle_id, entry_date, type, category, amount, due_date, remaining_amount)
  VALUES(rc.customer_id, rc.id, rc.vehicle_id, due, 'Charge', 'Rental', amt, due, amt)
  RETURNING id INTO cid;
  RETURN cid;
END $$;

-- Apply payment FIFO with P&L posting
DROP FUNCTION IF EXISTS payment_apply_fifo();

CREATE OR REPLACE FUNCTION payment_apply_fifo(p_id uuid)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  v_amt numeric; 
  v_left numeric; 
  v_rental uuid; 
  v_customer uuid; 
  v_vehicle uuid; 
  v_date date;
  c record; 
  applied_total numeric := 0;
BEGIN
  SELECT amount, rental_id, customer_id, vehicle_id, payment_date
  INTO v_amt, v_rental, v_customer, v_vehicle, v_date
  FROM payments WHERE id = p_id;

  -- Exit if payment not found or required fields are NULL
  IF v_amt IS NULL OR v_date IS NULL THEN
    RETURN;
  END IF;

  v_left := v_amt;

  -- Mirror receipt in ledger
  INSERT INTO ledger_entries(customer_id, rental_id, vehicle_id, entry_date, type, category, amount, remaining_amount)
  VALUES(v_customer, v_rental, v_vehicle, v_date, 'Payment', 'Rental', v_amt, 0);

  -- Apply to charges FIFO
  FOR c IN
    SELECT id, remaining_amount
    FROM ledger_entries
    WHERE rental_id = v_rental AND type = 'Charge' AND remaining_amount > 0 AND due_date <= CURRENT_DATE
    ORDER BY due_date ASC, entry_date ASC
  LOOP
    EXIT WHEN v_left <= 0;
    
    IF c.remaining_amount <= v_left THEN
      INSERT INTO payment_applications(payment_id, charge_entry_id, amount_applied)
      VALUES(p_id, c.id, c.remaining_amount);
      UPDATE ledger_entries SET remaining_amount = 0 WHERE id = c.id;
      applied_total := applied_total + c.remaining_amount;
      v_left := v_left - c.remaining_amount;
    ELSE
      INSERT INTO payment_applications(payment_id, charge_entry_id, amount_applied)
      VALUES(p_id, c.id, v_left);
      UPDATE ledger_entries SET remaining_amount = remaining_amount - v_left WHERE id = c.id;
      applied_total := applied_total + v_left;
      v_left := 0;
    END IF;
  END LOOP;

  -- Post P&L revenue for applied amount
  IF applied_total > 0 THEN
    INSERT INTO pnl_entries(vehicle_id, entry_date, side, category, amount, source_ref)
    VALUES (v_vehicle, v_date, 'Revenue', 'Rental', applied_total, p_id::text);
  END IF;
END $$;

-- Generate monthly charges for rental
DROP FUNCTION IF EXISTS generate_rental_charges();

CREATE OR REPLACE FUNCTION generate_rental_charges(r_id uuid)
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  rental_rec record;
  current_month integer := 0;
  charge_date date;
  duration_months integer;
BEGIN
  SELECT * INTO rental_rec FROM rentals WHERE id = r_id;
  
  -- Calculate duration in months
  duration_months := EXTRACT(YEAR FROM AGE(rental_rec.end_date, rental_rec.start_date)) * 12 + 
                     EXTRACT(MONTH FROM AGE(rental_rec.end_date, rental_rec.start_date));
  
  -- Generate monthly charges
  WHILE current_month < duration_months LOOP
    charge_date := rental_rec.start_date + INTERVAL '1 month' * current_month;
    
    PERFORM rental_create_charge(r_id, charge_date, rental_rec.monthly_amount);
    
    current_month := current_month + 1;
  END LOOP;
END $$;

-- Trigger to auto-generate charges on rental creation
-- Drop trigger first before dropping the function
DROP TRIGGER IF EXISTS rental_charges_trigger ON rentals;

DROP FUNCTION IF EXISTS trigger_generate_rental_charges() CASCADE;

CREATE OR REPLACE FUNCTION trigger_generate_rental_charges()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  PERFORM generate_rental_charges(NEW.id);
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS rental_charges_trigger ON rentals;
CREATE TRIGGER rental_charges_trigger
  AFTER INSERT ON rentals
  FOR EACH ROW
  EXECUTE FUNCTION trigger_generate_rental_charges();

-- Trigger to post acquisition costs
-- Drop trigger first before dropping the function
DROP TRIGGER IF EXISTS vehicle_acquisition_trigger ON vehicles;

DROP FUNCTION IF EXISTS trigger_post_acquisition() CASCADE;

CREATE OR REPLACE FUNCTION trigger_post_acquisition()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.purchase_price IS NOT NULL AND NEW.acquisition_date IS NOT NULL AND 
     (OLD IS NULL OR OLD.purchase_price IS DISTINCT FROM NEW.purchase_price OR 
      OLD.acquisition_date IS DISTINCT FROM NEW.acquisition_date) THEN
    PERFORM pnl_post_acquisition(NEW.id);
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS vehicle_acquisition_trigger ON vehicles;
CREATE TRIGGER vehicle_acquisition_trigger
  AFTER INSERT OR UPDATE ON vehicles
  FOR EACH ROW
  EXECUTE FUNCTION trigger_post_acquisition();

