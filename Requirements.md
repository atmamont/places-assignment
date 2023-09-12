# Requirements

## Main use-case

### Story
As a user, I want to see a venues list around my current location.

### Acceptance criteria

Given a user
When the user opens the places screen
AND 
the user doesn't have a location tracking permission yet
Then the iOS location trcking permission request is displayed

Given a user AND a location tracking permission
When the user opens places screen
Then the map is displayed with icons on it representing found places within a default radius of 1000m

Given a user AND a location tracking permission AND the places screen opened
When the user adjusts the radius setting
Then the updated map with new found places is dispalyed
