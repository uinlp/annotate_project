"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { LayoutDashboard, Database, FolderArchive } from "lucide-react";
import clsx from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: (string | undefined | null | false)[]) {
  return twMerge(clsx(inputs));
}

export function Sidebar() {
  const pathname = usePathname();

  const navLinks = [
    { name: "Overview", href: "/admin", icon: LayoutDashboard },
    { name: "Datasets", href: "/admin/datasets", icon: Database },
    { name: "Assets", href: "/admin/assets", icon: FolderArchive },
  ];

  return (
    <aside className="fixed inset-y-0 left-0 z-50 flex w-72 flex-col border-r border-gray-200 bg-white/70 backdrop-blur-3xl dark:border-gray-800 dark:bg-gray-950/70 transition-transform md:translate-x-0 -translate-x-full">
      <div className="flex h-16 shrink-0 items-center px-6">
        <span className="text-xl font-bold tracking-tight bg-gradient-to-r from-blue-600 to-indigo-500 bg-clip-text text-transparent">uiNLP Admin</span>
      </div>
      <nav className="flex flex-1 flex-col px-4 py-4 overflow-y-auto space-y-2">
        {navLinks.map((link) => {
          const isActive = pathname === link.href || pathname.startsWith(`${link.href}/`);
          const isExactActive = link.href === "/admin" ? pathname === "/admin" : isActive;
          const Icon = link.icon;
          return (
            <Link
              key={link.name}
              href={link.href}
              className={cn(
                "group flex items-center gap-x-3 rounded-xl p-3 text-sm font-medium transition-all duration-200",
                isExactActive
                  ? "bg-blue-50 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400 shadow-sm"
                  : "text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800/80 hover:scale-[1.02]"
              )}
            >
              <Icon
                className={cn(
                  "h-5 w-5 shrink-0 transition-colors",
                  isExactActive
                    ? "text-blue-700 dark:text-blue-400"
                    : "text-gray-400 group-hover:text-gray-700 dark:group-hover:text-gray-300"
                )}
              />
              {link.name}
            </Link>
          );
        })}
      </nav>
      <div className="border-t border-gray-200 dark:border-gray-800 p-4">
        <div className="flex items-center gap-3 px-2">
          <div className="h-8 w-8 rounded-full bg-gradient-to-tr from-purple-500 to-blue-500 shadow-inner flex items-center justify-center text-white text-xs font-bold">U</div>
          <span className="text-sm font-medium dark:text-gray-200">Admin User</span>
        </div>
      </div>
    </aside>
  );
}
