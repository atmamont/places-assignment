# Requirements

## Story
As a user, I want to see a venues list around my current location.

## Acceptance criteria

Given an online user
When the user opens the places screen
AND 
the user doesn't have a location tracking permission yet
Then the iOS location trcking permission request is displayed

Given an online user with a location tracking permission
When the user opens places screen
Then the map is displayed with icons on it representing found places within a default radius of 1000m

Given an online user with a location tracking permission and the places screen opened
When the user adjusts the radius setting
Then the updated map with new found places is dispalyed

## Assumptions and decisions we can make ourselves

- We assume user default location is Central Station in Amsterdam so we can populate the initial screen even before the user gives tracking location permission. This could be improved in the future by using any ip-to-location service. This should be working out of the box according to the Foursquare API documentation but I didn't get a proper response respecting my location.

- We do not support offline mode but we build in a way that allows us to use local database or cache in the future.

- We use UIKit for now but we build in a way that allows switching to SwiftUI/AppKit in the future with no changes in the business logic.


# Use cases

## Obtain current location

### Happy path (permission granted)
1. Sytem checks for location tracking permission status to be "Authorized"
2. System delivers current user location 

### Happy path (no permission granted yet)
1. Sytem checks for location tracking permission status to be "Not determined"
2. System performs OS request for permission with "When in use" level that results in a user seeing the system alert. 
3. User grants permission
4. System delivers current user location

### Sad path (get location error)
1. System delivers error

### Sad path (permissions are restricted or denied)
1. System delivers error

## Load places
### Input data
- URL 
- location (latitude, longitude) (Optional)
- radius (Optional)

### Happy path
1. Execute "Load places" command with above data
2. System downloads data from the URL applying optional filters by (latitude, longitude) and radius

### Sad path (no connectivity):
1. System delivers error

### Sad path (server error, invalid data):
1. System delivers error
