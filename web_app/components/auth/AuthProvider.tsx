"use client";

import { useEffect, useState } from "react";
import { userManager, getValidToken } from "@/lib/auth/cognito";
import { apiClient } from "@/lib/api/client";
import { User } from "oidc-client-ts";

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Inject the token fetcher so internal repository calls are authenticated
    apiClient.setTokenFetcher(getValidToken);

    // Initial user load
    userManager.getUser().then((loadedUser) => {
      setUser(loadedUser);
      setLoading(false);
    }).catch(() => {
        setLoading(false);
    });

    const onUserLoaded = (loadedUser: User) => setUser(loadedUser);
    const onUserUnloaded = () => setUser(null);

    userManager.events.addUserLoaded(onUserLoaded);
    userManager.events.addUserUnloaded(onUserUnloaded);

    return () => {
      userManager.events.removeUserLoaded(onUserLoaded);
      userManager.events.removeUserUnloaded(onUserUnloaded);
    };
  }, []);

  if (loading) {
      return (
          <div className="flex h-screen items-center justify-center dark:bg-gray-950">
              <span className="text-gray-500 font-medium">Checking authentication securely...</span>
          </div>
      );
  }

  // Redirect to login if user is missing or expired
  if (!user || user.expired) {
    return (
      <div className="flex h-screen w-full items-center justify-center bg-gray-50 dark:bg-gray-950">
        <div className="text-center space-y-5 bg-white dark:bg-gray-900 p-8 rounded-2xl shadow-sm border border-gray-100 dark:border-gray-800">
            <h1 className="text-3xl font-bold bg-gradient-to-r from-blue-600 to-indigo-500 bg-clip-text text-transparent">uiNLP Admin</h1>
            <p className="text-gray-500 max-w-sm">You must authenticate via Amazon Cognito to access the dashboard repositories.</p>
            <button
                onClick={() => userManager.signinRedirect()}
                className="w-full bg-blue-600 px-4 py-3 rounded-xl text-white font-semibold shadow-sm hover:bg-blue-500 transition-all active:scale-95"
                type="button"
            >
                Sign In
            </button>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}
