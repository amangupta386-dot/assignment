const mongoose = require("mongoose");

const progressSchema = new mongoose.Schema({
  problemId: { type: mongoose.Schema.Types.ObjectId, ref: "Problem" },
  status: { type: Boolean, default: false },
});

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    progress: [progressSchema],
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);
