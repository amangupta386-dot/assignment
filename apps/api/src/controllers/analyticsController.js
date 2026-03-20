const { Op } = require('sequelize');
const { Problem, RevisionHistory, WeeklyGoal, DailyLog } = require('../models');
const { startOfWeekMonday, endOfWeekSunday } = require('../utils/date');

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

const getPatternAnalytics = async (req, res) => {
  const userId = req.user.id;

  const problems = await Problem.findAll({
    where: { userId },
    attributes: ['id', 'pattern'],
    include: [{ model: RevisionHistory, attributes: ['action'], required: false }]
  });

  const map = new Map();

  for (const problem of problems) {
    const pattern = problem.pattern;
    if (!map.has(pattern)) {
      map.set(pattern, { pattern, solved: 0, failed: 0 });
    }

    const entry = map.get(pattern);
    entry.solved += 1;

    const failures = (problem.RevisionHistories || []).filter((h) => h.action === 'FAIL').length;
    entry.failed += failures;
  }

  const patterns = Array.from(map.values()).map((item) => {
    const totalAttempts = item.solved + item.failed;
    return {
      ...item,
      successRate: totalAttempts > 0 ? Math.round((item.solved / totalAttempts) * 100) : 0
    };
  });

  const weakPattern = patterns.length
    ? patterns.reduce((acc, curr) => (curr.successRate < acc.successRate ? curr : acc), patterns[0])
    : null;

  res.json({ patterns, weakPattern });
};

module.exports = { getWeeklyAnalytics, getPatternAnalytics };
