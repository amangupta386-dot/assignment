const router = require("express").Router();
const auth = require("../middleware/authMiddleware");
const { updateProgress, getProgress } = require("../controllers/progessController");

router.get("/", auth, getProgress);
router.post("/update", auth, updateProgress);

module.exports = router;
