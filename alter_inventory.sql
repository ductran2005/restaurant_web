USE Restaurant_Ipos;
GO

-- Alter inventory table to match entity
ALTER TABLE inventory ADD current_qty INT NOT NULL DEFAULT 0;
ALTER TABLE inventory ADD reorder_level INT NOT NULL DEFAULT 0;
ALTER TABLE inventory ADD updated_at DATETIME2(0) NOT NULL DEFAULT SYSDATETIME();
ALTER TABLE inventory DROP COLUMN quantity;
ALTER TABLE inventory DROP COLUMN last_updated;
ALTER TABLE inventory ADD CONSTRAINT UQ_inventory_product UNIQUE (product_id);
ALTER TABLE inventory ADD CONSTRAINT CK_inventory_current_qty CHECK (current_qty >= 0);
ALTER TABLE inventory ADD CONSTRAINT CK_inventory_reorder_level CHECK (reorder_level >= 0);

-- Alter inventory_logs table
EXEC sp_rename 'inventory_log', 'inventory_logs';
ALTER TABLE inventory_logs ADD changed_by INT NOT NULL DEFAULT 1;
ALTER TABLE inventory_logs ADD type NVARCHAR(20) NOT NULL DEFAULT 'ADJUST';
ALTER TABLE inventory_logs ADD qty_change INT NOT NULL DEFAULT 0;
ALTER TABLE inventory_logs ADD reason NVARCHAR(255) NULL;
ALTER TABLE inventory_logs ADD created_at DATETIME2(0) NOT NULL DEFAULT SYSDATETIME();
ALTER TABLE inventory_logs DROP COLUMN change_type;
ALTER TABLE inventory_logs DROP COLUMN old_quantity;
ALTER TABLE inventory_logs DROP COLUMN new_quantity;
ALTER TABLE inventory_logs DROP COLUMN change_reason;
ALTER TABLE inventory_logs DROP COLUMN changed_at;
ALTER TABLE inventory_logs ADD CONSTRAINT CK_inventory_logs_type CHECK (type IN ('IN','OUT','ADJUST'));

-- Update constraints
ALTER TABLE inventory_logs DROP CONSTRAINT FK_inventory_log_inventory;
ALTER TABLE inventory_logs ADD CONSTRAINT FK_inventory_logs_inventory FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id);
ALTER TABLE inventory_logs DROP CONSTRAINT FK_inventory_log_users;
ALTER TABLE inventory_logs ADD CONSTRAINT FK_inventory_logs_users FOREIGN KEY (changed_by) REFERENCES users(user_id);
GO