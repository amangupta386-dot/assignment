const { DailyLog } = require("../models");
const { toDateOnly } = require("../utils/date");

const ensureDailyLog = async (userId, date = new Date()) => {
  const logDate = toDateOnly(date);
  const [dailyLog] = await DailyLog.findOrCreate({
    where: { userId, date: logDate },
    defaults: { userId, date: logDate }
  });
  return dailyLog;
};

const incrementDailyLog = async ({ userId, field, by = 1, date = new Date() }) => {
  const dailyLog = await ensureDailyLog(userId, date);
  if (field === "problemsSolved") {
    dailyLog.problemsSolved += by;
  } else if (field === "revisionsDone") {
    dailyLog.revisionsDone += by;
  }
  await dailyLog.save();
  return dailyLog;
};

module.exports = { ensureDailyLog, incrementDailyLog };
