
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";

ALTER SCHEMA "public" OWNER TO "postgres";

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";

CREATE OR REPLACE FUNCTION "public"."add_member_on_created_chat"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$BEGIN
  INSERT INTO public.chat_members (user_id, chat_id) 
  VALUES (
    NEW.owner_id,
    NEW.id
  );
  RETURN NEW;
END;$$;

ALTER FUNCTION "public"."add_member_on_created_chat"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."create_user_meta_on_signup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$BEGIN
  INSERT INTO public.user_metas (id, name) 
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data ->> 'name'
  );
  RETURN NEW;
END;$$;

ALTER FUNCTION "public"."create_user_meta_on_signup"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."get_user_id_by_email"("input_email" character varying) RETURNS "uuid"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$declare
  selected_id uuid;
BEGIN
  SELECT id
    FROM auth.users
    WHERE users.email = input_email
    limit 1
    into selected_id;

  return selected_id;
END;$$;

ALTER FUNCTION "public"."get_user_id_by_email"("input_email" character varying) OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."install_available_extensions_and_test"() RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
DECLARE extension_name TEXT;
allowed_extentions TEXT[] := string_to_array(current_setting('supautils.privileged_extensions'), ',');
BEGIN 
  FOREACH extension_name IN ARRAY allowed_extentions 
  LOOP
    SELECT trim(extension_name) INTO extension_name;
    /* skip below extensions check for now */
    CONTINUE WHEN extension_name = 'pgroonga' OR  extension_name = 'pgroonga_database' OR extension_name = 'pgsodium';
    CONTINUE WHEN extension_name = 'plpgsql' OR  extension_name = 'plpgsql_check' OR extension_name = 'pgtap';
    CONTINUE WHEN extension_name = 'supabase_vault' OR extension_name = 'wrappers';
    RAISE notice 'START TEST FOR: %', extension_name;
    EXECUTE format('DROP EXTENSION IF EXISTS %s CASCADE', quote_ident(extension_name));
    EXECUTE format('CREATE EXTENSION %s CASCADE', quote_ident(extension_name));
    RAISE notice 'END TEST FOR: %', extension_name;
  END LOOP;
    RAISE notice 'EXTENSION TESTS COMPLETED..';
    return true;
END;
$$;

ALTER FUNCTION "public"."install_available_extensions_and_test"() OWNER TO "postgres";

CREATE OR REPLACE FUNCTION "public"."is_current_user_as_chat_member"("selected_chat_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$declare
  is_member boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM public.chat_members
    WHERE chat_members.chat_id = selected_chat_id 
    AND chat_members.user_id = (SELECT auth.uid())
  ) into is_member;

  return is_member;
END;$$;

ALTER FUNCTION "public"."is_current_user_as_chat_member"("selected_chat_id" "uuid") OWNER TO "authenticated";

CREATE OR REPLACE FUNCTION "public"."is_current_user_as_owner_chat"("selected_chat_id" "uuid") RETURNS boolean
    LANGUAGE "plpgsql"
    AS $$
declare
  is_owner boolean;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM public.chats
    WHERE chats.id = selected_chat_id 
    AND chats.owner_id = (SELECT auth.uid())
  ) into is_owner;

  return is_owner;
END;
$$;

ALTER FUNCTION "public"."is_current_user_as_owner_chat"("selected_chat_id" "uuid") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

CREATE TABLE IF NOT EXISTS "public"."chat_members" (
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "chat_id" "uuid" NOT NULL
);

ALTER TABLE "public"."chat_members" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."chats" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "name" character varying NOT NULL,
    "owner_id" "uuid" DEFAULT "auth"."uid"() NOT NULL
);

ALTER TABLE "public"."chats" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "message" "text" NOT NULL,
    "chat_id" "uuid" NOT NULL,
    "user_id" "uuid" DEFAULT "auth"."uid"() NOT NULL
);

ALTER TABLE "public"."messages" OWNER TO "postgres";

CREATE TABLE IF NOT EXISTS "public"."user_metas" (
    "id" "uuid" NOT NULL,
    "name" character varying NOT NULL,
    "pic_url" character varying,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);

ALTER TABLE "public"."user_metas" OWNER TO "postgres";

CREATE OR REPLACE VIEW "public"."chats_whit_last_messages" WITH ("security_invoker"='on') AS
 SELECT "chats"."id",
    "chats"."created_at",
    "chats"."name",
    "chats"."owner_id",
    "messages"."message" AS "last_message_message",
    "messages"."created_at" AS "last_message_created_at",
    "user_metas"."name" AS "last_message_user_name"
   FROM (("public"."chats"
     LEFT JOIN "public"."messages" ON (("messages"."id" = ( SELECT "b"."id"
           FROM "public"."messages" "b"
          WHERE ("b"."chat_id" = "chats"."id")
          ORDER BY "b"."created_at" DESC
         LIMIT 1))))
     LEFT JOIN "public"."user_metas" ON (("messages"."user_id" = "user_metas"."id")));

ALTER TABLE "public"."chats_whit_last_messages" OWNER TO "postgres";

ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_pkey" PRIMARY KEY ("user_id", "chat_id");

ALTER TABLE ONLY "public"."chats"
    ADD CONSTRAINT "chats_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."user_metas"
    ADD CONSTRAINT "user_metas_pkey" PRIMARY KEY ("id");

CREATE OR REPLACE TRIGGER "add_member_on_created_chat" AFTER INSERT ON "public"."chats" FOR EACH ROW EXECUTE FUNCTION "public"."add_member_on_created_chat"();

ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "public"."chats"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."chat_members"
    ADD CONSTRAINT "chat_members_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_metas"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."chats"
    ADD CONSTRAINT "chats_owner_id_fkey" FOREIGN KEY ("owner_id") REFERENCES "public"."user_metas"("id");

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_chat_id_fkey" FOREIGN KEY ("chat_id") REFERENCES "public"."chats"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."user_metas"("id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY "public"."user_metas"
    ADD CONSTRAINT "user_metas_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;

CREATE POLICY "Enable delete for owners chat" ON "public"."chat_members" FOR DELETE TO "authenticated" USING (("public"."is_current_user_as_owner_chat"("chat_id") AND ("user_id" <> ( SELECT "auth"."uid"() AS "uid"))));

CREATE POLICY "Enable delete for users based on owner" ON "public"."chats" FOR DELETE TO "authenticated" USING ((( SELECT "auth"."uid"() AS "uid") = "owner_id"));

CREATE POLICY "Enable insert for authenticated users only" ON "public"."chats" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for authenticated users only" ON "public"."messages" FOR INSERT TO "authenticated" WITH CHECK (true);

CREATE POLICY "Enable insert for owners chat" ON "public"."chat_members" FOR INSERT TO "authenticated" WITH CHECK ("public"."is_current_user_as_owner_chat"("chat_id"));

CREATE POLICY "Enable read access for all users" ON "public"."chat_members" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for authenticated only" ON "public"."chats" FOR SELECT TO "authenticated" USING ((("owner_id" = ( SELECT "auth"."uid"() AS "uid")) OR "public"."is_current_user_as_chat_member"("id")));

CREATE POLICY "Enable read access for authenticated user" ON "public"."user_metas" FOR SELECT TO "authenticated" USING (true);

CREATE POLICY "Enable read access for members only" ON "public"."messages" FOR SELECT TO "authenticated" USING ("public"."is_current_user_as_chat_member"("chat_id"));

ALTER TABLE "public"."chat_members" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."chats" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."user_metas" ENABLE ROW LEVEL SECURITY;

ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";

ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."messages";

REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";
GRANT ALL ON SCHEMA "public" TO PUBLIC;

GRANT ALL ON FUNCTION "public"."add_member_on_created_chat"() TO "anon";
GRANT ALL ON FUNCTION "public"."add_member_on_created_chat"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."add_member_on_created_chat"() TO "service_role";

GRANT ALL ON FUNCTION "public"."create_user_meta_on_signup"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_user_meta_on_signup"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_user_meta_on_signup"() TO "service_role";

GRANT ALL ON FUNCTION "public"."get_user_id_by_email"("input_email" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."get_user_id_by_email"("input_email" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_user_id_by_email"("input_email" character varying) TO "service_role";

GRANT ALL ON FUNCTION "public"."install_available_extensions_and_test"() TO "anon";
GRANT ALL ON FUNCTION "public"."install_available_extensions_and_test"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."install_available_extensions_and_test"() TO "service_role";

GRANT ALL ON FUNCTION "public"."is_current_user_as_owner_chat"("selected_chat_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_current_user_as_owner_chat"("selected_chat_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_current_user_as_owner_chat"("selected_chat_id" "uuid") TO "service_role";

GRANT ALL ON TABLE "public"."chat_members" TO "anon";
GRANT ALL ON TABLE "public"."chat_members" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_members" TO "service_role";

GRANT ALL ON TABLE "public"."chats" TO "anon";
GRANT ALL ON TABLE "public"."chats" TO "authenticated";
GRANT ALL ON TABLE "public"."chats" TO "service_role";

GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";

GRANT ALL ON TABLE "public"."user_metas" TO "anon";
GRANT ALL ON TABLE "public"."user_metas" TO "authenticated";
GRANT ALL ON TABLE "public"."user_metas" TO "service_role";

GRANT ALL ON TABLE "public"."chats_whit_last_messages" TO "anon";
GRANT ALL ON TABLE "public"."chats_whit_last_messages" TO "authenticated";
GRANT ALL ON TABLE "public"."chats_whit_last_messages" TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";

RESET ALL;
