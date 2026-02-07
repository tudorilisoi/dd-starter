import { MigrateUpArgs, MigrateDownArgs, sql } from '@payloadcms/db-postgres'

export async function up({ db, payload, req }: MigrateUpArgs): Promise<void> {
  await db.execute(sql`
   ALTER TABLE "two_factors" DISABLE ROW LEVEL SECURITY;
  ALTER TABLE "passkeys" DISABLE ROW LEVEL SECURITY;
  DROP TABLE "two_factors" CASCADE;
  DROP TABLE "passkeys" CASCADE;
  ALTER TABLE "payload_locked_documents_rels" DROP CONSTRAINT "payload_locked_documents_rels_two_factors_fk";
  
  ALTER TABLE "payload_locked_documents_rels" DROP CONSTRAINT "payload_locked_documents_rels_passkeys_fk";
  
  DROP INDEX "payload_locked_documents_rels_two_factors_id_idx";
  DROP INDEX "payload_locked_documents_rels_passkeys_id_idx";
  ALTER TABLE "users" DROP COLUMN "two_factor_enabled";
  ALTER TABLE "payload_locked_documents_rels" DROP COLUMN "two_factors_id";
  ALTER TABLE "payload_locked_documents_rels" DROP COLUMN "passkeys_id";`)
}

export async function down({ db, payload, req }: MigrateDownArgs): Promise<void> {
  await db.execute(sql`
   CREATE TABLE "two_factors" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"secret" varchar NOT NULL,
  	"backup_codes" varchar NOT NULL,
  	"user_id" integer NOT NULL,
  	"updated_at" timestamp(3) with time zone DEFAULT now() NOT NULL,
  	"created_at" timestamp(3) with time zone DEFAULT now() NOT NULL
  );
  
  CREATE TABLE "passkeys" (
  	"id" serial PRIMARY KEY NOT NULL,
  	"name" varchar,
  	"public_key" varchar NOT NULL,
  	"user_id" integer NOT NULL,
  	"credential_i_d" varchar NOT NULL,
  	"counter" numeric NOT NULL,
  	"device_type" varchar NOT NULL,
  	"backed_up" boolean DEFAULT false NOT NULL,
  	"transports" varchar,
  	"aaguid" varchar,
  	"updated_at" timestamp(3) with time zone DEFAULT now() NOT NULL,
  	"created_at" timestamp(3) with time zone DEFAULT now() NOT NULL
  );
  
  ALTER TABLE "users" ADD COLUMN "two_factor_enabled" boolean DEFAULT false;
  ALTER TABLE "payload_locked_documents_rels" ADD COLUMN "two_factors_id" integer;
  ALTER TABLE "payload_locked_documents_rels" ADD COLUMN "passkeys_id" integer;
  ALTER TABLE "two_factors" ADD CONSTRAINT "two_factors_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;
  ALTER TABLE "passkeys" ADD CONSTRAINT "passkeys_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;
  CREATE INDEX "two_factors_user_idx" ON "two_factors" USING btree ("user_id");
  CREATE INDEX "two_factors_updated_at_idx" ON "two_factors" USING btree ("updated_at");
  CREATE INDEX "two_factors_created_at_idx" ON "two_factors" USING btree ("created_at");
  CREATE INDEX "passkeys_user_idx" ON "passkeys" USING btree ("user_id");
  CREATE INDEX "passkeys_updated_at_idx" ON "passkeys" USING btree ("updated_at");
  CREATE INDEX "passkeys_created_at_idx" ON "passkeys" USING btree ("created_at");
  ALTER TABLE "payload_locked_documents_rels" ADD CONSTRAINT "payload_locked_documents_rels_two_factors_fk" FOREIGN KEY ("two_factors_id") REFERENCES "public"."two_factors"("id") ON DELETE cascade ON UPDATE no action;
  ALTER TABLE "payload_locked_documents_rels" ADD CONSTRAINT "payload_locked_documents_rels_passkeys_fk" FOREIGN KEY ("passkeys_id") REFERENCES "public"."passkeys"("id") ON DELETE cascade ON UPDATE no action;
  CREATE INDEX "payload_locked_documents_rels_two_factors_id_idx" ON "payload_locked_documents_rels" USING btree ("two_factors_id");
  CREATE INDEX "payload_locked_documents_rels_passkeys_id_idx" ON "payload_locked_documents_rels" USING btree ("passkeys_id");`)
}
