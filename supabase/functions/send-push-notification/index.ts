import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const APNS_HOST = 'api.push.apple.com'
const APNS_SANDBOX_HOST = 'api.sandbox.push.apple.com'

interface PushNotificationPayload {
  deviceTokens: string[]
  title: string
  body: string
  type: string
  data?: Record<string, any>
  badge?: number
  sound?: string
  teamId?: string
}

async function sendAPNSNotification(
  deviceToken: string,
  payload: any,
  isSandbox: boolean = true
) {
  const host = isSandbox ? APNS_SANDBOX_HOST : APNS_HOST
  const apnsKeyId = Deno.env.get('APNS_KEY_ID')
  const apnsTeamId = Deno.env.get('APNS_TEAM_ID')
  const apnsKey = Deno.env.get('APNS_KEY')

  if (!apnsKeyId || !apnsTeamId || !apnsKey) {
    throw new Error('APNS credentials not configured')
  }

  // Create JWT token for APNS authentication
  const header = {
    alg: 'ES256',
    kid: apnsKeyId,
  }

  const now = Math.floor(Date.now() / 1000)
  const claims = {
    iss: apnsTeamId,
    iat: now,
  }

  // Import jose for JWT signing
  const { SignJWT, importPKCS8 } = await import('https://deno.land/x/jose@v4.14.4/index.ts')
  
  const privateKey = await importPKCS8(apnsKey, 'ES256')
  const jwt = await new SignJWT(claims)
    .setProtectedHeader(header)
    .setIssuedAt()
    .sign(privateKey)

  // Send to APNS
  const bundleId = 'com.basketballers.expressunited'
  const url = `https://${host}/3/device/${deviceToken}`

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'authorization': `bearer ${jwt}`,
      'apns-topic': bundleId,
      'apns-push-type': 'alert',
      'apns-priority': '10',
    },
    body: JSON.stringify(payload),
  })

  if (!response.ok) {
    const errorText = await response.text()
    console.error(`APNS Error for token ${deviceToken}:`, errorText)
    throw new Error(`APNS request failed: ${response.status} ${errorText}`)
  }

  return { success: true, deviceToken }
}

serve(async (req) => {
  try {
    // Only allow POST requests
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        { status: 405, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Parse request body
    const { 
      deviceTokens, 
      title, 
      body, 
      type = 'announcement',
      data = {},
      badge,
      sound = 'default',
      teamId 
    }: PushNotificationPayload = await req.json()

    // Validate required fields
    if (!deviceTokens || deviceTokens.length === 0) {
      return new Response(
        JSON.stringify({ error: 'Device tokens required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    if (!title || !body) {
      return new Response(
        JSON.stringify({ error: 'Title and body required' }),
        { status: 400, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Build APNS payload
    const apnsPayload = {
      aps: {
        alert: {
          title,
          body,
        },
        sound,
        ...(badge !== undefined && { badge }),
      },
      type,
      ...data,
    }

    // Send to all device tokens
    const results = await Promise.allSettled(
      deviceTokens.map(token => 
        sendAPNSNotification(token, apnsPayload, true) // Using sandbox for now
      )
    )

    const successful = results.filter(r => r.status === 'fulfilled').length
    const failed = results.filter(r => r.status === 'rejected').length

    console.log(`Push notification sent: ${successful} successful, ${failed} failed`)

    return new Response(
      JSON.stringify({
        success: true,
        sent: successful,
        failed,
        results: results.map((r, i) => ({
          token: deviceTokens[i],
          status: r.status,
          ...(r.status === 'rejected' && { error: r.reason.message }),
        })),
      }),
      { status: 200, headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error sending push notification:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
