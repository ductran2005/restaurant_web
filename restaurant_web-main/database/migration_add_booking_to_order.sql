-- Migration: Add booking_id column to orders table
-- Purpose: Link orders to bookings for pre-order integration
-- Date: 2026-03-16

-- Add booking_id column (nullable since not all orders come from bookings)
-- Check if column exists before adding
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'orders' AND column_name = 'booking_id'
    ) THEN
        ALTER TABLE orders ADD COLUMN booking_id INT NULL;
        RAISE NOTICE 'Column booking_id added to orders table';
    ELSE
        RAISE NOTICE 'Column booking_id already exists in orders table';
    END IF;
END $$;

-- Add foreign key constraint (check if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE constraint_name = 'fk_orders_booking' AND table_name = 'orders'
    ) THEN
        ALTER TABLE orders 
        ADD CONSTRAINT fk_orders_booking 
        FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) 
        ON DELETE SET NULL;
        RAISE NOTICE 'Foreign key constraint fk_orders_booking added';
    ELSE
        RAISE NOTICE 'Foreign key constraint fk_orders_booking already exists';
    END IF;
END $$;

-- Add index for performance (check if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes 
        WHERE indexname = 'idx_orders_booking_id'
    ) THEN
        CREATE INDEX idx_orders_booking_id ON orders(booking_id);
        RAISE NOTICE 'Index idx_orders_booking_id created';
    ELSE
        RAISE NOTICE 'Index idx_orders_booking_id already exists';
    END IF;
END $$;

-- Add comment
COMMENT ON COLUMN orders.booking_id IS 'Reference to booking if order was created from a booking with pre-order items';
