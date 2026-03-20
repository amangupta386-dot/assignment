const dayjs = require("dayjs");
const { DailyPlan } = require("../models");
const { getDayType, createTasksByDayType } = require("../services/planEngine");
const { startOfWeekMonday, toDateOnly } = require("../utils/date");

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

  res.status(201).json({ plans: created });
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

  res.json({ plan });
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
  res.json({ plan });
};

module.exports = { generateWeekPlan, getTodayPlan, markTaskDone };
