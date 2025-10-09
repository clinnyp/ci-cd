import { serve } from '@hono/node-server'
import { Hono } from 'hono'

const app = new Hono()

app.get('/health', (c) => {
  return c.json({ message: 'OK' })
})

app.get('/', (c) => {
  return c.json({ message: 'Hello Hono! deployed on azure' })
})

app.get('/test', (c) => {
  return c.json({ message: 'Hello Hono! deployed on azure' })
})

serve({
  fetch: app.fetch,
  port: 3000
}, (info) => {
  console.log(`Server is running on http://localhost:${info.port}`)
})
