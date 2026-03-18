"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Menu, X, LayoutDashboard, Database, FolderArchive, LogOut } from "lucide-react";
import { signOutRedirect } from "@/lib/auth/cognito";
import clsx from "clsx";
import { twMerge } from "tailwind-merge";

function cn(...inputs: (string | undefined | null | false)[]) {
  return twMerge(clsx(inputs));
}

const navLinks = [
  { name: "Overview", href: "/admin", icon: LayoutDashboard },
  { name: "Datasets", href: "/admin/datasets", icon: Database },
  { name: "Assets", href: "/admin/assets", icon: FolderArchive },
];

export function MobileNav() {
  const [isOpen, setIsOpen] = useState(false);
  const pathname = usePathname();

  // Close sidebar on route change
  useEffect(() => {
    setIsOpen(false);
  }, [pathname]);

  return (
    <div className="md:hidden">
      {/* Header */}
      <header className="sticky top-0 z-40 flex h-16 items-center gap-x-4 border-b border-gray-200 bg-white/70 backdrop-blur-3xl px-4 shadow-sm sm:gap-x-6 sm:px-6 lg:px-8 dark:border-gray-800 dark:bg-gray-950/70">
        <button
          type="button"
          onClick={() => setIsOpen(true)}
          className="-m-2.5 p-2.5 text-gray-700 dark:text-gray-300"
        >
          <span className="sr-only">Open sidebar</span>
          <Menu className="h-6 w-6" aria-hidden="true" />
        </button>
        <div className="flex-1 text-sm font-semibold leading-6 text-gray-900 dark:text-white">
          <span className="bg-gradient-to-r from-blue-600 to-indigo-500 bg-clip-text text-transparent">UINLP Admin</span>
        </div>
      </header>

      {/* Sidebar Overlay */}
      {isOpen && (
        <div className="relative z-50">
          <div className="fixed inset-0 bg-gray-900/80 backdrop-blur-sm transition-opacity" onClick={() => setIsOpen(false)} />
          <div className="fixed inset-0 flex">
            <div className="relative mr-16 flex w-full max-w-xs flex-1 transform transition duration-300 ease-in-out">
              <div className="absolute left-full top-0 flex w-16 justify-center pt-5">
                <button type="button" onClick={() => setIsOpen(false)} className="-m-2.5 p-2.5 text-white/80 hover:text-white">
                  <span className="sr-only">Close sidebar</span>
                  <X className="h-6 w-6" aria-hidden="true" />
                </button>
              </div>

              <div className="flex grow flex-col gap-y-5 overflow-y-auto bg-white px-6 pb-4 dark:bg-gray-950">
                <div className="flex h-16 shrink-0 items-center">
                  <span className="text-xl font-bold tracking-tight bg-gradient-to-r from-blue-600 to-indigo-500 bg-clip-text text-transparent">UINLP Admin</span>
                </div>
                <nav className="flex flex-1 flex-col">
                  <ul role="list" className="flex flex-1 flex-col gap-y-7">
                    <li>
                      <ul role="list" className="-mx-2 space-y-1">
                        {navLinks.map((link) => {
                          const isActive = pathname === link.href || pathname.startsWith(`${link.href}/`);
                          const isExactActive = link.href === "/admin" ? pathname === "/admin" : isActive;
                          const Icon = link.icon;
                          return (
                            <li key={link.name}>
                              <Link
                                href={link.href}
                                onClick={() => setIsOpen(false)}
                                className={cn(
                                  "group flex gap-x-3 rounded-xl p-3 text-sm font-medium leading-6 transition-all",
                                  isExactActive
                                    ? "bg-blue-50 text-blue-700 dark:bg-blue-900/30 dark:text-blue-400 shadow-sm"
                                    : "text-gray-700 hover:bg-gray-100 dark:text-gray-300 dark:hover:bg-gray-800/80"
                                )}
                              >
                                <Icon className={cn("h-6 w-6 shrink-0 transition-colors", isExactActive ? "text-blue-700 dark:text-blue-400" : "text-gray-400 group-hover:text-gray-700 dark:group-hover:text-gray-300")} aria-hidden="true" />
                                {link.name}
                              </Link>
                            </li>
                          )
                        })}
                      </ul>
                    </li>
                    <li className="mt-auto -mx-2 mb-4">
                        <button
                          onClick={() => signOutRedirect()}
                          className="group flex w-full gap-x-3 rounded-xl p-3 text-sm font-medium leading-6 text-gray-700 hover:text-red-600 hover:bg-red-50 dark:text-gray-300 dark:hover:text-red-400 dark:hover:bg-red-900/20 transition-all"
                        >
                            <LogOut className="h-6 w-6 shrink-0 text-gray-400 group-hover:text-red-600 dark:group-hover:text-red-400 transition-colors" />
                            Sign Out
                        </button>
                    </li>
                  </ul>
                </nav>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
