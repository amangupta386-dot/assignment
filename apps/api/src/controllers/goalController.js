const dayjs = require("dayjs");
const { Op } = require("sequelize");
const { WeeklyGoal, RevisionHistory, Problem } = require("../models");
const { startOfWeekMonday, endOfWeekSunday } = require("../utils/date");

const sanitizeGoalProblems = (input) =>
  (Array.isArray(input) ? input : [])
    .map((item) => ({
      problemName: String(item?.problemName || "").trim(),
      patternName: String(item?.patternName || "").trim(),
      timeComplexity: String(item?.timeComplexity || "Not set").trim()
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

const toGoalKey = (item) =>
  `${item.problemName.trim().toLowerCase()}|${item.patternName.trim().toLowerCase()}`;

const buildWeekPerformance = async (userId, goal) => {
  const goalProblems = sanitizeGoalProblems(goal.focusPatterns);
  const plannedKeys = new Set(goalProblems.map(toGoalKey));

  const revisionRows = await RevisionHistory.findAll({
    include: [
      {
        model: Problem,
        where: { userId },
        attributes: ["title", "pattern"]
      }
    ],
    where: {
      action: "COMPLETE",
      stage: "REVISE",
      performedAt: {
        [Op.between]: [
          new Date(`${goal.weekStart}T00:00:00`),
          new Date(`${goal.weekEnd}T23:59:59`)
        ]
      }
    }
  });

  const completedKeys = new Set(
    revisionRows
      .map((row) => ({
        problemName: row.Problem?.title || "",
        patternName: row.Problem?.pattern || ""
      }))
      .map(toGoalKey)
      .filter((key) => plannedKeys.has(key))
  );

  const unfinishedProblems = goalProblems.filter(
    (item) => !completedKeys.has(toGoalKey(item))
  );
  const completedDayOneCount = goalProblems.length - unfinishedProblems.length;
  const plannedCount = goalProblems.length;
  const completionRate =
    plannedCount === 0 ? 0 : Math.round((completedDayOneCount / plannedCount) * 100);

  return {
    label: `${goal.weekStart} to ${goal.weekEnd}`,
    fromDate: goal.weekStart,
    toDate: goal.weekEnd,
    plannedCount,
    completedDayOneCount,
    completionRate,
    unfinishedProblems
  };
};

const getPlanningWindow = () => {
  const now = dayjs();
  const currentMonday = dayjs(startOfWeekMonday(now));
  const planningMonday = now.day() === 0 ? currentMonday.add(7, "day") : currentMonday;
  return {
    fromDate: planningMonday.format("YYYY-MM-DD"),
    toDate: planningMonday.add(6, "day").format("YYYY-MM-DD")
  };
};

const recommendTarget = (recentPerformance, carryForwardCount) => {
  if (!recentPerformance.length) {
    return Math.max(4, carryForwardCount);
  }

  const averageCompleted =
    Math.round(
      recentPerformance.reduce(
        (sum, item) => sum + item.completedDayOneCount,
        0
      ) / recentPerformance.length
    ) || 0;

  const lastWeek = recentPerformance[0];
  let recommended = averageCompleted;

  if (lastWeek.completionRate >= 85) {
    recommended += 1;
  } else if (lastWeek.completionRate >= 70) {
    recommended = Math.max(recommended, averageCompleted + 1);
  } else if (lastWeek.completionRate < 50) {
    recommended = Math.max(3, averageCompleted);
  }

  if (
    recentPerformance.length >= 2 &&
    recentPerformance.slice(0, 2).every((item) => item.completionRate >= 85)
  ) {
    recommended = Math.max(
      recommended,
      Math.max(
        recentPerformance[0].completedDayOneCount,
        recentPerformance[1].completedDayOneCount
      ) + 1
    );
  }

  recommended = Math.max(recommended, carryForwardCount);
  recommended = Math.max(3, recommended);
  recommended = Math.min(7, recommended);
  return recommended;
};

const getWeeklyGoalRecommendation = async (req, res) => {
  const userId = req.user.id;
  const planningWindow = getPlanningWindow();

  const recentGoals = await WeeklyGoal.findAll({
    where: {
      userId,
      weekEnd: { [Op.lt]: planningWindow.fromDate }
    },
    order: [["weekStart", "DESC"]],
    limit: 3
  });

  const recentPerformance = [];
  for (const goal of recentGoals) {
    recentPerformance.push(await buildWeekPerformance(userId, goal));
  }

  const lastWeek = recentPerformance[0] || {
    label: "",
    fromDate: "",
    toDate: "",
    plannedCount: 0,
    completedDayOneCount: 0,
    completionRate: 0,
    unfinishedProblems: []
  };

  const carryForwardProblems = lastWeek.unfinishedProblems || [];
  const recommendedTarget = recommendTarget(
    recentPerformance,
    carryForwardProblems.length
  );

  res.json({
    ...planningWindow,
    recommendedTarget,
    suggestedNewProblems: Math.max(
      0,
      recommendedTarget - carryForwardProblems.length
    ),
    carryForwardProblems,
    lastWeek,
    recentPerformance
  });
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

module.exports = {
  upsertWeeklyGoal,
  getCurrentWeeklyGoal,
  getMonthlyTimeline,
  getWeeklyGoalRecommendation
};
