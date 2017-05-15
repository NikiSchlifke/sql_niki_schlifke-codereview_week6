
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


