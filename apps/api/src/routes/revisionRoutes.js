const express = require("express");
const { asyncHandler } = require("../utils/asyncHandler");
const { getTodayRevisions, completeRevision, failRevision } = require("../controllers/revisionController");

const router = express.Router();

router.get("/today", asyncHandler(getTodayRevisions));
router.post("/:problemId/complete", asyncHandler(completeRevision));
router.post("/:problemId/fail", asyncHandler(failRevision));

module.exports = router;
