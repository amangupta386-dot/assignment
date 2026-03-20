const dayjs = require("dayjs");

const toDateOnly = (date) => dayjs(date).format("YYYY-MM-DD");

const addDays = (date, days) => toDateOnly(dayjs(date).add(days, "day"));

const startOfWeekMonday = (date = dayjs()) => {
  const d = dayjs(date);
  const day = d.day();
  const diff = day === 0 ? -6 : 1 - day;
  return toDateOnly(d.add(diff, "day"));
};

const endOfWeekSunday = (date = dayjs()) => toDateOnly(dayjs(startOfWeekMonday(date)).add(6, "day"));

module.exports = { toDateOnly, addDays, startOfWeekMonday, endOfWeekSunday };
