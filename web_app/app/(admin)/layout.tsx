import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "@/app/globals.css";
import { Sidebar } from "@/components/admin/Sidebar";
import { MobileNav } from "@/components/admin/MobileNav";
import { AuthProvider } from "@/components/auth/AuthProvider";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Admin",
  description: "Admin page",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="h-full bg-gray-50 dark:bg-gray-950">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased h-full`}
      >
        <AuthProvider>
          <div className="flex h-full min-h-screen pt-16 md:pt-0">
            {/* Desktop Sidebar */}
            <div className="hidden md:flex">
              <Sidebar />
            </div>
            
            {/* Mobile Navigation Header */}
            <div className="fixed inset-x-0 top-0 z-40 md:hidden">
              <MobileNav />
            </div>

            {/* Main Content */}
            <main className="flex-1 w-full bg-gray-50/50 dark:bg-gray-950/50 transition-all md:pl-72 border-t border-gray-200 dark:border-gray-800 md:border-none min-h-screen">
               <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8 w-full">
                  {children}
               </div>
            </main>
          </div>
        </AuthProvider>
      </body>
    </html>
  );
}
