import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import stationRoutes from "./routes/stations.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// ─── Middleware ────────────────────────────────────────────────
app.use(cors());
app.use(express.json());

// ─── Routes ───────────────────────────────────────────────────
app.use("/api/stations", stationRoutes);

// Health check
app.get("/", (_req, res) => {
  res.json({ status: "ok", message: "EV Charging Station API is running" });
});

// ─── Start ────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
