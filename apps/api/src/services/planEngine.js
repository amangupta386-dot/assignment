const dayjs = require("dayjs");
const { dayTypes } = require("../constants/enums");

const getDayType = (date) => {
  const day = dayjs(date).day();
  if (day === 6) return dayTypes.SATURDAY;
  if (day === 0) return dayTypes.SUNDAY;
  return dayTypes.WEEKDAY;
};

const createTasksByDayType = (dayType) => {
  if (dayType === dayTypes.SATURDAY) {
    return {
      deepProblems: { target: 3, done: 0 },
      patternNotes: { target: 1, done: 0 }
    };
  }

  if (dayType === dayTypes.SUNDAY) {
    return {
      mockProblems: { target: 5, done: 0 },
      timerMode: true
    };
  }

  return {
    newProblem: { target: 1, done: 0 },
    revisionProblem: { target: 1, done: 0 },
    patternRevision: { target: 1, done: 0 }
  };
};

module.exports = { getDayType, createTasksByDayType };
