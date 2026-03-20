const dayjs = require("dayjs");
const { Op } = require("sequelize");
const { revisionStages } = require("../constants/enums");
const { Problem, RevisionHistory, RevisionProgress, WeeklyGoal, DailyLog } = require("../models");
const { startOfWeekMonday, endOfWeekSunday, toDateOnly } = require("../utils/date");

const stageDefinitions = [
  {
    key: revisionStages.REVISE,
    title: "Learn About Problem",
    shortLabel: "Stage 1",
    description: "Learn the problem and understand the approach."
  },
  {
    key: revisionStages.SOLVE_AGAIN,
    title: "Revise And Solve",
    shortLabel: "Stage 2",
    description: "Revisit the concept and solve the problem again."
  },
  {
    key: revisionStages.SOLVE_WITHOUT_SEEING,
    title: "Solve Without Seeing",
    shortLabel: "Stage 3",
    description: "Solve the problem independently without looking."
  },
  {
    key: revisionStages.FINAL_REVISIT,
    title: "Revisit With Timer",
    shortLabel: "Stage 4",
    description: "Revisit the problem under timed conditions."
  }
];

const buildStageMetric = (definition, values = {}) => ({
  stageKey: definition.key,
  title: definition.title,
  shortLabel: definition.shortLabel,
  description: definition.description,
  due: values.due || 0,
  completed: values.completed || 0,
  overdue: values.overdue || 0,
  backlog: values.backlog || 0
});

const inDateRange = (value, start, end) =>
  dayjs(value).isSame(dayjs(start), "day") ||
  dayjs(value).isSame(dayjs(end), "day") ||
  (dayjs(value).isAfter(dayjs(start), "day") && dayjs(value).isBefore(dayjs(end), "day"));

const buildCompletionMap = (histories, start, end) => {
  const counts = Object.fromEntries(stageDefinitions.map((stage) => [stage.key, 0]));
  for (const row of histories) {
    if (!inDateRange(row.performedAt, start, end)) continue;
    if (counts[row.stage] !== undefined) {
      counts[row.stage] += 1;
    }
  }
  return counts;
};

const buildSnapshotMap = (progressRows, cutoffDate) => {
  const snapshot = Object.fromEntries(stageDefinitions.map((stage) => [stage.key, { due: 0, overdue: 0, backlog: 0 }]));
  for (const row of progressRows) {
    if (!snapshot[row.currentStage]) continue;
    const stage = snapshot[row.currentStage];
    stage.backlog += 1;
    if (row.nextReviewDate <= cutoffDate) {
      stage.due += 1;
    }
    if (row.nextReviewDate < cutoffDate) {
      stage.overdue += 1;
    }
  }
  return snapshot;
};

const buildWeekBreakdown = (histories, monthStart, monthEnd) => {
  const weeks = [];
  let cursor = dayjs(monthStart);
  let weekNumber = 1;

  while (cursor.isBefore(dayjs(monthEnd), "day") || cursor.isSame(dayjs(monthEnd), "day")) {
    const start = cursor;
    const rawEnd = cursor.add(6, "day");
    const end = rawEnd.isAfter(dayjs(monthEnd), "day") ? dayjs(monthEnd) : rawEnd;
    const completions = buildCompletionMap(histories, start.format("YYYY-MM-DD"), end.format("YYYY-MM-DD"));
    const totalCompleted = Object.values(completions).reduce((sum, count) => sum + count, 0);

    weeks.push({
      label: `Week ${weekNumber}`,
      startDate: start.format("YYYY-MM-DD"),
      endDate: end.format("YYYY-MM-DD"),
      totalCompleted,
      stageMetrics: stageDefinitions.map((stage) =>
        buildStageMetric(stage, {
          completed: completions[stage.key]
        })
      )
    });

    cursor = cursor.add(7, "day");
    weekNumber += 1;
  }

  return weeks;
};

const buildPatternAnalytics = (problems) => {
  const map = new Map();

  for (const problem of problems) {
    const pattern = problem.pattern;
    if (!map.has(pattern)) {
      map.set(pattern, { pattern, solved: 0, failed: 0 });
    }

    const entry = map.get(pattern);
    entry.solved += 1;

    const failures = (problem.RevisionHistories || []).filter((h) => h.action === "FAIL").length;
    entry.failed += failures;
  }

  return Array.from(map.values())
    .map((item) => {
      const totalAttempts = item.solved + item.failed;
      return {
        ...item,
        successRate: totalAttempts > 0 ? Math.round((item.solved / totalAttempts) * 100) : 0
      };
    })
    .sort((a, b) => b.solved - a.solved || b.successRate - a.successRate);
};

const getWeeklyAnalytics = async (req, res) => {
  const userId = req.user.id;
  const weekStart = startOfWeekMonday(new Date());
  const weekEnd = endOfWeekSunday(weekStart);

  const goal = await WeeklyGoal.findOne({ where: { userId, weekStart } });

  const problemCount = await Problem.count({
    where: {
      userId,
      createdAt: {
        [Op.between]: [new Date(weekStart), new Date(`${weekEnd}T23:59:59`)]
      }
    }
  });

  const revisionCount = await RevisionHistory.count({
    include: [{ model: Problem, where: { userId }, attributes: [] }],
    where: {
      action: 'COMPLETE',
      performedAt: {
        [Op.between]: [new Date(weekStart), new Date(`${weekEnd}T23:59:59`)]
      }
    }
  });

  const activeDays = await DailyLog.count({
    where: {
      userId,
      date: { [Op.between]: [weekStart, weekEnd] },
      [Op.or]: [{ problemsSolved: { [Op.gt]: 0 } }, { revisionsDone: { [Op.gt]: 0 } }]
    }
  });

  const targetProblems = goal?.targetProblems || 0;
  const targetRevisions = goal?.targetRevisions || 0;

  res.json({
    weekStart,
    weekEnd,
    targetProblems,
    targetRevisions,
    actualProblems: problemCount,
    actualRevisions: revisionCount,
    problemsProgress: targetProblems > 0 ? Math.round((problemCount / targetProblems) * 100) : 0,
    revisionsProgress: targetRevisions > 0 ? Math.round((revisionCount / targetRevisions) * 100) : 0,
    consistencyScore: Math.round((activeDays / 7) * 100)
  });
};

const getDashboardAnalytics = async (req, res) => {
  const userId = req.user.id;
  const today = toDateOnly(new Date());
  const weekStart = startOfWeekMonday(new Date());
  const weekEnd = endOfWeekSunday(new Date());
  const monthStart = dayjs(today).startOf("month").format("YYYY-MM-DD");
  const monthEnd = dayjs(today).endOf("month").format("YYYY-MM-DD");
  const logRangeStart = weekStart < monthStart ? weekStart : monthStart;

  const [progressRows, historyRows, dailyLogs, problems, goal] = await Promise.all([
    RevisionProgress.findAll({
      include: [{ model: Problem, where: { userId }, attributes: [] }],
      attributes: ["currentStage", "nextReviewDate", "lastCompletedAt"]
    }),
    RevisionHistory.findAll({
      include: [{ model: Problem, where: { userId }, attributes: ["pattern"] }],
      where: { action: "COMPLETE" },
      attributes: ["stage", "performedAt", "action", "result"]
    }),
    DailyLog.findAll({
      where: {
        userId,
        date: { [Op.between]: [logRangeStart, monthEnd] }
      }
    }),
    Problem.findAll({
      where: { userId },
      attributes: ["id", "pattern", "createdAt"],
      include: [{ model: RevisionHistory, attributes: ["action"], required: false }]
    }),
    WeeklyGoal.findOne({ where: { userId, weekStart } })
  ]);

  const dailyCompletion = buildCompletionMap(historyRows, today, today);
  const weeklyCompletion = buildCompletionMap(historyRows, weekStart, weekEnd);
  const monthlyCompletion = buildCompletionMap(historyRows, monthStart, monthEnd);

  const dailySnapshot = buildSnapshotMap(progressRows, today);
  const weeklySnapshot = buildSnapshotMap(progressRows, weekEnd);
  const monthlySnapshot = buildSnapshotMap(progressRows, today);

  const dailyStageMetrics = stageDefinitions.map((stage) =>
    buildStageMetric(stage, {
      due: dailySnapshot[stage.key].due,
      completed: dailyCompletion[stage.key],
      overdue: dailySnapshot[stage.key].overdue,
      backlog: dailySnapshot[stage.key].backlog
    })
  );

  const weeklyStageMetrics = stageDefinitions.map((stage) =>
    buildStageMetric(stage, {
      due: weeklySnapshot[stage.key].due,
      completed: weeklyCompletion[stage.key],
      overdue: weeklySnapshot[stage.key].overdue,
      backlog: weeklySnapshot[stage.key].backlog
    })
  );

  const monthlyStageMetrics = stageDefinitions.map((stage) =>
    buildStageMetric(stage, {
      due: monthlySnapshot[stage.key].due,
      completed: monthlyCompletion[stage.key],
      overdue: monthlySnapshot[stage.key].overdue,
      backlog: monthlySnapshot[stage.key].backlog
    })
  );

  const activeDaysWeekly = dailyLogs.filter(
    (log) =>
      log.date >= weekStart &&
      log.date <= weekEnd &&
      (log.problemsSolved > 0 || log.revisionsDone > 0)
  ).length;
  const activeDaysMonthly = dailyLogs.filter((log) => log.problemsSolved > 0 || log.revisionsDone > 0).length;

  const weekProblems = problems.filter((problem) => {
    const created = toDateOnly(problem.createdAt);
    return created >= weekStart && created <= weekEnd;
  }).length;
  const monthProblems = problems.filter((problem) => {
    const created = toDateOnly(problem.createdAt);
    return created >= monthStart && created <= monthEnd;
  }).length;

  const weeklyTotalCompleted = Object.values(weeklyCompletion).reduce((sum, count) => sum + count, 0);
  const monthlyTotalCompleted = Object.values(monthlyCompletion).reduce((sum, count) => sum + count, 0);
  const dailyTotalCompleted = Object.values(dailyCompletion).reduce((sum, count) => sum + count, 0);
  const dailyTotalDue = dailyStageMetrics.reduce((sum, metric) => sum + metric.due, 0);
  const dailyOverdue = dailyStageMetrics.reduce((sum, metric) => sum + metric.overdue, 0);

  const targetProblems = goal?.targetProblems || 0;
  const targetRevisions = goal?.targetRevisions || 0;
  const actualRevisions = weeklyTotalCompleted;

  const patterns = buildPatternAnalytics(problems).slice(0, 5);

  res.json({
    generatedOn: new Date().toISOString(),
    stages: stageDefinitions,
    daily: {
      label: today,
      totalDue: dailyTotalDue,
      totalCompleted: dailyTotalCompleted,
      overdue: dailyOverdue,
      completionScore: dailyTotalDue + dailyTotalCompleted === 0
        ? 0
        : Math.round((dailyTotalCompleted / (dailyTotalDue + dailyTotalCompleted)) * 100),
      stageMetrics: dailyStageMetrics
    },
    weekly: {
      label: `${weekStart} to ${weekEnd}`,
      activeDays: activeDaysWeekly,
      consistencyScore: Math.round((activeDaysWeekly / 7) * 100),
      totalCompleted: weeklyTotalCompleted,
      fullCycleCompleted: weeklyCompletion[revisionStages.FINAL_REVISIT] || 0,
      stageMetrics: weeklyStageMetrics,
      goalProgress: {
        targetProblems,
        targetRevisions,
        actualProblems: weekProblems,
        actualRevisions,
        problemsProgress: targetProblems > 0 ? Math.round((weekProblems / targetProblems) * 100) : 0,
        revisionsProgress: targetRevisions > 0 ? Math.round((actualRevisions / targetRevisions) * 100) : 0
      }
    },
    monthly: {
      label: dayjs(today).format("MMMM YYYY"),
      activeDays: activeDaysMonthly,
      totalCompleted: monthlyTotalCompleted,
      fullCycleCompleted: monthlyCompletion[revisionStages.FINAL_REVISIT] || 0,
      totalProblemsStarted: monthProblems,
      stageMetrics: monthlyStageMetrics,
      weekBreakdown: buildWeekBreakdown(historyRows, monthStart, monthEnd)
    },
    patterns
  });
};

const getPatternAnalytics = async (req, res) => {
  const userId = req.user.id;

  const problems = await Problem.findAll({
    where: { userId },
    attributes: ['id', 'pattern'],
    include: [{ model: RevisionHistory, attributes: ['action'], required: false }]
  });

  const patterns = buildPatternAnalytics(problems);

  const weakPattern = patterns.length
    ? patterns.reduce((acc, curr) => (curr.successRate < acc.successRate ? curr : acc), patterns[0])
    : null;

  res.json({ patterns, weakPattern });
};

module.exports = { getWeeklyAnalytics, getDashboardAnalytics, getPatternAnalytics };
