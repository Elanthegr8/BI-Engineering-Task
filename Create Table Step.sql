CREATE DATABASE IF NOT EXISTS sales;
USE sales; 

-- create the main fact table
CREATE TABLE IF NOT EXISTS sales_data (
   sale_id INT,
   customer_id INT NOT NULL,
   store_id INT NOT NULL,
   sale_date DATE NOT NULL,
   sale_amount DECIMAL(10, 2) NOT NULL,
   PRIMARY KEY (sale_id),
   UNIQUE KEY sale_date_unique (sale_date)
)
PARTITION BY RANGE (YEAR(sale_date)) (
   PARTITION p2020 VALUES LESS THAN (2021),
   PARTITION p2021 VALUES LESS THAN (2022),
   PARTITION p2022 VALUES LESS THAN (2023),
   PARTITION pmax  VALUES LESS THAN MAXVALUE
);

/*ALTER TABLE sales_data
   ADD CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
   ADD CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
   ADD CONSTRAINT fk_store FOREIGN KEY (store_id) REFERENCES stores(store_id) ON DELETE RESTRICT;
*/
-- create indexes for performance
-- Checking if index already exists, not compatible for IF EXISTS, so I used a SP
-- Calling the SP after all table creation
/*
DELIMITER $$
CREATE PROCEDURE test_if_index_exists()
BEGIN
    DECLARE sale_date_index INT DEFAULT 0;
    DECLARE sale_sum_index INT DEFAULT 0;

    SELECT COUNT(*) INTO sale_date_index
    FROM information_schema.statistics 
    WHERE table_name = 'sales_data' AND index_name = 'idx_sale_date';
    
    SELECT COUNT(*) INTO sale_sum_index
    FROM information_schema.statistics 
    WHERE table_name = 'daily_sales_summary' AND index_name = 'idx_sale_sum';

    IF sale_date_index > 0 THEN
        DROP INDEX idx_sale_date ON sales_data;
    ELSE
        CREATE INDEX idx_sale_date ON sales_data (sale_date);
    END IF;
    
    IF sale_sum_index > 0 THEN
        DROP INDEX idx_sale_sum ON daily_sales_summary;
    ELSE
        CREATE INDEX idx_sale_sum ON daily_sales_summary (sale_date);
    END IF;
    
END$$
DELIMITER ;
*/
-- create a daily_sales_summary table
CREATE TABLE IF NOT EXISTS daily_sales_summary (
   sale_date DATE PRIMARY KEY,
   total_sales DECIMAL(10, 2) NOT NULL,
   total_transactions INT NOT NULL
) PARTITION BY RANGE (YEAR(sale_date)) (
   PARTITION p2020 VALUES LESS THAN (2021),
   PARTITION p2021 VALUES LESS THAN (2022),
   PARTITION p2022 VALUES LESS THAN (2023),
   PARTITION pmax  VALUES LESS THAN MAXVALUE
);

-- Call the procedure
CALL test_if_index_exists();