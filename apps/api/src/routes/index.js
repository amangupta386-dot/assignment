const express = require("express");
const problemRoutes = require("./problemRoutes");
const revisionRoutes = require("./revisionRoutes");
const planRoutes = require("./planRoutes");
const goalRoutes = require("./goalRoutes");
const analyticsRoutes = require("./analyticsRoutes");

const router = express.Router();

router.use("/problems", problemRoutes);
router.use("/revisions", revisionRoutes);
router.use("/plans", planRoutes);
router.use("/goals", goalRoutes);
router.use("/analytics", analyticsRoutes);

module.exports = router;
