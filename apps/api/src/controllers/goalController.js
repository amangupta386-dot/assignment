const dayjs = require("dayjs");
const { Op } = require("sequelize");
const { WeeklyGoal } = require("../models");

const sanitizeGoalProblems = (input) =>
  (Array.isArray(input) ? input : [])
    .map((item) => ({
      problemName: String(item?.problemName || "").trim(),
      patternName: String(item?.patternName || "").trim()
    }))
    .filter((item) => item.problemName && item.patternName);

const serializeGoal = (goal) => {
  const goalJson = goal.toJSON();
  const goalProblems = sanitizeGoalProblems(goalJson.focusPatterns);
  return {
    ...goalJson,
    fromDate: goalJson.weekStart,
    toDate: goalJson.weekEnd,
    goalProblems
  };
};

const upsertWeeklyGoal = async (req, res) => {
  const userId = req.user.id;
  const weekStart = dayjs(req.body.fromDate).format("YYYY-MM-DD");
  const weekEnd = dayjs(req.body.toDate).format("YYYY-MM-DD");
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

  res.status(created ? 201 : 200).json({ goal: serializeGoal(goal) });
};

const getCurrentWeeklyGoal = async (req, res) => {
  const userId = req.user.id;
  const today = dayjs().format("YYYY-MM-DD");
  const goal = await WeeklyGoal.findOne({
    where: {
      userId,
      weekStart: { [Op.lte]: today },
      weekEnd: { [Op.gte]: today }
    },
    order: [["weekStart", "DESC"]]
  });
  if (!goal) return res.json({ goal: null });

  res.json({ goal: serializeGoal(goal) });
};

const getMonthlyTimeline = async (req, res) => {
  const userId = req.user.id;
  const month = req.query.month || dayjs().format("YYYY-MM");
  const monthStart = dayjs(`${month}-01`).startOf("month").format("YYYY-MM-DD");
  const monthEnd = dayjs(`${month}-01`).endOf("month").format("YYYY-MM-DD");

  const goals = await WeeklyGoal.findAll({
    where: {
      userId,
      weekStart: { [Op.lte]: monthEnd },
      weekEnd: { [Op.gte]: monthStart }
    },
    order: [["weekStart", "ASC"]]
  });

  res.json({ timelines: goals.map(serializeGoal) });
};

module.exports = { upsertWeeklyGoal, getCurrentWeeklyGoal, getMonthlyTimeline };
