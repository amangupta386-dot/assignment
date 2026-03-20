const express = require("express");
const { validate } = require("../middlewares/validate");
const { asyncHandler } = require("../utils/asyncHandler");
const { upsertWeeklyGoal, getCurrentWeeklyGoal } = require("../controllers/goalController");
const { weeklyGoalSchema } = require("../utils/validationSchemas");

const router = express.Router();

router.post("/weekly", validate(weeklyGoalSchema), asyncHandler(upsertWeeklyGoal));
router.get("/weekly/current", asyncHandler(getCurrentWeeklyGoal));

module.exports = router;
