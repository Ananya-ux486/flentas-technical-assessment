# Task 4: Step-by-Step Setup Guide

## CloudWatch Billing Alarm Setup

### Step 1: Enable Billing Alerts (One-time setup)

1. Sign in to AWS Console
2. Click your account name (top right) → **"Billing and Cost Management"**
3. In left sidebar, click **"Billing preferences"**
4. Scroll down to **"Alert preferences"**
5. Check these boxes:
   - ☑ **"Receive Free Tier Usage Alerts"**
   - ☑ **"Receive Billing Alerts"**
6. Enter your email address in the box
7. Click **"Save preferences"**

### Step 2: Create Billing Alarm in CloudWatch

1. Go to **CloudWatch** service (search in top bar)
2. In left sidebar, click **"Alarms"** → **"All alarms"**
3. Click orange **"Create alarm"** button
4. Click **"Select metric"**
5. Click **"Billing"** (if you don't see it, make sure you enabled billing alerts in Step 1)
6. Click **"Total Estimated Charge"**
7. Select the checkbox next to **"USD"** currency
8. Click **"Select metric"** button (bottom right)

### Step 3: Configure Alarm Threshold

1. Under "Metric", you'll see "EstimatedCharges"
2. Under "Conditions":
   - Threshold type: **Static**
   - Whenever EstimatedCharges is: **Greater**
   - than: **1.2** (this is approximately ₹100)
3. Click **"Next"**

### Step 4: Configure Notifications

1. Under "Notification":
   - Alarm state trigger: **In alarm**
   - Select an SNS topic: **Create new topic**
   - Topic name: **Billing-Alerts**
   - Email endpoints: **your-email@example.com**
2. Click **"Create topic"**
3. Click **"Next"**

### Step 5: Name and Create Alarm

1. Alarm name: **Billing-Alert-100-Rupees**
2. Alarm description: **Alert when estimated charges exceed ₹100**
3. Click **"Next"**
4. Review settings
5. Click **"Create alarm"**

### Step 6: Confirm Email Subscription

1. Check your email inbox
2. Look for email from **"AWS Notifications"**
3. Click **"Confirm subscription"** link
4. You'll see a confirmation page
5. Your alarm is now active!

## Free Tier Usage Alerts

These are automatically enabled when you checked "Receive Free Tier Usage Alerts" in Step 1.

AWS will email you when you:
- Approach 85% of Free Tier limit for any service
- Exceed 100% of Free Tier limit

## Testing Your Alarm

To verify the alarm works:

1. Go to CloudWatch → Alarms
2. Find your "Billing-Alert-100-Rupees" alarm
3. Click on it
4. Click **"Actions"** → **"Test alarm"**
5. You should receive a test email

## Screenshots to Take

### Screenshot 1: Billing Alarm
1. Go to CloudWatch → Alarms
2. Your alarm should show "OK" status (green)
3. Click on the alarm name
4. Take screenshot showing:
   - Alarm name
   - Status (OK)
   - Threshold ($1.20)
   - Graph
5. Save as: `billing-alarm.png`

### Screenshot 2: Free Tier Alerts
1. Go to Billing and Cost Management
2. Click "Billing preferences"
3. Scroll to "Alert preferences"
4. Take screenshot showing:
   - ☑ Receive Free Tier Usage Alerts (checked)
   - ☑ Receive Billing Alerts (checked)
   - Your email address
5. Save as: `free-tier-alerts.png`

## Troubleshooting

**Problem**: Don't see "Billing" in CloudWatch metrics
**Solution**: Make sure you enabled "Receive Billing Alerts" in Billing preferences and wait 15 minutes

**Problem**: Not receiving emails
**Solution**: Check spam folder, verify email confirmation was clicked

**Problem**: Alarm shows "Insufficient data"
**Solution**: Normal for new alarms. Wait 6-8 hours for billing data to populate

**Problem**: Want to change threshold
**Solution**: Edit the alarm, change the threshold value, save

## Important Notes

- Billing data updates every 6-8 hours, not real-time
- Alarms only work in **us-east-1** region (N. Virginia)
- Free Tier alerts are automatic, no configuration needed beyond enabling
- You can create multiple alarms for different thresholds (₹50, ₹100, ₹200, etc.)
