# Password Reset Email Troubleshooting Guide

## Issue: Not Receiving Password Reset Emails

### ✅ Changes Made
1. **Added detailed logging** - Check console for error messages
2. **Improved error handling** - Shows specific error messages
3. **Extended notification duration** - 5 seconds instead of 4
4. **Added spam folder reminder** - Message now says "Check inbox and spam folder"
5. **Removed OTP Login button** - Cleaned up login screen

---

## Troubleshooting Steps

### Step 1: Verify Firebase Email Settings
1. Go to **Firebase Console** → Your Project
2. Navigate to **Authentication** → **Templates** tab
3. Click on **Password reset** template
4. Verify the following:
   - ✅ Template is enabled
   - ✅ Sender name is set (e.g., "Appointment App")
   - ✅ Reply-to email is configured
   - ✅ Template looks correct

### Step 2: Check Email Provider Settings
Firebase uses its own email service, but some configurations might block it:

**Gmail Users:**
- Check **Spam/Junk** folder
- Check **Promotions** tab
- Add `noreply@<your-project-id>.firebaseapp.com` to contacts

**Other Email Providers:**
- Check spam/junk folders
- Whitelist Firebase domains
- Check email provider's security settings

### Step 3: Verify Email in Firebase
1. Go to **Firebase Console** → **Authentication** → **Users**
2. Find your user account
3. Verify the email address is correct
4. Check if email is verified (green checkmark)

### Step 4: Test with Different Email
Try the password reset with:
- ✅ Gmail account
- ✅ Different email provider
- ✅ Newly created test account

### Step 5: Check Firebase Quotas
1. Go to **Firebase Console** → **Usage and billing**
2. Check if you've hit any email sending limits
3. Free tier allows: **100 emails/day**

### Step 6: Enable Email Verification (Optional)
If password reset emails aren't working, you might need to configure SMTP:

1. Go to **Firebase Console** → **Authentication** → **Templates**
2. Click **Customize email templates**
3. Configure custom SMTP server (if needed)

---

## Testing the Feature

### Test 1: Valid Email
```
1. Go to Login screen
2. Click "Forgot Password?"
3. Enter: your-registered-email@gmail.com
4. Click "Send Reset Link"
5. Check console logs for: "Password reset email sent successfully"
6. Check email inbox (and spam folder)
```

**Expected Result:**
- ✅ Success message appears
- ✅ Console shows success log
- ✅ Email arrives within 1-2 minutes

### Test 2: Invalid Email
```
1. Go to Forgot Password screen
2. Enter: nonexistent@example.com
3. Click "Send Reset Link"
```

**Expected Result:**
- ❌ Error: "No account found with this email."

### Test 3: Invalid Format
```
1. Go to Forgot Password screen
2. Enter: invalid-email
3. Click "Send Reset Link"
```

**Expected Result:**
- ❌ Error: "Enter a valid email"

---

## Console Logs to Check

When you click "Send Reset Link", check browser console (F12) for:

**Success:**
```
Attempting to send password reset email to: user@example.com
Password reset email sent successfully
```

**Error:**
```
FirebaseAuthException: user-not-found - There is no user record...
```

---

## Common Issues & Solutions

### Issue 1: "No account found with this email"
**Solution:** 
- Verify email is registered in Firebase Authentication
- Check for typos in email address
- Ensure user account exists

### Issue 2: "Too many attempts"
**Solution:**
- Wait 15-30 minutes before trying again
- Firebase rate limits password reset requests

### Issue 3: Email arrives but link doesn't work
**Solution:**
- Link expires after 1 hour
- Request a new password reset email
- Ensure you're clicking the latest link

### Issue 4: Email never arrives
**Possible Causes:**
- Email is in spam/junk folder
- Email provider is blocking Firebase emails
- Firebase email quota exceeded
- Email template is disabled in Firebase

**Solutions:**
- Check spam folder
- Whitelist Firebase sender
- Wait and try again later
- Contact Firebase support if issue persists

---

## Alternative: Manual Password Reset (Admin)

If emails aren't working, admin can reset user passwords manually:

### Option 1: Firebase Console
1. Go to **Firebase Console** → **Authentication** → **Users**
2. Find the user
3. Click three dots (⋮) → **Reset password**
4. Firebase will send email directly

### Option 2: Delete & Recreate Account
1. User creates new account with same email
2. Admin approves provider application (if applicable)
3. User can login with new password

---

## Production Checklist

Before deploying to production:

- [ ] Test password reset with multiple email providers
- [ ] Verify Firebase email templates are customized
- [ ] Set up custom domain for emails (optional)
- [ ] Configure SMTP server (optional, for better deliverability)
- [ ] Test email delivery in different regions
- [ ] Monitor Firebase email quota usage
- [ ] Set up email delivery monitoring/alerts

---

## Firebase Email Template Customization

To improve email deliverability:

1. **Customize Sender Name:**
   - Go to Templates → Password reset
   - Set sender name to your app name
   - Example: "Appointment App Support"

2. **Customize Email Content:**
   - Make it clear and professional
   - Include app logo
   - Add support contact information

3. **Set Reply-To Email:**
   - Use a real email address
   - Example: support@yourdomain.com

---

## Debug Mode

The updated code now includes console logging. To debug:

1. Open browser DevTools (F12)
2. Go to Console tab
3. Try password reset
4. Look for logs starting with:
   - "Attempting to send..."
   - "Password reset email sent successfully"
   - "FirebaseAuthException: ..."

This will help identify the exact issue.

---

## Contact Firebase Support

If none of the above works:

1. Go to **Firebase Console** → **Support**
2. Create a support ticket
3. Include:
   - Project ID
   - Email address being tested
   - Console error logs
   - Steps to reproduce

Firebase support can check server-side logs and email delivery status.
