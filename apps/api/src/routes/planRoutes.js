const express = require("express");
const { validate } = require("../middlewares/validate");
const { asyncHandler } = require("../utils/asyncHandler");
const { generateWeekPlan, getTodayPlan, markTaskDone } = require("../controllers/planController");
const { weekPlanSchema, markTaskDoneSchema } = require("../utils/validationSchemas");

const router = express.Router();

router.post("/generate-week", validate(weekPlanSchema), asyncHandler(generateWeekPlan));
router.get("/today", asyncHandler(getTodayPlan));
router.post("/today/mark-done", validate(markTaskDoneSchema), asyncHandler(markTaskDone));

module.exports = router;
