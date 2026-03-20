const express = require("express");
const { validate } = require("../middlewares/validate");
const { asyncHandler } = require("../utils/asyncHandler");
const { createProblem, listProblems } = require("../controllers/problemController");
const { createProblemSchema } = require("../utils/validationSchemas");

const router = express.Router();

router.post("/", validate(createProblemSchema), asyncHandler(createProblem));
router.get("/", asyncHandler(listProblems));

module.exports = router;
