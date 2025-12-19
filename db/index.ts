import { drizzle } from "drizzle-orm/neon-serverless";
import { Pool as NeonPool, neonConfig } from "@neondatabase/serverless";
import { drizzle as drizzlePg, NodePgDatabase } from "drizzle-orm/node-postgres";
import { NeonDatabase } from "drizzle-orm/neon-serverless";
import { Pool as PgPool } from "pg";
import * as schema from "../shared/schema";
import ws from "ws";

// Support for Supabase, Neon, or local PostgreSQL
const isLocalPostgres = process.env.DATABASE_URL?.includes('localhost') || 
                        process.env.DATABASE_URL?.includes('127.0.0.1');

// Check if using Supabase (contains supabase.co domain)
const isSupabase = process.env.DATABASE_URL?.includes('supabase.co');

let db: NodePgDatabase<typeof schema> | NeonDatabase<typeof schema>;

if (isLocalPostgres || isSupabase) {
  // Use standard pg driver for local PostgreSQL or Supabase
  const pool = new PgPool({
    connectionString: process.env.DATABASE_URL!,
    ssl: isSupabase ? { rejectUnauthorized: false } : undefined,
  });
  db = drizzlePg(pool, { schema });
} else {
  // Neon serverless for other production deployments
  neonConfig.webSocketConstructor = ws;
  const pool = new NeonPool({
    connectionString: process.env.DATABASE_URL!,
  });
  db = drizzle(pool, { schema });
}

export { db };
