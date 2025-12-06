const User = require("../models/user");

exports.updateProgress = async (req, res) => {
  const userId = req.user.userId;
  const { problemId, status } = req.body;

  try {
    const user = await User.findById(userId);

    const existing = user.progress.find(
      (p) => p.problemId.toString() === problemId
    );

    if (existing) {
      existing.status = status;
    } else {
      user.progress.push({ problemId, status });
    }

    await user.save();
    res.json({ msg: "Progress updated" });
  } catch (err) {
    res.status(500).json({ msg: "Server error", err });
  }
};

exports.getProgress = async (req, res) => {
  const userId = req.user.userId;
  const user = await User.findById(userId);
  res.json(user.progress);
};
