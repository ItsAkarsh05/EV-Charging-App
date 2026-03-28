import { Router } from "express";
import { getStations, getStationById } from "../data/stations.js";

const router = Router();

// list all stations
router.get("/", (_req, res) => {
  try {
    const stations = getStations();
    res.json({ success: true, data: stations });
  } catch (err) {
    console.error("Error fetching stations:", err);
    res.status(500).json({ success: false, message: "Failed to fetch stations" });
  }
});

// get one station by id
router.get("/:id", (req, res) => {
  try {
    const station = getStationById(req.params.id);
    if (!station) {
      return res.status(404).json({ success: false, message: "Station not found" });
    }
    res.json({ success: true, data: station });
  } catch (err) {
    console.error(`Error fetching station ${req.params.id}:`, err);
    res.status(500).json({ success: false, message: "Failed to fetch station details" });
  }
});

export default router;
