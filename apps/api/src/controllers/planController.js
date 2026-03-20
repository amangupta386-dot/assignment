const dayjs = require("dayjs");
const { DailyPlan, WeeklyGoal } = require("../models");
const { getDayType, createTasksByDayType } = require("../services/planEngine");
const { startOfWeekMonday, toDateOnly } = require("../utils/date");

const sanitizeGoalProblems = (input) =>
  (Array.isArray(input) ? input : [])
    .map((item) => ({
      problemName: String(item?.problemName || "").trim(),
      patternName: String(item?.patternName || "").trim()
    }))
    .filter((item) => item.problemName && item.patternName);

const getAssignedGoalProblem = async (userId, date) => {
  const weekStart = startOfWeekMonday(date);
  const goal = await WeeklyGoal.findOne({ where: { userId, weekStart } });
  if (!goal) return null;

  const goalProblems = sanitizeGoalProblems(goal.focusPatterns);
  if (!goalProblems.length) return null;

  const dayIndex = dayjs(date).day();
  const mondayBasedIndex = dayIndex === 0 ? 6 : dayIndex - 1;
  return goalProblems[mondayBasedIndex % goalProblems.length];
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
    created.map(async (plan) => ({
      ...plan.toJSON(),
      assignedGoalProblem: await getAssignedGoalProblem(userId, plan.date)
    }))
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

  res.json({
    plan: {
      ...plan.toJSON(),
      assignedGoalProblem: await getAssignedGoalProblem(userId, today)
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
  res.json({
    plan: {
      ...plan.toJSON(),
      assignedGoalProblem: await getAssignedGoalProblem(userId, today)
    }
  });
};

module.exports = { generateWeekPlan, getTodayPlan, markTaskDone };
