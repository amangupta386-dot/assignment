import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import api from "../api";
import { useAuth } from "../context/AuthContext";

export default function Login() {
    const [form, setForm] = useState({ email: "", password: "" });
    const { login } = useAuth();
    const navigate = useNavigate();
    const [error, setError] = useState("");

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError("");

        try {
            const res = await api.post("/auth/login", form);
            login(res.data.user, res.data.token);
            navigate("/");
        } catch {
            setError("Invalid email or password");
        }
    };

    return (
        <div className="flex justify-center items-center min-h-screen bg-gray-100 dark:bg-slate-950 px-4">
            <div className="w-full max-w-sm p-8 rounded-2xl bg-white dark:bg-slate-900 shadow-lg border border-gray-200 dark:border-slate-700 transition-all">
                <h2 className="text-3xl font-bold mb-6 text-center text-gray-900 dark:text-white">
                    Login
                </h2>

                {error && <p className="text-red-500 text-sm mb-3">{error}</p>}

                <form onSubmit={handleSubmit} className="space-y-4">
                    <input
                        type="email"
                        placeholder="Email"
                        value={form.email}
                        name="email"
                        onChange={(e) => setForm({ ...form, email: e.target.value })}
                        className="w-full px-4 py-3 rounded-xl bg-gray-100 dark:bg-slate-800 text-black dark:text-white border border-gray-300 dark:border-slate-600 focus:ring-2 focus:ring-indigo-500 outline-none transition"
                    />

                    <input
                        type="password"
                        placeholder="Password"
                        value={form.password}
                        name="password"
                        onChange={(e) => setForm({ ...form, password: e.target.value })}
                        className="w-full px-4 py-3 rounded-xl bg-gray-100 dark:bg-slate-800 text-black dark:text-white border border-gray-300 dark:border-slate-600 focus:ring-2 focus:ring-indigo-500 outline-none transition"
                    />

                    <button className="w-full py-3 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-semibold shadow-md hover:shadow-lg transition">
                        Login
                    </button>
                </form>

                <p className="text-sm mt-4 text-center text-gray-700 dark:text-gray-300">
                    New here? <Link to="/register" className="font-semibold text-indigo-600 hover:underline">Register</Link>
                </p>
            </div>
        </div>

    );
}
