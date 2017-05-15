
-- Who booked how many persons on which room and level?
SELECT person.first_name, person.last_name, count(party_composition.person_id) AS booked_persons, person.customer_id, room.id AS room_nr, floor.level FROM booking_period
  INNER JOIN room_configuration ON booking_period.room_configuration_id = room_configuration.id
  INNER JOIN room ON room_configuration.room_id = room.id
  INNER JOIN floor ON room.floor_id = floor.id
  INNER JOIN party ON booking_period.party_id = party.id
  INNER JOIN party_composition ON party.id = party_composition.party_id
  INNER JOIN customer ON party.customer_id = customer.id
  INNER JOIN person ON customer.id = person.customer_id
GROUP BY booking_period.party_id, room_nr, person.first_name, person.last_name
;



-- show which components factor into the price calculation of rooms
SELECT
  room.id AS room_nr,
  room.area,
  floor.level,
  SUM(fa_price.booking) AS facility_booking_price,
  SUM(fa_price.daily) AS facility_daily_price,
  SUM(area_price.booking*fa_price.booking*room.area)/100 AS area_booking_price,
  SUM(area_price.booking*fa_price.daily*room.area)/100 AS area_daily_price,
  SUM(person_price.booking*fa_price.booking) AS person_booking_price,
  SUM(person_price.booking*fa_price.daily) AS person_daily_price
FROM room
  INNER JOIN floor ON room.floor_id = floor.id
  INNER JOIN price_band ON room.price_band_id = price_band.id
  INNER JOIN price AS area_price ON price_band.area_price_id = area_price.id
  INNER JOIN price AS person_price ON price_band.person_price_id = person_price.id
  INNER JOIN room_configuration ON room.id = room_configuration.room_id
  INNER JOIN facility ON room_configuration.facility_id = facility.id
  INNER JOIN price as fa_price ON facility.price_id = fa_price.id
GROUP BY room_id
;