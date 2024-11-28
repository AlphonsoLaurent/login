--CREATE SCHEMA IF NOT EXISTS login;
CREATE TABLE catalog_type (
                              id SERIAL PRIMARY KEY,
                              name VARCHAR(100) NOT NULL UNIQUE,  -- Ej: "categoría de productos", "tipo de cliente"
                              description TEXT                    -- Descripción opcional del tipo de catálogo
);

CREATE TABLE catalog_item (
                              id SERIAL PRIMARY KEY,
                              catalog_type_id INTEGER REFERENCES catalog_type(id) ON DELETE CASCADE,
                              name VARCHAR(100) NOT NULL,           -- Ej: "Electrónica", "Corporativo", etc.
                              code VARCHAR(50) UNIQUE,              -- Código opcional, útil para referencia rápida
                              description TEXT,                     -- Descripción opcional del elemento
                              active BOOLEAN DEFAULT TRUE,          -- Indicador para activar/desactivar elementos
                              created_at TIMESTAMP DEFAULT NOW(),
                              updated_at TIMESTAMP DEFAULT NOW()
);
CREATE TABLE catalog_item_attribute (
                                        id SERIAL PRIMARY KEY,
                                        catalog_item_id INTEGER REFERENCES catalog_item(id) ON DELETE CASCADE,
                                        attribute_key VARCHAR(50) NOT NULL,    -- Nombre del atributo, ej. "color", "tamaño"
                                        attribute_value VARCHAR(255) NOT NULL, -- Valor del atributo, ej. "rojo", "grande"
                                        created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE catalog_item_relationship (
                                           id SERIAL PRIMARY KEY,
                                           parent_item_id INTEGER REFERENCES catalog_item(id) ON DELETE CASCADE,
                                           child_item_id INTEGER REFERENCES catalog_item(id) ON DELETE CASCADE,
                                           relationship_type VARCHAR(50) DEFAULT 'parent-child', -- Tipo de relación, si se requiere
                                           created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE customer (
                          customer_id SERIAL PRIMARY KEY,
                          name VARCHAR(100) NOT NULL,
                          email VARCHAR(150) UNIQUE NOT NULL,
                          phone VARCHAR(15),
                          registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table service_address
CREATE TABLE address (
                         address_id SERIAL PRIMARY KEY,
                         customer_id INT NOT NULL,
                         address VARCHAR(255) NOT NULL,
                         apt_suite VARCHAR(50),
                         city VARCHAR(100) NOT NULL,
                         state VARCHAR(50) NOT NULL,
                         postal_code VARCHAR(10) NOT NULL,
                         FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE
);

CREATE TABLE service_customer (
                                  service_customer_id SERIAL PRIMARY KEY,
                                  customer_id INT NOT NULL,
                                  num_bedrooms_id INT NOT NULL,
                                  num_bathrooms_id INT NOT NULL,
                                  date_cleaning DATE NOT NULL,
                                  time_slot_id INT NOT NULL,
                                  payment_method_id INT NOT NULL,
                                  frequency_id INT NOT NULL,
                                  home_access_id INT NOT NULL,
                                  referral_source_id INT NULL,
                                  additional_instructions text,
                                  tip DECIMAL(10, 2),
                                  total DECIMAL(10, 2),
                                  discount_id INT,
                                  FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
                                  FOREIGN KEY (num_bedrooms_id) REFERENCES catalog_item(id) ON DELETE RESTRICT,
                                  FOREIGN KEY (num_bathrooms_id) REFERENCES catalog_item(id) ON DELETE RESTRICT,
                                  FOREIGN KEY (time_slot_id) REFERENCES catalog_item(id) ON DELETE RESTRICT,
                                  FOREIGN KEY (payment_method_id) REFERENCES catalog_item(id) ON DELETE RESTRICT,
                                  FOREIGN KEY (frequency_id) REFERENCES catalog_item(id) ON DELETE RESTRICT,
                                  FOREIGN KEY (home_access_id) REFERENCES catalog_item(id) ON DELETE RESTRICT,
                                  FOREIGN KEY (referral_source_id) REFERENCES catalog_item(id) ON DELETE RESTRICT,
                                  FOREIGN KEY (discount_id) REFERENCES discount(discount_id) ON DELETE SET NULL
);

CREATE TABLE service_customer_extra (
                                        service_customer_id INT NOT NULL,
                                        extra_service_id INT NOT NULL,
                                        FOREIGN KEY (service_customer_id) REFERENCES service_customer(service_customer_id) ON DELETE CASCADE,
                                        FOREIGN KEY (extra_service_id) REFERENCES catalog_item(id) ON DELETE RESTRICT
);

-- Table discount
CREATE TABLE discount (
                          discount_id SERIAL PRIMARY KEY,
                          code VARCHAR(50) UNIQUE NOT NULL,
                          percentage DECIMAL(5, 2) NOT NULL CHECK (percentage BETWEEN 0 AND 100),
                          valid_until DATE
);

-- Table subscription
CREATE TABLE subscription (
                              subscription_id SERIAL PRIMARY KEY,
                              customer_id INT NOT NULL,
                              plan_id INT NOT NULL,
                              status_id INT NOT NULL,
                              start_date DATE NOT NULL,
                              end_date DATE,
                              frequency_id INT NOT NULL,
                              FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
                              FOREIGN KEY (status_id) REFERENCES catalog_item(id) ON DELETE CASCADE,
                              FOREIGN KEY (frequency_id) REFERENCES catalog_item(id) ON DELETE CASCADE,
                              FOREIGN KEY (plan_id) REFERENCES catalog_item(id) ON DELETE RESTRICT
);

-- Table scheduled_service
CREATE TABLE scheduled (
                           scheduled_id SERIAL PRIMARY KEY,
                           customer_id INT NOT NULL,
                           service_id INT NOT NULL,
                           address_id INT NOT NULL,
                           service_date DATE NOT NULL,
                           service_time TIME NOT NULL,
                           frequency_id INT NOT NULL,
                           additional_instructions TEXT,
                           discount_id INT,
                           tip DECIMAL(10, 2),
                           FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
                           FOREIGN KEY (service_id) REFERENCES catalog_item(id) ON DELETE RESTRICT,
                           FOREIGN KEY (frequency_id) REFERENCES catalog_item(id) ON DELETE RESTRICT,
                           FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE CASCADE,
                           FOREIGN KEY (discount_id) REFERENCES discount(discount_id) ON DELETE SET NULL
);

-- Table extra_service_detail
CREATE TABLE detail (
                        detail_id SERIAL PRIMARY KEY,
                        scheduled_id INT NOT NULL,
                        extra_id INT NOT NULL,
                        FOREIGN KEY (scheduled_id) REFERENCES scheduled(scheduled_id) ON DELETE CASCADE,
                        FOREIGN KEY (extra_id) REFERENCES catalog_item(id) ON DELETE RESTRICT
);

-- Table automated_email
CREATE TABLE automated_email (
                                 email_id SERIAL PRIMARY KEY,
                                 customer_id INT NOT NULL,
                                 scheduled_id INT,
                                 email_type_id INT NOT NULL,
                                 sent_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                 FOREIGN KEY (email_type_id) REFERENCES catalog_item(id) ON DELETE CASCADE,
                                 FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE CASCADE,
                                 FOREIGN KEY (scheduled_id) REFERENCES scheduled(scheduled_id) ON DELETE SET NULL
);

-- Table payment
CREATE TABLE payment (
                         payment_id SERIAL PRIMARY KEY,
                         scheduled_id INT NOT NULL,
                         amount DECIMAL(10, 2) NOT NULL,
                         payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                         method_id INT NOT NULL,
                         FOREIGN KEY (scheduled_id) REFERENCES scheduled(scheduled_id) ON DELETE cascade,
                         FOREIGN KEY (method_id) REFERENCES catalog_item(id) ON DELETE CASCADE
);

-- Additional indexes to improve queries
CREATE INDEX idx_customer_email ON customer(email);
CREATE INDEX idx_scheduled_customer_date ON scheduled(customer_id, service_date);





SET session_replication_role = 'replica';

-- Insertar registros manualmente
INSERT INTO catalog_type (id, "name", description) VALUES (1, 'CLEANING_SERVICE', 'Base cleaning services offered by the company');
INSERT INTO catalog_type (id, "name", description) VALUES (2, 'EXTRA_SERVICE', 'Additional services that can be added to the cleaning service');
INSERT INTO catalog_type (id, "name", description) VALUES (3, 'PRICE', 'Price configuration for services and extras');
INSERT INTO catalog_type (id, "name", description) VALUES (4, 'SUBSCRIPTION_STATUS', 'Status options for subscriptions');
INSERT INTO catalog_type (id, "name", description) VALUES (5, 'SERVICE_FREQUENCY', 'Frequency of cleaning services');
INSERT INTO catalog_type (id, "name", description) VALUES (6, 'CONTACT_SOURCE', 'Source of contact for customers');
INSERT INTO catalog_type (id, "name", description) VALUES (7, 'EMAIL_TYPE', 'Types of emails sent to customers');
INSERT INTO catalog_type (id, "name", description) VALUES (8, 'PAYMENT_METHOD', 'Methods of payment accepted by the business');
INSERT INTO catalog_type (id, "name", description) VALUES (9, 'HOUSE_CLEANING', 'Base cleaning services offered by the house');
INSERT INTO catalog_type (id, "name", description) VALUES (10, 'SERVICE_BEDROOM', 'BEDROOM');
INSERT INTO catalog_type (id, "name", description) VALUES (11, 'SERVICE_BATHROOM', 'BATHROOM');
INSERT INTO catalog_type (id, "name", description) VALUES (12, 'TIME_SLOTS', 'A time slot is a specific period of time that is allocated for a particular activity or event');
INSERT INTO catalog_type (id, "name", description) VALUES (13, 'ACCESS_PROPERTY', 'How will we access your property');
INSERT INTO catalog_type (id, "name", description) VALUES (14, 'REFERRAL_SOURCE', 'How did you hear about us?');

-- Rehabilitar restricciones y secuencias
SET session_replication_role = 'origin';


SET session_replication_role = 'replica';
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(1, 1, 'STD_CLEAN', 'Standard Cleaning', 'Basic cleaning service covering essential areas', true, '2024-11-06 00:42:06.548', '2024-11-06 00:42:06.548');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(2, 1, 'DEEP_CLEAN', 'Deep Cleaning', 'Detailed cleaning for all areas, including hard-to-reach places', true, '2024-11-06 00:42:06.548', '2024-11-06 00:42:06.548');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(16, 4, 'ACTIVE', 'Active', 'Currently active subscription', true, '2024-11-06 00:42:06.553', '2024-11-06 00:42:06.553');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(17, 4, 'CANCELLED', 'Cancelled', 'Cancelled subscription', true, '2024-11-06 00:42:06.553', '2024-11-06 00:42:06.553');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(18, 4, 'PENDING', 'Pending', 'Pending subscription approval or payment', true, '2024-11-06 00:42:06.553', '2024-11-06 00:42:06.553');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(24, 6, 'ADVERTISEMENT', 'Advertisement', 'Customer reached through advertisement', true, '2024-11-06 00:42:06.561', '2024-11-06 00:42:06.561');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(25, 6, 'REFERRAL', 'Referral', 'Customer referred by another customer', true, '2024-11-06 00:42:06.561', '2024-11-06 00:42:06.561');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(26, 6, 'INTERNET', 'Internet', 'Customer found us online', true, '2024-11-06 00:42:06.561', '2024-11-06 00:42:06.561');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(27, 6, 'OTHER', 'Other', 'Other sources of contact', true, '2024-11-06 00:42:06.561', '2024-11-06 00:42:06.561');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(28, 7, 'CONFIRMATION', 'Confirmation', 'Email sent for confirming actions', true, '2024-11-06 00:42:06.563', '2024-11-06 00:42:06.563');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(29, 7, 'REMINDER', 'Reminder', 'Email sent as a reminder', true, '2024-11-06 00:42:06.563', '2024-11-06 00:42:06.563');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(30, 7, 'OTHER', 'Other', 'Other types of emails', true, '2024-11-06 00:42:06.563', '2024-11-06 00:42:06.563');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(40, 11, 'BATHROOM1', '1 Bathroom', 'assets/icons/flat/bathroom.png', true, '2024-11-16 19:42:17.928', '2024-11-16 19:42:17.928');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(41, 11, 'BATHROOM2', '2 Bathrooms', 'assets/icons/flat/bathroom.png', true, '2024-11-16 19:42:50.531', '2024-11-16 19:42:50.531');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(42, 11, 'BATHROOM3', '3 Bathrooms', 'assets/icons/flat/bathroom.png', true, '2024-11-16 19:43:01.908', '2024-11-16 19:43:01.908');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(43, 11, 'BATHROOM4', '4 Bathrooms', 'assets/icons/flat/bathroom.png', true, '2024-11-16 19:43:13.926', '2024-11-16 19:43:13.926');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(44, 11, 'BATHROOM5', '5 Bathrooms', 'assets/icons/flat/bathroom.png', true, '2024-11-16 19:43:30.430', '2024-11-16 19:43:30.430');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(45, 11, 'BATHROOM6', '6 Bathrooms', 'assets/icons/flat/bathroom.png', true, '2024-11-16 19:43:45.008', '2024-11-16 19:43:45.008');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(48, 12, '10_12PM', '10:00AM - 12:00PM', 'assets/icons/flat/clock1012.png', true, '2024-11-17 13:46:44.089', '2024-11-17 13:46:44.089');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(49, 12, '12_02PM', '12:00PM - 02:00PM', 'assets/icons/flat/clock1202.png', true, '2024-11-17 13:47:39.998', '2024-11-17 13:47:39.998');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(50, 12, '02_04PM', '02:00PM - 04:00PM', 'assets/icons/flat/clock0204.png', true, '2024-11-17 13:48:05.305', '2024-11-17 13:48:05.305');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(54, 14, 'GOOGLE', 'Google', 'assets/icons/flat/google.png', true, '2024-11-17 14:36:44.139', '2024-11-17 14:36:44.139');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(55, 14, 'FRIENDS', 'Friends or Family', 'assets/icons/flat/friends.png', true, '2024-11-17 14:36:56.930', '2024-11-17 14:36:56.930');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(19, 5, 'ONE_TIME', 'Frequency: One-time', 'assets/icons/flat/once.png', true, '2024-11-06 00:42:06.554', '2024-11-06 00:42:06.554');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(20, 5, 'WEEKLY', 'Frequency: Weekly', 'assets/icons/flat/weekly.png', true, '2024-11-06 00:42:06.554', '2024-11-06 00:42:06.554');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(21, 5, 'BIWEEKLY', 'Frequency: Biweekly', 'assets/icons/flat/biweekly.png', true, '2024-11-06 00:42:06.554', '2024-11-06 00:42:06.554');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(56, 14, 'OTHERS', 'Others', 'assets/icons/flat/others.png', true, '2024-11-17 14:37:08.327', '2024-11-17 14:37:08.327');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(47, 12, '8_10AM', '08:00AM - 10:00AM', 'assets/icons/flat/clock0810.png', true, '2024-11-17 13:46:02.222', '2024-11-17 13:46:02.222');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(31, 8, 'CARD', 'Card', 'assets/icons/flat/card_c.png', true, '2024-11-06 00:42:06.564', '2024-11-06 00:42:06.564');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(22, 5, 'MONTHLY', 'Frequency: Monthly', 'assets/icons/flat/monthly.png', true, '2024-11-06 00:42:06.554', '2024-11-06 00:42:06.554');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(3, 1, 'MOVE_OUT', 'Move-out Cleaning', 'assets/icons/flat/move-out.png', true, '2024-11-06 00:42:06.548', '2024-11-06 00:42:06.548');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(4, 2, 'WIN_CLEAN', 'Window Cleaning', 'assets/icons/flat/windows.png', true, '2024-11-06 00:42:06.551', '2024-11-06 00:42:06.551');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(6, 2, 'FRIDGE_CLEAN', 'Inside the Fridge', 'assets/icons/flat/fridge.png', true, '2024-11-06 00:42:06.551', '2024-11-06 00:42:06.551');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(7, 2, 'OVEN_CLEAN', 'Inside the Oven', 'assets/icons/flat/oven.png', true, '2024-11-06 00:42:06.551', '2024-11-06 00:42:06.551');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(8, 2, 'LAUNDRY', 'Load of Laundry', 'assets/icons/flat/laundry.png', true, '2024-11-06 00:42:06.551', '2024-11-06 00:42:06.551');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(9, 2, 'MOVE_IN_OUT', 'Move In / Move Out (Vacant)', 'assets/icons/flat/move-out.png', true, '2024-11-06 00:42:06.551', '2024-11-06 00:42:06.551');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(11, 2, 'OFFICE_CLEAN', 'Office', 'assets/icons/flat/office.png', true, '2024-11-06 00:42:06.551', '2024-11-06 00:42:06.551');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(13, 2, 'PET_HAIR', 'Pet Hair Removal', 'assets/icons/flat/pet.png', true, '2024-11-06 00:42:06.551', '2024-11-06 00:42:06.551');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(14, 2, 'GREEN_CLEAN', 'Green Clean', 'assets/icons/flat/green-clean.png', true, '2024-11-06 00:42:06.551', '2024-11-06 00:42:06.551');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(15, 2, 'WALL_CLEAN', 'Wall', 'assets/icons/flat/wall.png', true, '2024-11-06 00:42:06.551', '2024-11-06 00:42:06.551');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(10, 2, 'SECOND_LIVING', '2nd Living Room', 'assets/icons/flat/living-room.png', true, '2024-11-06 00:42:06.551', '2024-11-06 00:42:06.551');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(12, 2, 'WINDOWS_CLEAN', 'Outside Windows', 'assets/icons/flat/windows.png', true, '2024-11-06 00:42:06.551', '2024-11-06 00:42:06.551');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(46, 2, 'MICROWAVE', 'Microwave', 'assets/icons/flat/microwave.png', true, '2024-11-16 22:40:28.819', '2024-11-16 22:40:28.819');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(5, 2, 'CARP_CLEAN', 'Carpet Cleaning', 'assets/icons/flat/carpet.png', true, '2024-11-06 00:42:06.551', '2024-11-06 00:42:06.551');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(34, 10, 'BEDROOM1', '1 Bedroom', 'assets/icons/flat/bedroom.png', true, '2024-11-16 19:31:30.267', '2024-11-16 19:31:30.267');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(35, 10, 'BEDROOM2', '2 Bedrooms', 'assets/icons/flat/bedroom.png', true, '2024-11-16 19:32:25.570', '2024-11-16 19:32:25.570');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(36, 10, 'BEDROOM3', '3 Bedrooms', 'assets/icons/flat/bedroom.png', true, '2024-11-16 19:32:38.796', '2024-11-16 19:32:38.796');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(37, 10, 'BEDROOM4', '4 Bedrooms', 'assets/icons/flat/bedroom.png', true, '2024-11-16 19:35:19.485', '2024-11-16 19:35:19.485');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(38, 10, 'BEDROOM5', '5 Bedrooms', 'assets/icons/flat/bedroom.png', true, '2024-11-16 19:38:07.033', '2024-11-16 19:38:07.033');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(39, 10, 'BEDROOM6', '6 Bedrooms', 'assets/icons/flat/bedroom.png', true, '2024-11-16 19:38:41.857', '2024-11-16 19:38:41.857');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(51, 13, 'ACCESS_CODE', 'I will provide an access code', '', true, '2024-11-17 14:07:31.812', '2024-11-17 14:07:31.812');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(52, 13, 'LEAVE_KEY', 'Leave a key with us', '', true, '2024-11-17 14:07:44.175', '2024-11-17 14:07:44.175');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(53, 13, 'BE_HOME', 'I will be home', '', true, '2024-11-17 14:07:54.584', '2024-11-17 14:07:54.584');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(32, 8, 'PAYPAL', 'Paypal', 'assets/icons/flat/paypal_c.png', true, '2024-11-06 00:42:06.564', '2024-11-06 00:42:06.564');
INSERT INTO catalog_item (id, catalog_type_id, code, "name", description, active, created_at, updated_at) VALUES(33, 8, 'CASH', 'Cash', 'assets/icons/flat/cash_c.png', true, '2024-11-06 00:42:06.564', '2024-11-06 00:42:06.564');
SET session_replication_role = 'origin';

SET session_replication_role = 'replica';
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(1, 6, 'price', '20.00', '2024-11-06 00:42:06.565');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(2, 7, 'price', '20.00', '2024-11-06 00:42:06.565');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(3, 8, 'price', '15.00', '2024-11-06 00:42:06.565');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(5, 9, 'price', '100.00', '2024-11-06 00:42:06.565');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(6, 10, 'price', '25.00', '2024-11-06 00:42:06.565');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(7, 11, 'price', '25.00', '2024-11-06 00:42:06.565');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(8, 12, 'price', '15.00', '2024-11-06 00:42:06.565');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(9, 13, 'price', '20.00', '2024-11-06 00:42:06.565');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(10, 14, 'price', '30.00', '2024-11-06 00:42:06.565');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(11, 15, 'price', '25.00', '2024-11-06 00:42:06.565');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(12, 1, 'price', '100', '2024-11-11 23:37:34.684');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(13, 3, 'price', '250', '2024-11-11 23:37:34.684');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(4, 2, 'price', '200', '2024-11-06 00:42:06.565');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(14, 34, 'price', '100', '2024-11-16 19:31:30.267');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(15, 35, 'price', '110', '2024-11-16 19:32:25.570');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(16, 36, 'price', '150', '2024-11-16 19:32:38.796');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(17, 37, 'price', '185', '2024-11-16 19:35:19.485');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(18, 38, 'price', '255', '2024-11-16 19:38:07.033');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(19, 39, 'price', '305', '2024-11-16 19:38:41.857');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(20, 40, 'price', '30', '2024-11-16 19:42:17.928');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(21, 41, 'price', '60', '2024-11-16 19:42:50.531');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(22, 42, 'price', '90', '2024-11-16 19:43:01.908');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(23, 43, 'price', '120', '2024-11-16 19:43:13.926');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(24, 44, 'price', '150', '2024-11-16 19:43:30.430');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(25, 45, 'price', '180', '2024-11-16 19:43:45.008');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(26, 46, 'price', '15', '2024-11-16 22:40:28.819');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(27, 19, 'porcentage', '0', '2024-11-06 00:42:06.565');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(28, 20, 'porcentage', '20', '2024-11-16 19:31:30.267');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(29, 21, 'porcentage', '15', '2024-11-16 19:32:25.570');
INSERT INTO catalog_item_attribute (id, catalog_item_id, attribute_key, attribute_value, created_at) VALUES(30, 22, 'porcentage', '5', '2024-11-16 19:32:38.796');
SET session_replication_role = 'origin';
