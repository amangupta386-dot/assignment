const { Joi } = require("../middlewares/validate");

const createProblemSchema = Joi.object({
  title: Joi.string().trim().min(2).max(120).required(),
  platform: Joi.string().trim().valid("LEETCODE", "GFG", "CODESTUDIO", "OTHER").required(),
  difficulty: Joi.string().trim().valid("EASY", "MEDIUM", "HARD").required(),
  pattern: Joi.string().trim().min(2).max(80).required(),
  initialStatus: Joi.string().trim().valid("SOLVED", "WITH_HELP", "NOT_SOLVED").default("SOLVED")
});

const weeklyGoalSchema = Joi.object({
  fromDate: Joi.date().iso().required(),
  toDate: Joi.date().iso().min(Joi.ref("fromDate")).required(),
  goalProblems: Joi.array()
    .items(
      Joi.object({
        problemName: Joi.string().trim().min(2).max(120).required(),
        patternName: Joi.string().trim().min(2).max(120).required()
      })
    )
    .min(1)
    .required()
});

const weekPlanSchema = Joi.object({
  weekStart: Joi.date().iso().optional()
});

const markTaskDoneSchema = Joi.object({
  key: Joi.string().trim().required()
});

module.exports = {
  createProblemSchema,
  weeklyGoalSchema,
  weekPlanSchema,
  markTaskDoneSchema
};
