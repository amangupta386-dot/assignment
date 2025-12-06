import { Link } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { useTheme } from "../context/ThemeContext";

const Navbar = () => {
    const { user, logout } = useAuth();
    const { theme, toggleTheme } = useTheme();

    return (
        <nav className="w-full border-b bg-white/80 dark:bg-slate-900/80 dark:border-slate-700 backdrop-blur-md sticky top-0 z-50">
            <div className="max-w-5xl mx-auto flex items-center justify-between px-4 py-4">

                <Link to="/" className="text-xl font-bold text-gray-900 dark:text-white">
                    DSA Sheet
                </Link>

                <div className="flex gap-4 items-center">
                    <button
                        onClick={toggleTheme}
                        className={`relative w-14 h-7 flex items-center rounded-full transition-all 
  ${theme === "dark" ? "bg-slate-700" : "bg-gray-300"}`}
                    >
                        <span
                            className={`absolute w-6 h-6 bg-white rounded-full shadow-md transform transition-all 
    ${theme === "dark" ? "translate-x-7" : "translate-x-1"}`}
                        />
                        <span className="absolute left-1 text-xs pointer-events-none">🌞</span>
                        <span className="absolute right-1 text-xs pointer-events-none">🌙</span>
                    </button>



                    {user ? (
                        <>
                            <span className="text-gray-600 dark:text-gray-300 text-sm">{user.name}</span>
                            <button
                                onClick={logout}
                                className="border px-4 py-1 rounded-lg text-sm dark:border-gray-600 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-slate-700 transition"
                            >
                                Logout
                            </button>
                        </>
                    ) : (
                        <Link to="/login" className="link text-sm">Login</Link>
                    )}
                </div>
            </div>
        </nav>
    );
};

export default Navbar;
