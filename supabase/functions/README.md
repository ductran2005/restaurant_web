# Supabase Edge Functions

## booking-scheduler

Background scheduler for restaurant booking system.

### Features

- Auto-assign tables 60 mins before booking time
- Update table status to RESERVED 30 mins before
- Auto-cancel late bookings (20 mins for regular, 40 mins for pre-orders)
- Lock pre-orders 60 mins before booking
- Cleanup unavailable items from pre-orders

### Setup

1. Install Supabase CLI:
```bash
# Windows (PowerShell with Scoop)
scoop install supabase

# Or with npm
npm install -g supabase
```

2. Login to Supabase:
```bash
supabase login
```

3. Link to your project:
```bash
supabase link --project-ref your-project-ref
```

4. Deploy function:
```bash
supabase functions deploy booking-scheduler
```

### Testing

Test locally:
```bash
supabase functions serve booking-scheduler
```

Test deployed function:
```bash
supabase functions invoke booking-scheduler --no-verify-jwt
```

Or with curl:
```bash
curl -X POST https://your-project-ref.supabase.co/functions/v1/booking-scheduler \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

### Setup Cron Job

#### Option 1: Supabase Cron (Pro plan required)

1. Go to Supabase Dashboard > Database > Cron Jobs
2. Create new job:
   - Name: `booking-scheduler`
   - Schedule: `*/5 * * * *` (every 5 minutes)
   - Command:
   ```sql
   SELECT net.http_post(
     url := 'https://your-project-ref.supabase.co/functions/v1/booking-scheduler',
     headers := '{"Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb
   );
   ```

#### Option 2: pg_cron (Free)

1. Enable pg_cron extension:
```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

2. Create cron job:
```sql
SELECT cron.schedule(
  'booking-scheduler',
  '*/5 * * * *',
  $$
  SELECT net.http_post(
    url := 'https://your-project-ref.supabase.co/functions/v1/booking-scheduler',
    headers := '{"Authorization": "Bearer YOUR_ANON_KEY"}'::jsonb
  );
  $$
);
```

3. View scheduled jobs:
```sql
SELECT * FROM cron.job;
```

4. View job run history:
```sql
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;
```

5. Unschedule job (if needed):
```sql
SELECT cron.unschedule('booking-scheduler');
```

### Monitoring

View logs:
```bash
supabase functions logs booking-scheduler
```

Or in Supabase Dashboard > Edge Functions > booking-scheduler > Logs

### Environment Variables

The function uses these environment variables (automatically set by Supabase):
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY`: Service role key (bypasses RLS)

### Troubleshooting

**Function not running:**
- Check logs: `supabase functions logs booking-scheduler`
- Verify cron job is scheduled: `SELECT * FROM cron.job;`
- Check function is deployed: Supabase Dashboard > Edge Functions

**Database connection errors:**
- Verify SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are set
- Check database is accessible

**Tasks failing:**
- Check database schema matches expected structure
- Verify RLS policies allow service role access
- Review function logs for specific errors
