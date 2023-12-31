# API key

There is no API key provided with the code due to security considerations.
To add API key, the `DevSecrets.xcconfig` file should be provided with the `FSQ_TOKEN` key/value and placed at the same folder as `Dev.xcconfig` (`PlacesUIKit/Configuration`)

# Requirements

[Assignment description](Assignment.md)

# User story
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

- We do not support offline mode but we build in a way that allows us to use local database or cache in the future.

- We use UIKit for now but we build in a way that allows switching to SwiftUI/AppKit in the future with no changes in the business logic.

- We assume CoreLocation could be unavailable on some platforms

- We will not introduce any specific errors, we will redirect errors from any layer (networking) to the user interface

- We do not need user location for the whole app session so we only receive it once and then stop location tracking to preserve battery life. This could be easily adusted if needed and if new use-cases require that.

- We ask for "when in use" permission from iOS as we do not need to track user location always and we want to build trust

- We refetch places from server

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

### Sad path (permissions are restricted or denied)
1. System does not use location when performing Foursquare request, relying on its ip-based geolocation detection

## Load places
### Input data
- URL 
- location (latitude, longitude) (Optional)
- radius (Optional)

### Happy path
1. Execute "Load places" command with above data
2. System downloads data from the URL applying optional filters by (latitude, longitude) and radius

### Sad path (no connectivity, server error, invalid data):
1. System delivers error

## UX overview
1. User opens the app that shows "Places" screen right away
2. Places screen has two sections: 
    - a full-screen map (MapKit)
    - a control for adjusting search radius (UISlider)
3. The app shows the map and the icons of places loaded around user location (detected by Foursuare by IP address if no permissions were granted)
4. The map is centered on current user location
5. User sees place name under every pin
6. User can see place address by tapping any pin

# Dependencies diagram

![Diagram](PlacesDependencyChart.drawio.png)

# Potential improvements
1. Testing network layer my mocking responses using `URLProtocol`. 

Examples:
- what apiClient delivers on 200 status code and invalid JSON, etc?
- broken JSON

2. Better network errors handling. `EmptyErrorResponse` error type for `SearchPlacesRequest` doesn't provide a lot of context and `AdyenNetworking` framework itself neither. The next step to improve would be defining minimum set of user-facing errors, checking what kind of errors we receive in real scenario and then adjusting the `handle(:)` method in `RemotePlacesLoader`. This would be a much better way to handle errors and hide their networking-related details behind the predefined text that we can control and localize.

3. [UX] The map screen user experience could be improved by introducing a circular overlay for the time user interacts with a slider. Map could be also zoomed in/out based on continuous updates from the radius slider.

4. UI part could be decomposed further. The map could be extracted in a separate view controller so it can be reusable component in the future. I followed a simple MVC architecture for this screen and every screen component could have it's own MVC.

5. [UX] Map UX could be improved by introducing custom icons for every place type and custom views to render when user taps place pin. My first idea would be to add tappable phone number so anyone could easily tap it and make a reservation call.

6. [UX] We could open the Apple Maps or Google Maps to help users navigate to a selected place.

7. Ask for more places from server as long as a user increases the search radius. It feels like asking 50+ places in one batch could make sense for radiuses > 5km

## Final thoughts

I had a lot of fun working on this assignment. I had never a chance to work on something that is location related so I couldn't just move on using a simple tableview to render results. I opted for some real visual mapping experience, see what challenges I face and how easy or hard would be to find solutions.
I definitely faced a couple of them, specifically with the location permissions and the necessity of building the app flow around that.

I used full TDD technique which doesn't happen often in day-to-day work when all of us have some deadlines that can compromise this approach, it definitely takes longer.

I was able to immediately see the benefits.I discovered two memory leaks, one wich probably would be fixed without having tests as it was very simple and another that was much trickier - when I was assigning view controller method to a location controller update closure (this is not in the final assignment but can be found through a commit history). Apart from this, having logic covered helped me to make some desicions that I was less afraid of to make than usually, knowing that I would immediately see the consequences just by running tests.

This took me a bit more than 5 hours, it feels like it was 6-7. However, i still see a lot of corners that I decided to cut.