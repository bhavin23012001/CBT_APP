# 🚌 Bus Route Finder (Ahmedabad) - CBT
![Uploading image.png…]()


A Flutter project to help commuters in Ahmedabad find the best bus routes using an interactive map, source-destination selection, and real-time route data.

## 🚀 Features

- 🌆 Select **source & destination** from a list of stops fetched from **MongoDB**
- 🗺️ View **bus stops on map** using `flutter_map`
- 🔎 Find available **routes** between selected stops
- 📅 View **all available schedules**
- 📍 See **only your matching routes** based on selection
- 🛠️ Upcoming: **Route filters**, real-time tracking, favorites

---

## 🧭 App Flow

```mermaid
stateDiagram-v2
    [*] --> SplashScreen
    SplashScreen --> HomeScreen

    HomeScreen --> ViewStopsScreen : View Stops
    HomeScreen --> RoutesScreen : Find Routes
    HomeScreen --> MapScreen : Map (Coming Soon)

    RoutesScreen --> ViewScheduleScreen : View Schedule
    RoutesScreen --> MyRoutesScreen : My Routes
    RoutesScreen --> FilterRoutesScreen : Filter Routes (Upcoming)

🧱 MongoDB Collections

bus_stops
name (string)
latitude (double)
longitude (double)
bus_routes
route_name (string)
stops (list of stop names)

📦 Dependencies
Package	Description
flutter_map	Map using OpenStreetMap
geolocator, geocoding	Location services
mongo_dart	MongoDB integration
provider	State management
flutter_animate, lottie	Animations
http	API calls
dotenv	Secure environment variables
Full list in pubspec.yaml

📂 Project Structure
css
⚙️ Getting Started
Clone the repo

git clone 
cd bus_route_finder
Install dependencies

flutter pub get
Add .env file for MongoDB
Create a file in the root:

MONGO_CONN_URL=mongodb+srv://<username>:<password>@cluster.mongodb.net/myDB
Run the app
flutter run

📸 Screenshots
![Uploading splashscreen.png…]()
![Uploading homescreen.png…]()
![Uploading Stopsscreen.png…]()
![Uploading Mapscreen.png…]()
![Uploading Routesscreen.png…]()
![Uploading Routesdetailscreen.png…]()


🚧 Coming Soon
🧪 Route filters
🔔 Push notifications for route delays
🔐 Login with Firebase
📌 Favorites & history

🤝 Contributing
Pull requests are welcome. For major changes, please open an issue first.


Developed with 💙 using Flutter
