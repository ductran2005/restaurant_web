import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Create Supabase client with service role key (bypass RLS)
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseKey)

    console.log('========================================')
    console.log('>>> Scheduler running at:', new Date().toISOString())
    console.log('========================================')

    const results = {
      autoAssignTables: await autoAssignTables(supabase),
      updateTableStatus: await updateTableStatus(supabase),
      autoCancelLate: await autoCancelLateBookings(supabase),
      lockPreOrders: await lockPreOrders(supabase),
      cleanupItems: await cleanupUnavailableItems(supabase),
    }

    console.log('========================================')
    console.log('<<< Scheduler completed successfully')
    console.log('========================================')

    return new Response(
      JSON.stringify({ 
        success: true, 
        results, 
        timestamp: new Date().toISOString() 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200
      }
    )
  } catch (error) {
    console.error('========================================')
    console.error('✗✗✗ CRITICAL ERROR ✗✗✗')
    console.error('Error:', error.message)
    console.error('========================================')
    
    return new Response(
      JSON.stringify({ 
        success: false,
        error: error.message,
        timestamp: new Date().toISOString()
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

/**
 * Auto-assign tables for bookings 60 mins before booking time
 */
async function autoAssignTables(supabase: any) {
  console.log('\n[Task 1] Auto-assigning tables...')
  
  const now = new Date()
  const targetTime = new Date(now.getTime() + 60 * 60 * 1000) // +60 mins
  const today = now.toISOString().split('T')[0]

  // Get CONFIRMED bookings without table
  const { data: bookings, error } = await supabase
    .from('bookings')
    .select('*')
    .eq('status', 'CONFIRMED')
    .is('table_id', null)
    .gte('booking_date', today)

  if (error) {
    console.error('[Task 1] ✗ Failed:', error.message)
    throw error
  }

  let assigned = 0
  for (const booking of bookings || []) {
    const bookingDateTime = new Date(`${booking.booking_date}T${booking.booking_time}`)
    
    // Check if booking is within time window
    if (bookingDateTime > now && bookingDateTime < targetTime) {
      // Find best available table (smallest capacity >= party_size)
      const { data: tables } = await supabase
        .from('tables')
        .select('*')
        .gte('capacity', booking.party_size)
        .order('capacity', { ascending: true })
        .limit(10)

      if (tables && tables.length > 0) {
        // Check for time conflicts
        let bestTable = null
        for (const table of tables) {
          const hasConflict = await checkTimeConflict(
            supabase, 
            table.table_id, 
            booking.booking_date, 
            booking.booking_time,
            booking.booking_id
          )
          
          if (!hasConflict) {
            bestTable = table
            break
          }
        }

        if (bestTable) {
          // Assign table
          await supabase
            .from('bookings')
            .update({ 
              table_id: bestTable.table_id, 
              updated_at: new Date().toISOString() 
            })
            .eq('booking_id', booking.booking_id)

          // Set table to RESERVED
          await supabase
            .from('tables')
            .update({ status: 'RESERVED' })
            .eq('table_id', bestTable.table_id)

          assigned++
          console.log(`✓ Assigned table ${bestTable.table_name} to booking ${booking.booking_code}`)
        } else {
          console.log(`✗ No available table for booking ${booking.booking_code} (party: ${booking.party_size})`)
        }
      }
    }
  }

  console.log(`[Task 1] ✓ Completed - Assigned ${assigned} tables`)
  return { assigned }
}

/**
 * Update table status to RESERVED for bookings 15-30 mins away
 */
async function updateTableStatus(supabase: any) {
  console.log('\n[Task 2] Updating table status to RESERVED...')
  
  const now = new Date()
  const targetTime = new Date(now.getTime() + 30 * 60 * 1000) // +30 mins
  const today = now.toISOString().split('T')[0]

  const { data: bookings, error } = await supabase
    .from('bookings')
    .select('*, tables(*)')
    .eq('status', 'CONFIRMED')
    .not('table_id', 'is', null)
    .eq('booking_date', today)

  if (error) {
    console.error('[Task 2] ✗ Failed:', error.message)
    throw error
  }

  let updated = 0
  for (const booking of bookings || []) {
    const bookingDateTime = new Date(`${booking.booking_date}T${booking.booking_time}`)
    
    if (bookingDateTime <= targetTime && bookingDateTime > now) {
      if (booking.tables && booking.tables.status === 'EMPTY') {
        await supabase
          .from('tables')
          .update({ status: 'RESERVED' })
          .eq('table_id', booking.table_id)
        
        updated++
        console.log(`✓ Set table ${booking.tables.table_name} to RESERVED`)
      }
    }
  }

  console.log(`[Task 2] ✓ Completed - Updated ${updated} tables`)
  return { updated }
}

/**
 * Auto-cancel bookings if customer is late
 * Regular bookings: 20 mins late
 * Pre-order bookings: 40 mins late (more grace time)
 */
async function autoCancelLateBookings(supabase: any) {
  console.log('\n[Task 3] Auto-cancelling late bookings...')
  
  const now = new Date()

  const { data: bookings, error } = await supabase
    .from('bookings')
    .select('*, pre_order_items(*)')
    .eq('status', 'CONFIRMED')

  if (error) {
    console.error('[Task 3] ✗ Failed:', error.message)
    throw error
  }

  let cancelled = 0
  for (const booking of bookings || []) {
    const bookingDateTime = new Date(`${booking.booking_date}T${booking.booking_time}`)
    const hasPreOrder = booking.pre_order_items && booking.pre_order_items.length > 0
    const graceMinutes = hasPreOrder ? 40 : 20
    const cancelTime = new Date(bookingDateTime.getTime() + graceMinutes * 60 * 1000)

    if (now > cancelTime) {
      const minutesLate = Math.floor((now.getTime() - bookingDateTime.getTime()) / (60 * 1000))
      
      // Prepare updates
      const updates: any = {
        status: 'CANCELLED',
        cancel_reason: hasPreOrder 
          ? `Tự động hủy: Khách có pre-order không đến sau ${minutesLate} phút (cọc bị tịch thu)`
          : `Tự động hủy: Khách không đến sau ${minutesLate} phút`,
        updated_at: new Date().toISOString()
      }

      // Forfeit deposit if has pre-order and deposit was paid
      if (hasPreOrder && booking.deposit_status === 'PAID') {
        updates.deposit_status = 'FORFEITED'
        console.log(`⚠ Deposit forfeited for booking ${booking.booking_code} (amount: ${booking.deposit_amount})`)
      }

      // Update booking
      await supabase
        .from('bookings')
        .update(updates)
        .eq('booking_id', booking.booking_id)

      // Free table if assigned
      if (booking.table_id) {
        await supabase
          .from('tables')
          .update({ status: 'EMPTY' })
          .eq('table_id', booking.table_id)
        
        console.log(`✓ Freed table from booking ${booking.booking_code}`)
      }

      cancelled++
      console.log(`✓ Auto-cancelled booking ${booking.booking_code} (late by ${minutesLate} mins)`)
    }
  }

  console.log(`[Task 3] ✓ Completed - Cancelled ${cancelled} bookings`)
  return { cancelled }
}

/**
 * Lock pre-orders 60 mins before booking time
 */
async function lockPreOrders(supabase: any) {
  console.log('\n[Task 4] Locking pre-orders...')
  
  const now = new Date()
  const lockTime = new Date(now.getTime() + 60 * 60 * 1000) // +60 mins

  const { data: bookings, error } = await supabase
    .from('bookings')
    .select('*')
    .in('status', ['PENDING', 'CONFIRMED'])
    .is('preorder_locked_at', null)

  if (error) {
    console.error('[Task 4] ✗ Failed:', error.message)
    throw error
  }

  let locked = 0
  for (const booking of bookings || []) {
    const bookingDateTime = new Date(`${booking.booking_date}T${booking.booking_time}`)
    
    if (bookingDateTime <= lockTime) {
      await supabase
        .from('bookings')
        .update({ preorder_locked_at: new Date().toISOString() })
        .eq('booking_id', booking.booking_id)

      locked++
      console.log(`✓ Locked pre-order for booking ${booking.booking_code}`)
    }
  }

  console.log(`[Task 4] ✓ Completed - Locked ${locked} pre-orders`)
  return { locked }
}

/**
 * Cleanup unavailable items from active pre-orders
 */
async function cleanupUnavailableItems(supabase: any) {
  console.log('\n[Task 5] Cleaning up unavailable items...')
  
  const today = new Date().toISOString().split('T')[0]

  const { data: bookings, error } = await supabase
    .from('bookings')
    .select('*, pre_order_items(*, products(*))')
    .eq('status', 'CONFIRMED')
    .eq('booking_date', today)

  if (error) {
    console.error('[Task 5] ✗ Failed:', error.message)
    throw error
  }

  let cleaned = 0
  let itemsRemoved = 0

  for (const booking of bookings || []) {
    if (booking.pre_order_items && booking.pre_order_items.length > 0) {
      let hasChanges = false
      
      for (const item of booking.pre_order_items) {
        // Remove if product is unavailable or out of stock
        if (item.products && 
            (item.products.status === 'UNAVAILABLE' || item.products.quantity < item.quantity)) {
          
          await supabase
            .from('pre_order_items')
            .delete()
            .eq('pre_order_item_id', item.pre_order_item_id)
          
          hasChanges = true
          itemsRemoved++
          console.log(`✓ Removed unavailable item ${item.products.product_name} from booking ${booking.booking_code}`)
        }
      }
      
      if (hasChanges) {
        cleaned++
      }
    }
  }

  console.log(`[Task 5] ✓ Completed - Cleaned ${cleaned} bookings, removed ${itemsRemoved} items`)
  return { cleaned, itemsRemoved }
}

/**
 * Check if table has time conflict with other bookings
 * Assumes 2-hour booking duration
 */
async function checkTimeConflict(
  supabase: any, 
  tableId: number, 
  date: string, 
  time: string,
  excludeBookingId?: number
): Promise<boolean> {
  const { data: existingBookings, error } = await supabase
    .from('bookings')
    .select('booking_time')
    .eq('table_id', tableId)
    .eq('booking_date', date)
    .not('status', 'in', '(CANCELLED,NO_SHOW,COMPLETED)')

  if (error) return false
  if (!existingBookings || existingBookings.length === 0) return false

  const newStart = parseTime(time)
  const newEnd = newStart + 2 * 60 // +2 hours in minutes

  for (const existing of existingBookings) {
    const existingStart = parseTime(existing.booking_time)
    const existingEnd = existingStart + 2 * 60

    // Check overlap
    if (!(newEnd <= existingStart || newStart >= existingEnd)) {
      return true // Conflict found
    }
  }

  return false // No conflict
}

/**
 * Parse time string (HH:MM:SS or HH:MM) to minutes since midnight
 */
function parseTime(timeStr: string): number {
  const parts = timeStr.split(':')
  const hours = parseInt(parts[0])
  const minutes = parseInt(parts[1])
  return hours * 60 + minutes
}
