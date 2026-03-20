const dayjs = require("dayjs");
const { Op } = require("sequelize");
const { DailyPlan, WeeklyGoal, Problem, RevisionProgress, RevisionHistory } = require("../models");
const { revisionStages } = require("../constants/enums");
const { getDayType, createTasksByDayType } = require("../services/planEngine");
const { completeStage, getInitialProgress } = require("../services/revisionEngine");
const { toDateOnly } = require("../utils/date");

const sanitizeGoalProblems = (input) =>
  (Array.isArray(input) ? input : [])
    .map((item) => ({
      problemName: String(item?.problemName || "").trim(),
      patternName: String(item?.patternName || "").trim()
    }))
    .filter((item) => item.problemName && item.patternName);

const getAssignedGoalProblem = async (userId, date) => {
  const dateOnly = dayjs(date).format("YYYY-MM-DD");
  const goal = await WeeklyGoal.findOne({
    where: {
      userId,
      weekStart: { [Op.lte]: dateOnly },
      weekEnd: { [Op.gte]: dateOnly }
    },
    order: [["weekStart", "DESC"]]
  });
  if (!goal) return null;

  const goalProblems = sanitizeGoalProblems(goal.focusPatterns);
  if (!goalProblems.length) return null;

  const dayOffset = dayjs(dateOnly).diff(dayjs(goal.weekStart), "day");
  return goalProblems[Math.max(0, dayOffset) % goalProblems.length];
};

const getAssignedGoalProblemContext = async (userId, date) => {
  const assignedGoalProblem = await getAssignedGoalProblem(userId, date);
  if (!assignedGoalProblem) {
    return {
      assignedGoalProblem: null,
      dayOneCompleted: false,
      assignedProblemCurrentStage: null
    };
  }

  const problem = await Problem.findOne({
    where: {
      userId,
      title: assignedGoalProblem.problemName,
      pattern: assignedGoalProblem.patternName
    },
    order: [["id", "DESC"]]
  });

  if (!problem) {
    return {
      assignedGoalProblem,
      dayOneCompleted: false,
      assignedProblemCurrentStage: null
    };
  }

  const progress = await RevisionProgress.findOne({ where: { problemId: problem.id } });

  return {
    assignedGoalProblem,
    dayOneCompleted: Boolean(progress && progress.currentStage !== revisionStages.REVISE),
    assignedProblemCurrentStage: progress?.currentStage || null
  };
};

const problemStageTaskKeys = new Set(["newProblem", "deepProblems", "mockProblems", "problems"]);

const promoteDayOneToDayTwo = async ({ userId, date, taskKey }) => {
  if (!problemStageTaskKeys.has(taskKey)) return;
  const assigned = await getAssignedGoalProblem(userId, date);
  if (!assigned) return;

  let problem = await Problem.findOne({
    where: {
      userId,
      title: assigned.problemName,
      pattern: assigned.patternName
    },
    order: [["id", "DESC"]]
  });

  if (!problem) {
    problem = await Problem.create({
      userId,
      title: assigned.problemName,
      platform: "OTHER",
      difficulty: "MEDIUM",
      pattern: assigned.patternName,
      initialStatus: "NOT_SOLVED"
    });
  }

  let progress = await RevisionProgress.findOne({ where: { problemId: problem.id } });
  if (!progress) {
    progress = await RevisionProgress.create({
      problemId: problem.id,
      ...getInitialProgress(date)
    });
  }

  if (progress.currentStage !== revisionStages.REVISE) return;

  const next = completeStage(progress.currentStage, new Date());
  progress.currentStage = next.currentStage;
  progress.nextReviewDate = next.nextReviewDate;
  progress.lastCompletedAt = next.lastCompletedAt;
  await progress.save();

  await RevisionHistory.create({
    problemId: problem.id,
    stage: revisionStages.REVISE,
    action: "COMPLETE",
    result: "DAY_1_LEARN_DONE"
  });
};

const generateWeekPlan = async (req, res) => {
  const userId = req.user.id;
  const weekStart = req.body.weekStart || startOfWeekMonday(new Date());

  const created = [];
  for (let i = 0; i < 7; i += 1) {
    const date = toDateOnly(dayjs(weekStart).add(i, "day"));
    const dayType = getDayType(date);
    const tasks = createTasksByDayType(dayType);

    const [plan] = await DailyPlan.findOrCreate({
      where: { userId, date },
      defaults: { userId, date, dayType, tasks }
    });

    created.push(plan);
  }

  const enriched = await Promise.all(
    created.map(async (plan) => {
      const assignment = await getAssignedGoalProblemContext(userId, plan.date);
      return {
        ...plan.toJSON(),
        ...assignment
      };
    })
  );

  res.status(201).json({ plans: enriched });
};

const getTodayPlan = async (req, res) => {
  const userId = req.user.id;
  const today = toDateOnly(new Date());
  const dayType = getDayType(today);
  const tasks = createTasksByDayType(dayType);

  const [plan] = await DailyPlan.findOrCreate({
    where: { userId, date: today },
    defaults: { userId, date: today, dayType, tasks }
  });
  const assignment = await getAssignedGoalProblemContext(userId, today);

  res.json({
    plan: {
      ...plan.toJSON(),
      ...assignment
    }
  });
};

const markTaskDone = async (req, res) => {
  const userId = req.user.id;
  const today = toDateOnly(new Date());
  const { key } = req.body;

  const [plan] = await DailyPlan.findOrCreate({
    where: { userId, date: today },
    defaults: { userId, date: today, dayType: getDayType(today), tasks: createTasksByDayType(getDayType(today)) }
  });

  const tasks = { ...plan.tasks };
  if (!tasks[key] || typeof tasks[key] !== "object") {
    return res.status(400).json({ message: "Invalid task key" });
  }

  tasks[key].done = Math.min(tasks[key].done + 1, tasks[key].target);
  plan.tasks = tasks;

  const allDone = Object.values(tasks)
    .filter((item) => typeof item === "object" && item.target !== undefined)
    .every((item) => item.done >= item.target);

  if (allDone) plan.status = "COMPLETED";

  await plan.save();
  await promoteDayOneToDayTwo({ userId, date: today, taskKey: key });
  const assignment = await getAssignedGoalProblemContext(userId, today);
  res.json({
    plan: {
      ...plan.toJSON(),
      ...assignment
    }
  });
};

module.exports = { generateWeekPlan, getTodayPlan, markTaskDone };
