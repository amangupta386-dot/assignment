const { WeeklyGoal } = require("../models");
const { startOfWeekMonday, endOfWeekSunday } = require("../utils/date");

const upsertWeeklyGoal = async (req, res) => {
  const userId = req.user.id;
  const weekStart = req.body.weekStart || startOfWeekMonday(new Date());
  const weekEnd = endOfWeekSunday(weekStart);

  const payload = {
    userId,
    weekStart,
    weekEnd,
    targetProblems: req.body.targetProblems,
    targetRevisions: req.body.targetRevisions,
    focusPatterns: req.body.focusPatterns || []
  };

  const [goal, created] = await WeeklyGoal.findOrCreate({
    where: { userId, weekStart },
    defaults: payload
  });

  if (!created) {
    await goal.update(payload);
  }

  res.status(created ? 201 : 200).json({ goal });
};

const getCurrentWeeklyGoal = async (req, res) => {
  const userId = req.user.id;
  const weekStart = startOfWeekMonday(new Date());
  const goal = await WeeklyGoal.findOne({ where: { userId, weekStart } });
  res.json({ goal });
};

module.exports = { upsertWeeklyGoal, getCurrentWeeklyGoal };
