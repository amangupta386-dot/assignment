const test = require("node:test");
const assert = require("node:assert/strict");

const { dayTypes } = require("../src/constants/enums");
const { getDayType, createTasksByDayType } = require("../src/services/planEngine");
const { __testables } = require("../src/controllers/planController");

test("getDayType maps weekdays and weekends correctly", () => {
  assert.equal(getDayType("2026-03-18"), dayTypes.WEEKDAY);
  assert.equal(getDayType("2026-03-21"), dayTypes.SATURDAY);
  assert.equal(getDayType("2026-03-22"), dayTypes.SUNDAY);
});

test("createTasksByDayType uses visible problems and revisions structure", () => {
  assert.deepEqual(createTasksByDayType(dayTypes.WEEKDAY), {
    problems: { target: 1, done: 0 },
    revisions: { target: 1, done: 0 }
  });

  assert.deepEqual(createTasksByDayType(dayTypes.SATURDAY), {
    problems: { target: 3, done: 0 },
    revisions: { target: 2, done: 0 }
  });

  assert.deepEqual(createTasksByDayType(dayTypes.SUNDAY), {
    problems: { target: 5, done: 0 },
    revisions: { target: 2, done: 0 },
    timerMode: true
  });
});

test("normalizeTasksForDayType migrates legacy daily plan keys", () => {
  const normalizedWeekday = __testables.normalizeTasksForDayType(
    {
      newProblem: { target: 1, done: 1 },
      revisionProblem: { target: 1, done: 0 },
      patternRevision: { target: 1, done: 1 }
    },
    dayTypes.WEEKDAY
  );

  assert.deepEqual(normalizedWeekday, {
    problems: { target: 1, done: 1 },
    revisions: { target: 1, done: 0 }
  });

  const normalizedSunday = __testables.normalizeTasksForDayType(
    {
      mockProblems: { target: 5, done: 2 },
      timerMode: true
    },
    dayTypes.SUNDAY
  );

  assert.deepEqual(normalizedSunday, {
    problems: { target: 5, done: 2 },
    revisions: { target: 2, done: 0 },
    timerMode: true
  });
});

test("sanitizeGoalProblems keeps older goal items even without time complexity", () => {
  const sanitized = __testables.sanitizeGoalProblems([
    { problemName: "Two Sum", patternName: "Hashing" },
    { problemName: " ", patternName: "Sliding Window", timeComplexity: "O(n)" }
  ]);

  assert.deepEqual(sanitized, [
    {
      problemName: "Two Sum",
      patternName: "Hashing",
      timeComplexity: "Not set"
    }
  ]);
});
