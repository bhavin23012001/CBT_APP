const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
require("dotenv").config(); // Load environment variables

const app = express();
const port = process.env.PORT || 3000;

// Database Connection
mongoose.connect(process.env.MONGO_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
}).then(() => {
  console.log("Connected to MongoDB");
}).catch((error) => {
  console.error("MongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection errorMongoDB connection error:", error);
});

// Middleware
app.use(cors());
app.use(express.json());

// Bus Stop Schema (for the bus_stops collection)
const busStopSchema = new mongoose.Schema({
  stop_id: { type: String, required: true },
  stop_name: { type: String, required: true },
  coordinates: {
    type: { type: String, enum: ["Point"], default: "Point" },
    coordinates: { type: [Number], required: true },
  },
});

// Bus Route Schema (for the bus_routes collection)
const busRouteSchema = new mongoose.Schema({
  routeNumber: { type: Number, required: true },
  busName: { type: String, required: true },
  startPoint: { type: String, required: true },
  endPoint: { type: String, required: true },
  arrival: { type: String, required: true },
  departure: { type: String, required: true },
  stops: [
    {
      stop_id: { type: String, required: true },
      arrival: { type: String, required: true },
      departure: { type: String, required: true }
    }
  ]
});

// Define Models for both collections
const BusStop = mongoose.model("Bus_stops", busStopSchema);
const BusRoute = mongoose.model("Bus_routes", busRouteSchema);

// Routes
app.get("/", (req, res) => {
  res.send("AMTS API Running...");
});

// Fetch Bus Stops (Query with optional stopId)
app.get("/bus_stops", async (req, res) => {
  try {
    const stopId = req.query.stopId;
    const busStops = stopId
      ? await BusStop.find({ stop_id: stopId })
      : await BusStop.find();
    res.json(busStops);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add a new Bus Stop (POST Request)
app.post("/bus_stops", async (req, res) => {
  try {
    const newBusStop = new BusStop(req.body);
    await newBusStop.save();
    res.status(201).json(newBusStop);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Fetch Bus Routes (Query with optional routeNumber or stopId)
app.get("/bus_routes", async (req, res) => {
  try {
    const routeNumber = req.query.routeNumber;
    const stopId = req.query.stopId;

    let filter = {};

    if (routeNumber) filter.routeNumber = routeNumber;
    if (stopId) filter['stops.stop_id'] = stopId;

    const busRoutes = await BusRoute.find(filter);
    res.json(busRoutes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Add a new Bus Route (POST Request)
app.post("/bus_routes", async (req, res) => {
  try {
    const newBusRoute = new BusRoute(req.body);
    await newBusRoute.save();
    res.status(201).json(newBusRoute);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start Server
app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
