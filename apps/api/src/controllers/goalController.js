const { WeeklyGoal } = require("../models");
const { startOfWeekMonday, endOfWeekSunday } = require("../utils/date");

const sanitizeGoalProblems = (input) =>
  (Array.isArray(input) ? input : [])
    .map((item) => ({
      problemName: String(item?.problemName || "").trim(),
      patternName: String(item?.patternName || "").trim()
    }))
    .filter((item) => item.problemName && item.patternName);

const upsertWeeklyGoal = async (req, res) => {
  const userId = req.user.id;
  const weekStart = req.body.weekStart || startOfWeekMonday(new Date());
  const weekEnd = endOfWeekSunday(weekStart);
  const goalProblems = sanitizeGoalProblems(req.body.goalProblems);

  const payload = {
    userId,
    weekStart,
    weekEnd,
    targetProblems: goalProblems.length,
    targetRevisions: goalProblems.length,
    focusPatterns: goalProblems
  };

  const [goal, created] = await WeeklyGoal.findOrCreate({
    where: { userId, weekStart },
    defaults: payload
  });

  if (!created) {
    await goal.update(payload);
  }

  res.status(created ? 201 : 200).json({
    goal: {
      ...goal.toJSON(),
      goalProblems
    }
  });
};

const getCurrentWeeklyGoal = async (req, res) => {
  const userId = req.user.id;
  const weekStart = startOfWeekMonday(new Date());
  const goal = await WeeklyGoal.findOne({ where: { userId, weekStart } });
  if (!goal) return res.json({ goal: null });

  const goalJson = goal.toJSON();
  const goalProblems = sanitizeGoalProblems(goalJson.focusPatterns);
  res.json({
    goal: {
      ...goalJson,
      goalProblems
    }
  });
};

module.exports = { upsertWeeklyGoal, getCurrentWeeklyGoal };
