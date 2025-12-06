const mongoose = require("mongoose");

const ProblemSchema = new mongoose.Schema({
  topic: { type: String, required: true, trim: true },
  subtopic: { type: String, required: true, trim: true },
  title: { type: String, required: true, trim: true },
  difficulty: {
    type: String,
    enum: ["Easy", "Medium", "Hard"],
    required: true,
  },
  problemLink: { type: String },      // 👈 generic problem URL
  youtubeLink: { type: String },
  leetcodeLink: { type: String },     // can still keep this
  articleLink: { type: String },
}, { timestamps: true });


module.exports = mongoose.model("Problem", ProblemSchema);
