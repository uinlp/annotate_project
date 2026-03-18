"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { userManager } from "@/lib/auth/cognito";

export default function CallbackPage() {
  const router = useRouter();
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    userManager
      .signinRedirectCallback()
      .then(() => {
        router.push("/admin/datasets"); // Route immediately to the dashboard index
      })
      .catch((err) => {
        console.error("Error handling auth callback", err);
        setError("Failed to sign in securely map properties from Cognito. Please try again.");
      });
  }, [router]);

  if (error) {
    return (
      <div className="h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-950">
        <div className="p-8 bg-red-50 text-red-600 rounded-2xl border border-red-200 shadow-sm max-w-lg text-center font-medium">
            <p>{error}</p>
            <button onClick={() => router.push("/")} className="mt-4 px-4 py-2 bg-red-600 text-white rounded-lg shadow-sm">Go Home</button>
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-950">
      <div className="text-center space-y-3 p-8 border border-gray-200 dark:border-gray-800 bg-white dark:bg-gray-900 rounded-3xl shadow-sm">
          <div className="h-8 w-8 mx-auto animate-spin rounded-full border-b-2 border-blue-600"></div>
          <p className="text-gray-600 dark:text-gray-400 font-medium">Validating tokens securely...</p>
      </div>
    </div>
  );
}
