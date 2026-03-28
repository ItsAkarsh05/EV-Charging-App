import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import stationRoutes from "./routes/stations.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// middleware
app.use(cors());
app.use(express.json());

// routes
app.use("/api/stations", stationRoutes);

// health check
app.get("/", (_req, res) => {
  res.json({ status: "ok", message: "EV Charging Station API is running" });
});

// 404 handler
app.use((_req, res) => {
  res.status(404).json({ success: false, message: "Route not found" });
});

// catch-all error handler
app.use((err, _req, res, _next) => {
  console.error("Unhandled error:", err);
  res.status(500).json({ success: false, message: "Internal server error" });
});

// start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
