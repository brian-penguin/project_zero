--- migration:up
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  return NEW;
END;
$$ LANGUAGE plpgsql;

--- migration:down
DROP FUNCTION IF EXISTS update_updated_at_column();

--- migration:end
