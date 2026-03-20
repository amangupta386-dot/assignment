const { Op } = require('sequelize');
const { Problem, RevisionProgress, RevisionHistory } = require('../models');
const { completeStage, keepSameStage } = require('../services/revisionEngine');
const { incrementDailyLog } = require('../services/dailyLogService');
const { addDays, toDateOnly } = require('../utils/date');

const getTodayRevisions = async (req, res) => {
  const userId = req.user.id;
  const today = toDateOnly(new Date());
  const rows = await RevisionProgress.findAll({
    include: [{ model: Problem, where: { userId }, attributes: ['id', 'title', 'pattern', 'difficulty', 'platform'] }],
    where: {
      currentStage: { [Op.notIn]: ['REVISE', 'COMPLETED'] },
      nextReviewDate: {
        [Op.lte]: addDays(today, 10)
      }
    },
    order: [['nextReviewDate', 'ASC']]
  });

  return res.json({ revisions: rows });
};

const completeRevision = async (req, res) => {
  const userId = req.user.id;
  const { problemId } = req.params;
  const progress = await RevisionProgress.findOne({ include: [{ model: Problem, where: { userId } }], where: { problemId } });
  if (!progress) {
    return res.status(404).json({ message: 'Revision not found' });
  }

  const previousStage = progress.currentStage;
  const next = completeStage(progress.currentStage, new Date());
  progress.currentStage = next.currentStage;
  progress.nextReviewDate = next.nextReviewDate;
  progress.lastCompletedAt = next.lastCompletedAt;
  await progress.save();

  await RevisionHistory.create({
    problemId: Number(problemId),
    stage: previousStage,
    action: 'COMPLETE',
    result: 'SUCCESS'
  });

  await incrementDailyLog({ userId, field: 'revisionsDone', by: 1, date: new Date() });

  res.json({ revision: progress });
};

const failRevision = async (req, res) => {
  const userId = req.user.id;
  const { problemId } = req.params;
  const progress = await RevisionProgress.findOne({ include: [{ model: Problem, where: { userId } }], where: { problemId } });
  if (!progress) {
    return res.status(404).json({ message: 'Revision not found' });
  }

  const previousStage = progress.currentStage;
  const next = keepSameStage(progress.currentStage, progress.nextReviewDate);
  progress.currentStage = next.currentStage;
  progress.nextReviewDate = next.nextReviewDate;
  progress.lastCompletedAt = next.lastCompletedAt;
  await progress.save();

  await RevisionHistory.create({
    problemId: Number(problemId),
    stage: previousStage,
    action: 'FAIL',
    result: 'RETRY_SAME_STAGE'
  });

  res.json({ revision: progress });
};

module.exports = { getTodayRevisions, completeRevision, failRevision };
