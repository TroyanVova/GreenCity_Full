--
-- PostgreSQL database dump
--

-- Dumped from database version 12.19 (Debian 12.19-1.pgdg110+1)
-- Dumped by pg_dump version 12.19 (Debian 12.19-1.pgdg110+1)

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

--
-- Name: fn_recommended_econews_by_opened_eco_news(bigint); Type: FUNCTION; Schema: public; Owner: greencity
--

CREATE FUNCTION public.fn_recommended_econews_by_opened_eco_news(current_eco_news_id bigint) RETURNS TABLE(id bigint, title character varying, text character varying, creation_date timestamp with time zone, image_path character varying, author_id bigint, source character varying, news_rating bigint, short_info character varying)
    LANGUAGE plpgsql
    AS $$
            BEGIN

            RETURN QUERY

                WITH recomendet_news AS (
        SELECT uniq_ent.*,
        count(tags_id) OVER(PARTITION BY eco_news_id) AS news_rating
        FROM (SELECT DISTINCT ent.* FROM eco_news_tags AS ent) AS uniq_ent

        WHERE uniq_ent.tags_id IN (SELECT t.id FROM eco_news_tags AS ent
        JOIN tags AS t ON t.id = ent.tags_id
        WHERE ent.eco_news_id = current_eco_news_id)
        UNION

        SELECT uniq_ent.*,
        0 AS news_rating
        FROM (SELECT DISTINCT ent.* FROM eco_news_tags AS ent) AS uniq_ent

        WHERE uniq_ent.tags_id NOT IN (SELECT t.id FROM eco_news_tags AS ent
        JOIN tags AS t ON t.id = ent.tags_id
        WHERE ent.eco_news_id = current_eco_news_id)
        )

            SELECT DISTINCT en.id, en.title, en.text, en.creation_date,
                            en.image_path, en.author_id, en.source, ren.news_rating, en.short_info
            FROM recomendet_news AS ren
                     JOIN eco_news AS en ON en.id = ren.eco_news_id
            WHERE en.id != current_eco_news_id
            ORDER BY ren.news_rating DESC, en.creation_date DESC, en.id
                LIMIT 3;

            END
    $$;


ALTER FUNCTION public.fn_recommended_econews_by_opened_eco_news(current_eco_news_id bigint) OWNER TO greencity;

--
-- Name: pg_buffercache_pages(); Type: FUNCTION; Schema: public; Owner: greencity
--

CREATE FUNCTION public.pg_buffercache_pages() RETURNS SETOF record
    LANGUAGE c
    AS '$libdir/pg_buffercache', 'pg_buffercache_pages';


ALTER FUNCTION public.pg_buffercache_pages() OWNER TO greencity;

--
-- Name: pg_stat_statements(boolean); Type: FUNCTION; Schema: public; Owner: greencity
--

CREATE FUNCTION public.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT queryid bigint, OUT query text, OUT calls bigint, OUT total_time double precision, OUT min_time double precision, OUT max_time double precision, OUT mean_time double precision, OUT stddev_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision) RETURNS SETOF record
    LANGUAGE c STRICT
    AS '$libdir/pg_stat_statements', 'pg_stat_statements_1_3';


ALTER FUNCTION public.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT queryid bigint, OUT query text, OUT calls bigint, OUT total_time double precision, OUT min_time double precision, OUT max_time double precision, OUT mean_time double precision, OUT stddev_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision) OWNER TO greencity;

--
-- Name: pg_stat_statements_reset(); Type: FUNCTION; Schema: public; Owner: greencity
--

CREATE FUNCTION public.pg_stat_statements_reset() RETURNS void
    LANGUAGE c
    AS '$libdir/pg_stat_statements', 'pg_stat_statements_reset';


ALTER FUNCTION public.pg_stat_statements_reset() OWNER TO greencity;

--
-- Name: address_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

CREATE SEQUENCE public.address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.address_id_seq OWNER TO greencity;

--
-- Name: bag_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

CREATE SEQUENCE public.bag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bag_id_seq OWNER TO greencity;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.categories (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    parent_category_id bigint,
    name_ua character varying(100)
);


ALTER TABLE public.categories OWNER TO greencity;

--
-- Name: category_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.categories ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.category_id_seq
    START WITH 11
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    created_date timestamp(6) without time zone NOT NULL,
    modified_date timestamp(6) without time zone NOT NULL,
    text character varying(255) NOT NULL,
    estimate_id bigint,
    parent_comment_id bigint,
    place_id bigint,
    user_id bigint
);


ALTER TABLE public.comments OWNER TO greencity;

--
-- Name: comment_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.comments ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: custom_shopping_list_items; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.custom_shopping_list_items (
    id bigint NOT NULL,
    text character varying(255) NOT NULL,
    user_id bigint NOT NULL,
    status character varying(12) DEFAULT 'ACTIVE'::character varying NOT NULL,
    date_completed timestamp(6) without time zone,
    habit_id bigint NOT NULL
);


ALTER TABLE public.custom_shopping_list_items OWNER TO greencity;

--
-- Name: custom_goals_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.custom_shopping_list_items ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.custom_goals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: databasechangelog; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255),
    deployment_id character varying(10)
);


ALTER TABLE public.databasechangelog OWNER TO greencity;

--
-- Name: databasechangeloglock; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


ALTER TABLE public.databasechangeloglock OWNER TO greencity;

--
-- Name: eco_news; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.eco_news (
    id bigint NOT NULL,
    creation_date timestamp with time zone NOT NULL,
    image_path character varying(255),
    author_id bigint,
    text character varying(63206) NOT NULL,
    title character varying(170) NOT NULL,
    source character varying(255),
    short_info character varying
);


ALTER TABLE public.eco_news OWNER TO greencity;

--
-- Name: eco_news_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.eco_news ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.eco_news_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: eco_news_tags; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.eco_news_tags (
    eco_news_id bigint NOT NULL,
    tags_id bigint NOT NULL
);


ALTER TABLE public.eco_news_tags OWNER TO greencity;

--
-- Name: eco_news_users_dislikes; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.eco_news_users_dislikes (
    eco_news_id bigint NOT NULL,
    users_id bigint NOT NULL
);


ALTER TABLE public.eco_news_users_dislikes OWNER TO greencity;

--
-- Name: eco_news_users_likes; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.eco_news_users_likes (
    eco_news_id bigint NOT NULL,
    users_id bigint NOT NULL
);


ALTER TABLE public.eco_news_users_likes OWNER TO greencity;

--
-- Name: econews_comment; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.econews_comment (
    id bigint NOT NULL,
    text character varying(8000) NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    parent_comment_id bigint,
    user_id bigint NOT NULL,
    eco_news_id bigint NOT NULL,
    deleted boolean DEFAULT false
);


ALTER TABLE public.econews_comment OWNER TO greencity;

--
-- Name: econews_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.econews_comment ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.econews_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: econews_comment_users_liked; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.econews_comment_users_liked (
    econews_comment_id bigint NOT NULL,
    users_liked_id bigint NOT NULL
);


ALTER TABLE public.econews_comment_users_liked OWNER TO greencity;

--
-- Name: habit_fact_translations; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.habit_fact_translations (
    id bigint NOT NULL,
    language_id bigint NOT NULL,
    habit_fact_id bigint NOT NULL,
    content character varying(300),
    fact_of_day_status integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.habit_fact_translations OWNER TO greencity;

--
-- Name: fact_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.habit_fact_translations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.fact_translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: filters; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.filters (
    id bigint NOT NULL,
    user_id bigint,
    name character varying,
    type character varying,
    "values" character varying
);


ALTER TABLE public.filters OWNER TO greencity;

--
-- Name: filters_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.filters ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.filters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: shopping_list_item_translations; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.shopping_list_item_translations (
    id bigint NOT NULL,
    content character varying(255) NOT NULL,
    shopping_list_item_id bigint NOT NULL,
    language_id bigint NOT NULL
);


ALTER TABLE public.shopping_list_item_translations OWNER TO greencity;

--
-- Name: goal_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.shopping_list_item_translations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.goal_translations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: shopping_list_items; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.shopping_list_items (
    id bigint NOT NULL
);


ALTER TABLE public.shopping_list_items OWNER TO greencity;

--
-- Name: goals_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.shopping_list_items ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.goals_id_seq
    START WITH 145
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: habit_assign; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.habit_assign (
    id bigint NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL,
    user_id bigint,
    habit_id bigint,
    duration integer DEFAULT 0 NOT NULL,
    habit_streak integer DEFAULT 0 NOT NULL,
    working_days integer DEFAULT 0 NOT NULL,
    last_enrollment timestamp with time zone DEFAULT now() NOT NULL,
    status character varying(12) DEFAULT 'ACTIVE'::character varying NOT NULL,
    progress_notification_has_displayed boolean DEFAULT false
);


ALTER TABLE public.habit_assign OWNER TO greencity;

--
-- Name: habit_assign_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.habit_assign ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.habit_assign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: habit_translation; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.habit_translation (
    id bigint NOT NULL,
    name character varying(255),
    description text NOT NULL,
    habit_item character varying(255),
    language_id bigint NOT NULL,
    habit_id bigint NOT NULL
);


ALTER TABLE public.habit_translation OWNER TO greencity;

--
-- Name: habit_dictionary_translation_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.habit_translation ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.habit_dictionary_translation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: habit_facts; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.habit_facts (
    id bigint NOT NULL,
    habit_id bigint NOT NULL
);


ALTER TABLE public.habit_facts OWNER TO greencity;

--
-- Name: habit_facts_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.habit_facts ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.habit_facts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: habit_shopping_list_items; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.habit_shopping_list_items (
    id bigint NOT NULL,
    habit_id bigint NOT NULL,
    shopping_list_item_id bigint NOT NULL,
    status character varying DEFAULT 'ACTUAL'::character varying
);


ALTER TABLE public.habit_shopping_list_items OWNER TO greencity;

--
-- Name: habit_goals_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

CREATE SEQUENCE public.habit_goals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.habit_goals_id_seq OWNER TO greencity;

--
-- Name: habit_goals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: greencity
--

ALTER SEQUENCE public.habit_goals_id_seq OWNED BY public.habit_shopping_list_items.id;


--
-- Name: habit_statistics; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.habit_statistics (
    id bigint NOT NULL,
    rate character varying(10) NOT NULL,
    create_date timestamp with time zone DEFAULT now() NOT NULL,
    habit_assign_id bigint NOT NULL,
    amount_of_items integer NOT NULL
);


ALTER TABLE public.habit_statistics OWNER TO greencity;

--
-- Name: habit_statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.habit_statistics ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.habit_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: habit_status; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.habit_status (
    id bigint NOT NULL,
    working_days integer NOT NULL,
    habit_streak integer NOT NULL,
    habit_assign_id bigint NOT NULL,
    last_enrollment timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.habit_status OWNER TO greencity;

--
-- Name: habit_status_calendar; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.habit_status_calendar (
    id bigint NOT NULL,
    enroll_date date NOT NULL,
    habit_assign_id bigint NOT NULL
);


ALTER TABLE public.habit_status_calendar OWNER TO greencity;

--
-- Name: habit_status_calendar_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.habit_status_calendar ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.habit_status_calendar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: habit_status_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.habit_status ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.habit_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: habits; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.habits (
    id bigint NOT NULL,
    image character varying(255) DEFAULT 'bag'::character varying NOT NULL,
    default_duration integer DEFAULT 14 NOT NULL,
    complexity integer DEFAULT 1 NOT NULL,
    user_id bigint,
    is_custom_habit boolean DEFAULT false,
    CONSTRAINT complexity_size CHECK (((complexity >= 1) AND (complexity <= 3)))
);


ALTER TABLE public.habits OWNER TO greencity;

--
-- Name: habits_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.habits ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.habits_id_seq
    START WITH 32
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: habits_tags; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.habits_tags (
    habit_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE public.habits_tags OWNER TO greencity;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public; Owner: greencity
--

CREATE SEQUENCE public.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hibernate_sequence OWNER TO greencity;

--
-- Name: languages; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.languages (
    id bigint NOT NULL,
    code character varying(35) NOT NULL
);


ALTER TABLE public.languages OWNER TO greencity;

--
-- Name: languages_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.languages ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.languages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: message_like; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.message_like (
    message_id bigint NOT NULL,
    participant_id bigint NOT NULL
);


ALTER TABLE public.message_like OWNER TO greencity;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.orders_id_seq OWNER TO greencity;

--
-- Name: own_security; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.own_security (
    id bigint NOT NULL,
    password character varying(255) NOT NULL,
    user_id bigint
);


ALTER TABLE public.own_security OWNER TO greencity;

--
-- Name: own_security_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.own_security ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.own_security_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: rating_statistics; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.rating_statistics (
    id bigint NOT NULL,
    event character varying NOT NULL,
    create_date timestamp with time zone NOT NULL,
    user_id bigint NOT NULL,
    points_changed double precision NOT NULL,
    current_rating double precision NOT NULL
);


ALTER TABLE public.rating_statistics OWNER TO greencity;

--
-- Name: rating_statistics_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.rating_statistics ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.rating_statistics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: reasons_for_user_deactivation; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.reasons_for_user_deactivation (
    id bigint NOT NULL,
    reason character varying(256) NOT NULL,
    date_of_deactivation timestamp with time zone NOT NULL,
    id_user bigint NOT NULL
);


ALTER TABLE public.reasons_for_user_deactivation OWNER TO greencity;

--
-- Name: reasons_for_user_deactivation_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.reasons_for_user_deactivation ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.reasons_for_user_deactivation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: restore_password_email; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.restore_password_email (
    id bigint NOT NULL,
    expiry_date timestamp(6) without time zone,
    token character varying(255),
    user_id bigint
);


ALTER TABLE public.restore_password_email OWNER TO greencity;

--
-- Name: restore_password_email_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.restore_password_email ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.restore_password_email_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: social_network_images; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.social_network_images (
    id bigint NOT NULL,
    image_path character varying(300) NOT NULL,
    host_path character varying(300) NOT NULL
);


ALTER TABLE public.social_network_images OWNER TO greencity;

--
-- Name: social_network_images_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.social_network_images ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.social_network_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: social_networks; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.social_networks (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    social_network_url character varying(500) NOT NULL,
    social_network_image_id bigint NOT NULL
);


ALTER TABLE public.social_networks OWNER TO greencity;

--
-- Name: social_networks_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.social_networks ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.social_networks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: specifications; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.specifications (
    id bigint NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.specifications OWNER TO greencity;

--
-- Name: specification_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.specifications ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.specification_id_seq
    START WITH 7
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tag_translations; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.tag_translations (
    id bigint NOT NULL,
    name character varying(30) NOT NULL,
    tag_id bigint NOT NULL,
    language_id bigint NOT NULL
);


ALTER TABLE public.tag_translations OWNER TO greencity;

--
-- Name: tag_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.tag_translations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tag_translations_id_seq
    START WITH 34
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: tags; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.tags (
    id bigint NOT NULL,
    type character varying(30) DEFAULT 'ECO_NEWS'::character varying NOT NULL
);


ALTER TABLE public.tags OWNER TO greencity;

--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.tags ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.tags_id_seq
    START WITH 12
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ubs_user_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

CREATE SEQUENCE public.ubs_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ubs_user_id_seq OWNER TO greencity;

--
-- Name: unread_messages; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.unread_messages (
    id bigint NOT NULL,
    status integer NOT NULL,
    message_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.unread_messages OWNER TO greencity;

--
-- Name: unread_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.unread_messages ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.unread_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_actions; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.user_actions (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    achievement_category_id bigint,
    count integer
);


ALTER TABLE public.user_actions OWNER TO greencity;

--
-- Name: user_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.user_actions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.user_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: user_shopping_list; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.user_shopping_list (
    id bigint NOT NULL,
    habit_assign_id bigint NOT NULL,
    shopping_list_item_id bigint,
    status character varying(12) NOT NULL,
    date_completed timestamp(6) without time zone
);


ALTER TABLE public.user_shopping_list OWNER TO greencity;

--
-- Name: user_goals_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.user_shopping_list ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.user_goals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    date_of_registration timestamp(6) without time zone NOT NULL,
    email character varying(50) NOT NULL,
    email_notification integer,
    name character varying(30) NOT NULL,
    role character varying NOT NULL,
    user_status integer,
    refresh_token_key character varying(255) DEFAULT 'secret'::character varying NOT NULL,
    profile_picture character varying(300),
    rating double precision,
    last_activity_time timestamp with time zone,
    first_name character varying(255),
    city character varying(255),
    user_credo character varying(255),
    show_location boolean,
    show_eco_place boolean,
    show_shopping_list boolean,
    language_id bigint DEFAULT 2,
    uuid character varying(60),
    phone_number character varying,
    event_organizer_rating double precision
);


ALTER TABLE public.users OWNER TO greencity;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.users ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: verify_emails; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.verify_emails (
    id bigint NOT NULL,
    expiry_date timestamp(6) without time zone NOT NULL,
    token character varying(255) NOT NULL,
    user_id bigint
);


ALTER TABLE public.verify_emails OWNER TO greencity;

--
-- Name: verify_email_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.verify_emails ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.verify_email_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: web_pages; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.web_pages (
    id bigint NOT NULL,
    web_page character varying(255) NOT NULL
);


ALTER TABLE public.web_pages OWNER TO greencity;

--
-- Name: web_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: greencity
--

ALTER TABLE public.web_pages ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.web_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: web_pages_places; Type: TABLE; Schema: public; Owner: greencity
--

CREATE TABLE public.web_pages_places (
    web_pages_id bigint NOT NULL,
    places_id bigint NOT NULL
);


ALTER TABLE public.web_pages_places OWNER TO greencity;

--
-- Name: habit_shopping_list_items id; Type: DEFAULT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_shopping_list_items ALTER COLUMN id SET DEFAULT nextval('public.habit_goals_id_seq'::regclass);


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.categories (id, name, parent_category_id, name_ua) FROM stdin;
1	Vegan products	\N	Вегетаріанські продукти
2	Charging station	\N	Зарядні станції
3	Bike parking	\N	Парковка для мотоциклів
4	Cycling routes	\N	Велосипедні маршрути
5	Hotels	\N	Готелі
6	Shops	\N	Магазини
7	Restaurants	\N	Ресторани
8	Recycling points	\N	Станції приймання
9	Events	\N	Події
10	Bike rentals	\N	Оренда мотоциклів
\.


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.comments (id, created_date, modified_date, text, estimate_id, parent_comment_id, place_id, user_id) FROM stdin;
\.


--
-- Data for Name: custom_shopping_list_items; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.custom_shopping_list_items (id, text, user_id, status, date_completed, habit_id) FROM stdin;
\.


--
-- Data for Name: databasechangelog; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.databasechangelog (id, author, filename, dateexecuted, orderexecuted, exectype, md5sum, description, comments, tag, liquibase, contexts, labels, deployment_id) FROM stdin;
1571227598316-1	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:28.440414	1	EXECUTED	9:e219cbc9970b130826aabdbfb612a640	createTable tableName=break_time		\N	4.25.1	\N	\N	8360468164
1571227598316-2	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:28.51479	2	EXECUTED	9:4c2fc29267df7a74571d88b16b139c45	createTable tableName=category		\N	4.25.1	\N	\N	8360468164
1571227598316-3	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:28.564947	3	EXECUTED	9:0199056d002b4ce5cef2dd3f604d03c5	createTable tableName=comment		\N	4.25.1	\N	\N	8360468164
1571227598316-4	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:28.621437	4	EXECUTED	9:52c1ec44d408b1917b593a1cc3aabb91	createTable tableName=discount_value		\N	4.25.1	\N	\N	8360468164
1571227598316-5	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:28.681829	5	EXECUTED	9:bf77ffa71cadf80bf914109efb9c39f9	createTable tableName=estimate		\N	4.25.1	\N	\N	8360468164
1571227598316-6	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:28.739275	6	EXECUTED	9:bbb2f987f0e09d815c4ac136b0cf716f	createTable tableName=favorite_place		\N	4.25.1	\N	\N	8360468164
1571227598316-7	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:28.822492	7	EXECUTED	9:73da586b920a423dbfa71399839b57b3	createTable tableName=location		\N	4.25.1	\N	\N	8360468164
1571227598316-8	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:28.880846	8	EXECUTED	9:eb45bca57641ee1691795479ae460660	createTable tableName=opening_hours		\N	4.25.1	\N	\N	8360468164
1571227598316-9	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:28.948111	9	EXECUTED	9:ce9bd2f992c5b3c703a77c52b1154090	createTable tableName=own_security		\N	4.25.1	\N	\N	8360468164
1571227598316-10	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.014444	10	EXECUTED	9:053daee9c722cf6ff420df999e0d3f6c	createTable tableName=photo		\N	4.25.1	\N	\N	8360468164
1571227598316-11	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.081055	11	EXECUTED	9:4db129f448d1c8f31ab36c0e021f4d85	createTable tableName=place		\N	4.25.1	\N	\N	8360468164
1571227598316-12	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.147908	12	EXECUTED	9:d05d814cd21dae8f0c04963e12f284bc	createTable tableName=restore_password_email		\N	4.25.1	\N	\N	8360468164
1571227598316-13	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.314982	13	EXECUTED	9:a67f3896c55bf3b790020e2bcbc96dd3	createTable tableName=specification		\N	4.25.1	\N	\N	8360468164
1571227598316-14	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.398254	14	EXECUTED	9:765342770be0072f3274c56e8dd76418	createTable tableName=user		\N	4.25.1	\N	\N	8360468164
1571227598316-15	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.465149	15	EXECUTED	9:142a274a884ad4e9c02400b742f9a12b	createTable tableName=verify_email		\N	4.25.1	\N	\N	8360468164
1571227598316-16	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.556833	16	EXECUTED	9:4b06fd622c4013ab198a8a8c819a5373	createTable tableName=web_pages		\N	4.25.1	\N	\N	8360468164
1571227598316-17	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.59033	17	EXECUTED	9:a63eaa01ffe21a6b1d91c25f4174cce0	createTable tableName=web_pages_places		\N	4.25.1	\N	\N	8360468164
1571227598316-18	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.648769	18	EXECUTED	9:71e25cd5a915c4d84e4b70c98e08dc5b	addUniqueConstraint constraintName=UK_1c8hn389trq38f63p3r4mpy33, tableName=place		\N	4.25.1	\N	\N	8360468164
1571227598316-19	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.707078	19	EXECUTED	9:f3cbff13f076c845b54e4a8df0d93bef	addUniqueConstraint constraintName=UK_46ccwnsi9409t36lurvtyljak, tableName=category		\N	4.25.1	\N	\N	8360468164
1571227598316-20	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.764451	20	EXECUTED	9:1b8a5b579722d6f45e391776e924b54d	addUniqueConstraint constraintName=UK_663ftdbracrebppaa1smemex8, tableName=web_pages		\N	4.25.1	\N	\N	8360468164
1571227598316-21	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.831993	21	EXECUTED	9:6b9099769072de567513e9950251d2a7	addUniqueConstraint constraintName=UK_88inhvpybxm6bqnsthcolx838, tableName=photo		\N	4.25.1	\N	\N	8360468164
1571227598316-22	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.899276	22	EXECUTED	9:14c9186e9166e35b0bbd442a7edcefa2	addUniqueConstraint constraintName=UK_9cbyl8faff3immm5ehnelt18n, tableName=place		\N	4.25.1	\N	\N	8360468164
1571227598316-23	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.949507	23	EXECUTED	9:7093f88ab0ec3e8b5fd8d51f8f9bbd1f	addUniqueConstraint constraintName=UK_bdpr10axwx0a7ogp5ax531n9f, tableName=specification		\N	4.25.1	\N	\N	8360468164
1571227598316-24	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:29.998999	24	EXECUTED	9:0512fd8bd743df602da4cb9514543f91	addUniqueConstraint constraintName=UK_ob8kqyqqgmefl0aco34akdtpe, tableName=user		\N	4.25.1	\N	\N	8360468164
1571227598316-25	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.057906	25	EXECUTED	9:1c1f00a699475a39a053d5a395cdba1f	createIndex indexName=FK1faffy1p9x95n6v18m5urdkfc, tableName=verify_email		\N	4.25.1	\N	\N	8360468164
1571227598316-26	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.116109	26	EXECUTED	9:19545100f8969559ed06a270192da587	createIndex indexName=FK3297dq7rblawjc9n4kx9htui4, tableName=place		\N	4.25.1	\N	\N	8360468164
1571227598316-27	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.180631	27	EXECUTED	9:f7acf8c1df0c4e243ee0ef21d83a584d	createIndex indexName=FK4ybp1p4b8005qrgccsrookt9p, tableName=estimate		\N	4.25.1	\N	\N	8360468164
1571227598316-28	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.239201	28	EXECUTED	9:92efab487080b981bd51f7aa7fbb7493	createIndex indexName=FK6n25a2qft5y6fb21karg1obh5, tableName=estimate		\N	4.25.1	\N	\N	8360468164
1571227598316-29	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.29094	29	EXECUTED	9:c97cffbff19cfc68494be6a610d20cb5	createIndex indexName=FK74l2uk5a5nrjvi94rd9qaviu1, tableName=place		\N	4.25.1	\N	\N	8360468164
1571227598316-30	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.341012	30	EXECUTED	9:31d825c1e226b52e7ed08881fff632b6	createIndex indexName=FK84jlf1nvnb2duww5bi10j5kwy, tableName=restore_password_email		\N	4.25.1	\N	\N	8360468164
1571227598316-31	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.399022	31	EXECUTED	9:f8fc6403314a2818b32b438b44a1fc5d	createIndex indexName=FK8kcum44fvpupyw6f5baccx25c, tableName=comment		\N	4.25.1	\N	\N	8360468164
17	Yuriy O.	db/changelog/logs/ch-user-achievements-olkhovskyi-1.xml	2024-02-19 16:34:33.694867	118	EXECUTED	9:8a196a77f03b6107d14a276a22f7532c	createTable tableName=user_achievements		\N	4.25.1	\N	\N	8360468164
1571227598316-32	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.457354	32	EXECUTED	9:11f9499d60f3b22d494acddccc0ec01e	createIndex indexName=FK9ygkma6mdptstvup90n9ewptc, tableName=opening_hours		\N	4.25.1	\N	\N	8360468164
1571227598316-33	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.507797	33	EXECUTED	9:e5e0381ff4d4faae9bf5d75953275330	createIndex indexName=FKaxtbydhvr0oeed7oruruf0hn, tableName=place		\N	4.25.1	\N	\N	8360468164
1571227598316-34	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.616537	34	EXECUTED	9:ff954328801ff8c706162cdf0cd25afb	createIndex indexName=FKch8bkgqt3v8yjo230lysj668h, tableName=comment		\N	4.25.1	\N	\N	8360468164
1571227598316-35	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.666296	35	EXECUTED	9:3c8fb7bdefff5efbec65ae9dcddeaacf	createIndex indexName=FKhvh0e2ybgg16bpu229a5teje7, tableName=comment		\N	4.25.1	\N	\N	8360468164
1571227598316-36	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.716126	36	EXECUTED	9:b7be0f96fadd98dc9ad44092c5fd207e	createIndex indexName=FKio191h2kf8y7k7mumqjn1fn1v, tableName=opening_hours		\N	4.25.1	\N	\N	8360468164
1571227598316-37	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.766094	37	EXECUTED	9:ac96eaf56a092d3434a113e6cfad4608	createIndex indexName=FKmon8uughpdrxt7vskx5k2prji, tableName=favorite_place		\N	4.25.1	\N	\N	8360468164
1571227598316-38	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.816284	38	EXECUTED	9:39568e127cb9f9f9a5c27a81602c3102	createIndex indexName=FKmpd2wxnn6fldh4pilqnkpaqv9, tableName=discount_value		\N	4.25.1	\N	\N	8360468164
1571227598316-39	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.87552	39	EXECUTED	9:317d7c5805dec60fe22d86787d7dcebb	createIndex indexName=FKmrghmp8nq6diqqcjxtq3nudfs, tableName=web_pages_places		\N	4.25.1	\N	\N	8360468164
1571227598316-40	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.9245	40	EXECUTED	9:a17dae577863fea2b4ba5e798967cb01	createIndex indexName=FKn3innaybpdkeovqui6o4dsxb0, tableName=estimate		\N	4.25.1	\N	\N	8360468164
1571227598316-41	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:30.974709	41	EXECUTED	9:b55c3e107c66dc265cacf70c0a73136d	createIndex indexName=FKncp190mcvd1kd21cmnibcm19s, tableName=photo		\N	4.25.1	\N	\N	8360468164
1571227598316-42	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.024795	42	EXECUTED	9:208f72923fd18a919a8a2b1a15936bbe	createIndex indexName=FKnj78c83w4xmw23jp8etxgcqc5, tableName=discount_value		\N	4.25.1	\N	\N	8360468164
1571227598316-43	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.091497	43	EXECUTED	9:d304a672b433f87299b9ea041c752b92	createIndex indexName=FKpeyqdepr1vru2tsghm3sxwhrr, tableName=comment		\N	4.25.1	\N	\N	8360468164
1571227598316-44	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.141256	44	EXECUTED	9:bdcf88d036f4475a0a437cc9a6ea9ed2	createIndex indexName=FKrm26v5rrc5t54lhcd04dcwkw8, tableName=web_pages_places		\N	4.25.1	\N	\N	8360468164
1571227598316-45	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.183005	45	EXECUTED	9:c0ee522568b9282c9b7ca4adde4de09b	createIndex indexName=FKrtlnhb40rfqhkna5ijgoykgyl, tableName=favorite_place		\N	4.25.1	\N	\N	8360468164
1571227598316-46	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.224495	46	EXECUTED	9:00d9f65b6223b8c98412dfca69ad97d3	createIndex indexName=FKs084ey5e475cqp4w0hsgisjpd, tableName=own_security		\N	4.25.1	\N	\N	8360468164
1571227598316-47	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.266405	47	EXECUTED	9:92ce7102d51980da8183b18c6da5b163	createIndex indexName=FKs2ride9gvilxy2tcuv7witnxc, tableName=category		\N	4.25.1	\N	\N	8360468164
1571227598316-48	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.307998	48	EXECUTED	9:a5220765861df7637c763a0b580f5173	createIndex indexName=FKsm3nsiqunp5ke6cmkundcw4a1, tableName=photo		\N	4.25.1	\N	\N	8360468164
1571227598316-49	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.349687	49	EXECUTED	9:b4800dd1f129e0e6619a69baf5873729	createIndex indexName=FKsv2aa83c398y2xp3j01yi92rh, tableName=photo		\N	4.25.1	\N	\N	8360468164
1571227598316-50	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.399816	50	EXECUTED	9:3adee0375a05be4cd4d8311f4ef67205	addForeignKeyConstraint baseTableName=verify_email, constraintName=FK1faffy1p9x95n6v18m5urdkfc, referencedTableName=user		\N	4.25.1	\N	\N	8360468164
1571227598316-51	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.433191	51	EXECUTED	9:3b13c0969f772d2ceb834b16f723315f	addForeignKeyConstraint baseTableName=place, constraintName=FK3297dq7rblawjc9n4kx9htui4, referencedTableName=category		\N	4.25.1	\N	\N	8360468164
1571227598316-52	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.466342	52	EXECUTED	9:43f57100e0c23a078a3da82fbf10cf07	addForeignKeyConstraint baseTableName=estimate, constraintName=FK4ybp1p4b8005qrgccsrookt9p, referencedTableName=comment		\N	4.25.1	\N	\N	8360468164
1571227598316-53	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.491734	53	EXECUTED	9:0783174ebd07240aa71399e1891fe8c2	addForeignKeyConstraint baseTableName=estimate, constraintName=FK6n25a2qft5y6fb21karg1obh5, referencedTableName=user		\N	4.25.1	\N	\N	8360468164
1571227598316-54	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.516671	54	EXECUTED	9:ec3e2e5234b941ab950aaa0903cfa3a6	addForeignKeyConstraint baseTableName=place, constraintName=FK74l2uk5a5nrjvi94rd9qaviu1, referencedTableName=user		\N	4.25.1	\N	\N	8360468164
1571227598316-55	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.541365	55	EXECUTED	9:4457e3ca8352b802fa7f111dd55a3d1c	addForeignKeyConstraint baseTableName=restore_password_email, constraintName=FK84jlf1nvnb2duww5bi10j5kwy, referencedTableName=user		\N	4.25.1	\N	\N	8360468164
1571227598316-56	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.566764	56	EXECUTED	9:882553e6954887dbed1728011d11546f	addForeignKeyConstraint baseTableName=comment, constraintName=FK8kcum44fvpupyw6f5baccx25c, referencedTableName=user		\N	4.25.1	\N	\N	8360468164
1571227598316-57	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.600157	57	EXECUTED	9:1c6b01fcf6a81d101775466aac79c58e	addForeignKeyConstraint baseTableName=opening_hours, constraintName=FK9ygkma6mdptstvup90n9ewptc, referencedTableName=break_time		\N	4.25.1	\N	\N	8360468164
1571227598316-58	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.624754	58	EXECUTED	9:0e6f3e26d1fdda41c58f13cb29108422	addForeignKeyConstraint baseTableName=place, constraintName=FKaxtbydhvr0oeed7oruruf0hn, referencedTableName=location		\N	4.25.1	\N	\N	8360468164
1571227598316-59	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.649878	59	EXECUTED	9:561e662ccf4100b45af91c20cf78f93c	addForeignKeyConstraint baseTableName=comment, constraintName=FKch8bkgqt3v8yjo230lysj668h, referencedTableName=place		\N	4.25.1	\N	\N	8360468164
1571227598316-60	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.675296	60	EXECUTED	9:836d38bf17cdeb37bb707ccff43f2060	addForeignKeyConstraint baseTableName=comment, constraintName=FKhvh0e2ybgg16bpu229a5teje7, referencedTableName=comment		\N	4.25.1	\N	\N	8360468164
1571227598316-61	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.700239	61	EXECUTED	9:668303085f965168c590853169d82461	addForeignKeyConstraint baseTableName=opening_hours, constraintName=FKio191h2kf8y7k7mumqjn1fn1v, referencedTableName=place		\N	4.25.1	\N	\N	8360468164
1571227598316-62	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.725409	62	EXECUTED	9:518bd9ecbc132d47d6a95851f5f7bf50	addForeignKeyConstraint baseTableName=favorite_place, constraintName=FKmon8uughpdrxt7vskx5k2prji, referencedTableName=place		\N	4.25.1	\N	\N	8360468164
1571227598316-63	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.750163	63	EXECUTED	9:05f7e8eb4451a09e7f58cb963322f20c	addForeignKeyConstraint baseTableName=discount_value, constraintName=FKmpd2wxnn6fldh4pilqnkpaqv9, referencedTableName=place		\N	4.25.1	\N	\N	8360468164
1571227598316-64	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.781571	64	EXECUTED	9:7756b5ba3ad694935a44c3fc1cd0c43b	addForeignKeyConstraint baseTableName=web_pages_places, constraintName=FKmrghmp8nq6diqqcjxtq3nudfs, referencedTableName=place		\N	4.25.1	\N	\N	8360468164
1571227598316-65	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.806451	65	EXECUTED	9:7d6c002989b2458cdcca087741faae72	addForeignKeyConstraint baseTableName=estimate, constraintName=FKn3innaybpdkeovqui6o4dsxb0, referencedTableName=place		\N	4.25.1	\N	\N	8360468164
1571227598316-66	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.833896	66	EXECUTED	9:9856940ad17065ec5b93e7b3e92ac8ad	addForeignKeyConstraint baseTableName=photo, constraintName=FKncp190mcvd1kd21cmnibcm19s, referencedTableName=user		\N	4.25.1	\N	\N	8360468164
1571227598316-67	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.858869	67	EXECUTED	9:79ff8f42aea737439e995b596e2305fe	addForeignKeyConstraint baseTableName=discount_value, constraintName=FKnj78c83w4xmw23jp8etxgcqc5, referencedTableName=specification		\N	4.25.1	\N	\N	8360468164
1571227598316-68	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.883599	68	EXECUTED	9:4b680bae5c6388d680b0cc9a6b9b3f37	addForeignKeyConstraint baseTableName=comment, constraintName=FKpeyqdepr1vru2tsghm3sxwhrr, referencedTableName=estimate		\N	4.25.1	\N	\N	8360468164
1571227598316-69	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.925579	69	EXECUTED	9:b4580531a7865ed0bfde105ddef19917	addForeignKeyConstraint baseTableName=web_pages_places, constraintName=FKrm26v5rrc5t54lhcd04dcwkw8, referencedTableName=web_pages		\N	4.25.1	\N	\N	8360468164
1571227598316-70	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.950621	70	EXECUTED	9:61fe0bb91695b4e65a420ef5ba14a7f2	addForeignKeyConstraint baseTableName=favorite_place, constraintName=FKrtlnhb40rfqhkna5ijgoykgyl, referencedTableName=user		\N	4.25.1	\N	\N	8360468164
1571227598316-71	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:31.97541	71	EXECUTED	9:832a3df810a1448be568cfe784ac2507	addForeignKeyConstraint baseTableName=own_security, constraintName=FKs084ey5e475cqp4w0hsgisjpd, referencedTableName=user		\N	4.25.1	\N	\N	8360468164
1571227598316-72	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:32.000949	72	EXECUTED	9:0911cfb968a64a84aa339baccf79236a	addForeignKeyConstraint baseTableName=category, constraintName=FKs2ride9gvilxy2tcuv7witnxc, referencedTableName=category		\N	4.25.1	\N	\N	8360468164
1571227598316-73	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:32.025866	73	EXECUTED	9:5267fcb93c4970a4a2301350d092456c	addForeignKeyConstraint baseTableName=photo, constraintName=FKsm3nsiqunp5ke6cmkundcw4a1, referencedTableName=comment		\N	4.25.1	\N	\N	8360468164
1571227598316-74	Marian (generated)	db/changelog/logs/liquibase-outputChangeLog.xml	2024-02-19 16:34:32.050796	74	EXECUTED	9:c444f251563adb41932283d0e07f164d	addForeignKeyConstraint baseTableName=photo, constraintName=FKsv2aa83c398y2xp3j01yi92rh, referencedTableName=place		\N	4.25.1	\N	\N	8360468164
1	Yuriy	db/changelog/logs/ch-change-tables-names-1.xml	2024-02-19 16:34:32.075587	75	EXECUTED	9:4105de7ae182eee569ab1df9e2c11615	renameTable newTableName=users, oldTableName=user		\N	4.25.1	\N	\N	8360468164
2	Yuriy	db/changelog/logs/ch-change-tables-names-1.xml	2024-02-19 16:34:32.100448	76	EXECUTED	9:d51b6f1627bfb83264dda086b13ad0a0	renameTable newTableName=categories, oldTableName=category		\N	4.25.1	\N	\N	8360468164
3	Yuriy	db/changelog/logs/ch-change-tables-names-1.xml	2024-02-19 16:34:32.155118	77	EXECUTED	9:7a48914ec77ef16b891fc02a51f8c249	renameTable newTableName=comments, oldTableName=comment		\N	4.25.1	\N	\N	8360468164
4	Yuriy	db/changelog/logs/ch-change-tables-names-1.xml	2024-02-19 16:34:32.184194	78	EXECUTED	9:6afc1a186aea94fa58eed9e309bf5b70	renameTable newTableName=discount_values, oldTableName=discount_value		\N	4.25.1	\N	\N	8360468164
5	Yuriy	db/changelog/logs/ch-change-tables-names-1.xml	2024-02-19 16:34:32.209199	79	EXECUTED	9:e2b9450c83d8bb0c0b8c4b6674a29718	renameTable newTableName=estimates, oldTableName=estimate		\N	4.25.1	\N	\N	8360468164
6	Yuriy	db/changelog/logs/ch-change-tables-names-1.xml	2024-02-19 16:34:32.234352	80	EXECUTED	9:8e6ab7269ba36ba1d4a2d25f8cdc8fb1	renameTable newTableName=favorite_places, oldTableName=favorite_place		\N	4.25.1	\N	\N	8360468164
7	Yuriy	db/changelog/logs/ch-change-tables-names-1.xml	2024-02-19 16:34:32.259115	81	EXECUTED	9:32a897d1ed9ed685fefd1b884f5f2938	renameTable newTableName=locations, oldTableName=location		\N	4.25.1	\N	\N	8360468164
8	Yuriy	db/changelog/logs/ch-change-tables-names-1.xml	2024-02-19 16:34:32.28445	82	EXECUTED	9:8e1a09c4037361f05c3ae5fd6362f8d8	renameTable newTableName=photos, oldTableName=photo		\N	4.25.1	\N	\N	8360468164
9	Yuriy	db/changelog/logs/ch-change-tables-names-1.xml	2024-02-19 16:34:32.309229	83	EXECUTED	9:83ff8d92861a49bb6d9eb49f24ca7df2	renameTable newTableName=places, oldTableName=place		\N	4.25.1	\N	\N	8360468164
10	Yuriy	db/changelog/logs/ch-change-tables-names-1.xml	2024-02-19 16:34:32.334049	84	EXECUTED	9:647c85ab06afbc153936429e527eaae5	renameTable newTableName=specifications, oldTableName=specification		\N	4.25.1	\N	\N	8360468164
11	Yuriy	db/changelog/logs/ch-change-tables-names-1.xml	2024-02-19 16:34:32.358742	85	EXECUTED	9:5454b3414341a61d0dda3fea7d9a7a61	renameTable newTableName=verify_emails, oldTableName=verify_email		\N	4.25.1	\N	\N	8360468164
Yurii-1	Yurii Koval	db/changelog/logs/ch-add-column-Koval-1.xml	2024-02-19 16:34:32.392428	86	EXECUTED	9:e56a320bbb016394edbb4e81ca7d7c1b	addColumn tableName=users		\N	4.25.1	\N	\N	8360468164
1571227598316-150	Bogdan	db/changelog/logs/ch-habit-dictionary-kuzenko-1.xml	2024-02-19 16:34:32.442888	87	EXECUTED	9:bbc82b4025ff10cad37ef3c4745561ca	createTable tableName=habit_dictionary		\N	4.25.1	\N	\N	8360468164
1571227598316-76	Volodymyr	db/changelog/logs/ch-habits-turko-1.xml	2024-02-19 16:34:32.492904	88	EXECUTED	9:d63fa7faa908b3bb4dfe9ffa0b2eef6c	createTable tableName=habits		\N	4.25.1	\N	\N	8360468164
1571227598316-77	Volodymyr	db/changelog/logs/ch-habits-turko-1.xml	2024-02-19 16:34:32.522932	89	EXECUTED	9:7b5a7719672296b359d19959947c62c2	addForeignKeyConstraint baseTableName=habits, constraintName=fk_habits_user, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
1571227598316-78	Volodymyr	db/changelog/logs/ch-habits-turko-1.xml	2024-02-19 16:34:32.547957	90	EXECUTED	9:a0766798824fe162f2112a37f3284669	addForeignKeyConstraint baseTableName=habits, constraintName=fk_habits_habits_dictionary, referencedTableName=habit_dictionary		\N	4.25.1	\N	\N	8360468164
13	Olkhovskyi Y.	db/changelog/logs/ch-habit-statistics-olkhovskyi-1.xml	2024-02-19 16:34:32.58482	91	EXECUTED	9:92db142102bfd233dc66a1b7cc268cd0	createTable tableName=habit_statistics		\N	4.25.1	\N	\N	8360468164
15	Olkhovskyi Y.	db/changelog/logs/ch-habit-statistics-olkhovskyi-1.xml	2024-02-19 16:34:32.618111	92	EXECUTED	9:ba2c30382b30ed58e2a2f113c742416f	addForeignKeyConstraint baseTableName=habit_statistics, constraintName=FK_habit_habit_statistics, referencedTableName=habits		\N	4.25.1	\N	\N	8360468164
1571227598316-100	Vitalii S.	db/changelog/logs/ch-user-goals-skolozdra-1.xml	2024-02-19 16:34:32.67646	93	EXECUTED	9:f0c02e113b555a1c09f7258ce72cca4c	createTable tableName=goals		\N	4.25.1	\N	\N	8360468164
1571227598316-101	Vitalii S.	db/changelog/logs/ch-user-goals-skolozdra-1.xml	2024-02-19 16:34:32.726782	94	EXECUTED	9:1db42638f056cd85f6e90aa44cb07112	createTable tableName=user_goals		\N	4.25.1	\N	\N	8360468164
1571227598316-103	Vitalii S.	db/changelog/logs/ch-user-goals-skolozdra-1.xml	2024-02-19 16:34:32.751726	95	EXECUTED	9:90603fd2d163626255f2f7428b106f69	addForeignKeyConstraint baseTableName=user_goals, constraintName=FK_user_user_goals, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
4651326844-1	Vitaliy Dzen	db/changelog/logs/ch-advice-dzen-1.xml	2024-02-19 16:34:32.801978	96	EXECUTED	9:cb7a27c1708669cc684b520181b22a8e	createTable tableName=advices		\N	4.25.1	\N	\N	8360468164
4651326844-2	Vitaliy Dzen	db/changelog/logs/ch-advice-dzen-1.xml	2024-02-19 16:34:32.827032	97	EXECUTED	9:cb30bbf68f424e1b77a09ecff4a774ec	addForeignKeyConstraint baseTableName=advices, constraintName=FK_habit_advices, referencedTableName=habit_dictionary		\N	4.25.1	\N	\N	8360468164
23.09.20.Lehkyi-8_4651326844-2	Mykola Lehkyi	db/changelog/logs/ch-advice-dzen-1.xml	2024-02-19 16:34:32.868342	98	EXECUTED	9:9c4999857a6ac5f54cb9c2e7575d451a	dropForeignKeyConstraint baseTableName=advices, constraintName=FK_habit_advices; addForeignKeyConstraint baseTableName=advices, constraintName=FK_advices_habit_dictionary, referencedTableName=habit_dictionary		\N	4.25.1	\N	\N	8360468164
4651326844-5	Vitaliy Dzen	db/changelog/logs/ch-update-habit-dictionary-dzen-2.xml	2024-02-19 16:34:32.893639	99	EXECUTED	9:cb29588de14b49e5c7e1327434eec0ec	addColumn tableName=habit_dictionary		\N	4.25.1	\N	\N	8360468164
4651326844-6	Vitaliy Dzen	db/changelog/logs/ch-habit_facts-dzen-3.xml	2024-02-19 16:34:32.947533	100	EXECUTED	9:923f641bd1824d220a6156e0fbca1fe8	createTable tableName=habit_facts		\N	4.25.1	\N	\N	8360468164
4651326844-7	Vitaliy Dzen	db/changelog/logs/ch-habit_facts-dzen-3.xml	2024-02-19 16:34:32.972414	101	EXECUTED	9:4ca3df489030a06cce76f4cd42821eab	addForeignKeyConstraint baseTableName=habit_facts, constraintName=FK_habit_advices, referencedTableName=habit_dictionary		\N	4.25.1	\N	\N	8360468164
23.09.20.Lehkyi-9_4651326844-7	Mykola Lehkyi	db/changelog/logs/ch-habit_facts-dzen-3.xml	2024-02-19 16:34:32.997455	102	EXECUTED	9:ce50921a470b2f1cbe1921116855b0a5	dropForeignKeyConstraint baseTableName=habit_facts, constraintName=FK_habit_advices; addForeignKeyConstraint baseTableName=habit_facts, constraintName=FK_habit_facts_habit_dictionary, referencedTableName=habit_dictionary		\N	4.25.1	\N	\N	8360468164
Yurii-2	Yurii Koval	db/changelog/logs/ch-add-constraints-Koval-2.xml	2024-02-19 16:34:33.028969	103	EXECUTED	9:4ddbeff23105d7e0c9e84c8e4be6e78d	dropColumn tableName=verify_emails		\N	4.25.1	\N	\N	8360468164
Yurii-3	Yurii Koval	db/changelog/logs/ch-add-constraints-Koval-2.xml	2024-02-19 16:34:33.051881	104	EXECUTED	9:88566e79d3b03b3d2c0eb7503ebab730	addColumn tableName=verify_emails		\N	4.25.1	\N	\N	8360468164
Yurii-4	Yurii Koval	db/changelog/logs/ch-add-constraints-Koval-2.xml	2024-02-19 16:34:33.080314	105	EXECUTED	9:6ef8b7afd746fa6df45c5cff59f1019f	addForeignKeyConstraint baseTableName=verify_emails, constraintName=user_should_verify_email, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
Yurii-5	Yurii Koval	db/changelog/logs/ch-add-constraints-Koval-2.xml	2024-02-19 16:34:33.105043	106	EXECUTED	9:8b14ebbb3596350a9d1d8acf6e347024	addNotNullConstraint columnName=token, constraintName=email_verification_token_cannot_be_null, tableName=verify_emails		\N	4.25.1	\N	\N	8360468164
Yurii-6	Yurii Koval	db/changelog/logs/ch-add-constraints-Koval-2.xml	2024-02-19 16:34:33.130223	107	EXECUTED	9:d3a6536a3867c3c9d3854c5d2ba3ba7e	addNotNullConstraint columnName=expiry_date, constraintName=token_expiry_date_cannot_be_null, tableName=verify_emails		\N	4.25.1	\N	\N	8360468164
Yurii-7	Yurii Koval	db/changelog/logs/ch-add-constraints-Koval-2.xml	2024-02-19 16:34:33.188861	108	EXECUTED	9:ac9ee73e21d8146496800fecc589d2ae	addUniqueConstraint constraintName=one_user_one_email_verification_token, tableName=verify_emails		\N	4.25.1	\N	\N	8360468164
Yurii-8	Yurii Koval	db/changelog/logs/ch-add-constraints-Koval-2.xml	2024-02-19 16:34:33.215591	109	EXECUTED	9:0054f991d8adc60ddcfb2c6f2d95c5d4	dropColumn tableName=own_security		\N	4.25.1	\N	\N	8360468164
Yurii-9	Yurii Koval	db/changelog/logs/ch-add-constraints-Koval-2.xml	2024-02-19 16:34:33.238473	110	EXECUTED	9:36c5631926c9bc5e8100388b1001d075	addColumn tableName=own_security		\N	4.25.1	\N	\N	8360468164
Yurii-10	Yurii Koval	db/changelog/logs/ch-add-constraints-Koval-2.xml	2024-02-19 16:34:33.334364	111	EXECUTED	9:41bf5578ff6338f371111836b2fce1e9	addForeignKeyConstraint baseTableName=own_security, constraintName=password_exists_with_user, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
Yurii-11	Yurii Koval	db/changelog/logs/ch-add-constraints-Koval-2.xml	2024-02-19 16:34:33.405507	112	EXECUTED	9:e804ce4277abd4d7151f2362c6d11858	addUniqueConstraint constraintName=one_user_one_password, tableName=own_security		\N	4.25.1	\N	\N	8360468164
1571227598316-153	Kuzenko B.	db/changelog/logs/ch-custom-goals-Kuzenko-1.xml	2024-02-19 16:34:33.469263	113	EXECUTED	9:5cb60f0df68d20e68c5cbe07a9518684	createTable tableName=custom_goals		\N	4.25.1	\N	\N	8360468164
1571227598316-154	Kuzenko B.	db/changelog/logs/ch-custom-goals-Kuzenko-1.xml	2024-02-19 16:34:33.493915	114	EXECUTED	9:0542e7030a7e5888cef41c8bf5c88ae0	addForeignKeyConstraint baseTableName=custom_goals, constraintName=FK_users, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
1571227598316-152	Kuzenko B.	db/changelog/logs/ch-change-table-Kuzenko-1.xml	2024-02-19 16:34:33.519342	115	EXECUTED	9:39d6770551e9deea35b6ab4cbefc2090	addColumn tableName=user_goals; addForeignKeyConstraint baseTableName=user_goals, constraintName=user_custom_goals, referencedTableName=custom_goals		\N	4.25.1	\N	\N	8360468164
1571227598316-151	Bogdan	db/changelog/logs/ch-change-table-Kuzenko-1.xml	2024-02-19 16:34:33.552588	116	EXECUTED	9:bd2ad4aaad2c1fd135ecefe1b014d3f9	sql		\N	4.25.1	\N	\N	8360468164
16	Yuriy O.	db/changelog/logs/ch-user-achievements-olkhovskyi-1.xml	2024-02-19 16:34:33.631394	117	EXECUTED	9:ed8ec7a587ca809d9984e06dad5df60c	createTable tableName=achievements		\N	4.25.1	\N	\N	8360468164
18	Yuriy O.	db/changelog/logs/ch-user-achievements-olkhovskyi-1.xml	2024-02-19 16:34:33.722582	119	EXECUTED	9:798c34960fd8cafd3cffb12920ec95ee	addForeignKeyConstraint baseTableName=user_achievements, constraintName=FK_user_user_achievements, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
1571227598316-154	Bogdan	db/changelog/logs/ch-news-subscriber-table-Kuzenko-1.xml	2024-02-19 16:34:33.828601	120	EXECUTED	9:b4ffb851a55ade3037462b3c2772ef7b	createTable tableName=news_subscribers		\N	4.25.1	\N	\N	8360468164
19	Olkhovskyi Y.	db/changelog/logs/ch-econews-olkhovskyi-2.xml	2024-02-19 16:34:33.903541	121	EXECUTED	9:1f50096f2876e3ec69fa942d85caf8f5	createTable tableName=eco_news		\N	4.25.1	\N	\N	8360468164
0lezhka-1	Kopylchak O.	db/changelog/logs/ch-advice-localization-kopylchak-1.xml	2024-02-19 16:34:33.962297	122	EXECUTED	9:4bb605371f5bb5dc511fa6d57ad88aab	createTable tableName=languages		\N	4.25.1	\N	\N	8360468164
0lezhka-2	Kopylchak O.	db/changelog/logs/ch-advice-localization-kopylchak-1.xml	2024-02-19 16:34:34.031457	123	EXECUTED	9:e354d4511117cfa35d1e37ef355e9c69	createTable tableName=advice_translations		\N	4.25.1	\N	\N	8360468164
0lezhka-3	Kopylchak O.	db/changelog/logs/ch-advice-localization-kopylchak-1.xml	2024-02-19 16:34:34.056342	124	EXECUTED	9:fc2395bad546095d085e1ba085ea6bad	dropColumn tableName=advices		\N	4.25.1	\N	\N	8360468164
0lezhka-4	Kopylchak O.	db/changelog/logs/ch-advice-localization-kopylchak-1.xml	2024-02-19 16:34:34.08946	125	EXECUTED	9:b2e9933f95168b67f428056c34ba4bc7	addForeignKeyConstraint baseTableName=advice_translations, constraintName=FK_advice_translation_language, referencedTableName=languages; addForeignKeyConstraint baseTableName=advice_translations, constraintName=FK_advice_translation_advice, refere...		\N	4.25.1	\N	\N	8360468164
4651326844-8	Vitaliy Dzen	db/changelog/logs/ch-fact-localization-dzen-4.xml	2024-02-19 16:34:34.129069	126	EXECUTED	9:39e3d5d4af567ec411d2b664400d60f1	createTable tableName=fact_translations		\N	4.25.1	\N	\N	8360468164
4651326844-9	Vitaliy Dzen	db/changelog/logs/ch-fact-localization-dzen-4.xml	2024-02-19 16:34:34.156049	127	EXECUTED	9:bd7f25c07d0e20a7c4f5348cd5bec247	dropColumn tableName=habit_facts		\N	4.25.1	\N	\N	8360468164
4651326844-10	Vitaliy Dzen	db/changelog/logs/ch-fact-localization-dzen-4.xml	2024-02-19 16:34:34.195911	128	EXECUTED	9:3d68126feba0cd2ac91b9890b19ca585	addForeignKeyConstraint baseTableName=fact_translations, constraintName=FK_fact_translations_language, referencedTableName=languages; addForeignKeyConstraint baseTableName=fact_translations, constraintName=FK_fact_translation_fact, referencedTable...		\N	4.25.1	\N	\N	8360468164
0lezhka-5	Kopylchak O.	db/changelog/logs/ch-goals-localization-Kopylchak-1.xml	2024-02-19 16:34:34.255451	129	EXECUTED	9:3349d35065f1291bdcddf9722abd0764	createTable tableName=goal_translations		\N	4.25.1	\N	\N	8360468164
0lezhka-6	Kopylchak O.	db/changelog/logs/ch-goals-localization-Kopylchak-1.xml	2024-02-19 16:34:34.280728	130	EXECUTED	9:25b2062f663f8995b2eb260771ec88a9	dropColumn tableName=goals		\N	4.25.1	\N	\N	8360468164
0lezhka-7	Kopylchak O.	db/changelog/logs/ch-goals-localization-Kopylchak-1.xml	2024-02-19 16:34:34.321881	131	EXECUTED	9:3eebf68ebfb511f980d3ce5549ef9ccf	addForeignKeyConstraint baseTableName=goal_translations, constraintName=FK_goal_goal_translations, referencedTableName=goals; addForeignKeyConstraint baseTableName=goal_translations, constraintName=FK_language_goal_translations, referencedTableNam...		\N	4.25.1	\N	\N	8360468164
Yurii-12	Yurii Koval	db/changelog/logs/ch-modify-column-Koval-3.xml	2024-02-19 16:34:34.374616	132	EXECUTED	9:183d6191d3885fd48f9d004b12721b12	modifyDataType columnName=date, tableName=habit_statistics		\N	4.25.1	\N	\N	8360468164
Yurii-13	Yurii Koval	db/changelog/logs/ch-modify-column-Koval-3.xml	2024-02-19 16:34:34.405145	133	EXECUTED	9:aa23410dd5f4650b43f4e4a85eeab1f4	modifyDataType columnName=create_date, tableName=habits		\N	4.25.1	\N	\N	8360468164
4651326844-22222200	Volodymyr Turko	db/changelog/logs/ch-update-habit-dictionary-turko.xml	2024-02-19 16:34:34.43851	134	EXECUTED	9:f64ee77ffa657e1e31b514d031edfc45	dropColumn tableName=habit_dictionary; dropColumn tableName=habit_dictionary; dropColumn tableName=habit_dictionary; addColumn tableName=habit_dictionary		\N	4.25.1	\N	\N	8360468164
46513268344-2012222	Volodymyr Turko	db/changelog/logs/ch-habit-dictionary-translation-turko.xml	2024-02-19 16:34:34.530345	135	EXECUTED	9:28d504fb6a25cf5c6147473a27fa5af8	createTable tableName=habit_dictionary_translation		\N	4.25.1	\N	\N	8360468164
465132699844-271222	Volodymyr Turko	db/changelog/logs/ch-habit-dictionary-translation-turko.xml	2024-02-19 16:34:34.571969	136	EXECUTED	9:5ea88bf4dcc7ff65a8796b490c5489aa	addForeignKeyConstraint baseTableName=habit_dictionary_translation, constraintName=FK_habit_dictionary_translation, referencedTableName=languages; addForeignKeyConstraint baseTableName=habit_dictionary_translation, constraintName=FK_habit_dictiona...		\N	4.25.1	\N	\N	8360468164
0lezhka-8	Kopylchak O.	db/changelog/logs/ch-eco-news-localization-Kopylchak-1.xml	2024-02-19 16:34:34.729829	137	EXECUTED	9:8e5db36c6df67320296458def7751b96	createTable tableName=eco_news_translations		\N	4.25.1	\N	\N	8360468164
0lezhka-9	Kopylchak O.	db/changelog/logs/ch-eco-news-localization-Kopylchak-1.xml	2024-02-19 16:34:34.772072	138	EXECUTED	9:a9e305d14207cb0394407ee6ab0506c7	dropColumn tableName=eco_news		\N	4.25.1	\N	\N	8360468164
0lezhka-10	Kopylchak O.	db/changelog/logs/ch-eco-news-localization-Kopylchak-1.xml	2024-02-19 16:34:34.825732	139	EXECUTED	9:3ccbb8964f8e829c487bbd9eecb1f589	addForeignKeyConstraint baseTableName=eco_news_translations, constraintName=FK_ecp_news_eco_news_translations, referencedTableName=eco_news; addForeignKeyConstraint baseTableName=eco_news_translations, constraintName=FK_language_eco_news_translati...		\N	4.25.1	\N	\N	8360468164
taraskovaliv1	Kovaliv Taras	db/changelog/logs/ch-eco-news-Kovaliv-1.xml	2024-02-19 16:34:34.900555	140	EXECUTED	9:a732654689761c77c2cc33b172f8892a	addColumn tableName=eco_news_translations		\N	4.25.1	\N	\N	8360468164
taraskovaliv2	Kovaliv Taras	db/changelog/logs/ch-eco-news-Kovaliv-1.xml	2024-02-19 16:34:34.942269	141	EXECUTED	9:1a99da3e50cbb71e0bbd6002fdd8e5e0	dropColumn tableName=eco_news; addColumn tableName=eco_news		\N	4.25.1	\N	\N	8360468164
taraskovaliv3	Kovaliv Taras	db/changelog/logs/ch-eco-news-Kovaliv-1.xml	2024-02-19 16:34:34.984022	142	EXECUTED	9:99dc4ffde8975fa7a9248d175fb3939f	addForeignKeyConstraint baseTableName=eco_news, constraintName=FK_eco_news_users, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
taraskovaliv4	Kovaliv Taras	db/changelog/logs/ch-eco-news-Kovaliv-2.xml	2024-02-19 16:34:35.059046	143	EXECUTED	9:3e7bcd8ffab28be30daeda5a1c915c19	createTable tableName=tags		\N	4.25.1	\N	\N	8360468164
taraskovaliv5	Kovaliv Taras	db/changelog/logs/ch-eco-news-Kovaliv-2.xml	2024-02-19 16:34:35.101069	144	EXECUTED	9:3ba08bc91083a479455e1ebf167c0a63	createTable tableName=eco_news_tags		\N	4.25.1	\N	\N	8360468164
taraskovaliv6	Kovaliv Taras	db/changelog/logs/ch-eco-news-Kovaliv-2.xml	2024-02-19 16:34:35.151085	145	EXECUTED	9:ded12547e3676dbd69b6dae66083fb80	addForeignKeyConstraint baseTableName=eco_news_tags, constraintName=FK_eco_news_tags_eco_news, referencedTableName=eco_news; addForeignKeyConstraint baseTableName=eco_news_tags, constraintName=FK_eco_news_tags_tags, referencedTableName=tags		\N	4.25.1	\N	\N	8360468164
yuriizhurakovskyi	Yurii Zhurakovskyi	db/changelog/logs/ch-add-column-Zhurakovskyi-1.xml	2024-02-19 16:34:36.896985	173	EXECUTED	9:3623cd7c7bf009020689ade8a250563f	addColumn tableName=users		\N	4.25.1	\N	\N	8360468164
xaaoc-1	Oleh Yurchuk	db/changelog/logs/ch-change-table-users-Yurchuk-1.xml	2024-02-19 16:34:35.192835	146	EXECUTED	9:a8dc738f0894ad271eace8c8670bf8e9	dropColumn columnName=last_name, tableName=users; renameColumn newColumnName=name, oldColumnName=first_name, tableName=users; modifyDataType columnName=name, tableName=users		\N	4.25.1	\N	\N	8360468164
taraskovaliv7	Kovaliv Taras	db/changelog/logs/ch-eco-news-Kovaliv-3.xml	2024-02-19 16:34:35.234512	147	EXECUTED	9:eff440ec0c73b19a9787f3868a5d0dd0	addColumn tableName=eco_news; addColumn tableName=eco_news		\N	4.25.1	\N	\N	8360468164
taraskovaliv8	Kovaliv Taras	db/changelog/logs/ch-eco-news-Kovaliv-3.xml	2024-02-19 16:34:35.28137	148	EXECUTED	9:610c61a5e6b40503a9f95e21c1567b59	dropTable tableName=eco_news_translations		\N	4.25.1	\N	\N	8360468164
taraskovaliv8	Kovaliv Taras	db/changelog/logs/ch-eco-news-Kovaliv-4.xml	2024-02-19 16:34:35.326215	149	EXECUTED	9:3a358a1a1a86dd224cd8b1527f4187d1	addColumn tableName=eco_news; dropNotNullConstraint columnName=image_path, tableName=eco_news		\N	4.25.1	\N	\N	8360468164
taraskovaliv9	Kovaliv Taras	db/changelog/logs/ch-eco-news-Kovaliv-4.xml	2024-02-19 16:34:35.367905	150	EXECUTED	9:28c0b2b81452de2ae8f76745ba722758	modifyDataType columnName=text, tableName=eco_news; modifyDataType columnName=title, tableName=eco_news		\N	4.25.1	\N	\N	8360468164
datsko-1	Marian Datsko	db/changelog/logs/ch-change-users-addColumn-datsko.xml	2024-02-19 16:34:35.434542	151	EXECUTED	9:4c2e391a87fd0b732a83a8b10e2d5d78	addColumn tableName=users		\N	4.25.1	\N	\N	8360468164
Patsula-1	Yurii Patsula	db/changelog/logs/ch-change-fact-translations-Patsula.xml	2024-02-19 16:34:35.476106	152	EXECUTED	9:7098908d735875a451c70bdc0c679ddc	addColumn tableName=fact_translations		\N	4.25.1	\N	\N	8360468164
olesyaostriychuk1	Olesya Ostriychuk	db/changelog/logs/ch-add-tips-and-tricks-Ostriychuk-1.xml	2024-02-19 16:34:35.597503	153	EXECUTED	9:101a060b155293f7092e15b3137744be	createTable tableName=tips_and_tricks		\N	4.25.1	\N	\N	8360468164
olesyaostriychuk2	Olesya Ostriychuk	db/changelog/logs/ch-add-tips-and-tricks-Ostriychuk-1.xml	2024-02-19 16:34:35.668447	154	EXECUTED	9:07b67d67d4b108eb49ee50e55112f44a	createTable tableName=tips_and_tricks_tags		\N	4.25.1	\N	\N	8360468164
olesyaostriychuk3	Olesya Ostriychuk	db/changelog/logs/ch-add-tips-and-tricks-Ostriychuk-1.xml	2024-02-19 16:34:35.710174	155	EXECUTED	9:c2c14a658523cb480b3ef7bdd966944e	createTable tableName=tips_and_tricks_tips_and_tricks_tags		\N	4.25.1	\N	\N	8360468164
olesyaostriychuk4	Olesya Ostriychuk	db/changelog/logs/ch-add-tips-and-tricks-Ostriychuk-1.xml	2024-02-19 16:34:35.785138	156	EXECUTED	9:eb93a8ef18ffb3373a163e36ea476b25	addUniqueConstraint constraintName=tips_and_tricks_tag_unique_name, tableName=tips_and_tricks_tags; addForeignKeyConstraint baseTableName=tips_and_tricks_tips_and_tricks_tags, constraintName=FK_tt_tags_and_related_tips_and_tricks, referencedTableN...		\N	4.25.1	\N	\N	8360468164
Patsula-4	Yurii Patsula	db/changelog/logs/ch-add-econews-comment-Patsula.xml	2024-02-19 16:34:35.876935	157	EXECUTED	9:30f9bf9ebc0df3089c74ebf30b259fea	createTable tableName=econews_comment		\N	4.25.1	\N	\N	8360468164
Patsula-5	Yurii Patsula	db/changelog/logs/ch-add-econews-comment-Patsula.xml	2024-02-19 16:34:35.92728	158	EXECUTED	9:1a7531dbb93c54500cba2b7dd47643f6	addForeignKeyConstraint baseTableName=econews_comment, constraintName=fk_comment_parent, referencedTableName=econews_comment; addForeignKeyConstraint baseTableName=econews_comment, constraintName=fk_comment_user, referencedTableName=users; addFore...		\N	4.25.1	\N	\N	8360468164
23.09.20.Lehkyi-1	Mykola Lehkyi	db/changelog/logs/ch-add-econews-comment-Patsula.xml	2024-02-19 16:34:35.977607	159	EXECUTED	9:ecba4d4a085daf12e1e6c1b22ad450a7	dropForeignKeyConstraint baseTableName=econews_comment, constraintName=fk_comment_parent; addForeignKeyConstraint baseTableName=econews_comment, constraintName=fk_econews_comment_parent, referencedTableName=econews_comment; dropForeignKeyConstrain...		\N	4.25.1	\N	\N	8360468164
Patsula-9	Yurii Patsula	db/changelog/logs/ch-add-econews-comment-Patsula.xml	2024-02-19 16:34:36.080949	160	EXECUTED	9:d59b5bcd6c98dddc83dac6355d7e2c47	createTable tableName=econews_comment_users_liked		\N	4.25.1	\N	\N	8360468164
Patsula-8	Yurii Patsula	db/changelog/logs/ch-add-econews-comment-Patsula.xml	2024-02-19 16:34:36.127357	161	EXECUTED	9:c5910fb1fb7a2fe49ebc3965a7f4b5e8	addForeignKeyConstraint baseTableName=econews_comment_users_liked, constraintName=fk_econews_comment, referencedTableName=econews_comment; addForeignKeyConstraint baseTableName=econews_comment_users_liked, constraintName=fk_users_liked, referenced...		\N	4.25.1	\N	\N	8360468164
23.09.20.Lehkyi-3_Patsula-8	Mykola Lehkyi	db/changelog/logs/ch-add-econews-comment-Patsula.xml	2024-02-19 16:34:36.169052	162	EXECUTED	9:8f464362bbcfad6b84b9ba56d971a399	dropForeignKeyConstraint baseTableName=econews_comment_users_liked, constraintName=fk_econews_comment; addForeignKeyConstraint baseTableName=econews_comment_users_liked, constraintName=fk_econews_comment_users_liked_econews_comment, referencedTabl...		\N	4.25.1	\N	\N	8360468164
Patsula-10	Yurii Patsula	db/changelog/logs/ch-add-econews-comment-Patsula.xml	2024-02-19 16:34:36.210913	163	EXECUTED	9:d7edaf1dc44cd9083f96d6c77f4df920	addColumn tableName=econews_comment		\N	4.25.1	\N	\N	8360468164
15712275d85316-98	Marian Datsko	db/changelog/logs/ch-users-friends-Datsko.xml	2024-02-19 16:34:36.255617	164	EXECUTED	9:e8580779d20114aa9f82c9b8a8fd491b	createTable tableName=users_friends		\N	4.25.1	\N	\N	8360468164
1571227598d316-105	Marian Datsko	db/changelog/logs/ch-users-friends-Datsko.xml	2024-02-19 16:34:36.29746	165	EXECUTED	9:689fe49dacc74edff4eb5adc9be3d476	addForeignKeyConstraint baseTableName=users_friends, constraintName=FK_user_users, referencedTableName=users; addForeignKeyConstraint baseTableName=users_friends, constraintName=FK_user_userFriend, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
1571227598d316-106	Yurii Savchenko	db/changelog/logs/ch-users-friends-Datsko.xml	2024-02-19 16:34:36.372138	166	EXECUTED	9:ef7ed3f5b5fd16cb22a04e49938d7c56	addPrimaryKey constraintName=PK_users_friends, tableName=users_friends		\N	4.25.1	\N	\N	8360468164
Yurii-5	Yurii Savchenko	db/changelog/logs/ch-users-friends-Datsko.xml	2024-02-19 16:34:36.413968	167	EXECUTED	9:0dba83e479273c3ed117c4bda71f1581	addColumn tableName=users_friends; addColumn tableName=users_friends		\N	4.25.1	\N	\N	8360468164
datsko-2	Marian Datsko	db/changelog/logs/ch-change-users-rating-Datsko.xml	2024-02-19 16:34:36.447449	168	EXECUTED	9:51b592d26baaeb89594296ae32e96e42	addColumn tableName=users		\N	4.25.1	\N	\N	8360468164
23.09.20.Lehkyi-8_datsko-2	Mykola Lehkyi	db/changelog/logs/ch-change-users-rating-Datsko.xml	2024-02-19 16:34:36.578232	169	EXECUTED	9:3279f106a4f906c277e5b8c81bca6a6e	modifyDataType columnName=rating, tableName=users		\N	4.25.1	\N	\N	8360468164
olesyaostriychuk5	Olesya Ostriychuk	db/changelog/logs/ch-change-eco-news-Ostriychuk.xml	2024-02-19 16:34:36.682848	170	EXECUTED	9:a137a16ec7ebda4b5e0db1763806a89a	modifyDataType columnName=title, tableName=eco_news		\N	4.25.1	\N	\N	8360468164
olesyaostriychuk6	Olesya Ostriychuk	db/changelog/logs/ch-change-eco-news-Ostriychuk.xml	2024-02-19 16:34:36.728194	171	EXECUTED	9:5f9fa2fc428b035d9542b42fdf652bf7	addNotNullConstraint columnName=title, tableName=eco_news; addNotNullConstraint columnName=text, tableName=eco_news		\N	4.25.1	\N	\N	8360468164
olesyaostriychuk7	Olesya Ostriychuk	db/changelog/logs/ch-change-eco-news-Ostriychuk.xml	2024-02-19 16:34:36.86204	172	EXECUTED	9:e313b1aa6139c82f75e85480b5478265	modifyDataType columnName=name, tableName=users		\N	4.25.1	\N	\N	8360468164
Beshlei-1	Taras Beshlei	db/changelog/logs/ch-add-tipsandtricks-comment-Beshlei.xml	2024-02-19 16:34:37.003664	174	EXECUTED	9:d5faf9bcfb368651bb114d027abb91c1	createTable tableName=tipsandtricks_comment		\N	4.25.1	\N	\N	8360468164
Beshlei-2	Taras Beshlei	db/changelog/logs/ch-add-tipsandtricks-comment-Beshlei.xml	2024-02-19 16:34:37.055558	175	EXECUTED	9:40a606d40c1db8e51ed6b0c67cc382ee	addForeignKeyConstraint baseTableName=tipsandtricks_comment, constraintName=fk_comment_parent, referencedTableName=tipsandtricks_comment; addForeignKeyConstraint baseTableName=tipsandtricks_comment, constraintName=fk_comment_user, referencedTableN...		\N	4.25.1	\N	\N	8360468164
23.09.20.Lehkyi-2_Beshlei-2	Mykola Lehkyi	db/changelog/logs/ch-add-tipsandtricks-comment-Beshlei.xml	2024-02-19 16:34:37.097297	176	EXECUTED	9:5d8145970a8c840473a14799608d8e6e	dropForeignKeyConstraint baseTableName=tipsandtricks_comment, constraintName=fk_comment_parent; addForeignKeyConstraint baseTableName=tipsandtricks_comment, constraintName=fk_tipsandtricks_comment_parent, referencedTableName=tipsandtricks_comment;...		\N	4.25.1	\N	\N	8360468164
Beshlei-3	Taras Beshlei	db/changelog/logs/ch-add-tipsandtricks-comment-Beshlei.xml	2024-02-19 16:34:37.153856	177	EXECUTED	9:541506bb45418f6daa956ef82b4cf6e9	createTable tableName=tipsandtricks_comment_users_liked		\N	4.25.1	\N	\N	8360468164
Beshlei-4	Taras Beshlei	db/changelog/logs/ch-add-tipsandtricks-comment-Beshlei.xml	2024-02-19 16:34:37.197163	178	EXECUTED	9:f72a1dd6ea6dabffce1ccae7047c2e89	addForeignKeyConstraint baseTableName=tipsandtricks_comment_users_liked, constraintName=fk_tipsandtricks_comment, referencedTableName=tipsandtricks_comment; addForeignKeyConstraint baseTableName=tipsandtricks_comment_users_liked, constraintName=fk...		\N	4.25.1	\N	\N	8360468164
23.09.20.Lehkyi-4_Beshlei-4	Mykola Lehkyi	db/changelog/logs/ch-add-tipsandtricks-comment-Beshlei.xml	2024-02-19 16:34:37.230839	179	EXECUTED	9:b89c26ac586e7d0c7609b238e1665df2	dropForeignKeyConstraint baseTableName=tipsandtricks_comment_users_liked, constraintName=fk_tipsandtricks_comment; addForeignKeyConstraint baseTableName=tipsandtricks_comment_users_liked, constraintName=fk_tipsandtricks_comment_users_liked_tipsand...		\N	4.25.1	\N	\N	8360468164
Beshlei-5	Taras Beshlei	db/changelog/logs/ch-add-tipsandtricks-comment-Beshlei.xml	2024-02-19 16:34:37.264133	180	EXECUTED	9:0b74f6d33d3a59e11bca00142f5df718	addColumn tableName=tipsandtricks_comment		\N	4.25.1	\N	\N	8360468164
15712275v85316-98	Marian Datsko	db/changelog/logs/ch-user-profile-Datsko.xml.xml	2024-02-19 16:34:37.297333	181	EXECUTED	9:871f9a534da1c0427f7d5c4c24bed3b7	createTable tableName=user_social_networks		\N	4.25.1	\N	\N	8360468164
1571227598c316-105	Marian Datsko	db/changelog/logs/ch-user-profile-Datsko.xml.xml	2024-02-19 16:34:37.330799	182	EXECUTED	9:2bb4c803d5dc628299a9ada9c96c59c3	addForeignKeyConstraint baseTableName=user_social_networks, constraintName=FK_user_profile, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
15712275k85316-98	Marian Datsko	db/changelog/logs/ch-user-profile-Datsko.xml.xml	2024-02-19 16:34:37.40657	183	EXECUTED	9:fbff0cfdc2040994168fcc214e2c4c22	addColumn tableName=users; addColumn tableName=users; addColumn tableName=users; addColumn tableName=users; addColumn tableName=users; addColumn tableName=users		\N	4.25.1	\N	\N	8360468164
olesyaostriychuk8	Olesya Ostriychuk	db/changelog/logs/ch-merge-tags-Ostriychuk.xml	2024-02-19 16:34:37.462478	184	EXECUTED	9:3ac3910d3e48359d33f4a254c794dd99	dropForeignKeyConstraint baseTableName=tips_and_tricks_tips_and_tricks_tags, constraintName=FK_tips_and_tricks_and_related_tt_tags		\N	4.25.1	\N	\N	8360468164
olesyaostriychuk9	Olesya Ostriychuk	db/changelog/logs/ch-merge-tags-Ostriychuk.xml	2024-02-19 16:34:37.501143	185	EXECUTED	9:4707c49ab8725dba065a2a5921ca05dd	dropTable tableName=tips_and_tricks_tags		\N	4.25.1	\N	\N	8360468164
olesyaostriychuk10	Olesya Ostriychuk	db/changelog/logs/ch-merge-tags-Ostriychuk.xml	2024-02-19 16:34:37.537354	186	EXECUTED	9:be7fe029fd9c43e5647467b9e102ec7c	renameTable newTableName=tips_and_tricks_tags, oldTableName=tips_and_tricks_tips_and_tricks_tags; renameColumn newColumnName=tags_id, oldColumnName=tips_and_tricks_tags_id, tableName=tips_and_tricks_tags		\N	4.25.1	\N	\N	8360468164
olesyaostriychuk11	Olesya Ostriychuk	db/changelog/logs/ch-merge-tags-Ostriychuk.xml	2024-02-19 16:34:37.570774	187	EXECUTED	9:2eb336266c24adece781288a7689efe6	addForeignKeyConstraint baseTableName=tips_and_tricks_tags, constraintName=FK_tips_and_tricks_and_related_tags, referencedTableName=tags		\N	4.25.1	\N	\N	8360468164
Beshlei-8	Taras Beshlei	db/changelog/logs/ch-habit-status-Beshlei-2.xml	2024-02-19 16:34:37.63072	188	EXECUTED	9:f818f280678d69b47699d59201bc3f0e	createTable tableName=habit_status		\N	4.25.1	\N	\N	8360468164
Beshlei-7	Taras Beshlei	db/changelog/logs/ch-habit-status-Beshlei-2.xml	2024-02-19 16:34:37.66446	189	EXECUTED	9:74e93ad0ee340050f654f07d3485b2ad	addForeignKeyConstraint baseTableName=habit_status, constraintName=fk_habit_id, referencedTableName=habits		\N	4.25.1	\N	\N	8360468164
23.09.20.Lehkyi-7_Beshlei-7	Mykola Lehkyi	db/changelog/logs/ch-habit-status-Beshlei-2.xml	2024-02-19 16:34:37.697491	190	EXECUTED	9:2769c0471d879c93b264525d5005bd43	dropForeignKeyConstraint baseTableName=habit_status, constraintName=fk_habit_id; addForeignKeyConstraint baseTableName=habit_status, constraintName=fk_habit_status_habits, referencedTableName=habits		\N	4.25.1	\N	\N	8360468164
Beshlei-14	Taras Beshlei	db/changelog/logs/ch-habit-status-Beshlei-2.xml	2024-02-19 16:34:37.731007	191	EXECUTED	9:ec9012641af39208e659e53e3eb8e9a4	createTable tableName=habits_habit_statuses		\N	4.25.1	\N	\N	8360468164
Beshlei-16	Taras Beshlei	db/changelog/logs/ch-habit-status-Beshlei-2.xml	2024-02-19 16:34:37.764298	192	EXECUTED	9:2f385448be1a40eeceb471758a08911b	renameColumn newColumnName=habit_statuses_id, oldColumnName=habit_status_id, tableName=habits_habit_statuses		\N	4.25.1	\N	\N	8360468164
Beshlei-17	Taras Beshlei	db/changelog/logs/ch-habit-status-Beshlei-2.xml	2024-02-19 16:34:37.797502	193	EXECUTED	9:a96136400096ae063b99ae32c1412c76	addForeignKeyConstraint baseTableName=habits_habit_statuses, constraintName=fk_habit_statuses_id, referencedTableName=habit_status; addForeignKeyConstraint baseTableName=habits_habit_statuses, constraintName=fk_habit_id, referencedTableName=habits		\N	4.25.1	\N	\N	8360468164
Beshlei-18	Taras Beshlei	db/changelog/logs/ch-habit-status-Beshlei-2.xml	2024-02-19 16:34:37.830984	194	EXECUTED	9:93c81374405a6c2c0598f9b0f3b48e59	addColumn tableName=habit_status		\N	4.25.1	\N	\N	8360468164
Beshlei-19	Taras Beshlei	db/changelog/logs/ch-habit-status-Beshlei-2.xml	2024-02-19 16:34:37.864151	195	EXECUTED	9:57b32b1b414892e36cdfc89edb2399d3	addColumn tableName=habit_status; addForeignKeyConstraint baseTableName=habit_status, constraintName=fk_user_id, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
Beshlei-20	Taras Beshlei	db/changelog/logs/ch-habit-status-Beshlei-2.xml	2024-02-19 16:34:37.89959	196	EXECUTED	9:f3ed8abd4dcc16f97ebf600dd0786c50	dropTable tableName=habits_habit_statuses		\N	4.25.1	\N	\N	8360468164
Beshlei-23	Taras Beshlei	db/changelog/logs/ch-habit-status-Beshlei-2.xml	2024-02-19 16:34:37.930742	197	EXECUTED	9:930bd6ab2dc05258dcc7a706f4a629d6	addColumn tableName=habit_status		\N	4.25.1	\N	\N	8360468164
Beshlei-9	Taras Beshlei	db/changelog/logs/ch-habits-Beshlei-1.xml	2024-02-19 16:34:37.964296	198	EXECUTED	9:8edf82358f0db879aec215eaf2d63bb2	addColumn tableName=habits		\N	4.25.1	\N	\N	8360468164
Beshlei-10	Taras Beshei	db/changelog/logs/ch-habits-Beshlei-1.xml	2024-02-19 16:34:37.997514	199	EXECUTED	9:54535fe1c8d48286eac829560fb98638	addForeignKeyConstraint baseTableName=habits, constraintName=fk_habit_status_id, referencedTableName=habit_status		\N	4.25.1	\N	\N	8360468164
Beshlei-11	Taras Beshlei	db/changelog/logs/ch-habits-Beshlei-1.xml	2024-02-19 16:34:38.031014	200	EXECUTED	9:6de6f62361696ab156c430ddb29767b0	dropColumn columnName=user_id, tableName=habits		\N	4.25.1	\N	\N	8360468164
Beshlei-12	Taras Beshlei	db/changelog/logs/ch-habits-Beshlei-1.xml	2024-02-19 16:34:38.064339	201	EXECUTED	9:8a0be5e9a7ef2a971680c86c81c111f8	createTable tableName=habits_users_assign		\N	4.25.1	\N	\N	8360468164
Beshlei-13	Taras Beshlei	db/changelog/logs/ch-habits-Beshlei-1.xml	2024-02-19 16:34:38.097883	202	EXECUTED	9:8407b2710b31b5cfaf1f50a8d32c1617	addForeignKeyConstraint baseTableName=habits_users_assign, constraintName=fk_habit_id, referencedTableName=habits; addForeignKeyConstraint baseTableName=habits_users_assign, constraintName=fk_users_id, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
23.09.20.Lehkyi-5_Beshlei-13	Mykola Lehkyi	db/changelog/logs/ch-habits-Beshlei-1.xml	2024-02-19 16:34:38.139483	203	EXECUTED	9:358f7c6ec18c644e9c7fd514a5d2600c	dropForeignKeyConstraint baseTableName=habits_users_assign, constraintName=fk_habit_id; addForeignKeyConstraint baseTableName=habits_users_assign, constraintName=fk_habits_users_assign_habits, referencedTableName=habits; dropForeignKeyConstraint b...		\N	4.25.1	\N	\N	8360468164
Beshlei-14	Taras Beshlei	db/changelog/logs/ch-habits-Beshlei-1.xml	2024-02-19 16:34:38.172577	204	EXECUTED	9:f0467cfae92ad5008b09f2ab34347f83	dropColumn columnName=habit_status_id, tableName=habits		\N	4.25.1	\N	\N	8360468164
Beshlei-1	Taras Beshlei	db/changelog/logs/ch-habit-status-calendar-Beshlei-1.xml	2024-02-19 16:34:38.247204	205	EXECUTED	9:55b2b10947624e92f3ca40dc5d7f0d95	createTable tableName=habit_status_calendar		\N	4.25.1	\N	\N	8360468164
Beshlei-2	Taras Beshlei	db/changelog/logs/ch-habit-status-calendar-Beshlei-1.xml	2024-02-19 16:34:38.280716	206	EXECUTED	9:e451a94625f0a55d40fe4f0564b19513	addForeignKeyConstraint baseTableName=habit_status_calendar, constraintName=fk_habit_status_id, referencedTableName=habit_status		\N	4.25.1	\N	\N	8360468164
Beshlei-7	Taras Beshlei	db/changelog/logs/ch-habit-status-calendar-Beshlei-1.xml	2024-02-19 16:34:38.313999	207	EXECUTED	9:7e7e434e6ad126e4d412ef57c47e7f26	modifyDataType columnName=enroll_date, tableName=habit_status_calendar		\N	4.25.1	\N	\N	8360468164
Beshlei-8	Taras Beshlei	db/changelog/logs/ch-habit-status-calendar-Beshlei-1.xml	2024-02-19 16:34:38.37531	208	EXECUTED	9:34d8cf761a69ea13778afb09302194dc	modifyDataType columnName=enroll_date, tableName=habit_status_calendar		\N	4.25.1	\N	\N	8360468164
lehkyi-4	Mykola Lehkyi	db/changelog/logs/ch-primarykey-eco-news-tags-Lehkyi-1.xml	2024-02-19 16:34:38.421835	209	EXECUTED	9:fbc001ff71703982407bb208bf4f6c4b	addPrimaryKey constraintName=eco_news_tags_pkey, tableName=eco_news_tags		\N	4.25.1	\N	\N	8360468164
lehkyi-3	Mykola Lehkyi	db/changelog/logs/ch-primarykey-tips-and-tricks-tags-Lehkyi.xml	2024-02-19 16:34:38.471932	210	EXECUTED	9:b31b58c5354d8b30395bdad3e1c4beea	addPrimaryKey constraintName=tips_and_tricks_tags_pkey, tableName=tips_and_tricks_tags		\N	4.25.1	\N	\N	8360468164
Lehkyi-5	Mykola Lehkyi	db/changelog/logs/ch-fact-of-the-day-Lehkyi.xml	2024-02-19 16:34:38.530974	211	EXECUTED	9:1b133b6088a504d9822a63fa592610cc	createTable tableName=fact_of_the_day		\N	4.25.1	\N	\N	8360468164
Lehkyi-6	Mykola Lehkyi	db/changelog/logs/ch-fact-of-the-day-Lehkyi.xml	2024-02-19 16:34:38.588999	212	EXECUTED	9:3bc8c0825355b57d0e94e012299fbe99	createTable tableName=fact_of_the_day_translations		\N	4.25.1	\N	\N	8360468164
Lehkyi-7	Mykola Lehkyi	db/changelog/logs/ch-fact-of-the-day-Lehkyi.xml	2024-02-19 16:34:38.630464	213	EXECUTED	9:adb5f223bcd032af46cac5151023fe9a	addForeignKeyConstraint baseTableName=fact_of_the_day_translations, constraintName=FK_fact_of_the_day_fact_of_the_day_translations, referencedTableName=fact_of_the_day; addForeignKeyConstraint baseTableName=fact_of_the_day_translations, constraint...		\N	4.25.1	\N	\N	8360468164
Lehkyi-15	Mykola Lehkyi	db/changelog/logs/ch-social-network-Lehkyi.xml	2024-02-19 16:34:38.767065	214	EXECUTED	9:03cff8a3a7cccb1582fb7b51692376d0	createTable tableName=social_network_images		\N	4.25.1	\N	\N	8360468164
Lehkyi-16	Mykola Lehkyi	db/changelog/logs/ch-social-network-Lehkyi.xml	2024-02-19 16:34:38.889466	215	EXECUTED	9:f2292dd80b11ef7689067b6dd8018c0c	createTable tableName=social_networks		\N	4.25.1	\N	\N	8360468164
Lehkyi-17	Mykola Lehkyi	db/changelog/logs/ch-social-network-Lehkyi.xml	2024-02-19 16:34:38.931119	216	EXECUTED	9:3394db0a7186d7711f3b094815d6fb29	addForeignKeyConstraint baseTableName=social_networks, constraintName=FK_user_social_network, referencedTableName=users; addForeignKeyConstraint baseTableName=social_networks, constraintName=FK_social_network_social_network_image, referencedTableN...		\N	4.25.1	\N	\N	8360468164
Lehkyi-18	Mykola Lehkyi	db/changelog/logs/ch-social-network-Lehkyi.xml	2024-02-19 16:34:38.974401	217	EXECUTED	9:fed78d0314cfd55ad3964d839493d653	dropTable tableName=user_social_networks		\N	4.25.1	\N	\N	8360468164
Lehkyi-19	Mykola Lehkyi	db/changelog/logs/ch-social-network-Lehkyi.xml	2024-02-19 16:34:39.006125	218	EXECUTED	9:cf3a1ac6bd8353d9e107cf5e05dac673	insert tableName=social_network_images		\N	4.25.1	\N	\N	8360468164
Dovganyuk-1	Dovganyuk Taras	db/changelog/logs/ch_rating_statictics_Dovganyuk.xml	2024-02-19 16:34:39.11465	219	EXECUTED	9:d11b82be78eb7a15cf46afaf91ff74a8	createTable tableName=rating_statistics		\N	4.25.1	\N	\N	8360468164
Dovganyuk-2	Dovganyuk Taras	db/changelog/logs/ch_rating_statictics_Dovganyuk.xml	2024-02-19 16:34:39.155074	220	EXECUTED	9:8eb2cdb4143bb2c8fdfea2ec931f3e1e	addForeignKeyConstraint baseTableName=rating_statistics, constraintName=rating_statistics_users_id_fk, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
23.09.20.Lehkyi-8_Dovganyuk-1	Mykola Lehkyi	db/changelog/logs/ch_rating_statictics_Dovganyuk.xml	2024-02-19 16:34:39.311715	221	EXECUTED	9:eb3ca3cd549eb53d2adc382e9c429b59	modifyDataType columnName=points_changed, tableName=rating_statistics; modifyDataType columnName=current_rating, tableName=rating_statistics		\N	4.25.1	\N	\N	8360468164
Dovganyuk_15	Dovganyuk Taras	db/changelog/logs/ch-user-username-column-type.xml	2024-02-19 16:34:39.340209	222	EXECUTED	9:14f4738765278c5a8a6878ece362dfcd	modifyDataType columnName=name, tableName=users		\N	4.25.1	\N	\N	8360468164
Petryshak-1	Olena Petryshak	db/changelog/logs/ch-tips-and-tricks-translations-Petryshak.xml	2024-02-19 16:34:39.408221	223	EXECUTED	9:cdff65f3e320377261fb3057b34a76b2	createTable tableName=title_translations		\N	4.25.1	\N	\N	8360468164
Petryshak-2	Olena Petryshak	db/changelog/logs/ch-tips-and-tricks-translations-Petryshak.xml	2024-02-19 16:34:39.472214	224	EXECUTED	9:557272fca0b24125c1f78137206fbf14	createTable tableName=text_translations		\N	4.25.1	\N	\N	8360468164
Petryshak-3	Olena Petryshak	db/changelog/logs/ch-tips-and-tricks-translations-Petryshak.xml	2024-02-19 16:34:39.533483	225	EXECUTED	9:48ddd889f2257bfcc62f4a140dca83af	addForeignKeyConstraint baseTableName=title_translations, constraintName=FK_tips_and_tricks_title_translations, referencedTableName=tips_and_tricks; addForeignKeyConstraint baseTableName=title_translations, constraintName=FK_language_title_transla...		\N	4.25.1	\N	\N	8360468164
Petryshak-4	Olena Petryshak	db/changelog/logs/ch-tips-and-tricks-translations-Petryshak.xml	2024-02-19 16:34:39.583449	226	EXECUTED	9:ad4ac291c8e47f99ec791cacd9e44c6f	addForeignKeyConstraint baseTableName=text_translations, constraintName=FK_tips_and_tricks_text_translations, referencedTableName=tips_and_tricks; addForeignKeyConstraint baseTableName=text_translations, constraintName=FK_language_text_translation...		\N	4.25.1	\N	\N	8360468164
Petryshak-5	Olena Petryshak	db/changelog/logs/ch-tips-and-tricks-translations-Petryshak.xml	2024-02-19 16:34:39.616715	227	EXECUTED	9:9c3445ba09e63ec8990b1ddaa5605b61	dropColumn columnName=title, tableName=tips_and_tricks; dropColumn columnName=text, tableName=tips_and_tricks		\N	4.25.1	\N	\N	8360468164
1	Kravchenko	db/changelog/logs/ch-habits-refactor-Kravchenko.xml	2024-02-19 16:34:39.650104	228	EXECUTED	9:7322fec9d04c3c8dafd3d6e86e5aa10c	renameTable newTableName=habit_translation, oldTableName=habit_dictionary_translation		\N	4.25.1	\N	\N	8360468164
2	Kravchenko	db/changelog/logs/ch-habits-refactor-Kravchenko.xml	2024-02-19 16:34:39.692296	229	EXECUTED	9:41f435114e92e01cc1fa8ea21a7b2385	dropColumn tableName=habits; addColumn tableName=habits; renameColumn newColumnName=habit_id, oldColumnName=habit_dictionary_id, tableName=habit_translation; dropForeignKeyConstraint baseTableName=habit_translation, constraintName=FK_habit_diction...		\N	4.25.1	\N	\N	8360468164
3	Kravchenko	db/changelog/logs/ch-habits-refactor-Kravchenko.xml	2024-02-19 16:34:39.733765	230	EXECUTED	9:1b59b5cb8295c08319efb44d30b13d7a	renameColumn newColumnName=habit_id, oldColumnName=habit_dictionary_id, tableName=advices; dropForeignKeyConstraint baseTableName=advices, constraintName=FK_advices_habit_dictionary; addForeignKeyConstraint baseTableName=advices, constraintName=fk...		\N	4.25.1	\N	\N	8360468164
4	Kravchenko	db/changelog/logs/ch-habits-refactor-Kravchenko.xml	2024-02-19 16:34:39.775363	231	EXECUTED	9:5b503e61b88dd6608751dc8c0452657e	renameColumn newColumnName=habit_id, oldColumnName=habit_dictionary_id, tableName=habit_facts; dropForeignKeyConstraint baseTableName=habit_facts, constraintName=FK_habit_facts_habit_dictionary; addForeignKeyConstraint baseTableName=habit_facts, c...		\N	4.25.1	\N	\N	8360468164
5	Kravchenko	db/changelog/logs/ch-habits-refactor-Kravchenko.xml	2024-02-19 16:34:39.841674	232	EXECUTED	9:09ce0262aa560541a65c790b9d8d1576	dropTable tableName=habit_dictionary		\N	4.25.1	\N	\N	8360468164
6	Kravchenko	db/changelog/logs/ch-habits-refactor-Kravchenko.xml	2024-02-19 16:34:39.935456	233	EXECUTED	9:0e5b205d01796a42c49983c8f84e6e15	dropColumn columnName=status, tableName=habits; dropColumn columnName=create_date, tableName=habits; dropTable tableName=habits_users_assign; createTable tableName=habit_assign; addForeignKeyConstraint baseTableName=habit_assign, constraintName=fk...		\N	4.25.1	\N	\N	8360468164
7	Kravchenko	db/changelog/logs/ch-habits-refactor-Kravchenko.xml	2024-02-19 16:34:40.048844	234	EXECUTED	9:6b11bd6969522cfed6e6e28d5df54583	dropTable tableName=habit_status_calendar; dropTable tableName=habit_status; createTable tableName=habit_status; addForeignKeyConstraint baseTableName=habit_status, constraintName=fk_habit_status_habit_assign_id, referencedTableName=habit_assign		\N	4.25.1	\N	\N	8360468164
8	Kravchenko	db/changelog/logs/ch-habits-refactor-Kravchenko.xml	2024-02-19 16:34:40.198111	235	EXECUTED	9:df67bc27b819b5a1fa748e2e591ea2b9	dropTable tableName=habit_statistics; createTable tableName=habit_statistics; addForeignKeyConstraint baseTableName=habit_statistics, constraintName=fk_habit_statistics_habit_assign_id, referencedTableName=habit_assign		\N	4.25.1	\N	\N	8360468164
9	Kravchenko	db/changelog/logs/ch-habits-refactor-Kravchenko.xml	2024-02-19 16:34:40.296983	236	EXECUTED	9:f61271c78b2fa0c30b320a518d9f6c65	createTable tableName=habit_status_calendar; addForeignKeyConstraint baseTableName=habit_status_calendar, constraintName=fk_habit_status_id, referencedTableName=habit_status		\N	4.25.1	\N	\N	8360468164
10	Kravchenko	db/changelog/logs/ch-habits-refactor-Kravchenko.xml	2024-02-19 16:34:40.338677	237	EXECUTED	9:8115fb32b8450eb09726d948bee4e1f9	renameTable newTableName=habit_fact_translations, oldTableName=fact_translations		\N	4.25.1	\N	\N	8360468164
1	Olena Petryshak	db/changelog/logs/ch-change-column-name-goals-Petryshak.xml	2024-02-19 16:34:40.380245	238	EXECUTED	9:65954f94d228c70f76adc30f5a9e3bb7	renameColumn newColumnName=content, oldColumnName=text, tableName=goal_translations		\N	4.25.1	\N	\N	8360468164
dmytrokhonko1	Dmytro Khonko	db/changelog/logs/ch-change-custom-goals-Khonko.xml	2024-02-19 16:34:40.421984	239	EXECUTED	9:e3fc4186b7cb7a6e8520553953c16c83	addColumn tableName=custom_goals		\N	4.25.1	\N	\N	8360468164
dmytrokhonko2	Dmytro Khonko	db/changelog/logs/ch-change-custom-goals-Khonko.xml	2024-02-19 16:34:40.463797	240	EXECUTED	9:a537c4c3ca629372e433b2379f4a47ed	addColumn tableName=custom_goals		\N	4.25.1	\N	\N	8360468164
dmytrokhonko4	Dmytro Khonko	db/changelog/logs/ch-change-goals-Khonko.xml	2024-02-19 16:34:40.505467	241	EXECUTED	9:e5295c6b9578005c0e226650fb3e5378	sql		\N	4.25.1	\N	\N	8360468164
dmytrokhonko3	Dmytro Khonko	db/changelog/logs/ch-change-goals-Khonko.xml	2024-02-19 16:34:40.547439	242	EXECUTED	9:29ee87dd43c16f2a6e7b842ad275d7a2	dropColumn tableName=user_goals		\N	4.25.1	\N	\N	8360468164
1	Kravchenko	db/changelog/logs/ch-habits-new-fields-Kravchenko.xml	2024-02-19 16:34:40.588768	243	EXECUTED	9:294c0e11729aad84d4ca4b1b94301539	addColumn tableName=habit_assign		\N	4.25.1	\N	\N	8360468164
2	Kravchenko	db/changelog/logs/ch-habits-new-fields-Kravchenko.xml	2024-02-19 16:34:40.626553	244	EXECUTED	9:7f49af996dc4ceff72f454dccbde1283	addColumn tableName=habits		\N	4.25.1	\N	\N	8360468164
3	Kravchenko	db/changelog/logs/ch-habits-new-fields-Kravchenko.xml	2024-02-19 16:34:40.663907	245	EXECUTED	9:5697207758b14cfc77f0e8326b66b5c4	addColumn tableName=habit_assign		\N	4.25.1	\N	\N	8360468164
4	Kravchenko	db/changelog/logs/ch-habits-new-fields-Kravchenko.xml	2024-02-19 16:34:40.705532	246	EXECUTED	9:2d4c58519bb6adfc6979750365b5d657	addColumn tableName=habit_assign		\N	4.25.1	\N	\N	8360468164
5	Kravchenko	db/changelog/logs/ch-habits-new-fields-Kravchenko.xml	2024-02-19 16:34:40.747818	247	EXECUTED	9:d8a673d999086157555df3402da3f344	dropForeignKeyConstraint baseTableName=habit_status_calendar, constraintName=fk_habit_status_id; renameColumn newColumnName=habit_assign_id, oldColumnName=habit_status_id, tableName=habit_status_calendar; addForeignKeyConstraint baseTableName=habi...		\N	4.25.1	\N	\N	8360468164
dmytrokhonko5	Dmytro Khonko	db/changelog/logs/ch-habit-goals-Khonko-1.xml	2024-02-19 16:34:40.843407	248	EXECUTED	9:9c8893225fb1f5d0949bfe8ef6cf2325	createTable tableName=habit_goals		\N	4.25.1	\N	\N	8360468164
dmytrokhonko6	Dmytro Khonko	db/changelog/logs/ch-habit-goals-Khonko-1.xml	2024-02-19 16:34:40.893361	249	EXECUTED	9:c099a32bce9820d7a43035d0a787d77a	addForeignKeyConstraint baseTableName=habit_goals, constraintName=FK_habit_goal_goal, referencedTableName=goals; addForeignKeyConstraint baseTableName=habit_goals, constraintName=FK_habit_goal_habit, referencedTableName=habits		\N	4.25.1	\N	\N	8360468164
dmytrokhonko7	Dmytro Khonko	db/changelog/logs/ch-change-column-name-user-goals-Khonko.xml	2024-02-19 16:34:40.935127	250	EXECUTED	9:dee34c011fe6f49e8bcf28430daccbf8	dropForeignKeyConstraint baseTableName=user_goals, constraintName=FK_user_user_goals; delete tableName=user_goals		\N	4.25.1	\N	\N	8360468164
dmytrokhonko8	Dmytro Khonko	db/changelog/logs/ch-change-column-name-user-goals-Khonko.xml	2024-02-19 16:34:40.976613	251	EXECUTED	9:b865516eaf39990162de4fcdbe972350	renameColumn newColumnName=habit_assign_id, oldColumnName=user_id, tableName=user_goals		\N	4.25.1	\N	\N	8360468164
dmytrokhonko9	Dmytro Khonko	db/changelog/logs/ch-change-column-name-user-goals-Khonko.xml	2024-02-19 16:34:41.01823	252	EXECUTED	9:cc6174b97ef5ff6b348f04dfc0eb6b6a	addForeignKeyConstraint baseTableName=user_goals, constraintName=FK_user_goal_habit_assign, referencedTableName=habit_assign; addForeignKeyConstraint baseTableName=user_goals, constraintName=FK_user_goal_goal, referencedTableName=goals		\N	4.25.1	\N	\N	8360468164
Mamchuk-1	Orest Mamchuk	db/changelog/logs/ch-change-table-achievement-Mamchuk.xml	2024-02-19 16:34:41.136786	253	EXECUTED	9:1880780380c27f6a87c59c6ecfa2cb89	createTable tableName=achievement_categories		\N	4.25.1	\N	\N	8360468164
Mamchuk-2	Orest Mamchuk	db/changelog/logs/ch-change-table-achievement-Mamchuk.xml	2024-02-19 16:34:41.177524	254	EXECUTED	9:f1650d6a5e1d42b31da1be7e21f4156b	addColumn tableName=achievements; dropColumn tableName=achievements		\N	4.25.1	\N	\N	8360468164
Mamchuk-4	Orest Mamchuk	db/changelog/logs/ch-change-table-achievement-Mamchuk.xml	2024-02-19 16:34:41.218992	255	EXECUTED	9:ba262ceb948473a56e63e3390197e3fc	addForeignKeyConstraint baseTableName=achievements, constraintName=achievements_category_id_fk, referencedTableName=achievement_categories		\N	4.25.1	\N	\N	8360468164
Mamchuck-1	Mamchuk Orest	db/changelog/logs/ch-achievement_translations-Mamchuk.xml	2024-02-19 16:34:41.319454	256	EXECUTED	9:59845cff3e41116dfeceb942dec7fd0a	createTable tableName=achievement_translations		\N	4.25.1	\N	\N	8360468164
Mamchuk-2	Mamchuk Orest	db/changelog/logs/ch-achievement_translations-Mamchuk.xml	2024-02-19 16:34:41.369135	257	EXECUTED	9:941d6eb03454a147d3e09e9816f9b6f7	addForeignKeyConstraint baseTableName=achievement_translations, constraintName=achievement_translations_achievement_id_fk, referencedTableName=achievements; addForeignKeyConstraint baseTableName=achievement_translations, constraintName=achievement...		\N	4.25.1	\N	\N	8360468164
dmytrokhonko10	Dmytro Khonko	db/changelog/logs/ch-change-habitAssign-Khonko.xml	2024-02-19 16:34:41.410758	258	EXECUTED	9:77bb492df368ced156f60ff59d82cf03	addColumn tableName=habit_assign; dropColumn tableName=habit_assign; dropColumn tableName=habit_assign		\N	4.25.1	\N	\N	8360468164
Derevetskyi-1	Markiyan Derevetskyi	db/changelog/logs/ch-table-habits-tags-Derevetskyi.xml	2024-02-19 16:34:41.51087	259	EXECUTED	9:03402268517a12618772598a9fda00c9	createTable tableName=habits_tags		\N	4.25.1	\N	\N	8360468164
Derevetskyi-2	Markiyan Derevetskyi	db/changelog/logs/ch-table-habits-tags-Derevetskyi.xml	2024-02-19 16:34:41.605178	260	EXECUTED	9:620d3f09e59af2030106375bc6fea153	addPrimaryKey constraintName=PK_habits_tags, tableName=habits_tags; addForeignKeyConstraint baseTableName=habits_tags, constraintName=FK_habit_tags_habits, referencedTableName=habits; addForeignKeyConstraint baseTableName=habits_tags, constraintNa...		\N	4.25.1	\N	\N	8360468164
Mamchuk-1	Mamchuk Orest	db/changelog/logs/ch-user-actions-Mamchuk.xml	2024-02-19 16:34:41.688502	261	EXECUTED	9:4452b4f4d40547a29adb30acb6b7fcf8	createTable tableName=user_actions		\N	4.25.1	\N	\N	8360468164
Mamchuk-2	Mamchuk Orest	db/changelog/logs/ch-user-actions-Mamchuk.xml	2024-02-19 16:34:41.721711	262	EXECUTED	9:acbb99357f14388a2b0e6258744dddfc	addForeignKeyConstraint baseTableName=user_actions, constraintName=user_actions_users_id_fk, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
Derevetskyi-3	Markiyan Derevetskyi	db/changelog/logs/ch-drop-column-name-from-tag-Derevetskyi.xml	2024-02-19 16:34:41.763276	263	EXECUTED	9:1048ed173b8e5b65a9196a3e49be9f15	dropColumn tableName=tags		\N	4.25.1	\N	\N	8360468164
Derevetskyi-4	Markiyan Derevetskyi	db/changelog/logs/ch-table-tag-translations-Derevetskyi.xml	2024-02-19 16:34:41.805035	264	EXECUTED	9:a385fbaf4ede25032842f2eb880b4d96	createTable tableName=tag_translations		\N	4.25.1	\N	\N	8360468164
Derevetskyi-5	Markiyan Derevetskyi	db/changelog/logs/ch-table-tag-translations-Derevetskyi.xml	2024-02-19 16:34:41.897059	265	EXECUTED	9:c15a75964e7ce1256d6857a6a006ccad	addPrimaryKey constraintName=PK_tag_translations, tableName=tag_translations; addForeignKeyConstraint baseTableName=tag_translations, constraintName=FK_tag_translations_tags, referencedTableName=tags; addForeignKeyConstraint baseTableName=tag_tran...		\N	4.25.1	\N	\N	8360468164
5	Kravchenko	db/changelog/logs/ch-add-messages-Kravchenko.xml	2024-02-19 16:34:41.952904	266	EXECUTED	9:6a29932a4bfdc805902b375e318ecec9	createTable tableName=chat_rooms		\N	4.25.1	\N	\N	8360468164
6	Kravchenko	db/changelog/logs/ch-add-messages-Kravchenko.xml	2024-02-19 16:34:42.003432	267	EXECUTED	9:f950e00d045f87036659cec53165e883	createTable tableName=chat_messages; addForeignKeyConstraint baseTableName=chat_messages, constraintName=fk_sender_users_user_id, referencedTableName=users; addForeignKeyConstraint baseTableName=chat_messages, constraintName=fk_messages_room_chat_...		\N	4.25.1	\N	\N	8360468164
7	Kravchenko	db/changelog/logs/ch-add-messages-Kravchenko.xml	2024-02-19 16:34:42.080659	268	EXECUTED	9:aea600a3e07bdea37bad393c343372f2	createTable tableName=chat_rooms_participants; addForeignKeyConstraint baseTableName=chat_rooms_participants, constraintName=fk_participant_users_id, referencedTableName=users; addForeignKeyConstraint baseTableName=chat_rooms_participants, constra...		\N	4.25.1	\N	\N	8360468164
8	Kravchenko	db/changelog/logs/ch-add-messages-Kravchenko.xml	2024-02-19 16:34:42.111646	269	EXECUTED	9:65cf46671c7e7794daaaf899d9d103ab	addColumn tableName=chat_rooms		\N	4.25.1	\N	\N	8360468164
Derevetskyi-1	Markiyan Derevetskyi	db/changelog/logs/ch-add-type-column-to-tags-Derevetskyi.xml	2024-02-19 16:34:42.145326	270	EXECUTED	9:adf2ea139cc394bb5b9dd6029d00e30e	addColumn tableName=tags		\N	4.25.1	\N	\N	8360468164
Mamchuk-5	Orest Mamchuk	db/changelog/logs/ch-change-user-action-Mamchuk.xml	2024-02-19 16:34:42.178379	271	EXECUTED	9:aba88c32b47702d1788a25e397eedf76	dropColumn tableName=user_actions		\N	4.25.1	\N	\N	8360468164
Mamchuk-7	Orest Mamchuk	db/changelog/logs/ch-change-user-action-Mamchuk.xml	2024-02-19 16:34:42.211681	272	EXECUTED	9:accde0361f97c266f20d401b2e3d618c	addColumn tableName=user_actions		\N	4.25.1	\N	\N	8360468164
Mamchuk-8	Orest Mamchuk	db/changelog/logs/ch-change-user-action-Mamchuk.xml	2024-02-19 16:34:42.245094	273	EXECUTED	9:ee6a8407437820709aae23685351da64	addForeignKeyConstraint baseTableName=user_actions, constraintName=achievement_category_id_fk, referencedTableName=achievement_categories		\N	4.25.1	\N	\N	8360468164
Mamchuk-9	Mamchuk Orest	db/changelog/logs/ch-change-user-achievements-Mamchuk.xml	2024-02-19 16:34:42.278416	274	EXECUTED	9:af05c17ddcfc30c37fafa1a499a2b4f2	addColumn tableName=user_achievements		\N	4.25.1	\N	\N	8360468164
novosad1	Novosad R.	db/changelog/logs/ch-change-eco-news-Novosad.xml	2024-02-19 16:34:42.311833	275	EXECUTED	9:883131f54ab33bc58824d18e6789b0b1	createTable tableName=eco_news_users_likes		\N	4.25.1	\N	\N	8360468164
novosad2	Novosad R.	db/changelog/logs/ch-change-eco-news-Novosad.xml	2024-02-19 16:34:42.345229	276	EXECUTED	9:4b7247c824f365ca6f5fb6927b2d50da	addForeignKeyConstraint baseTableName=eco_news_users_likes, constraintName=fk_eco_news_users_likes_eco_news, referencedTableName=eco_news; addForeignKeyConstraint baseTableName=eco_news_users_likes, constraintName=fk_eco_news_users_likes_users, re...		\N	4.25.1	\N	\N	8360468164
Bilonizhka	Oleh Bilonizhka	db/changelog/logs/ch-add-column-Bilonizhka.xml	2024-02-19 16:34:42.378684	277	EXECUTED	9:e002892da0bfe0a64e5e667f83f025e0	addColumn tableName=users		\N	4.25.1	\N	\N	8360468164
1611329116503-1	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.39927	278	EXECUTED	9:c150e4f6d596935b488c0a28671e7cf1	createSequence sequenceName=address_id_seq		\N	4.25.1	\N	\N	8360468164
1611329116503-2	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.412845	279	EXECUTED	9:7f961f4514cca2dbeee63f6ed484515a	createSequence sequenceName=bag_id_seq		\N	4.25.1	\N	\N	8360468164
1611329116503-3	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.431603	280	EXECUTED	9:a17731710305111df20dcfac7e5b1160	createSequence sequenceName=hibernate_sequence		\N	4.25.1	\N	\N	8360468164
1611329116503-4	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.454642	281	EXECUTED	9:c792220616a21883446842f45d46b81f	createSequence sequenceName=orders_id_seq		\N	4.25.1	\N	\N	8360468164
1611329116503-7	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.473347	282	EXECUTED	9:403f5a51ad854a70b678cea8890c1d77	createSequence sequenceName=ubs_user_id_seq		\N	4.25.1	\N	\N	8360468164
1611329116503-10	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.52039	283	EXECUTED	9:cbe64cc2c33d47f39e5030f67c9532dd	createTable tableName=address		\N	4.25.1	\N	\N	8360468164
1611329116503-11	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.562183	284	EXECUTED	9:672091295aaf0a3d60b9da3023122871	createTable tableName=bag		\N	4.25.1	\N	\N	8360468164
1611329116503-12	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.622079	285	EXECUTED	9:cca0e44c4abd4e393420ef908e665eca	createTable tableName=certificate		\N	4.25.1	\N	\N	8360468164
1611329116503-13	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.655293	286	EXECUTED	9:aea1fb0d173ad155939c331691d52fab	createTable tableName=change_of_points_mapping		\N	4.25.1	\N	\N	8360468164
1611329116503-14	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.688677	287	EXECUTED	9:f2027189c58cf17ed0d799743f43814a	createTable tableName=order_bag_mapping		\N	4.25.1	\N	\N	8360468164
1611329116503-15	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.788941	288	EXECUTED	9:1b597d242f2100c7d1ef0024bd31024a	createTable tableName=orders		\N	4.25.1	\N	\N	8360468164
1611329116503-19	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.946821	289	EXECUTED	9:c84c74c1e72673d6b24de29f76871a38	createTable tableName=ubs_user		\N	4.25.1	\N	\N	8360468164
1611329116503-21	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:42.980248	290	EXECUTED	9:415306d9aa43da93cf377db94c0e8031	createTable tableName=users_orders		\N	4.25.1	\N	\N	8360468164
1611329116503-22	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.012825	291	EXECUTED	9:4a3b4f6070ef715c060069363df414b9	createTable tableName=users_ubs_users		\N	4.25.1	\N	\N	8360468164
1611329116503-24	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.071886	292	EXECUTED	9:025c00df38d101b62dc89c5238837353	addPrimaryKey constraintName=certificate_pkey, tableName=certificate		\N	4.25.1	\N	\N	8360468164
1611329116503-25	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.138124	293	EXECUTED	9:faebf8d9ca5354eaf317dc36c3ef7df2	addPrimaryKey constraintName=change_of_points_mapping_pkey, tableName=change_of_points_mapping		\N	4.25.1	\N	\N	8360468164
1611329116503-26	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.20488	294	EXECUTED	9:d8f2619a8ae91d6ba6c6dec407ec708a	addPrimaryKey constraintName=order_bag_mapping_pkey, tableName=order_bag_mapping		\N	4.25.1	\N	\N	8360468164
1611329116503-28	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.263222	295	EXECUTED	9:6afe417a5f124b7410941670fc832e32	addPrimaryKey constraintName=users_ubs_users_pkey, tableName=users_ubs_users		\N	4.25.1	\N	\N	8360468164
1611329116503-29	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.339019	296	EXECUTED	9:a974d40a2ec97578b8f2c597e147ac05	addUniqueConstraint constraintName=uk_1njdfitph68mh7p7c6f3qc736, tableName=users_orders		\N	4.25.1	\N	\N	8360468164
1611329116503-31	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.405579	297	EXECUTED	9:cff93389856cd2dd660760f838cc27c4	addUniqueConstraint constraintName=uk_ayqn8ucyg0vw9t6j8q9jqw4go, tableName=users_ubs_users		\N	4.25.1	\N	\N	8360468164
1611329116503-32	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.438956	298	EXECUTED	9:727e18dd97022aee78a00acc8924ba4e	addForeignKeyConstraint baseTableName=orders, constraintName=fk1evtdroba5rlynltqtprpcaay, referencedTableName=ubs_user		\N	4.25.1	\N	\N	8360468164
1611329116503-33	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.472194	299	EXECUTED	9:ec75818df5444355f4c5c9a13459c29a	addForeignKeyConstraint baseTableName=users_ubs_users, constraintName=fk1lkpw3mxvqakkyt3m7fk38b0x, referencedTableName=ubs_user		\N	4.25.1	\N	\N	8360468164
1611329116503-34	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.5056	300	EXECUTED	9:92c303992dba63d61af488cf618561c6	addForeignKeyConstraint baseTableName=users_orders, constraintName=fk2lnf5jw8p8q0ytkr8dp0mlx6, referencedTableName=orders		\N	4.25.1	\N	\N	8360468164
1611329116503-35	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.538934	301	EXECUTED	9:0345279093092dae73239c6b6602a65e	addForeignKeyConstraint baseTableName=change_of_points_mapping, constraintName=fk77v8r6rgf8obsgkrp9rtriacu, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
1611329116503-37	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.572212	302	EXECUTED	9:e6fd8df059308d892598b6f8f0720b01	addForeignKeyConstraint baseTableName=ubs_user, constraintName=fkc5cw0lrmhx6mbwqnklkyudhse, referencedTableName=address		\N	4.25.1	\N	\N	8360468164
1611329116503-39	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.605559	303	EXECUTED	9:250e8235c0af1e6a31e1a8f1c42b6905	addForeignKeyConstraint baseTableName=orders, constraintName=fke6k45xxoin4fylnwg2jkehwjf, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
1611329116503-41	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.638907	304	EXECUTED	9:688766e283ca18a513110324679d1506	addForeignKeyConstraint baseTableName=ubs_user, constraintName=fkfce5nygk074yf9qm7ofjo7em2, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
1611329116503-42	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.67228	305	EXECUTED	9:ef08d48bd0f8885a1ad71ee39eb70d76	addForeignKeyConstraint baseTableName=users_orders, constraintName=fkms88pdhtsiuuusjpeij73f6df, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
1611329116503-43	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.705565	306	EXECUTED	9:4459a71b813fac7015f2496a1b0f9ea3	addForeignKeyConstraint baseTableName=orders, constraintName=fkmu3q308of5895kb6flm0777nj, referencedTableName=certificate		\N	4.25.1	\N	\N	8360468164
1611329116503-44	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.738943	307	EXECUTED	9:9bd622fb76c993db9bd70846b9f96e8c	addForeignKeyConstraint baseTableName=order_bag_mapping, constraintName=fkpkamv5em3c345mcyo3b6gr50a, referencedTableName=orders		\N	4.25.1	\N	\N	8360468164
1611329116503-45	Oleh B. (generated)	db/changelog/logs/ch-add-all-ubs-tables-Bilonizhka.xml	2024-02-19 16:34:43.772319	308	EXECUTED	9:9b3a517b1d15018c6d3576abce793845	addForeignKeyConstraint baseTableName=users_ubs_users, constraintName=fkrxcrvbobq146pmg2k1qym0lkb, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
MarianDiakiv01	MarianDiakiv	db/changelog/logs/ch-change-habit-goal-id-Diakiv.xml	2024-02-19 16:34:43.805731	309	EXECUTED	9:47fc0d5b55076e1acf9ed696d733bdcf	addAutoIncrement columnName=id, tableName=habit_goals		\N	4.25.1	\N	\N	8360468164
MarianDiakiv02	MarianDiakiv	db/changelog/logs/ch-change-habit-goal-add-status-Diakiv.xml	2024-02-19 16:34:43.881441	310	EXECUTED	9:33b60c8a3f9eef7d3a84ec38ea7b1957	addColumn tableName=habit_goals		\N	4.25.1	\N	\N	8360468164
Bilonizhka8	Oleh Bilonizhka	db/changelog/logs/ch-add-coordinates-Bilonizhka.xml	2024-02-19 16:34:43.914084	311	EXECUTED	9:d140a6db4b8e70f661116f51ab2a3a9f	addColumn tableName=address; addColumn tableName=address		\N	4.25.1	\N	\N	8360468164
Bilonizhka1	Oleh Bilonizhka	db/changelog/logs/ch-add-column-1-Bilonizhka.xml	2024-02-19 16:34:43.947438	312	EXECUTED	9:374f3fa4295a6222ebf2f663794c1a79	addColumn tableName=orders		\N	4.25.1	\N	\N	8360468164
Bilonizhka11	Oleh Bilonizhka	db/changelog/logs/ch-add-new-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:43.980791	313	EXECUTED	9:e66f3a75aaf2b3d6a22ef22f8f5d8a7a	addColumn tableName=users		\N	4.25.1	\N	\N	8360468164
Bilonizhka12	Oleh Bilonizhka	db/changelog/logs/ch-add-new-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:44.014131	314	EXECUTED	9:261a84a5adff39bc107e3b10f8bb1663	addColumn tableName=certificate		\N	4.25.1	\N	\N	8360468164
Bilonizhka13	Oleh Bilonizhka	db/changelog/logs/ch-add-new-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:44.047563	315	EXECUTED	9:d6badd5abe8956b4152202de2965dc05	addColumn tableName=orders; addColumn tableName=orders; addColumn tableName=orders; addColumn tableName=orders		\N	4.25.1	\N	\N	8360468164
Bilonizhka14	Oleh Bilonizhka	db/changelog/logs/ch-add-new-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:44.113972	316	EXECUTED	9:0fc326391ed3cafa3afee9f47eb62cb6	createTable tableName=employees		\N	4.25.1	\N	\N	8360468164
Bilonizhka15	Oleh Bilonizhka	db/changelog/logs/ch-add-new-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:44.172362	317	EXECUTED	9:d65df830e53bbca049458bcd6bc06b9e	createTable tableName=positions		\N	4.25.1	\N	\N	8360468164
Bilonizhka16	Oleh Bilonizhka	db/changelog/logs/ch-add-new-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:44.288281	318	EXECUTED	9:9c507f3b35c673fbacd3b279f262339a	createTable tableName=employee_position; addForeignKeyConstraint baseTableName=employee_position, constraintName=employee_position_employeeId_FC, referencedTableName=employees; addForeignKeyConstraint baseTableName=employee_position, constraintNam...		\N	4.25.1	\N	\N	8360468164
Bilonizhka17	Oleh Bilonizhka	db/changelog/logs/ch-add-new-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:44.321673	319	EXECUTED	9:12e9a5c4f5a54d31a1addf88b6b9daf1	createTable tableName=order_employee; addForeignKeyConstraint baseTableName=order_employee, constraintName=order_employee_orderId_FC, referencedTableName=orders; addForeignKeyConstraint baseTableName=order_employee, constraintName=order_employee_e...		\N	4.25.1	\N	\N	8360468164
DeleteForeignKey	MarianDiakiv	db/changelog/logs/ch-rename-goal-to-shoping-list-item-Diakiv.xml	2024-02-19 16:34:44.355006	320	EXECUTED	9:5ba6a9848e24cb2e233df06db3c1f8ac	dropForeignKeyConstraint baseTableName=habit_goals, constraintName=FK_habit_goal_goal; dropForeignKeyConstraint baseTableName=goal_translations, constraintName=FK_goal_goal_translations; dropForeignKeyConstraint baseTableName=user_goals, constrain...		\N	4.25.1	\N	\N	8360468164
goal-rename	MarianDiakiv	db/changelog/logs/ch-rename-goal-to-shoping-list-item-Diakiv.xml	2024-02-19 16:34:44.388303	321	EXECUTED	9:d6d63f71278e11801452bf3bd22b06cf	renameTable newTableName=shopping_list_items, oldTableName=goals		\N	4.25.1	\N	\N	8360468164
rename_column_in_goal_translations	MarianDiakiv	db/changelog/logs/ch-rename-goal-to-shoping-list-item-Diakiv.xml	2024-02-19 16:34:44.421652	322	EXECUTED	9:957dd5d50c2ea5f8eb94a8494bbb80cd	renameColumn newColumnName=shopping_list_item_id, oldColumnName=goal_id, tableName=goal_translations		\N	4.25.1	\N	\N	8360468164
rename_table_goal_translations	MarianDiakiv	db/changelog/logs/ch-rename-goal-to-shoping-list-item-Diakiv.xml	2024-02-19 16:34:44.455267	323	EXECUTED	9:4cf41be32ff8cb1461b6f8b64229fbe6	renameTable newTableName=shopping_list_item_translations, oldTableName=goal_translations		\N	4.25.1	\N	\N	8360468164
rename_column_in_habit_goals	MarianDiakiv	db/changelog/logs/ch-rename-goal-to-shoping-list-item-Diakiv.xml	2024-02-19 16:34:44.488379	324	EXECUTED	9:1f111d5238d46cbfd93127613c997ca2	renameColumn newColumnName=shopping_list_item_id, oldColumnName=goal_id, tableName=habit_goals		\N	4.25.1	\N	\N	8360468164
rename_table_habit_goals	MarianDiakiv	db/changelog/logs/ch-rename-goal-to-shoping-list-item-Diakiv.xml	2024-02-19 16:34:44.521941	325	EXECUTED	9:a4d37d0fb7a8aa0a47e8a2f2eb029502	renameTable newTableName=habit_shopping_list_items, oldTableName=habit_goals		\N	4.25.1	\N	\N	8360468164
rename_column_in_user_goals	MarianDiakiv	db/changelog/logs/ch-rename-goal-to-shoping-list-item-Diakiv.xml	2024-02-19 16:34:44.555143	326	EXECUTED	9:d7632c2c43e7437a4fb87e6ba4e6a5d2	renameColumn newColumnName=shopping_list_item_id, oldColumnName=goal_id, tableName=user_goals		\N	4.25.1	\N	\N	8360468164
rename_table_user_goals	MarianDiakiv	db/changelog/logs/ch-rename-goal-to-shoping-list-item-Diakiv.xml	2024-02-19 16:34:44.588412	327	EXECUTED	9:ab983168024b257068851d8607008762	renameTable newTableName=user_shopping_list, oldTableName=user_goals		\N	4.25.1	\N	\N	8360468164
renameCustom-goal	MarianDiakiv	db/changelog/logs/ch-rename-goal-to-shoping-list-item-Diakiv.xml	2024-02-19 16:34:44.621664	328	EXECUTED	9:33e7bfbf315d9f3f613b06ba84dff452	renameTable newTableName=custom_shopping_list_items, oldTableName=custom_goals		\N	4.25.1	\N	\N	8360468164
addForeignForeignKey	MarianDiakiv	db/changelog/logs/ch-rename-goal-to-shoping-list-item-Diakiv.xml	2024-02-19 16:34:44.655282	329	EXECUTED	9:ef33e0fc932b5ec83b754ae599086591	addForeignKeyConstraint baseTableName=habit_shopping_list_items, constraintName=FK_habit_shopping_list_item, referencedTableName=shopping_list_items; addForeignKeyConstraint baseTableName=shopping_list_item_translations, constraintName=FK_translat...		\N	4.25.1	\N	\N	8360468164
add-language-column	MarianDiakiv	db/changelog/logs/ch-add-language-column-to-user-Diakiv.xml	2024-02-19 16:34:44.688501	330	EXECUTED	9:a9e3e3ebb8de59342ab850bafec100e1	addColumn tableName=users		\N	4.25.1	\N	\N	8360468164
addForeignKey	MarianDiakiv	db/changelog/logs/ch-add-language-column-to-user-Diakiv.xml	2024-02-19 16:34:44.721782	331	EXECUTED	9:528c6c7d09ecbabbb1dce995d18cf119	addForeignKeyConstraint baseTableName=users, constraintName=user_language_id, referencedTableName=languages		\N	4.25.1	\N	\N	8360468164
Bezrukavyy1	SerhiyBezrukavyy	db/changelog/logs/ch-add-column-imageName-to-chatMessages-Bezrukavyy.xml	2024-02-19 16:34:44.781349	332	EXECUTED	9:0b2106a0531a9a0e8c96e75fc5254188	addColumn tableName=chat_messages		\N	4.25.1	\N	\N	8360468164
Bezrukavyy2	SerhiyBezrukavyy	db/changelog/logs/ch-add-column-participantId-to-chatMessages-Bezrukavyy.xml	2024-02-19 16:34:44.821806	333	EXECUTED	9:10c3b8a4a4eb8fc0742dd07720c29d03	addColumn tableName=chat_rooms		\N	4.25.1	\N	\N	8360468164
addCertificateDateCreateionColumn	Marian Diakiv	db/changelog/logs/ch-add-column-Diakiv.xml	2024-02-19 16:34:44.855148	334	EXECUTED	9:91ccd5089a60a6abb771dee060d7fa61	addColumn tableName=certificate		\N	4.25.1	\N	\N	8360468164
modifyCertificateDataType	MarianDiakiv	db/changelog/logs/ch-add-column-Diakiv.xml	2024-02-19 16:34:44.929742	335	EXECUTED	9:718f997269fc2d4946be544729df0f8c	modifyDataType columnName=code, tableName=certificate		\N	4.25.1	\N	\N	8360468164
Bilonizhka18	Oleh Bilonizhka	db/changelog/logs/ch-change-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:44.971442	336	EXECUTED	9:cd5333f90ae2c0ea4688a376121c5018	dropColumn columnName=certificate_code, tableName=orders; dropColumn columnName=additional_order, tableName=orders		\N	4.25.1	\N	\N	8360468164
Bilonizhka19	Oleh Bilonizhka	db/changelog/logs/ch-change-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:45.004789	337	EXECUTED	9:cf72df280e28370b1306660232a78961	addColumn tableName=certificate; addForeignKeyConstraint baseTableName=certificate, constraintName=certificate_orderId_FC, referencedTableName=orders		\N	4.25.1	\N	\N	8360468164
Bilonizhka20	Oleh Bilonizhka	db/changelog/logs/ch-change-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:45.073392	338	EXECUTED	9:861352518ec5deff528d85835f5156da	createTable tableName=order_additional-order; addPrimaryKey tableName=order_additional-order; addForeignKeyConstraint baseTableName=order_additional-order, constraintName=order_additional-order_orderId_FC, referencedTableName=orders		\N	4.25.1	\N	\N	8360468164
Bilonizhka21	Oleh Bilonizhka	db/changelog/logs/ch-change-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:45.106762	339	EXECUTED	9:77dbbf148b285110bf606c8a3157347e	renameTable newTableName=order_additional, oldTableName=order_additional-order		\N	4.25.1	\N	\N	8360468164
Bilonizhka22	Oleh Bilonizhka	db/changelog/logs/ch-change-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:45.140072	340	EXECUTED	9:118615ab31e4057c6935ac19801c0b91	renameColumn newColumnName=additional_order, oldColumnName=additional-order, tableName=order_additional; renameColumn newColumnName=orders_id, oldColumnName=order_id, tableName=order_additional		\N	4.25.1	\N	\N	8360468164
Bilonizhka23	Oleh Bilonizhka	db/changelog/logs/ch-change-ubs-columns-Bilonizhka.xml	2024-02-19 16:34:45.17939	341	EXECUTED	9:a6546e243dcfbf63604e0dd917a95e67	dropTable tableName=users_orders; dropTable tableName=users_ubs_users		\N	4.25.1	\N	\N	8360468164
Bezrukavyy3	SerhiyBezrukavyy	db/changelog/logs/ch-add-column-fileType-to-chatMessages-Bezrukavyy.xml	2024-02-19 16:34:45.213643	342	EXECUTED	9:1bd25a1a9a7c5f2e03abe0d61bd7f249	addColumn tableName=chat_messages		\N	4.25.1	\N	\N	8360468164
Bezrukavyy4	SerhiyBezrukavyy	db/changelog/logs/ch-rename-column-imageName-in-fileName-Bezrukavyy.xml	2024-02-19 16:34:45.246701	343	EXECUTED	9:1b400cd6bdf182090aeb37aa9cbf3532	renameColumn newColumnName=file_name, oldColumnName=image_name, tableName=chat_messages		\N	4.25.1	\N	\N	8360468164
Pikhotskyi-1	Pikhotskyi	db/changelog/logs/ch-add-reasons-for-user-deactivatiom-table-Pikhotskyi.xml	2024-02-19 16:34:45.315257	344	EXECUTED	9:0c204bb0eed03c9f90110e51a8178a71	createTable tableName=reasons_for_user_deactivation; addForeignKeyConstraint baseTableName=reasons_for_user_deactivation, constraintName=fk_reasons_for_user_deactivation_users_id, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
Bilonizhka24	Oleh Bilonizhka	db/changelog/logs/ch-ubs-database-seperation.xml	2024-02-19 16:34:45.348589	345	EXECUTED	9:31ce9f8b9d3fe0740685a9005324bf65	addColumn tableName=users		\N	4.25.1	\N	\N	8360468164
Bilonizhka26	Oleh Bilonizhka	db/changelog/logs/ch-ubs-database-seperation.xml	2024-02-19 16:34:45.42075	346	EXECUTED	9:69e4e9d281b0f809c97c75af6b3c957c	dropTable tableName=employee_position; dropTable tableName=order_employee; dropTable tableName=employees; dropTable tableName=positions; dropTable tableName=change_of_points_mapping; dropTable tableName=order_additional; dropTable tableName=order_...		\N	4.25.1	\N	\N	8360468164
createTableMessageLikesInChat1	MarianDiakiv	db/changelog/logs/ch-add-table-message-likes-Diakiv.xml	2024-02-19 16:34:45.471491	347	EXECUTED	9:0055b8db9ec68023af8bdc168989fbb7	createTable tableName=message_like		\N	4.25.1	\N	\N	8360468164
createTableMessageLikesInChat2	MarianDiakiv	db/changelog/logs/ch-add-table-message-likes-Diakiv.xml	2024-02-19 16:34:45.51579	348	EXECUTED	9:230376ad98ad3d545ab30b31e536dafa	addForeignKeyConstraint baseTableName=message_like, constraintName=fk_message_id, referencedTableName=chat_messages; addForeignKeyConstraint baseTableName=message_like, constraintName=fk_participant_id, referencedTableName=users; addNotNullConstra...		\N	4.25.1	\N	\N	8360468164
Struk2	Nazar Struk	db/changelog/logs/ch-add-constraints-to-habits-assign-table-Struk.xml	2024-02-19 16:34:45.624062	349	EXECUTED	9:1c8e7e97c770f50e32f66669e2cf3bfa	addUniqueConstraint constraintName=one_unique_habit_one_unique_status_one_unique_userID_verification_token, tableName=habit_assign		\N	4.25.1	\N	\N	8360468164
Levko	Olha Levko	db/changelog/logs/ch-drop-column-last_visit-in-users-table-Levko.xml	2024-02-19 16:34:45.657459	350	EXECUTED	9:8d6bb5ff43ce1a2049b3fe8bd6959735	dropColumn tableName=users		\N	4.25.1	\N	\N	8360468164
add-column-file-url-to-chat-message-Diakiv1	MarianDiakiv	db/changelog/logs/ch-add-column-file-url-to-chat-message-Diakiv.xml	2024-02-19 16:34:45.690926	351	EXECUTED	9:124f52855e39fc06895faf9578392491	addColumn tableName=chat_messages		\N	4.25.1	\N	\N	8360468164
zakhar123	ZakharVeremchuk	db/changelog/logs/ch-update-column-habit-id-at-habit-status-calendar-Veremchuk.xml	2024-02-19 16:34:45.749136	352	EXECUTED	9:d91d6fa89f9924992a5edd6d3e2e0ee1	addUniqueConstraint constraintName=UK_eroll_date_and_habie_assign_id, tableName=habit_status_calendar		\N	4.25.1	\N	\N	8360468164
1571227598335-1	Hutei Volodymyr	db/changelog/logs/ch-add-table-Hutei.xml	2024-02-19 16:34:45.807847	353	EXECUTED	9:c5d5edd30edef46bf33cf7dcfb255433	createTable tableName=unread_messages; addForeignKeyConstraint baseTableName=unread_messages, constraintName=fk5s2hfa0bsgdsipw5kdyd5bhfx, referencedTableName=chat_messages; addForeignKeyConstraint baseTableName=unread_messages, constraintName=fkh8...		\N	4.25.1	\N	\N	8360468164
Hutei-xx1	Volodymyr Hutei	db/changelog/logs/ch-add-column-Hutei.xml	2024-02-19 16:34:45.842481	354	EXECUTED	9:4fd3879e81a9fd3babbf636998c1b36e	addColumn tableName=custom_shopping_list_items; addForeignKeyConstraint baseTableName=custom_shopping_list_items, constraintName=fk5s2hfx1xsgdsipw5kdyd5bhfx, referencedTableName=habits		\N	4.25.1	\N	\N	8360468164
Levko2	Olha Levko	db/changelog/logs/ch-add-column-habit-complexity-Levko.xml	2024-02-19 16:34:45.883927	355	EXECUTED	9:95627a07809f98fb803c7c1d52e56920	addColumn tableName=habits		\N	4.25.1	\N	\N	8360468164
Levko3	Olha Levko	db/changelog/logs/ch-add-column-habit-complexity-Levko.xml	2024-02-19 16:34:45.925762	356	EXECUTED	9:1417d3ec3e2d158e2ee84d47dd79531a	sql		\N	4.25.1	\N	\N	8360468164
Struk1	NazarStruk	db/changelog/logs/ch-add-column-phone-to-user-Struk.xml	2024-02-19 16:34:45.967295	357	EXECUTED	9:5d72deb3fb876ae8a37f8e6be2ed76be	addColumn tableName=users		\N	4.25.1	\N	\N	8360468164
Volianskyi1	Ihor Volianskyi	db/changelog/logs/ch-drop-constraint-habits-assign-table-Volianskyi.xml	2024-02-19 16:34:46.010416	358	EXECUTED	9:cbd76636664682534da30db8cc7c25ea	dropUniqueConstraint constraintName=one_unique_habit_one_unique_status_one_unique_userID_verification_token, tableName=habit_assign		\N	4.25.1	\N	\N	8360468164
FedorkivCratRoom1	BohdanFedorkiv	db/changelog/logs/ch-add-column-to-crat-room-fedorkiv.xml	2024-02-19 16:34:46.05057	359	EXECUTED	9:04a461639253c304898462c3c8ea00f5	addColumn tableName=chat_rooms		\N	4.25.1	\N	\N	8360468164
Max-32	Max Boiarchuk	db/changelog/logs/ch-update-column-status-in-users_friends.xml	2024-02-19 16:34:46.147539	360	EXECUTED	9:31edb382bb4cef2ef21562a4eb593b5c	modifyDataType columnName=status, tableName=users_friends		\N	4.25.1	\N	\N	8360468164
Max-1234q4	Boiarchuk Max	db/changelog/logs/ch-add-eco_news-Boiarchuk.xml	2024-02-19 16:34:46.184145	361	EXECUTED	9:2178ccbbc51f76bd10cb5b68a1a88a7c	addColumn tableName=eco_news		\N	4.25.1	\N	\N	8360468164
changeSetEventsMax5	Max Bohonko	db/changelog/logs/ch-add-table-events-Bohonko.xml	2024-02-19 16:34:46.267812	362	EXECUTED	9:d99bf46c84a014b79045beb957c07f71	createTable tableName=events		\N	4.25.1	\N	\N	8360468164
changeSetEventImagesMax5	Max Bohonko	db/changelog/logs/ch-add-table-events-Bohonko.xml	2024-02-19 16:34:46.35552	363	EXECUTED	9:efc74bc36afe67ac8ba90b38bb0dd1fe	createTable tableName=events_images		\N	4.25.1	\N	\N	8360468164
changeSetEventIAttendersMax5	Max Bohonko	db/changelog/logs/ch-add-table-events-Bohonko.xml	2024-02-19 16:34:46.397221	364	EXECUTED	9:190b5959fa0cb0998e566a093b889f6b	createTable tableName=events_attenders		\N	4.25.1	\N	\N	8360468164
Natalia-1	Kozak	db/changelog/logs/ch-insert-into-languages-Kozak.xml	2024-02-19 16:34:46.438909	365	EXECUTED	9:af894d8eb60234cec73dfc6573791158	insert tableName=languages; insert tableName=languages; insert tableName=languages		\N	4.25.1	\N	\N	8360468164
Natalia-2	Kozak	db/changelog/logs/ch-insert-into-categories-Kozak.xml	2024-02-19 16:34:46.480705	366	EXECUTED	9:f7a4984ef83b0d0dd2475a5a9a96d1c8	insert tableName=categories; insert tableName=categories; insert tableName=categories; insert tableName=categories; insert tableName=categories; insert tableName=categories; insert tableName=categories; insert tableName=categories; insert tableNam...		\N	4.25.1	\N	\N	8360468164
Natalia-3	Kozak	db/changelog/logs/ch-insert-into-fact-of-the-day-Kozak.xml	2024-02-19 16:34:46.530848	367	EXECUTED	9:f890eaa27953e80bf279ac1d5bcf4b00	insert tableName=fact_of_the_day; insert tableName=fact_of_the_day; insert tableName=fact_of_the_day; insert tableName=fact_of_the_day; insert tableName=fact_of_the_day; insert tableName=fact_of_the_day; insert tableName=fact_of_the_day; insert ta...		\N	4.25.1	\N	\N	8360468164
Natalia-4	Kozak	db/changelog/logs/ch-insert-into-fact-of-the-day-translations-Kozak.xml	2024-02-19 16:34:46.614211	368	EXECUTED	9:956472b9297c2391254077d49e832fc5	insert tableName=fact_of_the_day_translations; insert tableName=fact_of_the_day_translations; insert tableName=fact_of_the_day_translations; insert tableName=fact_of_the_day_translations; insert tableName=fact_of_the_day_translations; insert table...		\N	4.25.1	\N	\N	8360468164
Natalia-5	Kozak	db/changelog/logs/ch-insert-into-habits-Kozak.xml	2024-02-19 16:34:46.664083	369	EXECUTED	9:3add4584750716eac5ea6232b1c4012a	insert tableName=habits; insert tableName=habits; insert tableName=habits; insert tableName=habits; insert tableName=habits; insert tableName=habits; insert tableName=habits; insert tableName=habits; insert tableName=habits; insert tableName=habit...		\N	4.25.1	\N	\N	8360468164
Natalia-6	Kozak	db/changelog/logs/ch-insert-into-habit-translation-Kozak.xml	2024-02-19 16:34:46.741408	370	EXECUTED	9:62c9f872921d26833e05932694ec76ef	insert tableName=habit_translation; insert tableName=habit_translation; insert tableName=habit_translation; insert tableName=habit_translation; insert tableName=habit_translation; insert tableName=habit_translation; insert tableName=habit_translat...		\N	4.25.1	\N	\N	8360468164
Natalia-7	Kozak	db/changelog/logs/ch-insert-into-shopping-list-items-Kozak.xml	2024-02-19 16:34:46.805357	371	EXECUTED	9:3a8c4cc80f3f27dfd87c721a57841cf7	insert tableName=shopping_list_items; insert tableName=shopping_list_items; insert tableName=shopping_list_items; insert tableName=shopping_list_items; insert tableName=shopping_list_items; insert tableName=shopping_list_items; insert tableName=sh...		\N	4.25.1	\N	\N	8360468164
Natalia-8	Kozak	db/changelog/logs/ch-insert-into-shopping-list-item-translations-Kozak.xml	2024-02-19 16:34:47.036703	372	EXECUTED	9:c04bbefc9ea75abb840f7f5dc3a191d8	insert tableName=shopping_list_item_translations; insert tableName=shopping_list_item_translations; insert tableName=shopping_list_item_translations; insert tableName=shopping_list_item_translations; insert tableName=shopping_list_item_translation...		\N	4.25.1	\N	\N	8360468164
Natalia-9	Kozak	db/changelog/logs/ch-insert-into-habit-shopping-list-items-Kozak.xml	2024-02-19 16:34:47.128531	373	EXECUTED	9:f7453716be4bbeb4c9f104cf0000296e	insert tableName=habit_shopping_list_items; insert tableName=habit_shopping_list_items; insert tableName=habit_shopping_list_items; insert tableName=habit_shopping_list_items; insert tableName=habit_shopping_list_items; insert tableName=habit_shop...		\N	4.25.1	\N	\N	8360468164
Natalia-10	Kozak	db/changelog/logs/ch-insert-into-specifications-Kozak.xml	2024-02-19 16:34:47.161533	374	EXECUTED	9:f5abae5c17244cb1348eaeb67ad4773e	insert tableName=specifications; insert tableName=specifications; insert tableName=specifications; insert tableName=specifications; insert tableName=specifications; insert tableName=specifications		\N	4.25.1	\N	\N	8360468164
Natalia-11	Kozak	db/changelog/logs/ch-insert-into-tags-Kozak.xml	2024-02-19 16:34:47.194908	375	EXECUTED	9:1bfdbbd4677a40c7271bc9d6fcc1f539	insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=...		\N	4.25.1	\N	\N	8360468164
Natalia-12	Kozak	db/changelog/logs/ch-insert-into-tag-translations-Kozak.xml	2024-02-19 16:34:47.236561	376	EXECUTED	9:f830b4a0933d500a8fe3dd4df774b150	insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; in...		\N	4.25.1	\N	\N	8360468164
change	incognito	db/changelog/logs/ch-modify-function-Hlynskyi.xml	2024-02-19 16:34:47.286243	377	EXECUTED	9:d2e96e270d6e998b22bdd95d3d52beee	sql		\N	4.25.1	\N	\N	8360468164
Yezenitskyi-1	Andrii Yezenitskyi	db/changelog/logs/ch-insert-table-users-service-account-Yezenitskyi.xml	2024-02-19 16:34:47.327888	378	EXECUTED	9:b26cf82d0081156174fde44ec7898ce4	insert tableName=users		\N	4.25.1	\N	\N	8360468164
events-event-dates-Hlynskyi	Danylo Hlynskyi	db/changelog/logs/ch-change-events-and-create-eventsdate-table-Hlynskyi.xml	2024-02-19 16:34:47.396894	379	EXECUTED	9:b8c23e60f944ef13200d3d6bf669cf95	createTable tableName=event_dates; addForeignKeyConstraint baseTableName=event_dates, constraintName=events_date_event_id_fk, referencedTableName=events; addColumn tableName=events; addColumn tableName=events; dropColumn tableName=events		\N	4.25.1	\N	\N	8360468164
Bokalo3	Nazar Bokalo	db/changelog/logs/ch-drop-table-achievement-translation-Bokalo.xml	2024-02-19 16:34:49.81406	425	EXECUTED	9:9ada9b41abfac4baf149c577d4a90fc8	dropTable tableName=achievement_translations		\N	4.25.1	\N	\N	8360468164
events-event-location-Hlynskyi	Danylo Hlynskyi	db/changelog/logs/ch-change-events-events-location-Hlynskyi.xml	2024-02-19 16:34:47.430174	380	EXECUTED	9:21d15173469ef50c49a01e19fc238e45	addColumn tableName=event_dates; addColumn tableName=event_dates; addColumn tableName=event_dates; renameTable newTableName=event_dates_locations, oldTableName=event_dates; dropColumn tableName=events; dropColumn tableName=events; dropColumn table...		\N	4.25.1	\N	\N	8360468164
event-tags-Hlynskyi	Danylo Hlynskyi	db/changelog/logs/ch-add-event-tags-Hlynskyi.xml	2024-02-19 16:34:47.491316	381	EXECUTED	9:c764b60ab86cb62d60e9e3863d4237bb	insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; ins...		\N	4.25.1	\N	\N	8360468164
Yezenitskyi-2	Andrii Yezenitskyi	db/changelog/logs/ch-drop-all-tips-and-tricks-tables-Yezenitskyi.xml	2024-02-19 16:34:47.548355	382	EXECUTED	9:7e7ea54aa369806c699681613834dda2	dropTable tableName=tipsandtricks_comment_users_liked; dropTable tableName=tipsandtricks_comment; dropTable tableName=text_translations; dropTable tableName=title_translations; dropTable tableName=tips_and_tricks_tags; dropTable tableName=tips_and...		\N	4.25.1	\N	\N	8360468164
event-date-change-type-to-zoned-Hlynskyi	Danylo Hlynskyi	db/changelog/logs/ch-change-event-date-to-zoned-type-Hlynskyi.xml	2024-02-19 16:34:47.580127	383	EXECUTED	9:1af1c7e21cdf63601d2ed18f0ba73484	modifyDataType columnName=start_date, tableName=events_dates_locations; modifyDataType columnName=finish_date, tableName=events_dates_locations		\N	4.25.1	\N	\N	8360468164
1	Max Bohonko	db/changelog/logs/ch-changed-user-role-to-varchar.xml	2024-02-19 16:34:47.741454	384	EXECUTED	9:677f5c2384f3bce155f2d7f6cff1818e	sql		\N	4.25.1	\N	\N	8360468164
Place Filter		db/changelog/logs/ch-add-places-tags.xml	2024-02-19 16:34:47.796457	385	EXECUTED	9:54e5110cfbbfaa5abab34b1f1e102e26	insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_transl...		\N	4.25.1	\N	\N	8360468164
Categories change		db/changelog/logs/ch-add-places-tags.xml	2024-02-19 16:34:47.879342	386	EXECUTED	9:491ae528e93f3b932a7555df029c9ac6	addColumn tableName=categories; update tableName=categories; update tableName=categories; update tableName=categories; update tableName=categories; update tableName=categories; update tableName=categories; update tableName=categories; update table...		\N	4.25.1	\N	\N	8360468164
location change		db/changelog/logs/ch-add-places-tags.xml	2024-02-19 16:34:47.920806	387	EXECUTED	9:955a4ee27c2927aecfa22d7ccdbd4cf5	addColumn tableName=locations		\N	4.25.1	\N	\N	8360468164
events-location-add-addressees-Hlynskyi	Danylo Hlynskyi	db/changelog/logs/ch-change-events-location-add-addresses-Hlynskyi.xml	2024-02-19 16:34:47.970998	388	EXECUTED	9:777277472637c3b08876d40d2d885a9e	addColumn tableName=events_dates_locations		\N	4.25.1	\N	\N	8360468164
crateTableFilter1	Pavlo Hural	db/changelog/logs/ch-add-table-filters-Hural.xml	2024-02-19 16:34:48.029461	389	EXECUTED	9:2898fb831d3e18cfc92da55c28fff722	createTable tableName=filters		\N	4.25.1	\N	\N	8360468164
addKey	Pavlo Hural	db/changelog/logs/ch-add-table-filters-Hural.xml	2024-02-19 16:34:48.062844	390	EXECUTED	9:cb80245b2c62644eeb0ffe267c8f45a8	addForeignKeyConstraint baseTableName=filters, constraintName=user_filters_users_id_fk, referencedTableName=users		\N	4.25.1	\N	\N	8360468164
event-add-event-organizer-rating-Hlynskyi	Danylo Hlynskyi	db/changelog/logs/ch-add-event-organizer-raring-Hlynskyi.xml	2024-02-19 16:34:48.130211	391	EXECUTED	9:a22fd8db496dedda96e59905afe90728	createTable tableName=events_grades; addColumn tableName=users		\N	4.25.1	\N	\N	8360468164
ch-add-name-unique-constraint-Sakhno	Hanna Sakhno	db/changelog/logs/ch-add-name-unique-constraint-Sakhno.xml	2024-02-19 16:34:48.196447	392	EXECUTED	9:9fcf03ba8778863d2ea0b5bfba5487d4	addUniqueConstraint constraintName=name_unique, tableName=employee_authorities		\N	4.25.1	\N	\N	8360468164
Yashna-1	Inna Yashna	db/changelog/logs/ch-add-event-comment-Yashna.xml	2024-02-19 16:34:48.405123	393	EXECUTED	9:d1bc3aeb3e733b48f69a8de5959a75bc	createTable tableName=events_comment; addForeignKeyConstraint baseTableName=events_comment, constraintName=fk_comment_user, referencedTableName=users; addForeignKeyConstraint baseTableName=events_comment, constraintName=fk_comment_events, referenc...		\N	4.25.1	\N	\N	8360468164
Hlazova-1	Hlazova Nataliia	db/changelog/logs/ch-insert-into-employee-authority-Hlazova.xml	2024-02-19 16:34:48.446857	394	EXECUTED	9:318991b27f906fc7029bf70cf87655c6	insert tableName=employee_authorities; insert tableName=employee_authorities; insert tableName=employee_authorities; insert tableName=employee_authorities; insert tableName=employee_authorities; insert tableName=employee_authorities; insert tableN...		\N	4.25.1	\N	\N	8360468164
Hlazova-2	Hlazova Nataliia	db/changelog/logs/ch-update-into-tag-translations-Hlazova.xml	2024-02-19 16:34:48.487806	395	EXECUTED	9:79fb008e0c3445af3266395fc2fd2643	update tableName=tag_translations; update tableName=tag_translations; update tableName=tag_translations		\N	4.25.1	\N	\N	8360468164
Vatuliak-1	Oleh Vatuliak	db/changelog/logs/ch-add-column-parentComment-Vatuliak.xml	2024-02-19 16:34:48.521109	396	EXECUTED	9:51287f12aef60c6d8998aee1cc4f1614	addColumn tableName=events_comment		\N	4.25.1	\N	\N	8360468164
bykanowa1	Bykanowa L.	db/changelog/logs/ch-change-eco-news-create-user-dislikes.xml	2024-02-19 16:34:48.5545	397	EXECUTED	9:b8bc290ce8fa97cc44e0b6098912d492	createTable tableName=eco_news_users_dislikes		\N	4.25.1	\N	\N	8360468164
bykanowa2	Bykanowa L.	db/changelog/logs/ch-change-eco-news-create-user-dislikes.xml	2024-02-19 16:34:48.587878	398	EXECUTED	9:88564b727841f3e683958d53c72bd3cf	addForeignKeyConstraint baseTableName=eco_news_users_dislikes, constraintName=fk_eco_news_users_dislikes_eco_news, referencedTableName=eco_news; addForeignKeyConstraint baseTableName=eco_news_users_dislikes, constraintName=fk_eco_news_users_dislik...		\N	4.25.1	\N	\N	8360468164
Korzh-4	Nikita Korzh	db/changelog/logs/ch-insert-into-employees-authorities-Korzh.xml	2024-02-19 16:34:48.621151	399	EXECUTED	9:2b65fcda495213254e0334f2e435a209	insert tableName=employee_authorities		\N	4.25.1	\N	\N	8360468164
Korzh-1	Nikita Korzh	db/changelog/logs/ch-add-table-positions-Korzh.xml	2024-02-19 16:34:48.705386	400	EXECUTED	9:5d9e0cf20fa698b8e78400c0d3d0126f	createTable tableName=positions; insert tableName=positions; insert tableName=positions; insert tableName=positions; insert tableName=positions; insert tableName=positions; insert tableName=positions; insert tableName=positions		\N	4.25.1	\N	\N	8360468164
Korzh-2	Nikita Korzh	db/changelog/logs/ch-add-table-positions-authorities-mapping-Korzh.xml	2024-02-19 16:34:48.780596	401	EXECUTED	9:da1ff803b8857aeadb76ab56d1399bb7	createTable tableName=positions_authorities_mapping; addPrimaryKey tableName=positions_authorities_mapping; addForeignKeyConstraint baseTableName=positions_authorities_mapping, constraintName=fk_positions_authorities_mapping_position_id, reference...		\N	4.25.1	\N	\N	8360468164
Bokalo1	Nazar Bokalo	db/changelog/logs/ch-drop-table-achievements-categories-Bokalo.xml	2024-02-19 16:34:49.864156	426	EXECUTED	9:14953b96de2f89eedf0af01c1222c803	dropTable tableName=achievement_categories		\N	4.25.1	\N	\N	8360468164
Korzh-3	Nikita Korzh	db/changelog/logs/ch-insert-into-positions-authorities-mapping-Korzh.xml	2024-02-19 16:34:48.838993	402	EXECUTED	9:a1240cb644580c07e3b0b47703c4a65b	insert tableName=positions_authorities_mapping; insert tableName=positions_authorities_mapping; insert tableName=positions_authorities_mapping; insert tableName=positions_authorities_mapping; insert tableName=positions_authorities_mapping; insert ...		\N	4.25.1	\N	\N	8360468164
Korzh-5	Nikita Korzh	db/changelog/logs/ch-insert-into-users-Korzh.xml	2024-02-19 16:34:48.872404	403	EXECUTED	9:cde4452eef48560ebe447df9750cdc27	insert tableName=users		\N	4.25.1	\N	\N	8360468164
Korzh-6	Nikita Korzh	db/changelog/logs/ch-insert-into-employee-authority-mapping-Korzh.xml	2024-02-19 16:34:48.912554	404	EXECUTED	9:1cc5fd6beb1d5e9d0d04567a4351dc8d	insert tableName=employee_authorities_mapping; insert tableName=employee_authorities_mapping; insert tableName=employee_authorities_mapping; insert tableName=employee_authorities_mapping; insert tableName=employee_authorities_mapping; insert table...		\N	4.25.1	\N	\N	8360468164
AddNewTags	Lilia Mokhnatska	db/changelog/logs/ch-insert-into-tags-Mokhnatska.xml	2024-02-19 16:34:48.945925	405	EXECUTED	9:6a8bc28341af8640152cd9a851127c35	insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tags; insert tableName=tags		\N	4.25.1	\N	\N	8360468164
modifyNumberOfCharacters	Lilia Mokhnatska	db/changelog/logs/ch-change-tag-translations-column-name-Mokhnatska.xml	2024-02-19 16:34:48.979327	406	EXECUTED	9:60ab51add4445e4c764ccdfb97addba6	modifyDataType columnName=name, tableName=tag_translations		\N	4.25.1	\N	\N	8360468164
NewTagsForHabits_1	Lilia Mokhnatska	db/changelog/logs/ch-insert-into-tag-translations-Mokhnatska.xml	2024-02-19 16:34:49.020973	407	EXECUTED	9:fb08c66304f56a4596894d1b786c2bd7	insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; insert tableName=tag_translations; in...		\N	4.25.1	\N	\N	8360468164
AddNewDataIntoHabits_Tags	Lilia Mokhnatska	db/changelog/logs/ch-insert-into-habits-tags-Mokhnatska.xml	2024-02-19 16:34:49.062721	408	EXECUTED	9:421e49551b4e2aed129c94f73ff3df63	insert tableName=habits_tags; insert tableName=habits_tags; insert tableName=habits_tags; insert tableName=habits_tags; insert tableName=habits_tags; insert tableName=habits_tags; insert tableName=habits_tags; insert tableName=habits_tags; insert ...		\N	4.25.1	\N	\N	8360468164
Mokhnatska1	LiliaMokhnatska	db/changelog/logs/сh-add-new-columns-habit-Mokhnatska.xml	2024-02-19 16:34:49.096076	409	EXECUTED	9:de24d617feb9dcfc53d7b041b2fbf906	addColumn tableName=habits; addColumn tableName=habits		\N	4.25.1	\N	\N	8360468164
Golik-1	Maksym Golik	db/changelog/logs/ch-change-tables-events-events-dates-locations-Golik.xml	2024-02-19 16:34:49.129408	410	EXECUTED	9:1ad3a9d058d298491d0e7e56b3eba8a5	dropColumn columnName=address_ua, tableName=events_dates_locations; dropColumn columnName=address_en, tableName=events_dates_locations; addColumn tableName=events_dates_locations		\N	4.25.1	\N	\N	8360468164
Golik-2	Maksym Golik	db/changelog/logs/ch-change-tables-events-events-dates-locations-Golik.xml	2024-02-19 16:34:49.162729	411	EXECUTED	9:1a73b8323d67984f684dc5c2b771a030	addColumn tableName=events		\N	4.25.1	\N	\N	8360468164
Mokhnatska2	LiliaMokhnatska	db/changelog/logs/сh-add-new-column-habit-assign-Mokhnatska.xml	2024-02-19 16:34:49.196038	412	EXECUTED	9:45576e959737527ebb59d0a1e8e0b7db	addColumn tableName=habit_assign		\N	4.25.1	\N	\N	8360468164
Lenets-1	Maksym Lenets	db/changelog/logs/ch-add-column-deleted-to-events-comment-Lenets-1.xml	2024-02-19 16:34:49.229477	413	EXECUTED	9:41d0fc505f0912a2f9dab141572925e7	addColumn tableName=events_comment		\N	4.25.1	\N	\N	8360468164
Lenets-2	Maksym Lenets	db/changelog/logs/ch-add-tables-events-comment-user-likes-dislikes-Lenets.xml	2024-02-19 16:34:49.262879	414	EXECUTED	9:01691f1cd6074514627aea370931fe63	createTable tableName=events_comment_users_likes		\N	4.25.1	\N	\N	8360468164
Lenets-3	Maksym Lenets	db/changelog/logs/ch-add-tables-events-comment-user-likes-dislikes-Lenets.xml	2024-02-19 16:34:49.296081	415	EXECUTED	9:aa609c0efb1a544b8c6674b41edb21e6	addForeignKeyConstraint baseTableName=events_comment_users_likes, constraintName=fk_events_comment_users_likes_events_comment, referencedTableName=events_comment; addForeignKeyConstraint baseTableName=events_comment_users_likes, constraintName=fk_...		\N	4.25.1	\N	\N	8360468164
Vatuliak-3	Vatuliak Oleh	db/changelog/logs/ch-update-fact-of-the-day-translations-Vatuliak.xml	2024-02-19 16:34:49.329438	416	EXECUTED	9:8dedc865521cfe02eb1950df8c5d32c9	update tableName=fact_of_the_day_translations; update tableName=fact_of_the_day_translations		\N	4.25.1	\N	\N	8360468164
Vatuliak-2	Vatuliak Oleh	db/changelog/logs/ch-update-habit-translation-Vatuliak.xml	2024-02-19 16:34:49.362848	417	EXECUTED	9:560ec78365a7cf0d51c0c489bd2e7084	update tableName=habit_translation		\N	4.25.1	\N	\N	8360468164
Mokhnatska-7	Lilia Mokhnatska	db/changelog/logs/ch-update-habit-translations-Mokhnatska.xml	2024-02-19 16:34:49.396176	418	EXECUTED	9:061cd9d86172f2f27307dc7398fc568f	modifyDataType columnName=description, tableName=habit_translation		\N	4.25.1	\N	\N	8360468164
Bondar-1	Anton Bondar	db/changelog/logs/ch-add-table-employee-positions-mapping-Bondar.xml	2024-02-19 16:34:49.472968	419	EXECUTED	9:b027ce8f08af641aff9a9b9e25e702b7	createTable tableName=employee_positions_mapping; addPrimaryKey tableName=employee_positions_mapping; addForeignKeyConstraint baseTableName=employee_positions_mapping, constraintName=fk_employee_positions_mapping_user_id, referencedTableName=users...		\N	4.25.1	\N	\N	8360468164
Seti-1	Julia Seti	db/changelog/logs/ch-change-table-events-dates-locations-dropNotNullConstraint-Seti.xml	2024-02-19 16:34:49.506293	420	EXECUTED	9:4c7d90e5491fde46ce19f262ca0ad3b1	dropNotNullConstraint columnName=street_ua, tableName=events_dates_locations; dropNotNullConstraint columnName=city_ua, tableName=events_dates_locations; dropNotNullConstraint columnName=region_ua, tableName=events_dates_locations; dropNotNullCons...		\N	4.25.1	\N	\N	8360468164
Bondar-2	Anton Bondar	db/changelog/logs/ch-update-employee_authorities-table-name-value-Bondar.xml	2024-02-19 16:34:49.539809	421	EXECUTED	9:a8724ad5169f8964599c261cdea8dc55	update tableName=employee_authorities; update tableName=employee_authorities; update tableName=employee_authorities; update tableName=employee_authorities; update tableName=employee_authorities; update tableName=employee_authorities		\N	4.25.1	\N	\N	8360468164
Bondar-3	Anton Bondar	db/changelog/logs/ch-add-table-events-followers-Bondar.xml	2024-02-19 16:34:49.606587	422	EXECUTED	9:18c09ee632f66f0e9e728894c25d0ff3	createTable tableName=events_followers; addPrimaryKey tableName=events_followers; addForeignKeyConstraint baseTableName=events_followers, constraintName=fk_events_followers_event_id, referencedTableName=events; addForeignKeyConstraint baseTableNam...		\N	4.25.1	\N	\N	8360468164
Lenets-3	Maksym Lenets	db/changelog/logs/ch-add-formatted_address-to-event_dates_locations-Lenets.xml	2024-02-19 16:34:49.713098	423	EXECUTED	9:2dda06387192001c8c46a06fa022b147	addColumn tableName=events_dates_locations; addColumn tableName=events_dates_locations		\N	4.25.1	\N	\N	8360468164
Bokalo	Nazar Bokalo	db/changelog/logs/ch-drop-table-achievements-Bokalo.xml	2024-02-19 16:34:49.754017	424	EXECUTED	9:061fe9d953014ff502045901756609c0	dropTable tableName=achievements		\N	4.25.1	\N	\N	8360468164
Bokalo-1	Nazar Bokalo	db/changelog/logs/ch-drop-all-employee-tables-Bokalo.xml	2024-02-19 16:34:49.908635	427	EXECUTED	9:a00223b7d3d712e6de5bee182229ee44	dropTable tableName=employee_authorities; dropTable tableName=employee_authorities_mapping; dropTable tableName=employee_positions_mapping		\N	4.25.1	\N	\N	8360468164
Bokalo-2	Nazar Bokalo	db/changelog/logs/ch-drop-all-events-tables-Bokalo.xml	2024-02-19 16:34:49.988732	428	EXECUTED	9:ee4c651912afbee0aae41fbe83da8739	dropTable tableName=events; dropTable tableName=events_attenders; dropTable tableName=events_comment; dropTable tableName=events_comment_users_likes; dropTable tableName=events_dates_locations; dropTable tableName=events_followers; dropTable table...		\N	4.25.1	\N	\N	8360468164
Bokalo-3	Nazar Bokalo	db/changelog/logs/ch-drop-table-user-achievemets.xml	2024-02-19 16:34:50.036903	429	EXECUTED	9:bdf4a606db75307b90f00d73824021e8	dropTable tableName=user_achievements		\N	4.25.1	\N	\N	8360468164
Bokalo-3	Nazar Bokalo	db/changelog/logs/ch-drop-all-positions-tables.xml	2024-02-19 16:34:50.073548	430	EXECUTED	9:8e6e40f75048d797d683a7dc3573db9e	dropTable tableName=positions; dropTable tableName=positions_authorities_mapping		\N	4.25.1	\N	\N	8360468164
Bokalo-4	Nazar Bokalo	db/changelog/logs/ch-drop-all-advices-tables-Bokalo.xml	2024-02-19 16:34:50.117024	431	EXECUTED	9:4f9918c001cf621096f9d6a39b0a6616	dropTable tableName=advices; dropTable tableName=advice_translations		\N	4.25.1	\N	\N	8360468164
Bokalo-5	Nazar Bokalo	db/changelog/logs/ch-drop-table-break-time-Bokalo.xml	2024-02-19 16:34:50.153804	432	EXECUTED	9:7c73ce88d7f1c3e53c12165dac647f91	dropTable tableName=break_time		\N	4.25.1	\N	\N	8360468164
Bokalo-6	Nazar Bokalo	db/changelog/logs/ch-drop-all-chat-tables-Bokalo.xml	2024-02-19 16:34:50.196815	433	EXECUTED	9:8a298c6b61763c0a4e6d92eebb5bdc7b	dropTable tableName=chat_messages; dropTable tableName=chat_rooms; dropTable tableName=chat_rooms_participants		\N	4.25.1	\N	\N	8360468164
Bokalo-7	Nazar Bokalo	db/changelog/logs/ch-drop-all-fact-of-the-day-tables-Bokalo.xml	2024-02-19 16:34:50.256337	434	EXECUTED	9:2c58f5238f07fe7ddac09c180acc2050	dropTable tableName=fact_of_the_day; dropTable tableName=fact_of_the_day_translations		\N	4.25.1	\N	\N	8360468164
Bokalo-8	Nazar Bokalo	db/changelog/logs/ch-drop-discount-values-table-Bokalo.xml	2024-02-19 16:34:50.297175	435	EXECUTED	9:895b2a3d0f155da55ca0873c302e957d	dropTable tableName=discount_values		\N	4.25.1	\N	\N	8360468164
Bokalo-9	Nazar Bokalo	db/changelog/logs/ch-drop-estimates-table.xml	2024-02-19 16:34:50.335834	436	EXECUTED	9:d36b04f688fda447e51f95431628990c	dropTable tableName=estimates		\N	4.25.1	\N	\N	8360468164
Bokalo-10	Nazar Bokalo	db/changelog/logs/ch-drop-favorite-places-table.xml	2024-02-19 16:34:50.375231	437	EXECUTED	9:1b18cfea33c7d01270b2ab251da912ca	dropTable tableName=favorite_places		\N	4.25.1	\N	\N	8360468164
Bokalo-11	Nazar Bokalo	db/changelog/logs/ch-drop-locations-table-Bokalo.xml	2024-02-19 16:34:50.421897	438	EXECUTED	9:1f3c249e5042e45340aafd1a426af3c3	dropTable tableName=locations		\N	4.25.1	\N	\N	8360468164
Bokalo-15	Nazar Bokalo	db/changelog/logs/ch-drop-opening-hours-table.xml	2024-02-19 16:34:50.467752	439	EXECUTED	9:48d5882ed61a6136679c287b118e1a1b	dropTable tableName=opening_hours		\N	4.25.1	\N	\N	8360468164
Bokalo-16	Nazar Bokalo	db/changelog/logs/ch-drop-photo-table-Bokalo.xml	2024-02-19 16:34:50.501692	440	EXECUTED	9:873d5fe861b3adcdf748f2b8585c2ddc	dropTable tableName=photos		\N	4.25.1	\N	\N	8360468164
Bokalo-17	Nazar Bokalo	db/changelog/logs/ch-drop-places-table-Bokalo.xml	2024-02-19 16:34:50.544942	441	EXECUTED	9:6a6bd7370d139e21d01b338588289b70	dropTable tableName=places		\N	4.25.1	\N	\N	8360468164
Bokalo-18	Nazar Bokalo	db/changelog/logs/ch-drop-news-subscribers-table-Bokalo.xml	2024-02-19 16:34:50.585249	442	EXECUTED	9:e31debec940614a70a9939ba3d2280f2	dropTable tableName=news_subscribers		\N	4.25.1	\N	\N	8360468164
Bokalo-18	Nazar Bokalo	db/changelog/logs/ch-drop-user-friends-table-Bokalo.xml	2024-02-19 16:34:50.642488	443	EXECUTED	9:bb4d8fe755240397062179941bd2e024	dropTable tableName=users_friends		\N	4.25.1	\N	\N	8360468164
\.


--
-- Data for Name: databasechangeloglock; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.databasechangeloglock (id, locked, lockgranted, lockedby) FROM stdin;
1	f	\N	\N
\.


--
-- Data for Name: eco_news; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.eco_news (id, creation_date, image_path, author_id, text, title, source, short_info) FROM stdin;
\.


--
-- Data for Name: eco_news_tags; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.eco_news_tags (eco_news_id, tags_id) FROM stdin;
\.


--
-- Data for Name: eco_news_users_dislikes; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.eco_news_users_dislikes (eco_news_id, users_id) FROM stdin;
\.


--
-- Data for Name: eco_news_users_likes; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.eco_news_users_likes (eco_news_id, users_id) FROM stdin;
\.


--
-- Data for Name: econews_comment; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.econews_comment (id, text, created_date, modified_date, parent_comment_id, user_id, eco_news_id, deleted) FROM stdin;
\.


--
-- Data for Name: econews_comment_users_liked; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.econews_comment_users_liked (econews_comment_id, users_liked_id) FROM stdin;
\.


--
-- Data for Name: filters; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.filters (id, user_id, name, type, "values") FROM stdin;
\.


--
-- Data for Name: habit_assign; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.habit_assign (id, create_date, user_id, habit_id, duration, habit_streak, working_days, last_enrollment, status, progress_notification_has_displayed) FROM stdin;
\.


--
-- Data for Name: habit_fact_translations; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.habit_fact_translations (id, language_id, habit_fact_id, content, fact_of_day_status) FROM stdin;
\.


--
-- Data for Name: habit_facts; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.habit_facts (id, habit_id) FROM stdin;
\.


--
-- Data for Name: habit_shopping_list_items; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.habit_shopping_list_items (id, habit_id, shopping_list_item_id, status) FROM stdin;
1	1	1	ACTUAL
2	1	2	ACTUAL
3	1	3	ACTUAL
4	1	4	ACTUAL
5	1	5	ACTUAL
6	1	6	ACTUAL
7	1	7	ACTUAL
8	1	8	ACTUAL
9	1	9	ACTUAL
10	1	10	ACTUAL
11	2	11	ACTUAL
12	2	12	ACTUAL
13	2	13	ACTUAL
14	2	14	ACTUAL
15	2	15	ACTUAL
16	2	16	ACTUAL
17	3	17	ACTUAL
18	4	18	ACTUAL
19	5	19	ACTUAL
20	5	20	ACTUAL
21	6	21	ACTUAL
22	7	22	ACTUAL
23	7	23	ACTUAL
24	7	24	ACTUAL
25	7	25	ACTUAL
26	7	26	ACTUAL
27	7	27	ACTUAL
28	7	28	ACTUAL
29	7	29	ACTUAL
30	8	30	ACTUAL
31	8	31	ACTUAL
32	8	32	ACTUAL
33	8	33	ACTUAL
34	8	34	ACTUAL
35	8	35	ACTUAL
36	9	36	ACTUAL
37	9	37	ACTUAL
38	9	38	ACTUAL
39	9	39	ACTUAL
40	10	40	ACTUAL
41	11	41	ACTUAL
42	11	42	ACTUAL
43	11	43	ACTUAL
44	11	44	ACTUAL
45	11	45	ACTUAL
46	12	46	ACTUAL
47	12	47	ACTUAL
48	12	48	ACTUAL
49	12	49	ACTUAL
50	12	50	ACTUAL
51	12	51	ACTUAL
52	12	52	ACTUAL
53	12	53	ACTUAL
54	12	54	ACTUAL
55	12	55	ACTUAL
56	12	56	ACTUAL
57	12	57	ACTUAL
58	12	58	ACTUAL
59	12	59	ACTUAL
60	13	21	ACTUAL
61	14	60	ACTUAL
62	14	61	ACTUAL
63	14	62	ACTUAL
64	14	63	ACTUAL
65	14	64	ACTUAL
66	14	65	ACTUAL
67	14	66	ACTUAL
68	15	67	ACTUAL
69	15	68	ACTUAL
70	15	69	ACTUAL
71	15	70	ACTUAL
72	15	71	ACTUAL
73	15	72	ACTUAL
74	16	73	ACTUAL
75	16	74	ACTUAL
76	16	75	ACTUAL
77	17	76	ACTUAL
78	17	77	ACTUAL
79	17	78	ACTUAL
80	18	79	ACTUAL
81	18	80	ACTUAL
82	19	81	ACTUAL
83	19	82	ACTUAL
84	19	83	ACTUAL
85	19	84	ACTUAL
86	19	85	ACTUAL
87	20	86	ACTUAL
88	20	87	ACTUAL
89	20	88	ACTUAL
90	20	89	ACTUAL
91	20	90	ACTUAL
92	20	91	ACTUAL
93	20	92	ACTUAL
94	20	93	ACTUAL
95	20	94	ACTUAL
96	20	95	ACTUAL
97	20	96	ACTUAL
98	20	97	ACTUAL
99	21	41	ACTUAL
100	21	42	ACTUAL
101	21	43	ACTUAL
102	21	44	ACTUAL
103	21	45	ACTUAL
104	21	29	ACTUAL
105	22	98	ACTUAL
106	22	99	ACTUAL
107	22	100	ACTUAL
108	22	101	ACTUAL
109	22	102	ACTUAL
110	22	103	ACTUAL
111	22	104	ACTUAL
112	22	105	ACTUAL
113	22	35	ACTUAL
114	23	106	ACTUAL
115	23	107	ACTUAL
116	23	108	ACTUAL
117	23	109	ACTUAL
118	23	110	ACTUAL
119	23	111	ACTUAL
120	23	112	ACTUAL
121	23	113	ACTUAL
122	23	114	ACTUAL
123	23	115	ACTUAL
124	23	116	ACTUAL
125	24	117	ACTUAL
126	25	118	ACTUAL
127	25	119	ACTUAL
128	25	120	ACTUAL
129	25	121	ACTUAL
130	25	122	ACTUAL
131	25	123	ACTUAL
132	26	21	ACTUAL
133	27	21	ACTUAL
134	28	22	ACTUAL
135	28	24	ACTUAL
136	28	25	ACTUAL
137	28	41	ACTUAL
138	28	42	ACTUAL
139	28	43	ACTUAL
140	28	44	ACTUAL
141	28	29	ACTUAL
142	28	45	ACTUAL
143	28	115	ACTUAL
144	28	11	ACTUAL
145	28	12	ACTUAL
146	28	13	ACTUAL
147	28	14	ACTUAL
148	28	15	ACTUAL
149	28	16	ACTUAL
150	29	124	ACTUAL
151	29	125	ACTUAL
152	29	126	ACTUAL
153	29	127	ACTUAL
154	29	128	ACTUAL
155	30	129	ACTUAL
156	30	130	ACTUAL
157	30	131	ACTUAL
158	30	132	ACTUAL
159	30	133	ACTUAL
160	30	134	ACTUAL
161	30	135	ACTUAL
162	30	136	ACTUAL
163	30	137	ACTUAL
164	30	138	ACTUAL
165	30	139	ACTUAL
166	30	140	ACTUAL
167	31	141	ACTUAL
168	31	142	ACTUAL
169	31	143	ACTUAL
170	31	144	ACTUAL
\.


--
-- Data for Name: habit_statistics; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.habit_statistics (id, rate, create_date, habit_assign_id, amount_of_items) FROM stdin;
\.


--
-- Data for Name: habit_status; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.habit_status (id, working_days, habit_streak, habit_assign_id, last_enrollment) FROM stdin;
\.


--
-- Data for Name: habit_status_calendar; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.habit_status_calendar (id, enroll_date, habit_assign_id) FROM stdin;
\.


--
-- Data for Name: habit_translation; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.habit_translation (id, name, description, habit_item, language_id, habit_id) FROM stdin;
1	Use a towel instead of paper towels and napkins	Description	Item	2	1
2	Use a reusable water bottle	Description	Item	2	2
3	Use e-reader instead of paper book	Description	Item	2	3
4	Use solar panels to generate electricity	Description	Item	2	4
5	Drive an electric car	Description	Item	2	5
6	Buy second-hand things	Description	Item	2	6
7	Use a reusable shopping bag	Description	Item	2	7
8	Use your coffee cup instead of disposable cups	Description	Item	2	8
9	Use reusable batteries	Description	Item	2	9
10	Pay bills online	Description	Item	2	10
11	Buy goods without packing	Description	Item	2	11
12	Buy\\make natural products for cleaning	Description	Item	2	12
13	Buy local products	Description	Item	2	13
14	Walk instead of using public transport or car	Description	Item	2	14
15	Use bicycle	Description	Item	2	15
16	Use water sparingly when brushing your teeth	Description	Item	2	16
17	Take a shower instead of a bath	Description	Item	2	17
18	Recycle batteries	Description	Item	2	18
19	Turn off the lights as you leave the room	Description	Item	2	19
20	Do not eat meat	Description	Item	2	20
21	Buy products \\goods in recyclable packaging	Description	Item	2	21
22	Do not use a plastic straw	Description	Item	2	22
23	Carry food to work in your lunchbox	Description	Item	2	23
24	Use LED lamps	Description	Item	2	24
25	Sorting out rubbish	Description	Item	2	25
26	Use both sides of the paper for notes or drawing	Description	Item	2	26
27	Eat seasonal vegetables and fruits	Description	Item	2	27
28	Do not use disposable packages	Description	Item	2	28
29	Compost organic waste	Description	Item	2	29
30	Do not use one-time personal hygiene products	Description	Item	2	30
31	Women's hygiene products	Description	Item	2	31
32	Замість паперових рушників та серветок використовуйте рушник	Description	Item	1	1
33	Используйте полотенце вместо бумажных полотенец и салфеток	Description	Item	3	1
34	Використовуйте багаторазову пляшку з водою	Description	Item	1	2
35	Используйте многоразовую бутылку с водой	Description	Item	3	2
36	Використовуйте електронний пристрій для читання замість паперової книги	Description	Item	1	3
37	Используйте электронную книгу вместо бумажной книги	Description	Item	3	3
38	Використовуйте сонячні панелі для виробництва електроенергії	Description	Item	1	4
39	Используйте солнечные батареи для выработки электроэнергии	Description	Item	3	4
41	Используйте электромобилем	Description	Item	3	5
42	Купуйте б/у речі	Description	Item	1	6
43	Покупайте подержанные вещи	Description	Item	3	6
44	Використовуйте багаторазову сумку для покупок	Description	Item	1	7
45	Используйте многоразовую сумку для покупок	Description	Item	3	7
46	Використовуйте свою чашку для кави замість одноразових чашок	Description	Item	1	8
47	Используйте свою кофейную чашку вместо одноразовых чашек	Description	Item	3	8
48	Використовуйте багаторазові акумулятори	Description	Item	1	9
49	Используйте многоразовые батареи	Description	Item	3	9
50	Оплачуйте рахунки онлайн	Description	Item	1	10
51	Оплачивайте счета онлайн	Description	Item	3	10
52	Купуйте товари без упаковки	Description	Item	1	11
53	Покуапйте товары без упаковки	Description	Item	3	11
54	Купуйте \\ робіть натуральні засоби для чищення	Description	Item	1	12
55	Купите \\ сделайте натуральные средства для уборки	Description	Item	3	12
56	Купуйте місцеві продукти	Description	Item	1	13
57	Покупайте местные продукты	Description	Item	3	13
58	Ходіть пішки замість того, щоб користуватися громадським транспортом або автомобілем	Description	Item	1	14
59	Ходите вместо того, чтобы пользоваться общественным транспортом или автомобилем	Description	Item	3	14
60	Використовуйте велосипед	Description	Item	1	15
61	Используйте велосипед	Description	Item	3	15
62	Економте воду при чищенні зубів	Description	Item	1	16
63	При чистке зубов используйте воду экономно	Description	Item	3	16
64	Приймайте душ замість ванни	Description	Item	1	17
65	Принимайте душ вместо ванны	Description	Item	3	17
66	Утилізуйте акумулятори	Description	Item	1	18
67	Утилизируйте аккумуляторы	Description	Item	3	18
68	Вимикайте світло, виходячи з кімнати	Description	Item	1	19
69	Выключайте свет, когда выходите из комнаты	Description	Item	3	19
70	Не їжте м’яса	Description	Item	1	20
71	Не ешьте мясо	Description	Item	3	20
72	Купуйте продукти \\ товари в упаковці, що переробляється	Description	Item	1	21
73	Покупайте продукты \\ товары в перерабатываемой упаковке	Description	Item	3	21
74	Не використовуйте пластикову соломинку	Description	Item	1	22
75	Не используйте пластиковую соломинку	Description	Item	3	22
76	Несіть їжу на роботу у ланч-боксі	Description	Item	1	23
77	Носите еду на работу в коробке для завтрака	Description	Item	3	23
78	Використовуйте світлодіодні лампи	Description	Item	1	24
79	Используйте светодиодные лампы	Description	Item	3	24
80	Сортуйте сміття	Description	Item	1	25
81	Сортируйте мусор	Description	Item	3	25
82	Використовуйте обидві сторони паперу для нотаток або малювання	Description	Item	1	26
83	Используйте обе стороны листа для заметок или рисования.	Description	Item	3	26
84	Їжте сезонні овочі та фрукти	Description	Item	1	27
85	Ешьте сезонные овощи и фрукты	Description	Item	3	27
86	Не використовуйте одноразові пакети	Description	Item	1	28
87	Не используйте одноразовые упаковки	Description	Item	3	28
88	Компостуйте органічні відходи	Description	Item	1	29
89	Компостируйте органические отходы	Description	Item	3	29
90	Не використовуйте одноразові засоби особистої гігієни	Description	Item	1	30
91	Не используйте одноразовые средства личной гигиены	Description	Item	3	30
92	Товари для жіночої гігієни	Description	Item	1	31
93	Товары женской гигиены	Description	Item	3	31
40	Використовуйте електромобіль	Description	Item	1	5
\.


--
-- Data for Name: habits; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.habits (id, image, default_duration, complexity, user_id, is_custom_habit) FROM stdin;
1	https://csb10032000a548f571.blob.core.windows.net/allfiles/304ff73c-7e6d-4a17-be7d-59fc3666d351931fb71c088a926a1e04b6896d109fa2.jpg	14	1	\N	f
2	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	1	\N	f
3	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	3	\N	f
4	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	3	\N	f
5	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	3	\N	f
6	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
7	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	1	\N	f
8	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	1	\N	f
9	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
10	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	1	\N	f
11	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
12	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	1	\N	f
13	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
14	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
15	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
16	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
17	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	1	\N	f
18	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
19	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	1	\N	f
20	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	3	\N	f
21	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	1	\N	f
22	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	1	\N	f
23	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	1	\N	f
24	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
25	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	3	\N	f
26	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	1	\N	f
27	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
28	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
29	https://csb10032000a548f571.blob.core.windows.net/allfiles/35fd5c8b-9383-425c-8d3d-ad19dc617245picture.jpg	14	3	\N	f
30	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
31	https://csb10032000a548f571.blob.core.windows.net/allfiles/photo_2021-06-01_15-39-56.jpg	14	2	\N	f
\.


--
-- Data for Name: habits_tags; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.habits_tags (habit_id, tag_id) FROM stdin;
1	20
2	20
3	21
4	21
5	21
6	22
7	20
8	20
9	20
10	21
11	22
12	22
13	22
14	23
15	23
16	21
17	21
18	24
19	21
20	22
21	22
22	20
23	20
24	21
25	24
26	21
27	22
28	22
29	24
30	20
31	20
\.


--
-- Data for Name: languages; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.languages (id, code) FROM stdin;
1	ua
2	en
3	ru
\.


--
-- Data for Name: message_like; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.message_like (message_id, participant_id) FROM stdin;
\.


--
-- Data for Name: own_security; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.own_security (id, password, user_id) FROM stdin;
1	$2a$10$jDwJSCjl5WMT3tfZF5f2Re7P6XKfGNBhdleGpC6E4AKqJoiyH0.h.	3
\.


--
-- Data for Name: rating_statistics; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.rating_statistics (id, event, create_date, user_id, points_changed, current_rating) FROM stdin;
\.


--
-- Data for Name: reasons_for_user_deactivation; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.reasons_for_user_deactivation (id, reason, date_of_deactivation, id_user) FROM stdin;
\.


--
-- Data for Name: restore_password_email; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.restore_password_email (id, expiry_date, token, user_id) FROM stdin;
\.


--
-- Data for Name: shopping_list_item_translations; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.shopping_list_item_translations (id, content, shopping_list_item_id, language_id) FROM stdin;
1	Серветки целюлозні	1	1
2	Swedish cellulose dish cloths	1	2
3	Салфетки целлюлозные влоговпитывающие	1	3
4	Багаторазові бамбукові рушники	2	1
5	Reusable bamboo paper towels	2	2
6	Многоразовые бамбуковые полотенца	2	3
7	Багаторазові біорозкладні паперові рушники	3	1
8	Wowables reusable & biodegradable paper towel	3	2
9	Многоразовые биоразлагаемые бумажные полотенца	3	3
10	Серветки з мікрофібри	4	1
11	Microfiber cloths	4	2
12	Салфетки из микрофибры	4	3
13	Бамбукові кухонні серветки	5	1
14	Bamboo kitchen dish cloths	5	2
15	Бамбуковые полотенца для кухни	5	3
16	Бавовняні серветки / скатертини	6	1
17	Cotton napkins	6	2
18	Хлопковые салфетки и скатерти	6	3
19	Багаторазові вощені обгортки (серветки)	7	1
20	Reusable beeswax wrap	7	2
21	Многоразовая пищевая обертка из пчелиного воска	7	3
22	Ллянні коктейльні серветки	8	1
23	Linen cocktail napkins	8	2
24	Коктейльные льняные салфетки	8	3
25	Повсякденні бавовняні серветки	9	1
26	Everyday cotton napkins	9	2
27	Повседневные хлопковые салфетки	9	3
28	Кухонні рушники з органічної бавовни	10	1
29	Organic Cotton Dish Towels	10	2
30	Кухонные полотенца из органического хлопка	10	3
31	Пляшка для води з нержавіючої сталі	11	1
32	Reusable stainless steel water bottle	11	2
33	Бутылка для воды из нержавеющей стали	11	3
34	Скляна пляшка для води	12	1
35	Reusable glass water bottle	12	2
36	Стеклянная бутылка для воды	12	3
37	Складна силіконова пляшка для води	13	1
38	Collapsible Silicone Water Bottle	13	2
39	Складная силиконовая бутылка для воды	13	3
40	Пляшка для води з фільтром (фільтр-пляшка для води)	14	1
41	Water Filter Bottle	14	2
42	Бутылка для воды с фильтром	14	3
43	Плоска пляшка для води	15	1
44	Flat reusable bottle	15	2
45	Плоская бутылка для воды	15	3
46	Пляшка для води з соломинкою	16	1
47	Watter bottle with a straw	16	2
48	Бутылка для воды с трубочкой	16	3
49	Електронна книга	17	1
50	E-reader	17	2
51	Электронная книга	17	3
52	Сонячна батарея	18	1
53	Solar panels	18	2
54	Солнечная батарея	18	3
55	Купити електрокар	19	1
56	Buy an electric car	19	2
57	Купить электрокар	19	3
58	Взяти в оренду електрокар	20	1
59	Rent an electric car	20	2
60	Взять электрокар на прокат	20	3
61	Немає товарів для рекомендації	21	1
62	No items to recommend	21	2
63	Нет товаров для рекомендации	21	3
64	Бавовняна сумка для покупок	22	1
65	Cotton shopping bag	22	2
66	Сумка для покупок из хлопка	22	3
67	Нейлонова сумка для покупок	23	1
68	Nylon shopping bag	23	2
69	Нейлоновая сумка для покупок	23	3
70	Термосумка для покупок	24	1
71	Insulated hot&cold bag	24	2
72	Термосумка для покупок	24	3
73	Плетена сумка	25	1
74	Mesh string bag	25	2
75	Сетчаная сумка	25	3
76	Ламінована сумка-шопер	26	1
77	Bag from laminated material	26	2
78	Ламинированная сумка-шопер	26	3
79	Сумка для продуктового візка	27	1
80	Bag for grocery cart	27	2
81	Сумка для продуктовой тележки	27	3
82	Сумка візок	28	1
83	Shopping trolley bag	28	2
84	Сумка тележка	28	3
85	Лляний мішечок для хліба	29	1
86	Linen bread bags	29	2
87	Льняной мешочек для хранения хлеба	29	3
88	Багаторазова чашка із нержавіючої сталі	30	1
89	Reusable stainless steel cup	30	2
90	Многоразовая чашка из нержавеющей стали	30	3
91	Багаторазова скляна чашка	31	1
92	Reusable glass cup	31	2
93	Многоразовая стеклянная чашка	31	3
94	Складна силіконова чашка	32	1
95	Collapsible Silicone cup	32	2
96	Складная силиконовая чашка	32	3
97	Керамічна чашка	33	1
98	Ceramic coffee cup	33	2
99	Керамическая чашка	33	3
100	Багаторазова бамбукова чашка	34	1
101	Bamboo reusable cup	34	2
102	Многоразовая бамбуковая чашка	34	3
103	Чашка із соломинкою	35	1
104	Cup with a straw	35	2
105	Чашка с трубочкой	35	3
106	Нікель-кадмієві акумулятори	36	1
107	Nickel cadmium batteries	36	2
108	Никель-кадмиевые аккумуляторы	36	3
109	Нікель-метал-гідридний акумулятор	37	1
110	Nickel metal hydride batteries	37	2
111	Никель-металлогидридный аккумулятор	37	3
112	Літій-іонний акумулятор	38	1
113	Lithium ion batteries	38	2
114	Литий-ионный аккумулятор	38	3
115	Свинцево-кислотний акумулятор	39	1
116	Sealed lead acid batteries	39	2
117	Свинцово-кислотный аккумулятор	39	3
118	Додаток (програма) для здійснення оплати онлайн	40	1
119	Application for payment (buy / download)	40	2
120	Приложение для проведения онлайн оплат	40	3
121	Мішечки для фруктів та овочів	41	1
122	Cotton bags for fruits and vegetables	41	2
123	Мешочки для фруктов и овощей	41	3
124	Харчові контейнери з нержавійки	42	1
125	Reuse stainless steel containers	42	2
126	Пищевые контейнеры из нержавейки	42	3
127	Скляні харчові контейнери	43	1
128	Reuse glass containers	43	2
129	Стеклянные пищевые контейнеры	43	3
130	Силіконові харчові контейнери	44	1
131	Reuse silicone containers	44	2
132	Силиконовые пищевые контейнеры	44	3
133	Багаторазові пакети для бутербродів	45	1
134	Reusable sandwich and snack bags	45	2
135	Многоразовые пакеты для бутербродов	45	3
136	Харчова сода	46	1
137	Baking Soda	46	2
138	Пищевая сода	46	3
139	Білий дистильований оцет	47	1
140	Distilled White Vinegar	47	2
141	Дистиллированный белый уксус	47	3
142	Перекис водню	48	1
143	Hydrogen Peroxide	48	2
144	Пероксид водорода	48	3
145	Бавовняні кульки	49	1
146	Cotton Balls	49	2
147	Хлопковые шарики	49	3
148	Рідке мило	50	1
149	Liquid Dish Soap	50	2
150	Жидкое мыло	50	3
151	Сіль	51	1
152	Salt	51	2
153	Соль	51	3
154	Лимон	52	1
155	Lemon	52	2
156	Лимон	52	3
157	Кукурудзяний крохмаль	53	1
158	Corn Starch	53	2
159	Кукурузный крахмал	53	3
160	Олія чайного дерева	54	1
161	Tea Tree Oil	54	2
162	Масло чайного дерева	54	3
163	Найлонова щітка	55	1
164	Nylon Scrub Brush	55	2
165	Нейлоновая щетка	55	3
166	Обприскувач	56	1
167	Spray Bottles	56	2
168	Опрыскиватель	56	3
169	Пемза	57	1
170	Pumice Stone	57	2
171	Пемза	57	3
172	Серветки з мікрофібри	58	1
173	Microfiber Cleaning Cloths and other cloths	58	2
174	Салфетки из микрофибры	58	3
175	Меламінова губка	59	1
176	Melamine sponge	59	2
177	Меламиновая губка	59	3
178	Одяг з відбивачами	60	1
179	Clothes with reflectors	60	2
180	Одежда со светоотражателями	60	3
181	Взуття для прогулянок	61	1
182	Shoes for walking	61	2
183	Обувь для прогулок	61	3
184	Дихаючі шкарпетки	62	1
185	Breathable socks	62	2
186	Дышащие носки	62	3
187	Дощовик	63	1
188	Rain coat	63	2
189	Дождевик	63	3
190	Наплічник складаний	64	1
191	Backpack / convertible backpack	64	2
192	Рюкзак (трансформируемый рюкзак)	64	3
193	Пристрій або додаток для фітнесу	65	1
194	Fitness tracking device or application	65	2
195	Фитнес устройство или приложение	65	3
196	Устілки для ходьби	66	1
197	Walking insoles	66	2
198	Стельки для ходьбы	66	3
199	Велосипедний шолом	67	1
200	Bicycle helmet	67	2
201	Велосипедный шлем	67	3
202	Чохол-дощовик для сідла	68	1
203	Saddle rain cover	68	2
204	Чехол-дождевик для седла	68	3
205	Чохол для велосипеда	69	1
206	Bicycle cover	69	2
207	Чехол для велосипеда	69	3
208	Велокорзина	70	1
209	Bag / cart for baggage	70	2
210	Велокорзина	70	3
211	Світловідбивачі	71	1
212	Reflectors	71	2
213	Светоотражатели	71	3
214	Велофари, мигалки	72	1
215	Bike lights	72	2
216	Велосипедные фары, мигалки	72	3
217	Чашка	73	1
218	Reusable cup	73	2
219	Чашка	73	3
220	Клапан для зниження тиску	74	1
221	Pressure-reducing valve	74	2
222	Клапан для снижения давления	74	3
223	Змішувач для зниження тиску	75	1
224	Water-saving faucets	75	2
225	Смеситель для снижения давления	75	3
226	Водозберігаюча насадка для душу	76	1
227	Water saving shower head	76	2
228	Водосберегающая насадка для душа	76	3
229	Еко гель для душу	77	1
230	Eco shovel gel	77	2
231	Эко гель для душа	77	3
232	Рушник для ванни	78	1
233	Bath towel	78	2
234	Банное полотенце	78	3
235	Додаток із пунктами прийому або утилізації батарейок	79	1
236	Application with recycle places	79	2
237	Приложение с пунктами приема или утилизации батареек	79	3
238	Контейнери для батарейок	80	1
239	Containers for batteries	80	2
240	Контейнеры для батареек	80	3
241	Додаток для контролю за світлом	81	1
242	Home app to control lights	81	2
243	Приложение по управлению света	81	3
244	Акустичний вимикач світла	82	1
245	Clapper (lights switcher on claps)	82	2
246	Аккустический выключатель света по хлопку	82	3
247	Енергоощадні лампочки	83	1
248	Energy saving light bulb - diff.types	83	2
249	Энергоосберегающие лампочки	83	3
250	Розумний сенсорний вимикач	84	1
251	Smart touch switcher	84	2
252	Умный сенсорный выключатель	84	3
253	Контролер розумного будинку	85	1
254	Smart home controller	85	2
255	Контроллер умного дома	85	3
256	Зернобобові: боби, горошок і тд	86	1
257	Pulses: beans and peas	86	2
258	Зернобобовые: бобы, горошок и др.	86	3
259	Яйця	87	1
260	Eggs	87	2
261	Яйца	87	3
262	Кіноа	88	1
263	Quinoa	88	2
264	Киноа	88	3
265	Знежирені молочні продукти	89	1
266	Low fat dairy products	89	2
267	Снежиренные молочные продукты	89	3
268	Соєві продукти	90	1
269	Soy products	90	2
270	Продукты из сои	90	3
271	Горіхи та насіння	91	1
272	Nuts and seeds	91	2
273	Орехи и семена	91	3
274	Тофу	92	1
275	Tofu	92	2
276	Тофу	92	3
277	Темпе - ферментований соєвий продукт	93	1
278	Tempeh	93	2
279	Темпе - ферментированный соевый продукт	93	3
280	Сейтан - пшенична клейковина	94	1
281	Seitan - пшенична клейковина	94	2
282	Сейтан - пшеничная клейковина	94	3
283	Кворн - замінник м'яса	95	1
284	Quorn	95	2
285	Кворн	95	3
286	Риба	96	1
287	Fish	96	2
288	Рыба	96	3
289	Рослинні замінники м'яса	97	1
290	Beyond meat	97	2
291	Растительные заменители мяса	97	3
292	Бамбукові соломинки	98	1
293	Bamboo Straw	98	2
294	Бамбуковые трубочки	98	3
295	Солом'яні соломинки	99	1
296	Straw by Straw	99	2
297	Соломенные трубочки	99	3
298	Паперові соломинки	100	1
299	Paper Straws	100	2
300	Бумажные трубочки	100	3
301	Металеві соломинки	101	1
302	Steel Straws	101	2
303	Металические трубочки	101	3
304	Скляні соломинки	102	1
305	Glass Straws	102	2
306	Стеклянные трубочки	102	3
307	Їстівна соломинки	103	1
308	Edible straw	103	2
309	Съедобные трубочки	103	3
310	Силіконові соломинки	104	1
311	Silicone straw	104	2
312	Силиконовые трубочки	104	3
313	Пляшка із соломинкою	105	1
314	Water Bottle	105	2
315	Бутылка с трубочкой	105	3
316	Багаторазові пакети для сендвічів	106	1
317	Reusable Cup With Straw	106	2
318	Многоразовые пакети для сендвичей	106	3
319	Скляні банки	107	1
320	Glass Canning Jars	107	2
321	Стеклянные банки	107	3
322	Скляні контейнери	108	1
323	Glass Storage Containers	108	2
324	Стеклянные контейнери	108	3
325	Силіконові контейнери	109	1
326	Silicone Containers	109	2
327	Силиконовые контейнеры	109	3
328	Тканинні мішечки для їжі	110	1
329	Cloth Food Sacks	110	2
330	Тканевые мешки для еды	110	3
331	Металеві контейнери з нержавіючої сталі	111	1
332	Stainless Steel containers	111	2
333	Металические контейнеры из нержавеющей стали	111	3
334	Вощені багаторазові серветки	112	1
335	Beeswax food wrap	112	2
336	Пищевая пленка из пчелиного воска	112	3
337	Багаторазова сумка для обідів	113	1
338	Lunch bag	113	2
339	Многоразовая сумка для обедов	113	3
340	Пляшка для води	114	1
341	Water bottle	114	2
342	Бутылка для воды	114	3
343	Бамбуковий контейнер для обідів	115	1
344	Bamboo lunch pot	115	2
345	Бамбуковый контейнер для обедов	115	3
346	Набір столових приборів із бамбуку	116	1
347	Bamboo utensils set	116	2
348	Набор столовых приборов из бамбука	116	3
349	Світлодіодна лампа	117	1
350	LED lamp	117	2
351	Светодиодная лампа	117	3
352	Сміттєзбірник для висувних поверхонь	118	1
353	Waste systems for pull-out fronts	118	2
354	Мусоросборник для выдвижных поверхностей	118	3
355	Сміттєзбірник для відкидних поверхонь	119	1
356	Waste systems for hinged doors	119	2
357	Мусоросборник для откидных поверхностей	119	3
358	Сміттєзбірник двосекційний з педаллю	120	1
359	Double Recycling Pedal Bin	120	2
360	Мусоросборник двухсекционный с педалью	120	3
361	Сміттєзбірник трьохсекційний з педаллю	121	1
362	3 Section Recycling Pedal Bin	121	2
363	Мусоросборник трехсекционный с педалью	121	3
364	Контейнер для сміття з 2 баками	122	1
365	Totem Waste & Recycling Bins	122	2
366	Контейнер для мусора с 2 баками	122	3
367	Контейнер для харчових відходів	123	1
368	Food Waste Caddy	123	2
369	Контейнер для пищевых отходов	123	3
370	Відро для компосту	124	1
371	Compost bin	124	2
372	Ведро для компоста	124	3
373	Контейнер для компосту	125	1
374	Compost container	125	2
375	Контейнер для компоста	125	3
376	Відро для компосту із нержавіючої сталі з вбудованим вугільним фільтром	126	1
377	Stainless steel compost pail with an carbon filter	126	2
378	Ведро для компоста из нержавеющей стали с угольным фильтром	126	3
379	Компостер для саду	127	1
380	Garden compost bin	127	2
381	Компостер садовый	127	3
382	Екологічні пакети для сміття, що компостуються	128	1
383	Compostable bags	128	2
384	Компостированные мешки для муссора	128	3
385	Багаторазова серветка для зняття макіяжу	129	1
386	Microfiber face and makeup remover cloth	129	2
387	Многоразовая салфетка для снятия макияжа	129	3
388	Багаторазові бавовняні диски для очищення обличчя	130	1
389	Reusable cotton rounds	130	2
390	Многоразовые хлопковые диски для очищения лица	130	3
391	Бамбукові ватні палички	131	1
392	Bamboo cotton swabs	131	2
393	Бамбуковые ватные палочки	131	3
394	Бавовняні носові хустинки	132	1
395	Cotton Handkerchiefs	132	2
396	Хлопковые носовые платки	132	3
397	Натуральна морська губка для душу	133	1
398	Natural sea sponge for a shower	133	2
399	Натуральная морская мочалка для душа	133	3
400	Металева бритва	134	1
401	Metal razors	134	2
402	Металлическая бритва	134	3
403	Засоби для догляду власного виробництва (скраб, крем для лиця..)	135	1
404	Homemade treatments (scrab, face cream..)	135	2
405	Средства для ухода собственного производства (скраб, крем для лица)	135	3
406	Бамбукова зубна щітка	136	1
407	Bamboo toothbrush	136	2
408	Бамбуковая зубная щетка	136	3
409	Замінники зубної пасти	137	1
410	Toothpaste replacement	137	2
411	Заменители зубной пасты	137	3
412	Натуральна зубна нитка	138	1
413	Eco floss	138	2
414	Натуральная зубная нить	138	3
415	Натуральний дезодорант	139	1
416	Natural deodorant	139	2
417	Натуральный дезодорант	139	3
418	Ефірні олії замість парфумів	140	1
419	Essential oils instead of perfumes and frangrances	140	2
420	Эфирные масла вместо духов	140	3
421	Менструальна чаша / диск	141	1
422	Menstrual cup / disk	141	2
423	Ментсруальная чаша / диск	141	3
424	Менструальна білизна	142	1
425	Reusable period panties	142	2
426	Менструальное белье	142	3
427	Органічні тампони	143	1
428	Organic tampons	143	2
429	Органические тампоны	143	3
430	Багаторазові прокладки	144	1
431	Reusable period pads	144	2
432	Многоразовые прокладки	144	3
\.


--
-- Data for Name: shopping_list_items; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.shopping_list_items (id) FROM stdin;
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82
83
84
85
86
87
88
89
90
91
92
93
94
95
96
97
98
99
100
101
102
103
104
105
106
107
108
109
110
111
112
113
114
115
116
117
118
119
120
121
122
123
124
125
126
127
128
129
130
131
132
133
134
135
136
137
138
139
140
141
142
143
144
\.


--
-- Data for Name: social_network_images; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.social_network_images (id, image_path, host_path) FROM stdin;
1	img/default_social_network_icon.png	img/default_social_network_icon.png
\.


--
-- Data for Name: social_networks; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.social_networks (id, user_id, social_network_url, social_network_image_id) FROM stdin;
\.


--
-- Data for Name: specifications; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.specifications (id, name) FROM stdin;
1	Animal
2	Own cup
3	Karaoke
4	Shopping
5	Ukrainian food
6	Dance
\.


--
-- Data for Name: tag_translations; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.tag_translations (id, name, tag_id, language_id) FROM stdin;
1	Новини	1	1
2	News	1	2
3	Новости	1	3
4	Події	2	1
5	Events	2	2
6	События	2	3
10	Ініціативи	4	1
11	Initiatives	4	2
12	Инициативы	4	3
13	Реклама	5	1
14	Ads	5	2
15	Реклама	5	3
31	Тестування	11	1
32	Testing	11	2
33	Тестирование	11	3
34	Соціальний	12	1
35	Social	12	2
36	Социальный	12	3
37	Екологічний	13	1
38	Environmental	13	2
39	Экологический	13	3
40	Економічний	14	1
41	Economic	14	2
42	Экономический	14	3
43	Магазини	15	1
44	Shops	15	2
45	Магазины	15	3
46	Ресторани	16	1
47	Restaurants	16	2
48	Рестораны	16	3
49	Пункти приймання	17	1
50	Recycling points	17	2
51	Пункты приема	17	3
52	Події	18	1
53	Events	18	2
54	События	18	3
55	Збереженні місця	19	1
56	Saved places	19	2
57	Сохраненные места	19	3
7	Освіта	3	1
8	Education	3	2
9	Образование	3	3
58	Багаторазове використання	20	1
59	Reusable	20	2
60	Економія ресурсів	21	1
61	Resource saving	21	2
62	Розумне споживання	22	1
63	Smart consuming	22	2
64	Транспорт	23	1
65	Transportation	23	2
66	Переробити/сортувати відходи	24	1
67	Recycling/Waste sorting	24	2
\.


--
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.tags (id, type) FROM stdin;
1	ECO_NEWS
2	ECO_NEWS
3	ECO_NEWS
4	ECO_NEWS
5	ECO_NEWS
11	HABIT
12	EVENT
13	EVENT
14	EVENT
15	PLACES_FILTER
16	PLACES_FILTER
17	PLACES_FILTER
18	PLACES_FILTER
19	PLACES_FILTER
20	HABIT
21	HABIT
22	HABIT
23	HABIT
24	HABIT
\.


--
-- Data for Name: unread_messages; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.unread_messages (id, status, message_id, user_id) FROM stdin;
\.


--
-- Data for Name: user_actions; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.user_actions (id, user_id, achievement_category_id, count) FROM stdin;
\.


--
-- Data for Name: user_shopping_list; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.user_shopping_list (id, habit_assign_id, shopping_list_item_id, status, date_completed) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.users (id, date_of_registration, email, email_notification, name, role, user_status, refresh_token_key, profile_picture, rating, last_activity_time, first_name, city, user_credo, show_location, show_eco_place, show_shopping_list, language_id, uuid, phone_number, event_organizer_rating) FROM stdin;
1	1970-01-01 00:00:00	service@greencity.ua	0	service	ROLE_ADMIN	2	de7fa570-e9c3-4242-90e3-fd391bdd2554	\N	0	1970-01-01 00:00:00+00	service	\N	\N	\N	\N	\N	1	c6049b1b-39e7-4cd5-9fb0-3eeeb4bf7ac6	\N	\N
2	1970-01-01 00:00:00	green.city.ubs@gmail.com	0	UBS	ROLE_UBS_EMPLOYEE	2	e59b50f5-53c2-48e5-9439-b171634ffdd0	\N	0	\N	ADMIN	Kyiv	\N	t	t	t	2	d0840b34-3f17-4820-a375-305b855dff8b	+380675554433	\N
3	2024-02-19 16:36:41.309169	urio999@gmail.com	0	Yurii	ROLE_ADMIN	2	a833c917-de8b-4e35-a155-a5fa3cd646d0	\N	0	2024-02-19 16:36:41.309186+00	Yurii	\N	\N	t	t	t	2	7a58a9fc-f3bd-4084-a13e-5b1c4fb6720f	\N	\N
\.


--
-- Data for Name: verify_emails; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.verify_emails (id, expiry_date, token, user_id) FROM stdin;
\.


--
-- Data for Name: web_pages; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.web_pages (id, web_page) FROM stdin;
\.


--
-- Data for Name: web_pages_places; Type: TABLE DATA; Schema: public; Owner: greencity
--

COPY public.web_pages_places (web_pages_id, places_id) FROM stdin;
\.


--
-- Name: address_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.address_id_seq', 1, false);


--
-- Name: bag_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.bag_id_seq', 1, false);


--
-- Name: category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.category_id_seq', 11, false);


--
-- Name: comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.comment_id_seq', 1, false);


--
-- Name: custom_goals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.custom_goals_id_seq', 1, false);


--
-- Name: eco_news_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.eco_news_id_seq', 1, false);


--
-- Name: econews_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.econews_comment_id_seq', 1, false);


--
-- Name: fact_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.fact_translations_id_seq', 1, false);


--
-- Name: filters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.filters_id_seq', 1, false);


--
-- Name: goal_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.goal_translations_id_seq', 432, true);


--
-- Name: goals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.goals_id_seq', 145, false);


--
-- Name: habit_assign_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.habit_assign_id_seq', 1, false);


--
-- Name: habit_dictionary_translation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.habit_dictionary_translation_id_seq', 93, true);


--
-- Name: habit_facts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.habit_facts_id_seq', 1, false);


--
-- Name: habit_goals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.habit_goals_id_seq', 170, true);


--
-- Name: habit_statistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.habit_statistics_id_seq', 1, false);


--
-- Name: habit_status_calendar_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.habit_status_calendar_id_seq', 1, false);


--
-- Name: habit_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.habit_status_id_seq', 1, false);


--
-- Name: habits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.habits_id_seq', 32, false);


--
-- Name: hibernate_sequence; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.hibernate_sequence', 1, false);


--
-- Name: languages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.languages_id_seq', 1, false);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.orders_id_seq', 1, false);


--
-- Name: own_security_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.own_security_id_seq', 1, true);


--
-- Name: rating_statistics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.rating_statistics_id_seq', 1, false);


--
-- Name: reasons_for_user_deactivation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.reasons_for_user_deactivation_id_seq', 1, false);


--
-- Name: restore_password_email_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.restore_password_email_id_seq', 1, false);


--
-- Name: social_network_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.social_network_images_id_seq', 1, true);


--
-- Name: social_networks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.social_networks_id_seq', 1, false);


--
-- Name: specification_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.specification_id_seq', 7, false);


--
-- Name: tag_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.tag_translations_id_seq', 57, true);


--
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.tags_id_seq', 12, false);


--
-- Name: ubs_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.ubs_user_id_seq', 1, false);


--
-- Name: unread_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.unread_messages_id_seq', 1, false);


--
-- Name: user_actions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.user_actions_id_seq', 1, false);


--
-- Name: user_goals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.user_goals_id_seq', 1, false);


--
-- Name: user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.user_id_seq', 3, true);


--
-- Name: verify_email_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.verify_email_id_seq', 1, true);


--
-- Name: web_pages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: greencity
--

SELECT pg_catalog.setval('public.web_pages_id_seq', 1, false);


--
-- Name: habits_tags PK_habits_tags; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habits_tags
    ADD CONSTRAINT "PK_habits_tags" PRIMARY KEY (habit_id, tag_id);


--
-- Name: tag_translations PK_tag_translations; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.tag_translations
    ADD CONSTRAINT "PK_tag_translations" PRIMARY KEY (id);


--
-- Name: categories UK_46ccwnsi9409t36lurvtyljak; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT "UK_46ccwnsi9409t36lurvtyljak" UNIQUE (name);


--
-- Name: web_pages UK_663ftdbracrebppaa1smemex8; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.web_pages
    ADD CONSTRAINT "UK_663ftdbracrebppaa1smemex8" UNIQUE (web_page);


--
-- Name: specifications UK_bdpr10axwx0a7ogp5ax531n9f; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.specifications
    ADD CONSTRAINT "UK_bdpr10axwx0a7ogp5ax531n9f" UNIQUE (name);


--
-- Name: habit_status_calendar UK_eroll_date_and_habie_assign_id; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_status_calendar
    ADD CONSTRAINT "UK_eroll_date_and_habie_assign_id" UNIQUE (enroll_date, habit_assign_id);


--
-- Name: users UK_ob8kqyqqgmefl0aco34akdtpe; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "UK_ob8kqyqqgmefl0aco34akdtpe" UNIQUE (email);


--
-- Name: categories categories_name_ua_key; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_name_ua_key UNIQUE (name_ua);


--
-- Name: categories category_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT category_pkey PRIMARY KEY (id);


--
-- Name: comments comment_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: custom_shopping_list_items custom_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.custom_shopping_list_items
    ADD CONSTRAINT custom_goals_pkey PRIMARY KEY (id);


--
-- Name: databasechangeloglock databasechangeloglock_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.databasechangeloglock
    ADD CONSTRAINT databasechangeloglock_pkey PRIMARY KEY (id);


--
-- Name: eco_news eco_news_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.eco_news
    ADD CONSTRAINT eco_news_pkey PRIMARY KEY (id);


--
-- Name: eco_news_tags eco_news_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.eco_news_tags
    ADD CONSTRAINT eco_news_tags_pkey PRIMARY KEY (eco_news_id, tags_id);


--
-- Name: econews_comment econews_comment_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.econews_comment
    ADD CONSTRAINT econews_comment_pkey PRIMARY KEY (id);


--
-- Name: habit_fact_translations fact_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_fact_translations
    ADD CONSTRAINT fact_translations_pkey PRIMARY KEY (id);


--
-- Name: filters filters_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.filters
    ADD CONSTRAINT filters_pkey PRIMARY KEY (id);


--
-- Name: shopping_list_item_translations goal_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.shopping_list_item_translations
    ADD CONSTRAINT goal_translations_pkey PRIMARY KEY (id);


--
-- Name: shopping_list_items goals_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.shopping_list_items
    ADD CONSTRAINT goals_pkey PRIMARY KEY (id);


--
-- Name: habit_assign habit_assign_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_assign
    ADD CONSTRAINT habit_assign_pkey PRIMARY KEY (id);


--
-- Name: habit_translation habit_dictionary_translation_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_translation
    ADD CONSTRAINT habit_dictionary_translation_pkey PRIMARY KEY (id);


--
-- Name: habit_facts habit_facts_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_facts
    ADD CONSTRAINT habit_facts_pkey PRIMARY KEY (id);


--
-- Name: habit_shopping_list_items habit_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_shopping_list_items
    ADD CONSTRAINT habit_goals_pkey PRIMARY KEY (id);


--
-- Name: habit_statistics habit_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_statistics
    ADD CONSTRAINT habit_statistics_pkey PRIMARY KEY (id);


--
-- Name: habit_status_calendar habit_status_calendar_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_status_calendar
    ADD CONSTRAINT habit_status_calendar_pkey PRIMARY KEY (id);


--
-- Name: habit_status habit_status_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_status
    ADD CONSTRAINT habit_status_pkey PRIMARY KEY (id);


--
-- Name: habits habits_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habits
    ADD CONSTRAINT habits_pkey PRIMARY KEY (id);


--
-- Name: languages languages_code_key; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_code_key UNIQUE (code);


--
-- Name: languages languages_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.languages
    ADD CONSTRAINT languages_pkey PRIMARY KEY (id);


--
-- Name: verify_emails one_user_one_email_verification_token; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.verify_emails
    ADD CONSTRAINT one_user_one_email_verification_token UNIQUE (user_id);


--
-- Name: own_security one_user_one_password; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.own_security
    ADD CONSTRAINT one_user_one_password UNIQUE (user_id);


--
-- Name: own_security own_security_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.own_security
    ADD CONSTRAINT own_security_pkey PRIMARY KEY (id);


--
-- Name: rating_statistics rating_statistics_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.rating_statistics
    ADD CONSTRAINT rating_statistics_pkey PRIMARY KEY (id);


--
-- Name: reasons_for_user_deactivation reasons_for_user_deactivation_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.reasons_for_user_deactivation
    ADD CONSTRAINT reasons_for_user_deactivation_pkey PRIMARY KEY (id);


--
-- Name: restore_password_email restore_password_email_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.restore_password_email
    ADD CONSTRAINT restore_password_email_pkey PRIMARY KEY (id);


--
-- Name: social_network_images social_network_images_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.social_network_images
    ADD CONSTRAINT social_network_images_pkey PRIMARY KEY (id);


--
-- Name: social_networks social_networks_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.social_networks
    ADD CONSTRAINT social_networks_pkey PRIMARY KEY (id);


--
-- Name: specifications specification_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.specifications
    ADD CONSTRAINT specification_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: unread_messages unread_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.unread_messages
    ADD CONSTRAINT unread_messages_pkey PRIMARY KEY (id);


--
-- Name: user_actions user_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.user_actions
    ADD CONSTRAINT user_actions_pkey PRIMARY KEY (id);


--
-- Name: user_shopping_list user_goals_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.user_shopping_list
    ADD CONSTRAINT user_goals_pkey PRIMARY KEY (id);


--
-- Name: users user_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: verify_emails verify_email_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.verify_emails
    ADD CONSTRAINT verify_email_pkey PRIMARY KEY (id);


--
-- Name: web_pages web_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.web_pages
    ADD CONSTRAINT web_pages_pkey PRIMARY KEY (id);


--
-- Name: FK84jlf1nvnb2duww5bi10j5kwy; Type: INDEX; Schema: public; Owner: greencity
--

CREATE INDEX "FK84jlf1nvnb2duww5bi10j5kwy" ON public.restore_password_email USING btree (user_id);


--
-- Name: FK8kcum44fvpupyw6f5baccx25c; Type: INDEX; Schema: public; Owner: greencity
--

CREATE INDEX "FK8kcum44fvpupyw6f5baccx25c" ON public.comments USING btree (user_id);


--
-- Name: FKch8bkgqt3v8yjo230lysj668h; Type: INDEX; Schema: public; Owner: greencity
--

CREATE INDEX "FKch8bkgqt3v8yjo230lysj668h" ON public.comments USING btree (place_id);


--
-- Name: FKhvh0e2ybgg16bpu229a5teje7; Type: INDEX; Schema: public; Owner: greencity
--

CREATE INDEX "FKhvh0e2ybgg16bpu229a5teje7" ON public.comments USING btree (parent_comment_id);


--
-- Name: FKmrghmp8nq6diqqcjxtq3nudfs; Type: INDEX; Schema: public; Owner: greencity
--

CREATE INDEX "FKmrghmp8nq6diqqcjxtq3nudfs" ON public.web_pages_places USING btree (places_id);


--
-- Name: FKpeyqdepr1vru2tsghm3sxwhrr; Type: INDEX; Schema: public; Owner: greencity
--

CREATE INDEX "FKpeyqdepr1vru2tsghm3sxwhrr" ON public.comments USING btree (estimate_id);


--
-- Name: FKrm26v5rrc5t54lhcd04dcwkw8; Type: INDEX; Schema: public; Owner: greencity
--

CREATE INDEX "FKrm26v5rrc5t54lhcd04dcwkw8" ON public.web_pages_places USING btree (web_pages_id);


--
-- Name: FKs2ride9gvilxy2tcuv7witnxc; Type: INDEX; Schema: public; Owner: greencity
--

CREATE INDEX "FKs2ride9gvilxy2tcuv7witnxc" ON public.categories USING btree (parent_category_id);


--
-- Name: restore_password_email FK84jlf1nvnb2duww5bi10j5kwy; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.restore_password_email
    ADD CONSTRAINT "FK84jlf1nvnb2duww5bi10j5kwy" FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: comments FK8kcum44fvpupyw6f5baccx25c; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "FK8kcum44fvpupyw6f5baccx25c" FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: eco_news_tags FK_eco_news_tags_eco_news; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.eco_news_tags
    ADD CONSTRAINT "FK_eco_news_tags_eco_news" FOREIGN KEY (eco_news_id) REFERENCES public.eco_news(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: eco_news_tags FK_eco_news_tags_tags; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.eco_news_tags
    ADD CONSTRAINT "FK_eco_news_tags_tags" FOREIGN KEY (tags_id) REFERENCES public.tags(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: eco_news FK_eco_news_users; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.eco_news
    ADD CONSTRAINT "FK_eco_news_users" FOREIGN KEY (author_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: habit_fact_translations FK_fact_translation_fact; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_fact_translations
    ADD CONSTRAINT "FK_fact_translation_fact" FOREIGN KEY (habit_fact_id) REFERENCES public.habit_facts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: habit_fact_translations FK_fact_translations_language; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_fact_translations
    ADD CONSTRAINT "FK_fact_translations_language" FOREIGN KEY (language_id) REFERENCES public.languages(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: habit_translation FK_habit_dictionary_translation; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_translation
    ADD CONSTRAINT "FK_habit_dictionary_translation" FOREIGN KEY (language_id) REFERENCES public.languages(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: habit_shopping_list_items FK_habit_goal_habit; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_shopping_list_items
    ADD CONSTRAINT "FK_habit_goal_habit" FOREIGN KEY (habit_id) REFERENCES public.habits(id);


--
-- Name: habit_shopping_list_items FK_habit_shopping_list_item; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_shopping_list_items
    ADD CONSTRAINT "FK_habit_shopping_list_item" FOREIGN KEY (shopping_list_item_id) REFERENCES public.shopping_list_items(id);


--
-- Name: habits_tags FK_habit_tags_habits; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habits_tags
    ADD CONSTRAINT "FK_habit_tags_habits" FOREIGN KEY (habit_id) REFERENCES public.habits(id);


--
-- Name: habits_tags FK_habits_tags_tags; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habits_tags
    ADD CONSTRAINT "FK_habits_tags_tags" FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- Name: shopping_list_item_translations FK_language_goal_translations; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.shopping_list_item_translations
    ADD CONSTRAINT "FK_language_goal_translations" FOREIGN KEY (language_id) REFERENCES public.languages(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: social_networks FK_social_network_social_network_image; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.social_networks
    ADD CONSTRAINT "FK_social_network_social_network_image" FOREIGN KEY (social_network_image_id) REFERENCES public.social_network_images(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: tag_translations FK_tag_translations_languages; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.tag_translations
    ADD CONSTRAINT "FK_tag_translations_languages" FOREIGN KEY (language_id) REFERENCES public.languages(id);


--
-- Name: tag_translations FK_tag_translations_tags; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.tag_translations
    ADD CONSTRAINT "FK_tag_translations_tags" FOREIGN KEY (tag_id) REFERENCES public.tags(id);


--
-- Name: shopping_list_item_translations FK_translations_shopping_list_item; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.shopping_list_item_translations
    ADD CONSTRAINT "FK_translations_shopping_list_item" FOREIGN KEY (shopping_list_item_id) REFERENCES public.shopping_list_items(id);


--
-- Name: user_shopping_list FK_user_goal_habit_assign; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.user_shopping_list
    ADD CONSTRAINT "FK_user_goal_habit_assign" FOREIGN KEY (habit_assign_id) REFERENCES public.habit_assign(id);


--
-- Name: user_shopping_list FK_user_shopping_list_item; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.user_shopping_list
    ADD CONSTRAINT "FK_user_shopping_list_item" FOREIGN KEY (shopping_list_item_id) REFERENCES public.shopping_list_items(id);


--
-- Name: social_networks FK_user_social_network; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.social_networks
    ADD CONSTRAINT "FK_user_social_network" FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: custom_shopping_list_items FK_users; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.custom_shopping_list_items
    ADD CONSTRAINT "FK_users" FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: comments FKhvh0e2ybgg16bpu229a5teje7; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT "FKhvh0e2ybgg16bpu229a5teje7" FOREIGN KEY (parent_comment_id) REFERENCES public.comments(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: web_pages_places FKrm26v5rrc5t54lhcd04dcwkw8; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.web_pages_places
    ADD CONSTRAINT "FKrm26v5rrc5t54lhcd04dcwkw8" FOREIGN KEY (web_pages_id) REFERENCES public.web_pages(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: categories FKs2ride9gvilxy2tcuv7witnxc; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT "FKs2ride9gvilxy2tcuv7witnxc" FOREIGN KEY (parent_category_id) REFERENCES public.categories(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: custom_shopping_list_items fk5s2hfx1xsgdsipw5kdyd5bhfx; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.custom_shopping_list_items
    ADD CONSTRAINT fk5s2hfx1xsgdsipw5kdyd5bhfx FOREIGN KEY (habit_id) REFERENCES public.habits(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: eco_news_users_dislikes fk_eco_news_users_dislikes_eco_news; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.eco_news_users_dislikes
    ADD CONSTRAINT fk_eco_news_users_dislikes_eco_news FOREIGN KEY (eco_news_id) REFERENCES public.eco_news(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: eco_news_users_dislikes fk_eco_news_users_dislikes_users; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.eco_news_users_dislikes
    ADD CONSTRAINT fk_eco_news_users_dislikes_users FOREIGN KEY (users_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: eco_news_users_likes fk_eco_news_users_likes_eco_news; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.eco_news_users_likes
    ADD CONSTRAINT fk_eco_news_users_likes_eco_news FOREIGN KEY (eco_news_id) REFERENCES public.eco_news(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: eco_news_users_likes fk_eco_news_users_likes_users; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.eco_news_users_likes
    ADD CONSTRAINT fk_eco_news_users_likes_users FOREIGN KEY (users_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: econews_comment fk_econews_comment_econews; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.econews_comment
    ADD CONSTRAINT fk_econews_comment_econews FOREIGN KEY (eco_news_id) REFERENCES public.eco_news(id) ON DELETE CASCADE;


--
-- Name: econews_comment fk_econews_comment_parent; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.econews_comment
    ADD CONSTRAINT fk_econews_comment_parent FOREIGN KEY (parent_comment_id) REFERENCES public.econews_comment(id) ON DELETE CASCADE;


--
-- Name: econews_comment fk_econews_comment_user; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.econews_comment
    ADD CONSTRAINT fk_econews_comment_user FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: econews_comment_users_liked fk_econews_comment_users_liked_econews_comment; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.econews_comment_users_liked
    ADD CONSTRAINT fk_econews_comment_users_liked_econews_comment FOREIGN KEY (econews_comment_id) REFERENCES public.econews_comment(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: econews_comment_users_liked fk_econews_comment_users_liked_users; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.econews_comment_users_liked
    ADD CONSTRAINT fk_econews_comment_users_liked_users FOREIGN KEY (users_liked_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: habit_assign fk_habit_assign_habits_habit_id; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_assign
    ADD CONSTRAINT fk_habit_assign_habits_habit_id FOREIGN KEY (habit_id) REFERENCES public.habits(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: habit_assign fk_habit_assign_users_user_id; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_assign
    ADD CONSTRAINT fk_habit_assign_users_user_id FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: habit_facts fk_habit_facts_habits_habit_id; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_facts
    ADD CONSTRAINT fk_habit_facts_habits_habit_id FOREIGN KEY (habit_id) REFERENCES public.habits(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: habit_statistics fk_habit_statistics_habit_assign_id; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_statistics
    ADD CONSTRAINT fk_habit_statistics_habit_assign_id FOREIGN KEY (habit_assign_id) REFERENCES public.habit_assign(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: habit_status_calendar fk_habit_status_calendar_habit_assign; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_status_calendar
    ADD CONSTRAINT fk_habit_status_calendar_habit_assign FOREIGN KEY (habit_assign_id) REFERENCES public.habit_assign(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: habit_status fk_habit_status_habit_assign_id; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_status
    ADD CONSTRAINT fk_habit_status_habit_assign_id FOREIGN KEY (habit_assign_id) REFERENCES public.habit_assign(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: habit_translation fk_habit_translation_habits_habit_id; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.habit_translation
    ADD CONSTRAINT fk_habit_translation_habits_habit_id FOREIGN KEY (habit_id) REFERENCES public.habits(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: message_like fk_participant_id; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.message_like
    ADD CONSTRAINT fk_participant_id FOREIGN KEY (participant_id) REFERENCES public.users(id);


--
-- Name: reasons_for_user_deactivation fk_reasons_for_user_deactivation_users_id; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.reasons_for_user_deactivation
    ADD CONSTRAINT fk_reasons_for_user_deactivation_users_id FOREIGN KEY (id_user) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: unread_messages fkh84h4eq2rt6ams9mbbb0keadp; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.unread_messages
    ADD CONSTRAINT fkh84h4eq2rt6ams9mbbb0keadp FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: own_security password_exists_with_user; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.own_security
    ADD CONSTRAINT password_exists_with_user FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE CASCADE DEFERRABLE;


--
-- Name: rating_statistics rating_statistics_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.rating_statistics
    ADD CONSTRAINT rating_statistics_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: user_actions user_actions_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.user_actions
    ADD CONSTRAINT user_actions_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: filters user_filters_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.filters
    ADD CONSTRAINT user_filters_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: users user_language_id; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_language_id FOREIGN KEY (language_id) REFERENCES public.languages(id);


--
-- Name: verify_emails user_should_verify_email; Type: FK CONSTRAINT; Schema: public; Owner: greencity
--

ALTER TABLE ONLY public.verify_emails
    ADD CONSTRAINT user_should_verify_email FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE RESTRICT ON DELETE CASCADE DEFERRABLE;


--
-- PostgreSQL database dump complete
--
