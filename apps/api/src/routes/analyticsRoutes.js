const express = require("express");
const { asyncHandler } = require("../utils/asyncHandler");
const { getWeeklyAnalytics, getPatternAnalytics } = require("../controllers/analyticsController");

const router = express.Router();

router.get("/weekly", asyncHandler(getWeeklyAnalytics));
router.get("/patterns", asyncHandler(getPatternAnalytics));

module.exports = router;
