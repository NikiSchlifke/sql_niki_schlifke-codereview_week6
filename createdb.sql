DROP DATABASE IF EXISTS hotel;
CREATE DATABASE IF NOT EXISTS hotel CHARACTER SET utf8 COLLATE utf8_unicode_ci;
USE hotel;
-- Price that can be attached to various items
CREATE TABLE IF NOT EXISTS price
(
  id      INT PRIMARY KEY AUTO_INCREMENT,
  name    VARCHAR(255),
  booking DECIMAL         DEFAULT 0,
  daily   DECIMAL         DEFAULT 0
);

-- A price band that a room has to be in.
CREATE TABLE IF NOT EXISTS price_band
(
  id               INT PRIMARY KEY AUTO_INCREMENT,
  name             VARCHAR(255) NOT NULL UNIQUE,
  booking_price_id INT,
  person_price_id  INT,
  area_price_id    INT
);

-- Facility for instance bed, mini-fridge, balcony
CREATE TABLE IF NOT EXISTS facility
(
  id       INT PRIMARY KEY AUTO_INCREMENT,
  name     VARCHAR(255) NOT NULL UNIQUE,
  price_id INT          NOT NULL
);

-- Hotel room with just the area
CREATE TABLE IF NOT EXISTS room
(
  id            INT PRIMARY KEY AUTO_INCREMENT,
  area          DECIMAL NOT NULL,
  floor_id      INT,
  price_band_id INT
);

-- A hotel room floor
CREATE TABLE IF NOT EXISTS floor
(
  id       INT PRIMARY KEY AUTO_INCREMENT,
  level    INT NOT NULL,
  name     VARCHAR(255),
  price_id INT
);

-- Which facility is present at which room
CREATE TABLE IF NOT EXISTS room_configuration
(
  id          INT PRIMARY KEY AUTO_INCREMENT,
  quantiy     INT             DEFAULT 1,
  start_time  DATETIME        DEFAULT NOW(),
  end_time    DATETIME,
  facility_id INT,
  room_id     INT
);

-- A time period during which a certain room configuration is booked
CREATE TABLE IF NOT EXISTS booking_period
(
  id                    INT PRIMARY KEY AUTO_INCREMENT,
  start_date            DATETIME NOT NULL,
  end_date              DATETIME NOT NULL,
  room_configuration_id INT,
  party_id              INT
);

-- A person with just intrinsic data, can be a customer
CREATE TABLE IF NOT EXISTS person
(
  id          INT PRIMARY KEY AUTO_INCREMENT,
  first_name  VARCHAR(255) NOT NULL,
  last_name   VARCHAR(255) NOT NULL,
  birth_day   DATE,
  contact_id INT,
  customer_id INT UNIQUE
);

-- A legal entity that can be a customer
CREATE TABLE IF NOT EXISTS company
(
  id          INT PRIMARY KEY AUTO_INCREMENT,
  name        VARCHAR(255) NOT NULL,
  contact_id INT,
  customer_id INT UNIQUE
);

-- A customer is the entity responsible for parties and is billed
CREATE TABLE IF NOT EXISTS customer
(
  id         INT PRIMARY KEY AUTO_INCREMENT,
  role  VARCHAR(255),
  discount DECIMAL
);

-- Data of how a customer can be reached
CREATE TABLE IF NOT EXISTS contact
(
  id        INT PRIMARY KEY AUTO_INCREMENT,
  address   VARCHAR(255),
  telephone VARCHAR(255),
  email     VARCHAR(255),
  region_id INT
);

-- A region where a contact can be found in
CREATE TABLE IF NOT EXISTS region (
  id INT PRIMARY KEY AUTO_INCREMENT,
  city      VARCHAR(255),
  state    VARCHAR(255),
  zip       VARCHAR(255),
  country   VARCHAR(255)
);

-- A party is a collection of people
CREATE TABLE IF NOT EXISTS party
(
  id          INT PRIMARY KEY AUTO_INCREMENT,
  name        VARCHAR(255),
  customer_id INT
);

-- a party can have several persons and each person can be in different parties
CREATE TABLE IF NOT EXISTS party_composition
(
  id        INT PRIMARY KEY AUTO_INCREMENT,
  person_id INT,
  party_id  INT
);

-- A service item for things like room service, etc
CREATE TABLE IF NOT EXISTS service
(
  id       INT PRIMARY KEY AUTO_INCREMENT,
  name     VARCHAR(255) NOT NULL,
  price_id INT          NOT NULL
);

-- A service bill containing services
CREATE TABLE IF NOT EXISTS service_bill
(
  id         INT PRIMARY KEY  AUTO_INCREMENT,
  service_id INT NOT NULL,
  booking_id INT NOT NULL
);

-- An item on a restaurant order
CREATE TABLE IF NOT EXISTS restaurant_item
(
  id       INT PRIMARY KEY AUTO_INCREMENT,
  name     VARCHAR(255) NOT NULL,
  type     VARCHAR(255),
  price_id INT
);

-- A restaurant order consisting of several items it can be associated with a booking period and/or a customer
CREATE TABLE IF NOT EXISTS restaurant_order
(
  id                INT PRIMARY KEY AUTO_INCREMENT,
  type              VARCHAR(255),
  time              DATETIME        DEFAULT NOW(),
  booking_period_id INT,
  customer_id INT
);

-- Which items are on which order
CREATE TABLE IF NOT EXISTS restaurant_order_composition
(
  id                  INT PRIMARY KEY AUTO_INCREMENT,
  restaurant_order_id INT NOT NULL,
  restaurant_item_id  INT NOT NULL
);

-- foreign key constraints

-- The the price band contains three prices for booking, for each person and for each square meter
ALTER TABLE price_band
  ADD CONSTRAINT price_band_booking_price FOREIGN KEY (booking_price_id) REFERENCES price (id),
  ADD CONSTRAINT price_band_person_price FOREIGN KEY (person_price_id) REFERENCES price (id),
  ADD CONSTRAINT price_band_area_price FOREIGN KEY (area_price_id) REFERENCES price (id);

-- A facility has a associated price
ALTER TABLE facility
  ADD CONSTRAINT facility_price FOREIGN KEY (price_id) REFERENCES price (id);

-- A room is on a designated floor and it has a price-band associated with it
ALTER TABLE room
  ADD CONSTRAINT room_floor FOREIGN KEY (floor_id) REFERENCES floor (id),
  ADD CONSTRAINT room_price_band FOREIGN KEY (price_band_id) REFERENCES price_band (id);

-- A floor can have a price premium that is added to the regular price
ALTER TABLE floor
  ADD CONSTRAINT floor_price FOREIGN KEY (price_id) REFERENCES price (id);

-- A room configuration has a room and a facility associated with it.
ALTER TABLE room_configuration
  ADD CONSTRAINT room_configuration_room FOREIGN KEY (room_id) REFERENCES room (id),
  ADD CONSTRAINT room_configuration_facility FOREIGN KEY (facility_id) REFERENCES facility (id);

-- A booking period has a room configuration and a party associated with it.
ALTER TABLE booking_period
  ADD CONSTRAINT booking_period_room_configuration FOREIGN KEY (room_configuration_id) REFERENCES room_configuration (id),
  ADD CONSTRAINT booking_period_party FOREIGN KEY (party_id) REFERENCES party (id);

-- A person can be a customer
ALTER TABLE person
  ADD CONSTRAINT person_contact FOREIGN KEY (contact_id) REFERENCES contact (id),
  ADD CONSTRAINT person_customer FOREIGN KEY (customer_id) REFERENCES customer (id);


-- A company can be a customer too and can have a representative
ALTER TABLE company
  ADD CONSTRAINT company_contact FOREIGN KEY (contact_id) REFERENCES contact (id),
  ADD CONSTRAINT company_customer FOREIGN KEY (customer_id) REFERENCES customer (id);


-- A contact can be in a specified region
ALTER TABLE contact
    ADD CONSTRAINT contact_region FOREIGN KEY (region_id) REFERENCES region (id);

-- A party belongs to one customer who will pay it's bill
ALTER TABLE party
  ADD CONSTRAINT party_customer FOREIGN KEY (customer_id) REFERENCES customer (id);

-- A party is composed of people
ALTER TABLE party_composition
  ADD CONSTRAINT party_composition_person FOREIGN KEY (person_id) REFERENCES person (id),
  ADD CONSTRAINT party_composition_party FOREIGN KEY (party_id) REFERENCES party (id);

-- A service has a price
ALTER TABLE service
  ADD CONSTRAINT service_price FOREIGN KEY (price_id) REFERENCES price (id);

-- A service-bill item connects a service to a booking-period
ALTER TABLE service_bill
  ADD CONSTRAINT service_bill_service FOREIGN KEY (service_id) REFERENCES service (id),
  ADD CONSTRAINT service_booking_period FOREIGN KEY (booking_id) REFERENCES booking_period (id);

-- A restaurant item has a price
ALTER TABLE restaurant_item
  ADD CONSTRAINT restaurant_item_price FOREIGN KEY (price_id) REFERENCES price (id);

-- A restaurant order can be associated with a booking period
ALTER TABLE restaurant_order
  ADD CONSTRAINT restaurant_order_booking_period FOREIGN KEY (booking_period_id) REFERENCES booking_period (id),
  ADD CONSTRAINT restaurant_order_customer FOREIGN KEY (customer_id) REFERENCES customer (id);

-- A restaurant order is composed using restaurant items
ALTER TABLE restaurant_order_composition
  ADD CONSTRAINT restaurant_order_composition_restaurant_items FOREIGN KEY (restaurant_item_id) REFERENCES restaurant_item (id),
  ADD CONSTRAINT restaurant_order_composition_restaurant_order FOREIGN KEY (restaurant_order_id) REFERENCES restaurant_order (id);


