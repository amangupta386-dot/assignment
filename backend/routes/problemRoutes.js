const router = require("express").Router();
const auth = require("../middleware/authMiddleware");
const { getAllProblems, createProblem } = require("../controllers/problemController");

// All problems (requires login)
router.get("/", auth, getAllProblems);

// Admin problem creation (for now not protected, you can later add admin check)
router.post("/", createProblem);

module.exports = router;
