// ─── Dummy Charging Station Data ───────────────────────────────
// Connector availability and station isOpen are randomized on each
// call to getStations() / getStationById() so polling shows live changes.

const baseStations = [
  {
    id: "1",
    name: "Purwokerto Core Station",
    address: "Jl. Di Panjaitan no. 3, Purwokerto Selatan",
    hours: "09.00 PM – 12.00 PM",
    latitude: 28.6139,
    longitude: 77.209,
    chargePowerMin: 12000,
    chargePowerMax: 15000,
    distanceKm: 1.6,
    distanceMin: 12,
    plugCount: 8,
    imageUrl: "",
    connectors: [
      { id: "c1", name: "Connector XY1", type: "Type D CCS5-2" },
      { id: "c2", name: "Connector CCD6", type: "Type D CC09-2" },
    ],
  },
  {
    id: "2",
    name: "Green Charge Hub",
    address: "Connaught Place, New Delhi",
    hours: "06.00 AM – 11.00 PM",
    latitude: 28.628,
    longitude: 77.2197,
    chargePowerMin: 10000,
    chargePowerMax: 22000,
    distanceKm: 3.2,
    distanceMin: 18,
    plugCount: 12,
    imageUrl: "",
    connectors: [
      { id: "c3", name: "Connector AB2", type: "Type 2 AC" },
      { id: "c4", name: "Connector DC1", type: "CCS2 DC" },
    ],
  },
  {
    id: "3",
    name: "EV Power Station",
    address: "Karol Bagh, New Delhi",
    hours: "24 Hours",
    latitude: 28.6519,
    longitude: 77.1909,
    chargePowerMin: 15000,
    chargePowerMax: 20000,
    distanceKm: 5.1,
    distanceMin: 25,
    plugCount: 6,
    imageUrl: "",
    connectors: [
      { id: "c5", name: "Connector FT3", type: "Type D CCS5-2" },
      { id: "c6", name: "Connector BHA-98", type: "CHAdeMO" },
    ],
  },
  {
    id: "4",
    name: "Metro EV Point",
    address: "Rajiv Chowk Metro Station, New Delhi",
    hours: "06.00 AM – 10.00 PM",
    latitude: 28.6328,
    longitude: 77.2195,
    chargePowerMin: 11000,
    chargePowerMax: 18000,
    distanceKm: 2.8,
    distanceMin: 15,
    plugCount: 4,
    imageUrl: "",
    connectors: [
      { id: "c7", name: "Connector MV1", type: "Type 2 AC" },
      { id: "c8", name: "Connector MV2", type: "CCS2 DC" },
      { id: "c9", name: "Connector MV3", type: "CHAdeMO" },
    ],
  },
  {
    id: "5",
    name: "SunCharge Plaza",
    address: "Saket District Centre, New Delhi",
    hours: "08.00 AM – 09.00 PM",
    latitude: 28.5244,
    longitude: 77.2167,
    chargePowerMin: 14000,
    chargePowerMax: 25000,
    distanceKm: 8.4,
    distanceMin: 35,
    plugCount: 10,
    imageUrl: "",
    connectors: [
      { id: "c10", name: "Connector SC1", type: "Type D CCS5-2" },
      { id: "c11", name: "Connector SC2", type: "Type 2 AC" },
    ],
  },
];

// ─── Helpers ───────────────────────────────────────────────────

/** Randomize connector availability & station isOpen for a station. */
function randomize(station) {
  const isOpen = Math.random() > 0.15; // 85 % chance open
  const connectors = station.connectors.map((c) => ({
    ...c,
    isAvailable: Math.random() > 0.3, // 70 % chance available
  }));
  return { ...station, isOpen, connectors };
}

/** Return all stations with randomized live fields. */
export function getStations() {
  return baseStations.map(randomize);
}

/** Return a single station by ID with randomized live fields. */
export function getStationById(id) {
  const station = baseStations.find((s) => s.id === id);
  if (!station) return null;
  return randomize(station);
}
