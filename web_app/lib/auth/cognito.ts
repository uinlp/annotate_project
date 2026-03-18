import { UserManager } from "oidc-client-ts";

const cognitoAuthConfig = {
    authority: process.env.NEXT_PUBLIC_COGNITO_AUTHORITY || "",
    client_id: process.env.NEXT_PUBLIC_COGNITO_CLIENT_ID || "",
    redirect_uri: process.env.NEXT_PUBLIC_COGNITO_REDIRECT_URI || "",
    response_type: "code",
    scope: "email openid profile"
};

export const userManager = new UserManager({
    ...cognitoAuthConfig,
});

export async function signOutRedirect () {
    const clientId = process.env.NEXT_PUBLIC_COGNITO_CLIENT_ID || "";
    const logoutUri = process.env.NEXT_PUBLIC_COGNITO_LOGOUT_URI || "";
    const cognitoDomain = process.env.NEXT_PUBLIC_COGNITO_DOMAIN || "";
    window.location.href = `${cognitoDomain}/logout?client_id=${clientId}&logout_uri=${encodeURIComponent(logoutUri)}`;
};

export async function getValidToken(): Promise<string | null> {
    try {
        const user = await userManager.getUser();
        if (user && !user.expired) return user.access_token;
        if (user && user.expired) {
            const renewed = await userManager.signinSilent();
            return renewed?.access_token || null;
        }
        return null; // Not logged in
    } catch {
        return null;
    }
}
