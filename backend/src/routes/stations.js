import { Router } from "express";
import { getStations, getStationById } from "../data/stations.js";

const router = Router();

// GET /api/stations — list all stations
router.get("/", (_req, res) => {
  const stations = getStations();
  res.json({ success: true, data: stations });
});

// GET /api/stations/:id — single station detail
router.get("/:id", (req, res) => {
  const station = getStationById(req.params.id);
  if (!station) {
    return res.status(404).json({ success: false, message: "Station not found" });
  }
  res.json({ success: true, data: station });
});

export default router;
