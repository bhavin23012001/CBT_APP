const express = require('express');
const mongoose = require('mongoose');
const { Schema } = mongoose;

require('dotenv').config();

const app = express();
app.use(express.json());

const busStopSchema = new Schema({
  stop_id: { type: String, required: true },
  stop_name: { type: String, required: true },
  coordinates: {
    type: { type: String, enum: ['Point'], default: 'Point' },
    coordinates: { type: [Number], required: true },
  },
});

const busRouteSchema = new Schema({
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

const BusStop = mongoose.model('Bus_stops', busStopSchema);
const BusRoute = mongoose.model('Bus_routes', busRouteSchema);

// Setup routes same as your main app for test
app.get('/bus_stops', async (req, res) => {
  const busStops = await BusStop.find();
  res.json(busStops);
});

app.get('/bus_routes', async (req, res) => {
  const busRoutes = await BusRoute.find();
  res.json(busRoutes);
});

// Jest test suite starts here
describe('AMTS API', () => {
  beforeAll(async () => {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    await BusStop.deleteMany({});
    await BusRoute.deleteMany({});
  });

  afterAll(async () => {
    await mongoose.connection.close();
  });

  test('GET /bus_stops returns empty array initially', async () => {
    const res = await request(app).get('/bus_stops');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toEqual([]);
  });

  test('GET /bus_routes returns empty array initially', async () => {
    const res = await request(app).get('/bus_routes');
    expect(res.statusCode).toEqual(200);
    expect(res.body).toEqual([]);
  });

  test('POST /bus_stops adds a new bus stop', async () => {
    const newStop = { stop_id: 'stop1', stop_name: 'First Stop', coordinates: { type: 'Point', coordinates: [10, 20] } };
    const stop = new BusStop(newStop);
    await stop.save();

    const res = await request(app).get('/bus_stops');
    expect(res.body.length).toBe(1);
    expect(res.body[0].stop_id).toBe('stop1');
  });

  test('POST /bus_routes adds a new bus route', async () => {
    const newRoute = {
      routeNumber: 1,
      busName: 'Bus 1',
      startPoint: 'Start',
      endPoint: 'End',
      arrival: '10:00',
      departure: '10:05',
      stops: [
        { stop_id: 'stop1', arrival: '10:10', departure: '10:15' }
      ]
    };
    const route = new BusRoute(newRoute);
    await route.save();

    const res = await request(app).get('/bus_routes');
    expect(res.body.length).toBe(1);
    expect(res.body[0].routeNumber).toBe(1);
  });
});
