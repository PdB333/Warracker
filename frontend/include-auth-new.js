/**
 * Immediate Authentication State Handler
 * 
 * This script runs as soon as possible to hide login/register buttons if a user is logged in
 * It should be included directly in the HTML before any other scripts
 */

console.log('include-auth-new.js: Running immediate auth check');

// Function to update UI based on auth state (extracted for reuse)
function updateAuthUI() {
    if (localStorage.getItem('auth_token')) {
        console.log('include-auth-new.js: Updating UI for authenticated user');
        // Inject CSS to hide auth buttons and show user menu
        const styleId = 'auth-ui-style';
        let style = document.getElementById(styleId);
        if (!style) {
            style = document.createElement('style');
            style.id = styleId;
            document.head.appendChild(style);
        }
        style.textContent = `
            #authContainer, .auth-buttons, a[href="login.html"], a[href="register.html"], 
            .login-btn, .register-btn, .auth-btn.login-btn, .auth-btn.register-btn {
                display: none !important;
                visibility: hidden !important;
            }
            #userMenu, .user-menu {
                display: block !important;
                visibility: visible !important;
            }
        `;

        // Update user info display elements immediately
        try {
            var userInfoStr = localStorage.getItem('user_info');
            if (userInfoStr) {
                var userInfo = JSON.parse(userInfoStr);
                var displayName = userInfo.username || 'User';
                var userDisplayName = document.getElementById('userDisplayName');
                if (userDisplayName) userDisplayName.textContent = displayName;
                var userName = document.getElementById('userName');
                if (userName) {
                    userName.textContent = (userInfo.first_name || '') + ' ' + (userInfo.last_name || '');
                    if (!userName.textContent.trim()) userName.textContent = userInfo.username || 'User';
                }
                var userEmail = document.getElementById('userEmail');
                if (userEmail && userInfo.email) userEmail.textContent = userInfo.email;
            }
        } catch (e) {
            console.error('include-auth-new.js: Error updating user info display:', e);
        }

    } else {
        console.log('include-auth-new.js: Updating UI for logged-out user');
        // Inject CSS to show auth buttons and hide user menu
        const styleId = 'auth-ui-style';
        let style = document.getElementById(styleId);
        if (!style) {
            style = document.createElement('style');
            style.id = styleId;
            document.head.appendChild(style);
        }
        style.textContent = `
            #authContainer, .auth-buttons {
                display: flex !important; /* Use flex for container */
                visibility: visible !important;
            }
            a[href="login.html"], a[href="register.html"], 
            .login-btn, .register-btn, .auth-btn.login-btn, .auth-btn.register-btn {
                display: inline-block !important; /* Use inline-block for buttons */
                visibility: visible !important;
            }
            #userMenu, .user-menu {
                display: none !important;
                visibility: hidden !important;
            }
        `;
    }
}

// Immediately check auth state and update UI
updateAuthUI();

// Listen for changes to localStorage and update UI without reloading
window.addEventListener('storage', function(event) {
    if (event.key === 'auth_token' || event.key === 'user_info') {
        console.log(`include-auth-new.js: Storage event detected for ${event.key}. Updating UI.`);
        updateAuthUI(); // Update UI instead of reloading
        // window.location.reload(); // <-- Keep commented out / Remove permanently
    }
});

/**
 * auth-new.js used to duplicate the auth lifecycle and caused random logouts.
 * Keep this file limited to the immediate CSS toggle; auth.js remains the single
 * controller for authentication state and redirects.
 */

console.log('include-auth-new.js: auth-new.js auto-loader disabled; auth.js is the single auth controller.');
