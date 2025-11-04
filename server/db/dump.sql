--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Homebrew)
-- Dumped by pg_dump version 14.18 (Homebrew)

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
-- Name: enum_notifications_type; Type: TYPE; Schema: public; Owner: nwmac
--

CREATE TYPE public.enum_notifications_type AS ENUM (
    'push',
    'email',
    'in-app'
);


ALTER TYPE public.enum_notifications_type OWNER TO nwmac;

--
-- Name: enum_registrations_status; Type: TYPE; Schema: public; Owner: nwmac
--

CREATE TYPE public.enum_registrations_status AS ENUM (
    'active',
    'used',
    'cancelled',
    'refunded'
);


ALTER TYPE public.enum_registrations_status OWNER TO nwmac;

--
-- Name: enum_waitlists_status; Type: TYPE; Schema: public; Owner: nwmac
--

CREATE TYPE public.enum_waitlists_status AS ENUM (
    'waiting',
    'notified',
    'converted',
    'expired'
);


ALTER TYPE public.enum_waitlists_status OWNER TO nwmac;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: event_metrics; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.event_metrics (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    total_tickets_sold integer DEFAULT 0,
    total_revenue numeric(10,2) DEFAULT 0,
    attendance_count integer DEFAULT 0,
    no_show_count integer DEFAULT 0
);


ALTER TABLE public.event_metrics OWNER TO nwmac;

--
-- Name: event_vendors; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.event_vendors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    vendor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.event_vendors OWNER TO nwmac;

--
-- Name: events; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    organizer_id uuid NOT NULL,
    venue_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    event_type character varying(50) NOT NULL,
    description text,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    capacity integer NOT NULL,
    waitlist_enabled boolean DEFAULT false,
    status character varying(50) DEFAULT 'scheduled'::character varying,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT events_capacity_check CHECK ((capacity >= 0)),
    CONSTRAINT events_check CHECK ((end_date > start_date))
);


ALTER TABLE public.events OWNER TO nwmac;

--
-- Name: feedback; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.feedback (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    user_id uuid,
    rating integer NOT NULL,
    comments text,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT feedback_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.feedback OWNER TO nwmac;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    message text NOT NULL,
    type public.enum_notifications_type NOT NULL,
    sent_at timestamp with time zone NOT NULL,
    is_read boolean DEFAULT false,
    target_role integer NOT NULL,
    user_id uuid
);


ALTER TABLE public.notifications OWNER TO nwmac;

--
-- Name: payments; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    registration_id uuid,
    payment_provider character varying(100),
    transaction_id character varying(255),
    amount numeric(10,2),
    status character varying(50) DEFAULT 'pending'::character varying,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT payments_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'completed'::character varying, 'failed'::character varying, 'refunded'::character varying])::text[])))
);


ALTER TABLE public.payments OWNER TO nwmac;

--
-- Name: registrations; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.registrations (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    ticket_type_id uuid NOT NULL,
    purchase_date timestamp with time zone NOT NULL,
    qr_code text NOT NULL,
    status character varying(50) DEFAULT 'active'::character varying NOT NULL,
    check_in_time timestamp with time zone,
    check_in boolean DEFAULT false,
    updated_at timestamp with time zone NOT NULL,
    registration_code text NOT NULL,
    event_id uuid NOT NULL,
    CONSTRAINT registrations_status_check CHECK (((status)::text = ANY (ARRAY[('active'::character varying)::text, ('used'::character varying)::text, ('cancelled'::character varying)::text, ('refunded'::character varying)::text])))
);


ALTER TABLE public.registrations OWNER TO nwmac;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.roles OWNER TO nwmac;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: nwmac
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_id_seq OWNER TO nwmac;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nwmac
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: session_speakers; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.session_speakers (
    session_id uuid NOT NULL,
    speaker_id uuid NOT NULL
);


ALTER TABLE public.session_speakers OWNER TO nwmac;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    venue_location character varying(255),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT sessions_check CHECK ((end_time > start_time))
);


ALTER TABLE public.sessions OWNER TO nwmac;

--
-- Name: speakers; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.speakers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    name character varying(255) NOT NULL,
    contact_email character varying(255),
    bio text,
    image_url text,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.speakers OWNER TO nwmac;

--
-- Name: ticket_types; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.ticket_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    name character varying(100) NOT NULL,
    price numeric(10,2) NOT NULL,
    quantity integer NOT NULL,
    sale_start timestamp with time zone,
    sale_end timestamp with time zone,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT ticket_types_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT ticket_types_quantity_check CHECK ((quantity >= 0))
);


ALTER TABLE public.ticket_types OWNER TO nwmac;

--
-- Name: users; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    role_id integer NOT NULL,
    f_name character varying(100) NOT NULL,
    l_name character varying(100) NOT NULL,
    phone character varying(20),
    email character varying(255) NOT NULL,
    password text NOT NULL,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    fcm_token text
);


ALTER TABLE public.users OWNER TO nwmac;

--
-- Name: vendors; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.vendors (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    company_name character varying(255),
    contact_email character varying(255),
    phone character varying(20),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.vendors OWNER TO nwmac;

--
-- Name: venues; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.venues (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying(255) NOT NULL,
    address text NOT NULL,
    city character varying(100) NOT NULL,
    state character varying(100) NOT NULL,
    country character varying(100) NOT NULL,
    zip_code character varying(20),
    capacity integer,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    CONSTRAINT venues_capacity_check CHECK ((capacity >= 0))
);


ALTER TABLE public.venues OWNER TO nwmac;

--
-- Name: waitlists; Type: TABLE; Schema: public; Owner: nwmac
--

CREATE TABLE public.waitlists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    event_id uuid NOT NULL,
    user_id uuid NOT NULL,
    status character varying(50) DEFAULT 'waiting'::character varying NOT NULL,
    requested_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.waitlists OWNER TO nwmac;

--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Data for Name: event_metrics; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.event_metrics (id, event_id, total_tickets_sold, total_revenue, attendance_count, no_show_count) FROM stdin;
\.


--
-- Data for Name: event_vendors; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.event_vendors (id, event_id, vendor_id, created_at, updated_at) FROM stdin;
8af9932a-9c86-47c3-a28b-4e0ba42a095c	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	c7e3d57b-4899-4d7d-9966-71d9af7e1da2	2025-11-02 18:43:15.196-05	2025-11-02 18:43:15.196-05
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.events (id, organizer_id, venue_id, title, event_type, description, start_date, end_date, capacity, waitlist_enabled, status, created_at, updated_at) FROM stdin;
7f96c538-5630-403f-bf2b-c7a9b678f684	e85bf48f-e1a9-40b9-9718-2808b1218c6b	f1a7d842-e153-4a38-924f-0318366af18a	Trunk or Treat	outdoor	Bring the kids Trunk or Treating at the school!	2025-11-04 17:30:00-05	2025-11-04 20:00:00-05	75	t	scheduled	2025-10-31 07:33:22.341-04	2025-10-31 07:33:22.341-04
b2378821-52dc-4dac-abc7-e0b7921732a2	e85bf48f-e1a9-40b9-9718-2808b1218c6b	460e8efc-be39-4471-a5f2-b2192a5cc370	Virtual Introductory Coding Workshop	professional	Take an introductory coding workshop with Techtonica!	2025-11-08 19:00:00-05	2025-11-08 20:00:00-05	40	t	scheduled	2025-10-31 07:59:05.558-04	2025-10-31 07:59:05.558-04
b9182aa0-2787-45d2-975e-fcacdbea710a	15e01e43-28be-4c22-9d67-2cdf80bb6788	decff87d-d03a-49d7-9d1b-3a7053794a48	Basketball Tournament	athletic	AAU Summer Basketball Tournament	2025-11-12 10:10:00-05	2025-11-17 17:00:00-05	75	f	scheduled	2025-11-01 00:19:39.689-04	2025-11-01 00:19:39.689-04
3a59f760-22e4-4242-b623-6038e8126b89	e85bf48f-e1a9-40b9-9718-2808b1218c6b	a07a84c5-f4dd-41a8-a142-cbc22d1d1c7b	Vicky's Bar Crawl	nightlife	bar	2025-11-22 01:43:00-05	2025-11-29 01:43:00-05	125	t	scheduled	2025-11-01 01:44:19.927-04	2025-11-01 01:44:19.927-04
30b8c9b6-729c-4310-87bc-ffc67defbbdb	e85bf48f-e1a9-40b9-9718-2808b1218c6b	c5f9f486-a392-43c0-a302-9167bc0f4cbd	Sailor's Tea Party	party	Enjoy a posh tea party with us at Kissaten Cafe!	2025-11-11 13:00:00-05	2025-11-11 15:00:00-05	50	f	scheduled	2025-11-01 01:56:18.142-04	2025-11-01 01:56:18.142-04
dde81c9d-5c54-4e97-b5f2-d801c8fcdb38	15e01e43-28be-4c22-9d67-2cdf80bb6788	f1a7d842-e153-4a38-924f-0318366af18a	Math Olympiad	competition	Compete in the national Math Olympiad and win to receive $5000 (Open K-12).	2025-11-08 09:00:00-05	2025-11-09 18:00:00-05	5000	t	scheduled	2025-10-31 08:24:30.903-04	2025-11-01 23:48:29.7-04
d084c59d-8859-429b-b334-4761ead5da7e	15e01e43-28be-4c22-9d67-2cdf80bb6788	87035111-d861-42aa-a218-a8a4b89f413f	Karaoke Night	nightlife	Come to Karaoke Night at Frank's Ankle!	2025-11-12 19:00:00-05	2025-11-12 21:00:00-05	45	t	canceled	2025-11-01 03:22:35.251-04	2025-11-02 00:03:28.218-04
d97cd96d-9431-440a-97a8-fb63f0b46f32	15e01e43-28be-4c22-9d67-2cdf80bb6788	c5f9f486-a392-43c0-a302-9167bc0f4cbd	Speed Dating @ Kissaten Cafe	dating	Come meet your soul mate!	2025-11-23 12:00:00-05	2025-11-23 13:30:00-05	40	t	scheduled	2025-11-02 00:25:08.277-04	2025-11-02 00:32:03.607-04
6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	89ecf34a-94c2-4b81-9b3c-692d0a5b5f97	b0de8cac-0665-401e-bbe7-c4655d32c5a6	DJ Spoof at Midnight Tax	entertainment	Catch DJ Spoof one night only at Midnight Tax!	2025-11-29 20:00:00-05	2025-11-29 23:00:00-05	300	t	scheduled	2025-11-01 03:47:24.849-04	2025-11-03 02:12:06.178-05
0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	15e01e43-28be-4c22-9d67-2cdf80bb6788	a07a84c5-f4dd-41a8-a142-cbc22d1d1c7b	Finance 101 for Professionals	professional	Learn the basics of finances	2025-11-26 16:00:00-05	2025-11-26 17:00:00-05	40	f	scheduled	2025-11-02 04:51:43.493-05	2025-11-03 04:43:03.229-05
\.


--
-- Data for Name: feedback; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.feedback (id, event_id, user_id, rating, comments, created_at) FROM stdin;
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.notifications (id, event_id, title, message, type, sent_at, is_read, target_role, user_id) FROM stdin;
b8c36be4-dd62-428e-9c55-d86b73680f0a	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Event Updated	The event "Finance 101 !!" has been updated.	email	2025-11-02 21:31:55.443-05	f	2	\N
612693fe-b94f-4dd4-8af5-80fd9306b873	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Event Updated	The event "Finance 101 !!" has been updated.	email	2025-11-02 21:33:04.088-05	f	2	\N
285297b4-fc93-4a39-a2fe-488aaf5e0ea2	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Event Updated	The event "Finance 101 for Early Professionals" has been updated.	email	2025-11-02 21:35:33.533-05	f	2	\N
1872b9cc-f7ea-4fa6-ad7e-3bcc30d0f309	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Event Updated	The event "Finance 101 for Early Professionals" has been updated.	email	2025-11-02 21:49:15.883-05	f	2	\N
f2c6d8d3-260d-4dba-a68e-07fd5c204c9f	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Event Updated	The event "Finance 101 !!" has been updated.	email	2025-11-02 21:51:38.089-05	f	2	\N
aef24ab3-829c-4d51-ba23-5a6f1d72bdf8	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	Updates to DJ Spoof @ Midnight Tax's Event Schedules	We wanted to inform you that the event schedules for "DJ Spoof @ Midnight Tax" have been updated.	email	2025-11-02 23:31:44.574-05	f	2	\N
ed8babf5-0de0-486b-b60f-a9c6edc389aa	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Updates to Finance 101 !!'s Event Schedules	We wanted to inform you that the event schedules for "Finance 101 !!" have been updated.	email	2025-11-03 00:02:54.184-05	f	2	\N
1e3f01a5-c472-46dc-8e13-10d2015a6d2d	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Event Schedule added to Finance 101 !!	We wanted to inform you that an event schedule was added to "Finance 101 !!" have been updated.	email	2025-11-03 00:48:01.907-05	f	2	\N
319cd90c-027c-455d-aa20-83f17496729d	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Speaker/ Performer was added to Finance 101 !!	We wanted to inform you that a speaker/ performer was added to Finance 101 !!.	email	2025-11-03 01:03:27.387-05	f	2	\N
491eea05-c4b9-4c82-8941-009d370c0ae0	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Speaker/ Performer (Brittney Gilmore) removed from Finance 101 !!	We wanted to inform you that a speaker/ performer (Brittney Gilmore) was removed from "Finance 101 !!".	email	2025-11-03 01:03:56.555-05	f	2	\N
95aed8be-de04-4ae1-8a07-8b8c2e571635	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	The Event, DJ Spoof @ Midnight Tax, has been updated	We wanted to inform you that the event "DJ Spoof @ Midnight Tax" has been updated.	email	2025-11-03 01:21:33.149-05	f	2	\N
ff5235ea-864b-4515-80d4-2a0ef286d222	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	The Event Venue for DJ Spoof @ Midnight Tax has been updated	We wanted to inform you that the event venue for DJ Spoof @ Midnight Tax has been updated.	email	2025-11-03 01:27:23.754-05	f	2	\N
38df26a4-b048-45e9-a88f-d15d4381ff7e	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	The Event (DJ Spoof at Midnight Tax) has been updated	We wanted to inform you that the event "DJ Spoof at Midnight Tax" has been updated.	email	2025-11-03 01:46:31.82-05	f	2	\N
29087362-d7c6-4eb6-9f65-ad611745d40c	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	The Event (DJ Spoof @ Midnight Tax) has been updated	We wanted to inform you that DJ Spoof @ Midnight Tax has been updated.	email	2025-11-03 01:51:07.921-05	f	2	\N
a26046a3-a460-492c-b3a0-52fe38e16604	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	The Event (DJ Spoof at Midnight Tax) has been updated	We wanted to inform you that DJ Spoof at Midnight Tax has been updated.	email	2025-11-03 01:56:21.849-05	f	2	\N
563f1176-5790-44ea-8995-14f69e9ea624	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	The Event (DJ Spoof at Midnight Tax) has been updated	We wanted to inform you that DJ Spoof at Midnight Tax has been updated.	email	2025-11-03 01:56:58.877-05	f	2	\N
565c0ab4-b7aa-48e6-9c3d-f11036437232	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	The Event (DJ Spoof at Midnight Tax) has been updated	We wanted to inform you that DJ Spoof at Midnight Tax has been updated.	email	2025-11-03 01:59:29.287-05	f	2	\N
30aaf411-d8b6-4b0e-912f-ed832e43f942	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	The Event (DJ Spoof at Midnight Tax) has been updated	We wanted to inform you that DJ Spoof at Midnight Tax has been updated.	email	2025-11-03 02:00:14.638-05	f	2	\N
5a7ef7df-8fc9-4311-8937-b95190c7a64b	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	The Event (DJ Spoof at Midnight Tax) has been updated	We wanted to inform you that DJ Spoof at Midnight Tax has been updated.	email	2025-11-03 02:01:46.553-05	f	2	\N
12612467-bb03-4c86-9dab-f4fac34332cd	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	The Event (DJ Spoof at Midnight Tax) has been updated	We wanted to inform you that DJ Spoof at Midnight Tax has been updated.	email	2025-11-03 02:03:27.378-05	f	2	\N
b5a99794-9946-44d9-83b0-a43224746b34	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	The Event (DJ Spoof @ Midnight Tax) has been updated	We wanted to inform you that DJ Spoof @ Midnight Tax has been updated.	email	2025-11-03 02:05:05.475-05	f	2	\N
d068bc5c-624f-44e6-a887-91c2509c58e6	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	The Event (DJ Spoof at Midnight Tax) has been updated	We wanted to inform you that DJ Spoof at Midnight Tax has been updated.	email	2025-11-03 02:12:06.222-05	f	2	\N
5a774fc5-5c90-4bda-9024-d69069a16b27	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Speaker/ Performer (Hailey Williams) removed from Finance 101 !!	We wanted to inform you that a speaker/ performer (Hailey Williams) was removed from Finance 101 !!.	email	2025-11-03 04:19:09.859-05	f	2	\N
74f04dce-4435-4650-971f-8135e9497bc9	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Speaker/ Performer was added to Finance 101 !!	We wanted to inform you that a speaker/ performer was added to Finance 101 !!.	email	2025-11-03 04:32:26.858-05	f	2	\N
d513b063-8e07-4fc0-8493-d9d48c2ba588	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	The Event (Finance 101 for Early Professionals) has been updated	We wanted to inform you that Finance 101 for Early Professionals has been updated.	email	2025-11-03 04:38:38.894-05	f	2	\N
da860943-a3e3-454a-b10d-56531c9ec8d1	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	The Event (Finance 101 for Professionals) has been updated	We wanted to inform you that Finance 101 for Professionals has been updated.	email	2025-11-03 04:43:03.266-05	f	2	\N
04f5a56d-afc8-4df9-9162-40f3f3d64a87	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Event Schedule (test) added to Finance 101 for Professionals	We wanted to inform you that an event schedule (test) was added to Finance 101 for Professionals.	email	2025-11-03 04:45:12.167-05	f	2	\N
2077fdcd-9123-44eb-959e-bcfdde82d654	b2378821-52dc-4dac-abc7-e0b7921732a2	Speaker/ Performer was added to Virtual Introductory Coding Workshop	We wanted to inform you that a speaker/ performer was added to Virtual Introductory Coding Workshop.	email	2025-11-03 17:13:42.304-05	f	2	\N
5098d49f-0a7b-477c-847e-413d211da112	b2378821-52dc-4dac-abc7-e0b7921732a2	Speaker/ Performer (Penny) removed from Virtual Introductory Coding Workshop	We wanted to inform you that a speaker/ performer (Penny) was removed from Virtual Introductory Coding Workshop.	email	2025-11-03 17:14:10.7-05	f	2	\N
8e9b88de-068e-417f-8544-5ea1a2ced417	3a59f760-22e4-4242-b623-6038e8126b89	Event Schedule (Irish Pub) added to Vicky's Bar Crawl	We wanted to inform you that an event schedule (Irish Pub) was added to Vicky's Bar Crawl.	email	2025-11-03 17:17:08.431-05	f	2	\N
60a5732b-a30e-4114-b5dc-1dc072c7609e	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Event Schedule (test) deleted from Finance 101 for Professionals	We wanted to inform you that an event schedule (test) has been deleted from Finance 101 for Professionals.	email	2025-11-03 17:28:39.636-05	f	2	\N
0417b6d0-82b8-44e1-9165-0313a4388b31	b2378821-52dc-4dac-abc7-e0b7921732a2	Event Schedule (rga) added to Virtual Introductory Coding Workshop	We wanted to inform you that an event schedule (rga) was added to Virtual Introductory Coding Workshop.	email	2025-11-03 17:30:14.019-05	f	2	\N
06a85b57-5cd1-4b24-a381-a8f6baed7d83	b2378821-52dc-4dac-abc7-e0b7921732a2	Event Schedule (rga) deleted from Virtual Introductory Coding Workshop	We wanted to inform you that an event schedule (rga) has been deleted from Virtual Introductory Coding Workshop.	email	2025-11-03 17:30:20.424-05	f	2	\N
1a6ac101-1fc5-40e4-b1bc-b136e952e0e9	b2378821-52dc-4dac-abc7-e0b7921732a2	Event Schedule (dfa) added to Virtual Introductory Coding Workshop	We wanted to inform you that an event schedule (dfa) was added to Virtual Introductory Coding Workshop.	email	2025-11-03 17:30:54.603-05	f	2	\N
fbf85d3e-92dc-4847-8434-d6a1a0b2e52b	b2378821-52dc-4dac-abc7-e0b7921732a2	Event Schedule (dfa) deleted from Virtual Introductory Coding Workshop	We wanted to inform you that an event schedule (dfa) has been deleted from Virtual Introductory Coding Workshop.	email	2025-11-03 17:30:58.398-05	f	2	\N
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.payments (id, registration_id, payment_provider, transaction_id, amount, status, metadata, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: registrations; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.registrations (id, user_id, ticket_type_id, purchase_date, qr_code, status, check_in_time, check_in, updated_at, registration_code, event_id) FROM stdin;
bccd5266-2f19-4476-80c0-ece33ba818e0	9cb26016-6907-4cd4-a447-32665bf196f8	f94e0364-04d5-4182-b2cd-44faab428186	2025-11-01 20:19:31.956-04	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJQAAACUCAYAAAB1PADUAAAAAklEQVR4AewaftIAAATnSURBVO3BQY4kRxIEQdNA/f/Lun30U2AT6dUcDk0Ef6RqyUnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYtOqhadVC06qVp0UrXok5eA/CY1bwB5Qs0EZFIzAZnUTEAmNTdAfpOaN06qFp1ULTqpWvTJMjWbgGxScwNkAnIDZFIzAZnUvKFmE5BNJ1WLTqoWnVQt+uTLgDyh5gkgN2reUPNNQCY1TwB5Qs03nVQtOqladFK16JO/HJBJzQRkUjMBqf/fSdWik6pFJ1WLPvnLqHlCzY2aJ4DcAJnU/E1OqhadVC06qVr0yZep+ZMAuVFzA+RGzRNAJjVPqPmTnFQtOqladFK16JNlQP4kQCY1E5AbIJOaCcgNkEnNG0D+ZCdVi06qFp1ULfrkJTX/ZWpu1NyouVHzb3JSteikatFJ1aJPXgIyqZmAbFIzqZmAbFIzAZnUTEBu1DwBZJOabzqpWnRSteikatEnX6bmCSCTmhsgk5obIDdAbtRMQCY1N0Bu1NyomYDcqJmA3Kh546Rq0UnVopOqRfgjLwC5UXMDZFIzAZnU3AC5UXMD5JvUTEBu1ExAJjU3QCY133RSteikatFJ1aJPlqmZgNyouVEzAXlCzQTkCTVvALlRcwNkUjMBmdRMan7TSdWik6pFJ1WLPnlJzQRkUjMBuQHyhJoJyI2aCcikZgJyo2YCMqmZgDyhZgIyqZmA3Kj5ppOqRSdVi06qFn3yEpBJzSY1/yQ1N0AmNROQGzUTkAnIpGYCcqNmAnKj5o2TqkUnVYtOqhbhj7wA5Ak1N0CeUPMEkBs1N0DeUDMBmdRMQCY1N0Bu1HzTSdWik6pFJ1WLPnlJzQTkCSCTmhsgE5AbNZOaCcgNkCfUTEDeUHMDZFLzTzqpWnRSteikahH+yCIgT6iZgDyh5gbIjZongDyhZgIyqZmATGomIJOaCcgTajadVC06qVp0UrXok5eA3Kh5Q80E5A01E5An1DwB5Ak1E5BJzQTkRs0EZAIyqXnjpGrRSdWik6pFnyxTMwF5A8ikZgLym4BMaiYgN2qeUDMBmdRMQG7UfNNJ1aKTqkUnVYs++TI1TwCZ1DyhZgIyAXlCzQTkRs0NkEnNBGRSM6mZgLwBZFLzxknVopOqRSdViz75MiCTmieAPAHkCTU3QCY1E5An1ExAboA8oWYCMqmZ1Gw6qVp0UrXopGoR/si/GJBJzQTkRs0mIJOaCciNmieA3Ki5ATKpeeOkatFJ1aKTqkWfvATkN6mZ1Dyh5g0gk5pJzQTkDSCTmhs1E5AbNZtOqhadVC06qVr0yTI1m4DcAHkDyKRmAnIDZFJzo2YCcqPmDTUTkG86qVp0UrXopGrRJ18G5Ak1b6h5Qs2NmgnIpGYC8gaQN4DcqPmmk6pFJ1WLTqoWffKXATKpeQLIjZoJyKTmDTU3QCY1E5BJzQTkRs0bJ1WLTqoWnVQt+uQ/BsgbQCY1b6iZgNyomYBMap5Qs+mkatFJ1aKTqkWffJmab1IzAZmA3KiZgExqJiBPAHlDzQTkT3ZSteikatFJ1aJPlgH5TUBu1LwB5AbIE2pugExAbtTcAJnUfNNJ1aKTqkUnVYvwR6qWnFQtOqladFK16KRq0UnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYv+BxdvRz07D/g0AAAAAElFTkSuQmCC	active	\N	f	2025-11-01 20:19:31.956-04	7aef75f4-3233-4b22-9a48-2bc840d85cc3	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26
7e9f46c5-acca-4d51-a2eb-45137bd34a89	9cb26016-6907-4cd4-a447-32665bf196f8	d109e59f-3768-45f4-92a0-eff77f152528	2025-11-02 13:20:54.748-05	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJQAAACUCAYAAAB1PADUAAAAAklEQVR4AewaftIAAATSSURBVO3BQY4bSRAEwfAC//9lXx3zVECjkyPtIMzwj1QtOaladFK16KRq0UnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYtOqhZ98hKQn6TmCSCTmhsgk5oJyKTmBsgTaiYgP0nNGydVi06qFp1ULfpkmZpNQJ4AcgPkCSBvqNmkZhOQTSdVi06qFp1ULfrky4A8oeYJIDdqngAyqZmATEAmNROQJ9Q8AeQJNd90UrXopGrRSdWiT34ZNW+omYDcqJmA3KiZgPwmJ1WLTqoWnVQt+uSXAfKGmknNDZAngExqfpOTqkUnVYtOqhZ98mVq/mVq3lDzN6n5l5xULTqpWnRSteiTZUD+JjUTkEnNBGRSMwGZ1ExAJjUTkEnNBGRScwPkX3ZSteikatFJ1aJPXlLzfwJkUvMEkEnNjZoJyKTmRs3/yUnVopOqRSdViz55CcikZgKySc2k5gk1T6i5ATKpmYBMap4AsknNN51ULTqpWnRSteiTl9TcqLkBcqNmAjKp2QRkk5oJyI2aGzUTkEnNDZAbNW+cVC06qVp0UrXokx8GZFJzA2RSMwG5UTMBmdQ8oeYJIJOaCciNmgnIDZAbNd90UrXopGrRSdUi/COLgNyoeQPIpGYCsknNBORGzQRkUrMJyKTmbzqpWnRSteikatEnLwG5UfMEkBs1E5AbNROQSc0NkBs1m4BMaiYgk5oJyI2abzqpWnRSteikatEnL6m5ATKpeULN36RmAnIDZFIzAXkCyKRmAjKpmYD8pJOqRSdVi06qFuEf+UFAJjU3QCY1/xIgT6iZgExqJiCTmhsgk5oJyKRm00nVopOqRSdViz5ZBuQNIJOaJ4BMam6ATGomIDdqvknNDZBJzd90UrXopGrRSdWiT14CMqmZgNwAmdRMQJ5QMwF5Q80E5A0gk5oJyKRmAjKpmYDcqPmmk6pFJ1WLTqoWffKPATKpmYA8oWYCcgPkCSA3ap5QMwGZ1ExAbtT8pJOqRSdVi06qFn3yw9RMQG6AvAFkUnMD5EbNDZAbNU+o2QTkRs0bJ1WLTqoWnVQt+uTL1Dyh5gkgTwB5Qs0EZFJzA+RGzQRkUvOEmifUbDqpWnRSteikahH+kReATGomIN+kZgIyqbkBMqmZgExqNgH5SWq+6aRq0UnVopOqRZ+8pOZGzTcBmdRMQCY1T6iZgNyomYBMam7UPAFkUjMBmYBMajadVC06qVp0UrXok5eA/CQ1k5qfpOYNIE8AmdQ8oeYGyKTmjZOqRSdVi06qFn2yTM0mIDdAJjU3QCY1N0Bu1HyTmieATGomIJOaTSdVi06qFp1ULfrky4A8oWaTmjfUTEAmIJOaGzUTkAnIG2omID/ppGrRSdWik6pFn/xyQCY1E5A31NyomYDcqLkBMqmZgExqJiDfdFK16KRq0UnVok9+GSCTmifUPAFkUjMBmdTcALlRMwGZ1ExAftJJ1aKTqkUnVYs++TI136TmCSBvAJnUvAHkRs0E5Ak1P+mkatFJ1aKTqkWfLAPyk4BMam7UTECeUDMBmdTcAJnUvKHmBsiNmk0nVYtOqhadVC3CP1K15KRq0UnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYtOqhadVC06qVr0HwwEQCy06xzwAAAAAElFTkSuQmCC	active	\N	f	2025-11-02 13:20:54.748-05	073c958f-0215-4acb-ab6d-862768d20a69	d084c59d-8859-429b-b334-4761ead5da7e
65db54d5-4c00-4078-8bcf-1e15023eab0c	31125a59-e4c9-419d-8f87-aa4e1af1c524	58f8e729-dc27-449e-a05c-a4679fa8ed88	2025-11-02 23:03:21.677-05	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJQAAACUCAYAAAB1PADUAAAAAklEQVR4AewaftIAAATRSURBVO3BQY4bSRAEwfAC//9lXx3zVECjkyPNIszwj1QtOaladFK16KRq0UnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYtOqhZ98hKQn6RmAnKj5gkgk5oJyKTmCSCTmhsgP0nNGydVi06qFp1ULfpkmZpNQN4AsknNBOQJNROQSc2Nmk1ANp1ULTqpWnRSteiTLwPyhJon1LwBZFJzA2RScwNkAjKpeQPIE2q+6aRq0UnVopOqRZ/8ckAmNROQN4DcAHkDyKTmNzupWnRSteikatEnv5yaCcikZgIyqXlDzRNA/s9OqhadVC06qVr0yZep+ZuA3AC5UXMDZFIzAblR84aaf8lJ1aKTqkUnVYs+WQbkJwGZ1ExAJjUTkEnNBGRS84aaCcik5gbIv+ykatFJ1aKTqkX4R34xIDdqJiCTmk1AnlDzf3JSteikatFJ1aJPXgIyqZmA3KiZgDyh5gbIDZAbNROQSc2NmgnIBGRSMwGZ1NwAmdRMQG7UvHFSteikatFJ1aJPXlIzAXlDzRtAnlAzAZmATGpu1DyhZgJyA+RfdlK16KRq0UnVok9eAvKEmgnIpGYCcqPmm9TcAJnUTEAmNTdqboBMam6A3KjZdFK16KRq0UnVIvwji4A8oWYTkDfU3AC5UXMDZFLzBJBJzQRkUjMBuVHzxknVopOqRSdViz75YWomIJOaCcgTajYBuVEzAZnU3AC5UfMGkBs1m06qFp1ULTqpWvTJMjVvAJnU3ACZgNyo2QRkk5oJyBNqngAyqXnjpGrRSdWik6pFnywDMqmZgExqboDcqJmA3ACZ1ExAJjVPAHkDyKRmAnIDZFLzk06qFp1ULTqpWoR/5AUgb6j5JiCTmieAPKHmCSCTmhsgT6iZgExqNp1ULTqpWnRSteiTZWqeAPKEmgnIjZoJyI2aGzUTkCeAvKFmAjKp+ZtOqhadVC06qVr0yUtqJiBPqHkCyBNAJjUTkCeAPAFkUnMDZFJzo2YCMqn5SSdVi06qFp1ULfrkJSCTmgnIpGYC8oaaN9RMQH4SkEnNE0BugExqJiCTmjdOqhadVC06qVr0yUtqngDyhJoJyARkUvMEkCfU3ACZ1GwCMqm5ATIBmdRsOqladFK16KRq0SfLgExqJiCTmhsgbwCZ1ExqJiA3QCY1TwC5AfIEkEnN33RSteikatFJ1SL8I78YkEnNDZBJzU8CcqPmCSCTmhsgN2reOKladFK16KRq0ScvAflJan4SkEnNBGRSswnIpOYGyN90UrXopGrRSdWiT5ap2QTkDSCTmgnINwF5Q80bam6AbDqpWnRSteikatEnXwbkCTVPqLlR84SaGyCTmgnIpOYGyARkE5AbNZtOqhadVC06qVr0yS8HZFIzAZnUTGomIJOaGyBvqJmATGpugDyh5ptOqhadVC06qVr0yf+cmk1qJiCTmgnIjZpJzRNqJiBPAJnUvHFSteikatFJ1aJPvkzNN6mZgExq3gDyTUAmNTdAbtQ8oWbTSdWik6pFJ1WLPlkG5CcBeQLIG2reUDMBmYBMaiY1E5B/yUnVopOqRSdVi/CPVC05qVp0UrXopGrRSdWik6pFJ1WLTqoWnVQtOqladFK16KRq0UnVopOqRSdVi06qFv0HrYkganF0KrYAAAAASUVORK5CYII=	active	\N	f	2025-11-02 23:03:21.677-05	735d8c16-054b-4e21-9685-6c03dda95c87	b2378821-52dc-4dac-abc7-e0b7921732a2
d8ee5f29-d4a2-4ccd-a9d0-937ca3d757fe	31125a59-e4c9-419d-8f87-aa4e1af1c524	01f89cab-723d-49e1-9df6-7fd293d9de2f	2025-11-02 23:09:33.449-05	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJQAAACUCAYAAAB1PADUAAAAAklEQVR4AewaftIAAATFSURBVO3BQY4bSRAEwfAC//9l3znmqYBGJ2clIczwR6qWnFQtOqladFK16KRq0UnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYs+eQnIb1IzAZnU3ACZ1HwTkEnNE0B+k5o3TqoWnVQtOqla9MkyNZuA3KiZgNyomYBMap4AcqNmAnKj5kbNJiCbTqoWnVQtOqla9MmXAXlCzSY1E5AbIJOaCcifBMgTar7ppGrRSdWik6pFn/zlgExqJiCTmgnIpGYC8oSaGzUTkH/JSdWik6pFJ1WLPvnHAJnUTEAmNROQGzUTkAnIjZp/2UnVopOqRSdViz75MjW/Sc0EZFIzAXkCyKTmCSCTmjfU/ElOqhadVC06qVr0yTIgfzM1E5BJzQRkUjMBmdRMQCY1N0D+ZCdVi06qFp1ULfrkJTV/EiCTmm9SMwG5ATKpuVHzNzmpWnRSteikahH+yAtAJjVPAJnUTECeUPMGkCfU3AD5P6m5ATKpeeOkatFJ1aKTqkX4Iy8AuVEzAXlCzSYgk5o/CZAbNROQJ9RMQCY1b5xULTqpWnRStQh/5H8EZJOaN4BsUnMD5A01N0AmNROQSc0bJ1WLTqoWnVQtwh95AcgbaiYgk5oJyKRmAjKpuQFyo2YC8oSaJ4BMav4mJ1WLTqoWnVQtwh95AciNmjeATGomIJOaGyBPqHkCyI2a/xOQSc2mk6pFJ1WLTqoWfbJMzQTkCTWTmgnIpGYC8oSaCcgE5JuATGomIN8EZFLzxknVopOqRSdViz55Sc0Tap4AMqm5UTMBeULNDZBJzTepmYDcqLkB8k0nVYtOqhadVC365CUgk5obIDdqJjUTkBs1k5obIJOaCcikZgJyo+YNIDdqJiCTmhs1m06qFp1ULTqpWvTJl6mZgExqboDcqJmATGomIDdAnlAzAZmATGqeUPM3OaladFK16KRqEf7IC0DeUPMEkBs1E5AbNW8AuVFzA+Q3qZmATGreOKladFK16KRq0ScvqXkDyKRmAvIEkEnNBOQGyCYgk5pJzQ2QSc0TQH7TSdWik6pFJ1WLPvkyIG+omYA8AWRS84SaJ4BMaiYgbwCZ1Nyo+U0nVYtOqhadVC365CUgN2pugNwAeUPNBGRS8zcDMqm5ATKp2XRSteikatFJ1SL8kb8YkEnNBORGzQTkCTVPALlR8wSQJ9RMQCY1b5xULTqpWnRSteiTl4D8JjVPqHlCzQ2QCciNmjeATGpu1ExAftNJ1aKTqkUnVYs+WaZmE5AbNROQN9RMQN4A8oaaJ4BMaiYg33RSteikatFJ1aJPvgzIE2qeADKpmYBMaiYgE5AbNW8AuQHyTWomIJtOqhadVC06qVr0yV9OzQTkCTUTkEnNDZBJzRNqvgnIjZpNJ1WLTqoWnVQt+uQfp2YCcqNmAvIEkEnNbwIyqZmATEAmNW+cVC06qVp0UrXoky9T85vUbFLzBJAJyA2QSc0EZFJzo+b/dFK16KRq0UnVok+WAflNQCY1E5AbNROQGzVPqJmA3AC5ATKpmYBMam7UbDqpWnRSteikahH+SNWSk6pFJ1WLTqoWnVQtOqladFK16KRq0UnVopOqRSdVi06qFp1ULTqpWnRSteikatF/zAUsPWL9+AUAAAAASUVORK5CYII=	active	\N	f	2025-11-02 23:09:33.449-05	ef7b0b2e-abd2-476f-9c6f-5724532786d6	d97cd96d-9431-440a-97a8-fb63f0b46f32
8bbe4fa7-2770-4cc8-840a-ea3444310a7f	31125a59-e4c9-419d-8f87-aa4e1af1c524	0b5a42dd-a84f-4b50-aaea-1f11f956a6c8	2025-11-02 23:09:56.359-05	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJQAAACUCAYAAAB1PADUAAAAAklEQVR4AewaftIAAATiSURBVO3BQY4cSRIEQdNA/f/Lujz6KYBEenVzuCaCf6RqyUnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYtOqhadVC06qVp0UrXok5eA/CQ1N0Bu1ExAbtRMQCY1TwCZ1NwA+Ulq3jipWnRSteikatEny9RsAvKEmgnIG0A2qXlDzSYgm06qFp1ULTqpWvTJlwF5Qs0TQCY1T6iZgExqJiATkEnNBOQJNU8AeULNN51ULTqpWnRSteiTf5yaCcikZlIzAblRMwG5UfMvO6ladFK16KRq0Sf/OCCTmifU3AB5AsiNmv+yk6pFJ1WLTqoWffJlan6TmgnIpOYJIJOa36Tmb3JSteikatFJ1aJPlgH5mwCZ1ExAJjUTkEnNBGRSMwGZ1ExAJjU3QP5mJ1WLTqoWnVQt+uQlNX8zNROQN4A8oeYNNf8lJ1WLTqoWnVQt+uQlIJOaCcgmNZOaCcikZlLzhJoJyKRmAnKj5gkgm9R800nVopOqRSdViz75YWomIJOaGyCTmhsgk5obIDdqJiCTmhsgk5on1ExAbtTcAJnUvHFSteikatFJ1SL8Iy8A+UlqJiCTmjeAPKHmBsik5gbIJjUTkEnNppOqRSdVi06qFn2yTM0E5EbNE0CeAHKj5kbNBOSb1NwAuVHzm06qFp1ULTqpWvTJS2q+Ccik5g01E5BJzQRkUjMBeQLIE2omNTdAftNJ1aKTqkUnVYs+eQnIE2omIDdqngCySc2NmieATGomIBOQJ9Q8AWRS88ZJ1aKTqkUnVYs++WVqJiATkEnNjZoJyATkDSA3aiYgk5oJyKRmAjKpuQHyhJpNJ1WLTqoWnVQt+mSZmieATGpugExqbtRMQCY1N0DeUPOGmhsgk5rfdFK16KRq0UnVIvwjLwB5Qs0NkBs1bwC5UXMDZFIzAZnUTEAmNROQSc0EZFIzAblR800nVYtOqhadVC365IcBmdRMajYBmdTcALlRMwGZ1ExAnlAzAZnUTEAmNTdAbtS8cVK16KRq0UnVok+WqbkB8gSQGzUTkBsgbwCZ1NyouQEyqZnUTECeADKp+aaTqkUnVYtOqhZ98mVAboBMaiY1E5AJyI2aJ4BMam6ATGqeUDMBmdS8oeYGyKTmjZOqRSdVi06qFuEfeQHIpOYGyDepuQFyo2YCcqNmAnKjZgLym9RsOqladFK16KRqEf6R/zAgT6iZgExqngAyqbkBcqPmCSCTmhsgN2reOKladFK16KRq0ScvAflJaiY1E5BJzY2aJ4D8JCCTmhsgk5pJzTedVC06qVp0UrXok2VqNgG5ATKpmYBMaiYgk5oJyI2aJ9RMQG7UbAIyqdl0UrXopGrRSdWiT74MyBNq3gAyqZmAPKFmAjIBeULNDZA31ExAJjXfdFK16KRq0UnVok/+MWpu1ExAboBMat4AMql5AsikZgIyqZmA3Kh546Rq0UnVopOqRZ/8nwEyqZmATGomIE+oeQLIjZoJyKTmCTWbTqoWnVQtOqla9MmXqfkmNROQn6TmBsgNkEnNDZC/2UnVopOqRSdViz5ZBuQnAblR8waQGyBPqNmk5gbIpOabTqoWnVQtOqlahH+kaslJ1aKTqkUnVYtOqhadVC06qVp0UrXopGrRSdWik6pFJ1WLTqoWnVQtOqladFK16H+j+lAlglmfLgAAAABJRU5ErkJggg==	active	\N	f	2025-11-02 23:09:56.359-05	ce05321d-52e9-4e51-84f4-01e5611fe8dd	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf
d39a43ae-a9bc-4206-b24b-7ecd320b8a26	9cb26016-6907-4cd4-a447-32665bf196f8	58f8e729-dc27-449e-a05c-a4679fa8ed88	2025-11-03 12:48:16.868-05	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJQAAACUCAYAAAB1PADUAAAAAklEQVR4AewaftIAAATuSURBVO3BQY4cSRIEQdNA/f/Lujz6KYBEevWQvSaCf6RqyUnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYtOqhadVC06qVp0UrXok5eA/CQ1TwCZ1ExAbtRMQCY1N0CeUDMB+Ulq3jipWnRSteikatEny9RsAvKGmhs1E5AJyBNAbtRMQJ5QswnIppOqRSdVi06qFn3yZUCeUPMEkEnNE0Bu1ExAbtRMQCYgm4A8oeabTqoWnVQtOqla9MkvA+QJNTdAJjUTkCfUTEB+k5OqRSdVi06qFn3yfw7IpGZSMwF5A8ik5jc5qVp0UrXopGrRJ1+m5jdRswnIpOYJNX+Tk6pFJ1WLTqoWfbIMyH9JzQRkUjMBuQEyqZmATGomIJOaN4D8zU6qFp1ULTqpWvTJS2r+ZWqeAPKEmhs1N2r+JSdVi06qFp1ULfrkJSCTmgnIJjWTmgnIJjU3QG6ATGqeALJJzTedVC06qVp0UrXok5fUvKFmAjKpeULNBOQGyBNqJjU3aiYgN2pu1ExAbtTcAJnUvHFSteikatFJ1SL8Iy8AmdRMQCY1E5BvUvMEkCfU3ACZ1NwAmdRMQG7U3ACZ1Gw6qVp0UrXopGrRJy+p+SY1E5AngExqnlAzAXkDyKTmCTV/s5OqRSdVi06qFn3yEpBJzRNqboDcqJmA3ACZ1ExqJiCb1LwBZFIzAblR800nVYtOqhadVC3CP/ICkE1q3gByo2YCMqm5AfKEmgnIG2omIJOaCcgTat44qVp0UrXopGrRJy+pmYBMam6A3AB5Qs0E5EbNG2omIBOQSc0EZFIzAXkCyKTmJ51ULTqpWnRSteiTl4A8AeQJNROQSc0EZFIzAblRMwF5Qs0mNU+ouQFyo+aNk6pFJ1WLTqoWfbJMzRtAbtTcqJmATGqeUHMDZFIzAblRMwGZ1ExAJjUTkCfUbDqpWnRSteikatEnfzk1N0CeADKpmYA8oWYCMqmZgNyomYBMaiYgN2pugExq3jipWnRSteikatEnP0zNBOQGyI2aJ4BMQJ5QMwG5ATKpeULNJiCTmk0nVYtOqhadVC365MuAvKHmBsiNmknNDZBJzQRkUvMEkEnNBGRS801AJjVvnFQtOqladFK16JMfpuYGyATkCTUTkBs1k5oJyKTmBsikZlIzAbkB8oSaCciNmk0nVYtOqhadVC3CP/IPA/KEmgnIpOYGyKTmBsikZgIyqXkCyKTmCSCTmjdOqhadVC06qVr0yUtAfpKaSc0EZFIzAZnUPKFmAjKpmdRMQJ4AMql5AsiNmk0nVYtOqhadVC36ZJmaTUBugExqJiBvALlR801qngAyqZmAfNNJ1aKTqkUnVYs++TIgT6h5A8ikZgLyhJoJyARkUjMBmdRMQCYgb6iZgNwAmdS8cVK16KRq0UnVok9+GTU3am6APKHmRs0EZFLzBJBJzQRkUvOTTqoWnVQtOqla9MkvB2RSc6NmAjKpmYBMaiYgk5obIDdqJiBPAJnUbDqpWnRSteikatEnX6bmm9S8AWRScwPkDSA3am6A3Kj5L51ULTqpWnRSteiTZUB+EpBNQG7UvKHmBsik5kbNDZBJzTedVC06qVp0UrUI/0jVkpOqRSdVi06qFp1ULTqpWnRSteikatFJ1aKTqkUnVYtOqhadVC06qVp0UrXopGrR/wC6SlI10y3umQAAAABJRU5ErkJggg==	active	\N	f	2025-11-03 12:48:16.868-05	22d495be-0090-4d1b-ba7b-795404dbf822	b2378821-52dc-4dac-abc7-e0b7921732a2
97a935b7-37b1-485e-a27e-973db08974fc	f9fdb613-2a98-4f78-977f-30c2a637fcc7	7a7a4137-b4e5-4466-aa6a-b1d4531af860	2025-11-03 19:04:08.565-05	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJQAAACUCAYAAAB1PADUAAAAAklEQVR4AewaftIAAATsSURBVO3BQYokSRAEQdOg/v9l3T76KSBJr2Z6MRH8kaolJ1WLTqoWnVQtOqladFK16KRq0UnVopOqRSdVi06qFp1ULTqpWnRSteikatFJ1aJPXgLym9RMQG7UPAFkUjMBmdQ8AWRScwPkN6l546Rq0UnVopOqRZ8sU7MJyBNqngDyhJoJyI2aSc0EZFJzo2YTkE0nVYtOqhadVC365MuAPKHmCTWb1NwAmdQ8AWRS8waQJ9R800nVopOqRSdViz7544BMajYBeQLIjZoJyKTmLzupWnRSteikatEnf5yaCcikZgIyqXlCzY2aGyD/ZydVi06qFp1ULfrky9T8JjU3am6ATGomIDdqJiA3at5Q8y85qVp0UrXopGrRJ8uA/CYgk5oJyKRmAjKpmYBMaiYgT6iZgExqboD8y06qFp1ULTqpWvTJS2r+ZWomIE+omYDcANmk5i85qVp0UrXopGrRJy8BmdRMQG7UTECeUDMBuVEzAZmATGreUPMGkEnNDZBJzQTkRs0bJ1WLTqoWnVQtwh9ZBGRScwPkRs0E5EbNG0CeUPMEkEnNBGSTmhsgk5o3TqoWnVQtOqlahD/yi4BsUvMEkEnNBGRS8wSQGzUTkEnNG0Bu1HzTSdWik6pFJ1WLPlkGZFIzqZmATGpugExAJjVvqHkCyKTmCTUTkCfU3Ki5ATKpeeOkatFJ1aKTqkX4Iy8AeULNE0Bu1ExAJjUTkBs1E5BNam6ATGqeAHKj5ptOqhadVC06qVr0yTI1E5AJyI2aSc0NkEnNBGRSMwF5Qs0NkBsgk5pJzQRkUnOjZgJyA2RS88ZJ1aKTqkUnVYs+eUnNjZobIDdAbtRMQN4AMql5Qs0NkAnIjZpNQL7ppGrRSdWik6pF+CMvAHlCzSYgk5oJyKTmCSCTmk1AJjU3QG7U3ACZ1Gw6qVp0UrXopGrRJy+peQPIpGYCMqm5AXID5EbNJiCb1ExAJiCTmt90UrXopGrRSdUi/JEvAvKGmgnIG2omIJOaCciNmk1AJjV/yUnVopOqRSdViz55Ccik5kbNBGRSMwF5Qs0EZAIyqZmA/CYgk5ongExqJiCTmm86qVp0UrXopGrRJy+puVEzAbkBMqn5l6i5AfJNQCY1TwCZ1Gw6qVp0UrXopGrRJ8uATGqeUDMB+SYg36RmAnID5Akgk5ongExq3jipWnRSteikahH+yB8GZFJzA+RGzTcBuVHzBJAbNTdAJjVvnFQtOqladFK16JOXgPwmNTdAJjWTmgnIDZBJzW8CMqm5UfOEmk0nVYtOqhadVC36ZJmaTUC+Sc0E5AbIjZpNap4AMqmZgNyoeeOkatFJ1aKTqkWffBmQJ9Q8oeYGyKTmRs0NkBsgN2omIBOQTUBu1Gw6qVp0UrXopGrRJ38ckEnNpOYGyI2aGzUTkBsgN2qeADKpmYBMaiYgk5o3TqoWnVQtOqla9Mn/HJBJzaRmAnKjZgIyqZmAPAFkUnOjZgIyqflNJ1WLTqoWnVQt+uTL1HyTmgnIE0AmNTdAnlAzAXkDyI2aGyCTmk0nVYtOqhadVC36ZBmQ3wRkUjMBmYDcAJnUTGomIE+omYDcAJnUTED+JSdVi06qFp1ULcIfqVpyUrXopGrRSdWik6pFJ1WLTqoWnVQtOqladFK16KRq0UnVopOqRSdVi06qFp1ULfoPR6dSNcmK6OEAAAAASUVORK5CYII=	active	\N	f	2025-11-03 19:04:08.565-05	5dd53660-04ea-4393-b800-41e25420c647	d084c59d-8859-429b-b334-4761ead5da7e
0f318976-ad61-4d7f-8dd2-e6c38057ae9f	f9fdb613-2a98-4f78-977f-30c2a637fcc7	b1aa91d3-0b16-4991-b652-a1fb38075540	2025-11-03 19:05:38.815-05	data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAJQAAACUCAYAAAB1PADUAAAAAklEQVR4AewaftIAAATrSURBVO3BQQ4bwREEwcoB///ltI59GmCxTVqyKwL/SNWSk6pFJ1WLTqoWnVQtOqladFK16KRq0UnVopOqRSdVi06qFp1ULTqpWnRSteikatEnLwH5JTUTkEnNDZAn1ExAJjUTkEnNDZBJzQTkl9S8cVK16KRq0UnVok+WqdkE5JvUTEBu1DwBZJOaTUA2nVQtOqladFK16JMvA/KEmifU3ACZ1ExAJjVPALlRMwHZBOQJNd90UrXopGrRSdWiT/5xQCY1T6i5AXKjZgIyAZnU/C87qVp0UrXopGrRJ/84NROQGyA3am7UTEDeADKp+ZedVC06qVp0UrXoky9T80tqJiCTmgnIBGRSMwGZ1NwA+SY1f5OTqkUnVYtOqhZ9sgzILwGZ1LyhZgIyqZmATGq+Ccjf7KRq0UnVopOqRZ+8pOZvpmYC8oSaGzXfpOZfclK16KRq0UnVok9eAjKpmYDcqJmAPKHmBsiNmgnIpGYCMqm5UfMGkEnNDZBJzQTkRs0bJ1WLTqoWnVQtwj/yApAbNROQJ9RMQG7UPAHkCTU3QG7UTEBu1ExAJjU3QCY133RSteikatFJ1aJPlqmZgDyhZgJyo+YNNROQSc0NkCeAPAHkCSCTml86qVp0UrXopGrRJy+pmYA8oWYCMqmZgExAnlAzAZnU3ACZ1ExAJjUTkEnNDZBJzSYgk5o3TqoWnVQtOqla9MmPqZmATGomIP9NQCY1N2pu1NwA+SYgk5pNJ1WLTqoWnVQt+uTL1NyouVEzAXlCzY2aN4DcqJmATGreADKpmYD80knVopOqRSdViz5ZpuYGyKRmAnKj5puATGqeUHOjZpOaJ9RMQCY1b5xULTqpWnRSteiTl4BMat5QcwNkUnMD5EbNpGYCcqNmAnKjZgJyo2YC8oSaXzqpWnRSteikatEnL6mZgExqboA8oWYCcqNmAvKGmk1qJiATkEnNJjWbTqoWnVQtOqla9MmPqZmATGpugExqboBMar5JzQTkm4BMaiYgk5pvOqladFK16KRq0ScvAZnU3ACZ1NwAmdRMQCY1TwB5Asik5gkgk5obNROQGyCTml86qVp0UrXopGrRJy+p2QRkUvMEkEnNBOQNNROQSc2NmgnIpOZGzQRkUvMEkEnNGydVi06qFp1ULfpkGZBJzaTmRs0E5EbNBGQCMqm5AbJJzRNAvgnIN51ULTqpWnRSteiTZWo2qbkB8gaQSc0NkEnNDZAn1DwB5Ak1E5BNJ1WLTqoWnVQt+uQlIL+k5kbNE2pugNwAeULNBOQGyKTmCSCTmknNppOqRSdVi06qFn2yTM0mIG8AmdTcALlRcwNkUvOGmjfU/NJJ1aKTqkUnVYs++TIgT6h5Qs0E5AbIpGZScwNkUjOpuQFyA2QTkBs1m06qFp1ULTqpWvTJPw7IpOYGyATkRs2kZgJyo2ZSMwF5Qs0bar7ppGrRSdWik6pFn/yfUTMBuQHyhJon1ExAboA8oeYGyKTmjZOqRSdVi06qFn3yZWq+Sc0EZFIzAfkmIE+omdRMQCY1E5BJzQTkRs2mk6pFJ1WLTqoWfbIMyC8BeULNJiBPqLkBMqm5UTMBmdRMQL7ppGrRSdWik6pF+EeqlpxULTqpWnRSteikatFJ1aKTqkUnVYtOqhadVC06qVp0UrXopGrRSdWik6pFJ1WL/gOQMlkl155bAAAAAABJRU5ErkJggg==	active	\N	f	2025-11-03 19:05:38.815-05	6c787438-7e83-47e6-86a7-c04a051a9747	dde81c9d-5c54-4e97-b5f2-d801c8fcdb38
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.roles (id, name) FROM stdin;
1	organizer
2	attendee
3	vendor
4	admin
\.


--
-- Data for Name: session_speakers; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.session_speakers (session_id, speaker_id) FROM stdin;
a031f798-5f07-4418-bf8b-7c845bb1ae23	85e68fa6-e07f-45b2-9e9e-5bd104cb5754
69b77d6c-b221-4738-8c88-8765a9e6ee76	9d52cd2f-5bd2-4c91-8bc4-307a906c3dd9
ce71592f-7e08-4e1c-a865-e33b949c47f2	e2cce108-2a6f-4c5c-a64b-73f793cc5cf9
d7e2299f-c2e6-4403-92cd-da0a0d11fd55	318735a6-f1da-4d39-a842-1043b6b4bb25
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.sessions (id, event_id, title, description, start_time, end_time, venue_location, created_at, updated_at) FROM stdin;
a031f798-5f07-4418-bf8b-7c845bb1ae23	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	Main Act- DJ Spoof		2025-11-02 21:15:00-05	2025-11-02 23:00:00-05		2025-11-02 07:47:09.035-05	2025-11-02 07:47:09.035-05
8c9d4229-5191-4ab2-a833-4456338c22b0	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	Intermission		2025-11-29 20:45:00-05	2025-11-29 21:15:00-05		2025-11-02 07:52:37.941-05	2025-11-02 07:52:37.941-05
69b77d6c-b221-4738-8c88-8765a9e6ee76	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Investing 101	Learn how to invest easy.	2025-11-06 16:00:00-05	2025-11-06 17:00:00-05		2025-11-02 10:24:23.953-05	2025-11-02 10:24:23.953-05
10118fd3-7f08-4063-8f6b-551c8c400379	b9182aa0-2787-45d2-975e-fcacdbea710a	Preliminaries	all teams compete	2025-11-11 10:00:00-05	2025-11-17 17:00:00-05	Basketball Annex	2025-11-02 07:26:27.716-05	2025-11-02 11:18:37.652-05
ce71592f-7e08-4e1c-a865-e33b949c47f2	b2378821-52dc-4dac-abc7-e0b7921732a2	Workshop		2025-11-08 19:00:00-05	2025-11-08 20:00:00-05		2025-11-02 12:36:25.038-05	2025-11-02 12:36:25.038-05
40672fb2-fd91-447d-91de-f2fa25417f72	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	Opening Act - Thomas the Kid	Thomas the Kid opens the show	2025-11-29 20:00:00-05	2025-11-29 20:30:00-05		2025-11-02 07:45:12.955-05	2025-11-02 23:13:11.408-05
d7e2299f-c2e6-4403-92cd-da0a0d11fd55	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Intro to Crypto	After this you won't be as scared of it anymore!	2025-11-26 16:30:00-05	2025-11-26 17:00:00-05		2025-11-03 00:02:53.995-05	2025-11-03 00:02:53.995-05
c3ad97f8-9384-48c7-b2d6-97f1e4aca5f5	3a59f760-22e4-4242-b623-6038e8126b89	Irish Pub		2025-11-23 17:16:00-05	2025-11-23 18:16:00-05	Irish Pub	2025-11-03 17:17:08.281-05	2025-11-03 17:17:08.281-05
\.


--
-- Data for Name: speakers; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.speakers (id, user_id, name, contact_email, bio, image_url, created_at, updated_at) FROM stdin;
85e68fa6-e07f-45b2-9e9e-5bd104cb5754	89ecf34a-94c2-4b81-9b3c-692d0a5b5f97	DJ Spoof	djspoof@gmail.com	One of the biggest DJ's in town	\N	2025-11-02 09:48:18.108-05	2025-11-02 09:48:18.108-05
9d52cd2f-5bd2-4c91-8bc4-307a906c3dd9	15e01e43-28be-4c22-9d67-2cdf80bb6788	Nicole Parker	nparker@gmail.com	Worked on Wall St for 10+ years	\N	2025-11-02 10:25:12.7-05	2025-11-02 10:25:12.7-05
0364b87e-d94d-4fed-b0a4-f01da07c82b3	15e01e43-28be-4c22-9d67-2cdf80bb6788	Denise Simmons	dsimmons@gmail.com		\N	2025-11-02 12:15:21.265-05	2025-11-02 12:21:02.813-05
e2cce108-2a6f-4c5c-a64b-73f793cc5cf9	e85bf48f-e1a9-40b9-9718-2808b1218c6b	Phyllis Tran			\N	2025-11-02 12:37:16.407-05	2025-11-02 12:37:16.407-05
e10cd761-d004-4e26-8048-39bec348f70f	e85bf48f-e1a9-40b9-9718-2808b1218c6b	Hailey Williams			\N	2025-11-03 00:48:01.742-05	2025-11-03 00:48:01.742-05
6011a779-abb9-4826-974c-fadd94f15cef	e85bf48f-e1a9-40b9-9718-2808b1218c6b	Brittney Gilmore			\N	2025-11-03 01:03:27.181-05	2025-11-03 01:03:27.181-05
318735a6-f1da-4d39-a842-1043b6b4bb25	15e01e43-28be-4c22-9d67-2cdf80bb6788	Hailey Williams			\N	2025-11-03 04:32:26.691-05	2025-11-03 04:32:26.691-05
ae67f391-55ad-41dc-aede-2ec023afce02	e85bf48f-e1a9-40b9-9718-2808b1218c6b	Penny		Sanchez	\N	2025-11-03 17:13:42.167-05	2025-11-03 17:13:42.167-05
\.


--
-- Data for Name: ticket_types; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.ticket_types (id, event_id, name, price, quantity, sale_start, sale_end, created_at, updated_at) FROM stdin;
7a7a4137-b4e5-4466-aa6a-b1d4531af860	d084c59d-8859-429b-b334-4761ead5da7e	General	10.00	30	\N	\N	2025-11-01 03:36:09.573-04	2025-11-01 03:36:09.573-04
d109e59f-3768-45f4-92a0-eff77f152528	d084c59d-8859-429b-b334-4761ead5da7e	General + Free Drink	15.00	10	\N	\N	2025-11-01 03:37:45.541-04	2025-11-01 03:37:45.541-04
1ee9b44a-99dc-49b4-a921-bbf6efc384c9	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	General Admission	50.00	60	2025-11-24 06:01:00-05	2025-11-29 17:00:00-05	2025-11-01 03:49:40.487-04	2025-11-01 03:49:40.487-04
6a3a2faa-7a52-4d0c-907d-c7005d5bb0d7	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	Barricade Pass	80.00	30	2025-11-24 06:01:00-05	2025-11-29 17:00:00-05	2025-11-01 03:50:38.649-04	2025-11-01 03:50:38.649-04
f94e0364-04d5-4182-b2cd-44faab428186	6e079c02-73bc-4f65-bc1b-e3e4c9c76a26	VIP - Backstage	125.00	10	2025-11-24 06:01:00-05	2025-11-29 17:00:00-05	2025-11-01 03:51:13.31-04	2025-11-01 03:51:13.31-04
01f89cab-723d-49e1-9df6-7fd293d9de2f	d97cd96d-9431-440a-97a8-fb63f0b46f32	General	15.00	40	2025-11-09 00:00:00-05	2025-11-22 23:59:00-05	2025-11-02 00:26:45.805-04	2025-11-02 00:26:45.805-04
40ae5b2d-08c5-4566-8f61-dab0437795c7	b9182aa0-2787-45d2-975e-fcacdbea710a	General	5.00	45	\N	\N	2025-11-02 03:22:52.913-05	2025-11-02 03:22:52.913-05
30f05e57-6116-4112-b19c-cdfd7755cefd	dde81c9d-5c54-4e97-b5f2-d801c8fcdb38	Participant	0.00	500	\N	\N	2025-11-02 03:39:15.395-05	2025-11-02 03:39:15.395-05
b1aa91d3-0b16-4991-b652-a1fb38075540	dde81c9d-5c54-4e97-b5f2-d801c8fcdb38	Audience	30.00	1500	2025-11-03 00:00:00-05	2025-11-07 23:59:00-05	2025-11-02 03:41:12.361-05	2025-11-02 04:01:54.464-05
58f8e729-dc27-449e-a05c-a4679fa8ed88	b2378821-52dc-4dac-abc7-e0b7921732a2	General	50.00	40	\N	\N	2025-11-02 12:33:52.49-05	2025-11-02 12:33:52.49-05
0b5a42dd-a84f-4b50-aaea-1f11f956a6c8	0fca0eb4-44ca-443e-a0d0-8f3ddf2994cf	Regular	7.00	40	2025-11-03 21:58:00-05	2025-11-04 21:58:00-05	2025-11-02 04:52:25.999-05	2025-11-02 21:58:30.906-05
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.users (id, role_id, f_name, l_name, phone, email, password, is_active, created_at, updated_at, fcm_token) FROM stdin;
15e01e43-28be-4c22-9d67-2cdf80bb6788	1	Jane	Doe	787-094-3839	jdoe@gmail.com	$2b$10$oDRw0Dkd405B/GP4p4fiwOR2LlMJ9C49JoLWKkUAnem3IUZYMUj.e	t	2025-10-31 00:38:12.815-04	2025-10-31 00:38:12.815-04	\N
d79154c7-f0fb-4784-8dbd-89ea3d96ea47	1	Taylor	Smith	546-977-4574	tsmith@gmail.com	$2b$10$lFcXUk7JOiNIsS4S9vZ6Kec0kfZ58bXladYQcmHqlXI6VU8yzgsDW	t	2025-10-31 00:44:53.887-04	2025-10-31 00:44:53.887-04	\N
e85bf48f-e1a9-40b9-9718-2808b1218c6b	4	Darth	Vader	980-343-5443	dvader@gmail.com	$2b$10$Bnjy7ze82RmyUusub4LvO.eqkbIr7QBuVt9qDJrTZm5c22AD0DBUy	t	2025-10-31 02:00:20.468-04	2025-10-31 02:00:20.468-04	\N
cf4eafd8-6793-4b67-8bfc-53eeee12fe82	3	Vanessa	Wall	875-353-6685	vwall@gmail.com	$2b$10$kBql4duQL5Rejm1yMPtgSOey9lssdZPp11Q.gaInKUQdg0HdtW0cW	t	2025-10-31 02:01:51.94-04	2025-10-31 02:01:51.94-04	\N
89ecf34a-94c2-4b81-9b3c-692d0a5b5f97	1	Laura	Jones	874-243-2352	ljones@gmail.com	$2b$10$A.GLdRJmDeDVIx.gw60KO.SU1pSDxeot7MLH6pGUxfPZw4AW46Fvu	t	2025-11-01 01:30:17.619-04	2025-11-01 01:30:17.619-04	\N
9cb26016-6907-4cd4-a447-32665bf196f8	2	Serena	Martin	353-864-2353	niaspamacc@gmail.com	$2b$10$Uos1exfYDE9ZTsFoUIlSMuVeecu3PG20.0HuztKWl2jCc4LnpvFkW	t	2025-10-31 00:52:02.029-04	2025-10-31 00:52:02.029-04	\N
31125a59-e4c9-419d-8f87-aa4e1af1c524	2	Prince	Andre	890-435-2314	koisblog@gmail.com	$2b$10$TZeAL5pNxabzbhcaWEfrWusyuVoCIAn7LKtsVE4ABpc3YIoxQGE6S	t	2025-11-02 21:23:18.04-05	2025-11-02 21:23:18.04-05	\N
f9fdb613-2a98-4f78-977f-30c2a637fcc7	2	Philip	Rose	973-554-1314	prose@gmail.com	$2b$10$bdTzKUiTcGnwZFc7cMBxgu0pXdn0fk2svmpAeYFpqMNZ/m2.nSDJi	t	2025-11-03 18:58:59.514-05	2025-11-03 18:58:59.514-05	\N
\.


--
-- Data for Name: vendors; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.vendors (id, user_id, company_name, contact_email, phone, created_at, updated_at) FROM stdin;
8873f857-2d97-4c4e-9863-b797d23f8da7	15e01e43-28be-4c22-9d67-2cdf80bb6788	Dance Dance Revolution	\N	234-453-123	2025-11-02 17:29:45.87-05	2025-11-02 17:29:45.87-05
c7e3d57b-4899-4d7d-9966-71d9af7e1da2	cf4eafd8-6793-4b67-8bfc-53eeee12fe82	Pine Woods & Co. Realty	pwrealty@gmail.com	897-544-7954	2025-11-02 18:24:39.884354-05	2025-11-02 19:29:37.93-05
\.


--
-- Data for Name: venues; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.venues (id, name, address, city, state, country, zip_code, capacity, created_at, updated_at) FROM stdin;
460e8efc-be39-4471-a5f2-b2192a5cc370	Virtual	virtual					\N	2025-10-31 07:59:05.556-04	2025-10-31 07:59:05.556-04
266d532a-0179-49e9-9b9e-ad078634a6e9	Honda Stadium	5 Murphy Dr	Dallas	TX	USA	73564	50000	2025-10-31 09:24:50.906-04	2025-10-31 09:24:50.906-04
decff87d-d03a-49d7-9d1b-3a7053794a48	Imagine Center	4509 Ballantine Ct	Islip	NY	USA	60987	\N	2025-11-01 00:19:39.682-04	2025-11-01 00:19:39.682-04
c5f9f486-a392-43c0-a302-9167bc0f4cbd	Kissaten Cafe	3 Coffee Dr	Vancouver		CA		60	2025-11-01 01:56:18.14-04	2025-11-01 01:56:18.14-04
87035111-d861-42aa-a218-a8a4b89f413f	Frank's Ankle	59 Rodilla St	Los Angeles	CA	USA	87986	50	2025-11-01 03:22:35.244-04	2025-11-01 03:22:35.244-04
f1a7d842-e153-4a38-924f-0318366af18a	Oak School	3 Oak Rd	Pineville	GA	USA	45632	500	2025-10-31 07:33:22.336-04	2025-11-02 04:48:03.877-05
a07a84c5-f4dd-41a8-a142-cbc22d1d1c7b	Morrisette Garden	90 Flower Ct	Medina	OH	USA	48935	500	2025-11-01 00:35:27.828-04	2025-11-02 21:56:58.286-05
b0de8cac-0665-401e-bbe7-c4655d32c5a6	Midnight Tax	80 Twilight Ln					125	2025-11-01 03:47:24.78-04	2025-11-03 01:27:23.72-05
\.


--
-- Data for Name: waitlists; Type: TABLE DATA; Schema: public; Owner: nwmac
--

COPY public.waitlists (id, event_id, user_id, status, requested_at, updated_at) FROM stdin;
\.


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: nwmac
--

SELECT pg_catalog.setval('public.roles_id_seq', 4, true);


--
-- Name: event_metrics event_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.event_metrics
    ADD CONSTRAINT event_metrics_pkey PRIMARY KEY (id);


--
-- Name: event_vendors event_vendors_event_id_vendor_id_key; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.event_vendors
    ADD CONSTRAINT event_vendors_event_id_vendor_id_key UNIQUE (event_id, vendor_id);


--
-- Name: event_vendors event_vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.event_vendors
    ADD CONSTRAINT event_vendors_pkey PRIMARY KEY (id);


--
-- Name: waitlists event_waitlist_event_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.waitlists
    ADD CONSTRAINT event_waitlist_event_id_user_id_key UNIQUE (event_id, user_id);


--
-- Name: waitlists event_waitlist_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.waitlists
    ADD CONSTRAINT event_waitlist_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: feedback feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: registrations registrations_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_pkey PRIMARY KEY (id);


--
-- Name: registrations registrations_qr_code_key; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key1; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key1 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key10; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key10 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key100; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key100 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key101; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key101 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key102; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key102 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key103; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key103 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key104; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key104 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key105; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key105 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key106; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key106 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key107; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key107 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key108; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key108 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key109; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key109 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key11; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key11 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key110; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key110 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key111; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key111 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key112; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key112 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key113; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key113 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key114; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key114 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key115; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key115 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key116; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key116 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key117; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key117 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key118; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key118 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key119; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key119 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key12; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key12 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key120; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key120 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key121; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key121 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key122; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key122 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key123; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key123 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key124; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key124 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key125; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key125 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key126; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key126 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key127; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key127 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key128; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key128 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key129; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key129 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key13; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key13 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key130; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key130 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key131; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key131 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key132; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key132 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key133; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key133 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key134; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key134 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key135; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key135 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key136; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key136 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key137; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key137 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key138; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key138 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key139; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key139 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key14; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key14 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key140; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key140 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key141; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key141 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key142; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key142 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key143; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key143 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key144; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key144 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key145; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key145 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key146; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key146 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key147; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key147 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key148; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key148 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key149; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key149 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key15; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key15 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key150; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key150 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key151; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key151 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key152; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key152 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key153; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key153 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key154; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key154 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key155; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key155 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key156; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key156 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key157; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key157 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key158; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key158 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key159; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key159 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key16; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key16 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key160; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key160 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key161; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key161 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key162; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key162 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key163; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key163 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key164; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key164 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key165; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key165 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key166; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key166 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key167; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key167 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key168; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key168 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key169; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key169 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key17; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key17 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key170; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key170 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key171; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key171 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key172; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key172 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key173; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key173 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key174; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key174 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key175; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key175 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key176; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key176 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key177; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key177 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key178; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key178 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key179; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key179 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key18; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key18 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key180; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key180 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key181; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key181 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key182; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key182 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key183; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key183 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key184; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key184 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key185; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key185 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key186; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key186 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key187; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key187 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key188; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key188 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key189; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key189 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key19; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key19 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key190; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key190 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key191; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key191 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key192; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key192 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key193; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key193 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key194; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key194 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key195; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key195 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key196; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key196 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key197; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key197 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key198; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key198 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key199; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key199 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key2; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key2 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key20; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key20 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key200; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key200 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key201; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key201 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key202; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key202 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key203; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key203 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key204; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key204 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key205; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key205 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key206; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key206 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key207; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key207 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key208; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key208 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key209; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key209 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key21; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key21 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key210; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key210 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key211; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key211 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key212; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key212 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key213; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key213 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key214; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key214 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key215; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key215 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key216; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key216 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key217; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key217 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key218; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key218 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key219; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key219 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key22; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key22 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key220; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key220 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key221; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key221 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key222; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key222 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key223; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key223 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key224; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key224 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key225; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key225 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key226; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key226 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key227; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key227 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key228; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key228 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key229; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key229 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key23; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key23 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key230; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key230 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key231; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key231 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key232; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key232 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key233; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key233 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key234; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key234 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key235; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key235 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key236; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key236 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key237; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key237 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key238; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key238 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key239; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key239 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key24; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key24 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key240; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key240 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key241; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key241 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key242; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key242 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key243; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key243 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key244; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key244 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key245; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key245 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key246; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key246 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key247; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key247 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key248; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key248 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key249; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key249 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key25; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key25 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key250; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key250 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key251; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key251 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key252; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key252 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key253; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key253 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key254; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key254 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key255; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key255 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key256; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key256 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key257; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key257 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key258; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key258 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key259; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key259 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key26; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key26 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key260; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key260 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key261; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key261 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key262; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key262 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key263; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key263 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key264; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key264 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key265; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key265 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key266; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key266 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key267; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key267 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key268; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key268 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key269; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key269 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key27; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key27 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key270; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key270 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key271; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key271 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key272; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key272 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key273; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key273 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key274; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key274 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key275; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key275 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key276; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key276 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key277; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key277 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key278; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key278 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key279; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key279 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key28; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key28 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key280; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key280 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key281; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key281 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key282; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key282 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key283; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key283 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key284; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key284 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key285; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key285 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key286; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key286 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key287; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key287 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key288; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key288 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key289; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key289 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key29; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key29 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key290; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key290 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key291; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key291 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key292; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key292 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key293; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key293 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key294; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key294 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key295; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key295 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key296; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key296 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key297; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key297 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key298; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key298 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key299; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key299 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key3; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key3 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key30; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key30 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key300; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key300 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key301; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key301 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key302; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key302 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key303; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key303 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key304; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key304 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key305; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key305 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key306; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key306 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key307; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key307 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key308; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key308 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key309; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key309 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key31; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key31 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key310; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key310 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key311; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key311 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key312; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key312 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key313; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key313 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key314; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key314 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key315; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key315 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key316; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key316 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key317; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key317 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key318; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key318 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key319; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key319 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key32; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key32 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key320; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key320 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key321; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key321 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key322; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key322 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key323; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key323 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key324; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key324 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key325; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key325 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key326; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key326 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key327; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key327 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key328; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key328 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key329; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key329 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key33; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key33 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key330; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key330 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key331; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key331 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key332; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key332 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key333; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key333 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key334; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key334 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key335; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key335 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key336; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key336 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key337; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key337 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key338; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key338 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key339; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key339 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key34; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key34 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key340; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key340 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key341; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key341 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key342; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key342 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key343; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key343 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key344; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key344 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key345; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key345 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key346; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key346 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key347; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key347 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key348; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key348 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key349; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key349 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key35; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key35 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key350; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key350 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key351; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key351 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key352; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key352 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key353; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key353 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key354; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key354 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key355; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key355 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key356; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key356 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key357; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key357 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key358; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key358 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key359; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key359 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key36; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key36 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key360; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key360 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key361; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key361 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key362; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key362 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key363; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key363 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key364; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key364 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key365; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key365 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key366; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key366 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key367; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key367 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key368; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key368 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key369; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key369 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key37; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key37 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key370; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key370 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key371; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key371 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key372; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key372 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key373; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key373 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key374; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key374 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key375; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key375 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key376; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key376 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key377; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key377 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key378; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key378 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key379; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key379 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key38; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key38 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key380; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key380 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key381; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key381 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key382; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key382 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key39; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key39 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key4; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key4 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key40; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key40 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key41; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key41 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key42; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key42 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key43; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key43 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key44; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key44 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key45; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key45 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key46; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key46 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key47; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key47 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key48; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key48 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key49; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key49 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key5; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key5 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key50; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key50 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key51; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key51 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key52; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key52 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key53; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key53 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key54; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key54 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key55; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key55 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key56; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key56 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key57; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key57 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key58; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key58 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key59; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key59 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key6; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key6 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key60; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key60 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key61; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key61 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key62; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key62 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key63; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key63 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key64; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key64 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key65; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key65 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key66; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key66 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key67; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key67 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key68; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key68 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key69; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key69 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key7; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key7 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key70; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key70 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key71; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key71 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key72; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key72 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key73; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key73 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key74; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key74 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key75; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key75 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key76; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key76 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key77; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key77 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key78; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key78 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key79; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key79 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key8; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key8 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key80; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key80 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key81; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key81 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key82; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key82 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key83; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key83 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key84; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key84 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key85; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key85 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key86; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key86 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key87; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key87 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key88; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key88 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key89; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key89 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key9; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key9 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key90; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key90 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key91; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key91 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key92; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key92 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key93; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key93 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key94; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key94 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key95; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key95 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key96; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key96 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key97; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key97 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key98; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key98 UNIQUE (qr_code);


--
-- Name: registrations registrations_qr_code_key99; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_qr_code_key99 UNIQUE (qr_code);


--
-- Name: registrations registrations_registration_code_key; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key1; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key1 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key10; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key10 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key100; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key100 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key101; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key101 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key102; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key102 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key103; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key103 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key104; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key104 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key105; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key105 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key106; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key106 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key107; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key107 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key108; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key108 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key109; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key109 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key11; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key11 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key110; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key110 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key111; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key111 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key112; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key112 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key113; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key113 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key114; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key114 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key115; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key115 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key116; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key116 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key117; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key117 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key118; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key118 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key119; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key119 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key12; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key12 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key120; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key120 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key121; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key121 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key122; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key122 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key123; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key123 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key124; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key124 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key125; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key125 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key126; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key126 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key127; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key127 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key128; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key128 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key129; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key129 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key13; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key13 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key130; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key130 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key131; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key131 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key132; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key132 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key133; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key133 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key134; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key134 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key135; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key135 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key136; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key136 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key137; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key137 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key138; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key138 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key139; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key139 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key14; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key14 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key140; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key140 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key141; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key141 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key142; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key142 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key143; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key143 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key144; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key144 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key145; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key145 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key146; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key146 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key147; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key147 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key148; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key148 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key149; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key149 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key15; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key15 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key150; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key150 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key151; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key151 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key152; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key152 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key153; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key153 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key154; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key154 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key155; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key155 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key156; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key156 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key157; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key157 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key158; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key158 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key159; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key159 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key16; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key16 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key160; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key160 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key161; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key161 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key162; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key162 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key163; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key163 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key164; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key164 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key165; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key165 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key166; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key166 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key167; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key167 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key168; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key168 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key169; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key169 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key17; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key17 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key170; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key170 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key171; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key171 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key172; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key172 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key173; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key173 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key174; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key174 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key175; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key175 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key176; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key176 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key177; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key177 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key178; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key178 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key179; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key179 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key18; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key18 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key180; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key180 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key181; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key181 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key182; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key182 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key183; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key183 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key184; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key184 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key185; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key185 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key186; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key186 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key187; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key187 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key188; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key188 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key189; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key189 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key19; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key19 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key190; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key190 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key191; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key191 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key192; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key192 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key193; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key193 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key194; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key194 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key195; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key195 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key196; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key196 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key197; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key197 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key198; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key198 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key199; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key199 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key2; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key2 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key20; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key20 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key200; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key200 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key201; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key201 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key202; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key202 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key203; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key203 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key204; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key204 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key205; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key205 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key206; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key206 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key207; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key207 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key208; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key208 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key209; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key209 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key21; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key21 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key210; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key210 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key211; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key211 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key212; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key212 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key213; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key213 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key214; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key214 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key215; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key215 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key216; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key216 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key217; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key217 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key218; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key218 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key219; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key219 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key22; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key22 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key220; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key220 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key221; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key221 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key222; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key222 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key223; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key223 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key224; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key224 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key225; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key225 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key226; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key226 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key227; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key227 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key228; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key228 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key229; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key229 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key23; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key23 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key230; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key230 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key231; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key231 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key232; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key232 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key233; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key233 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key234; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key234 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key235; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key235 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key236; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key236 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key237; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key237 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key238; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key238 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key239; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key239 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key24; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key24 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key240; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key240 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key241; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key241 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key242; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key242 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key243; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key243 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key244; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key244 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key245; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key245 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key246; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key246 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key247; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key247 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key248; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key248 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key249; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key249 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key25; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key25 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key250; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key250 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key251; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key251 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key252; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key252 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key253; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key253 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key254; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key254 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key255; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key255 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key256; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key256 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key257; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key257 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key258; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key258 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key259; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key259 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key26; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key26 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key260; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key260 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key261; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key261 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key27; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key27 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key28; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key28 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key29; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key29 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key3; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key3 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key30; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key30 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key31; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key31 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key32; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key32 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key33; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key33 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key34; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key34 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key35; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key35 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key36; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key36 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key37; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key37 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key38; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key38 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key39; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key39 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key4; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key4 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key40; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key40 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key41; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key41 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key42; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key42 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key43; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key43 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key44; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key44 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key45; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key45 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key46; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key46 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key47; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key47 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key48; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key48 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key49; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key49 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key5; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key5 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key50; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key50 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key51; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key51 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key52; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key52 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key53; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key53 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key54; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key54 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key55; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key55 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key56; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key56 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key57; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key57 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key58; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key58 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key59; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key59 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key6; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key6 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key60; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key60 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key61; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key61 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key62; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key62 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key63; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key63 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key64; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key64 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key65; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key65 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key66; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key66 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key67; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key67 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key68; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key68 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key69; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key69 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key7; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key7 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key70; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key70 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key71; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key71 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key72; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key72 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key73; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key73 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key74; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key74 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key75; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key75 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key76; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key76 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key77; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key77 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key78; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key78 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key79; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key79 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key8; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key8 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key80; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key80 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key81; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key81 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key82; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key82 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key83; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key83 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key84; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key84 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key85; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key85 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key86; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key86 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key87; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key87 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key88; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key88 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key89; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key89 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key9; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key9 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key90; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key90 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key91; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key91 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key92; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key92 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key93; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key93 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key94; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key94 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key95; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key95 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key96; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key96 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key97; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key97 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key98; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key98 UNIQUE (registration_code);


--
-- Name: registrations registrations_registration_code_key99; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_registration_code_key99 UNIQUE (registration_code);


--
-- Name: roles roles_name_key; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);


--
-- Name: roles roles_name_key1; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key1 UNIQUE (name);


--
-- Name: roles roles_name_key10; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key10 UNIQUE (name);


--
-- Name: roles roles_name_key100; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key100 UNIQUE (name);


--
-- Name: roles roles_name_key101; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key101 UNIQUE (name);


--
-- Name: roles roles_name_key102; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key102 UNIQUE (name);


--
-- Name: roles roles_name_key103; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key103 UNIQUE (name);


--
-- Name: roles roles_name_key104; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key104 UNIQUE (name);


--
-- Name: roles roles_name_key105; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key105 UNIQUE (name);


--
-- Name: roles roles_name_key106; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key106 UNIQUE (name);


--
-- Name: roles roles_name_key107; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key107 UNIQUE (name);


--
-- Name: roles roles_name_key108; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key108 UNIQUE (name);


--
-- Name: roles roles_name_key109; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key109 UNIQUE (name);


--
-- Name: roles roles_name_key11; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key11 UNIQUE (name);


--
-- Name: roles roles_name_key110; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key110 UNIQUE (name);


--
-- Name: roles roles_name_key111; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key111 UNIQUE (name);


--
-- Name: roles roles_name_key112; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key112 UNIQUE (name);


--
-- Name: roles roles_name_key113; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key113 UNIQUE (name);


--
-- Name: roles roles_name_key114; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key114 UNIQUE (name);


--
-- Name: roles roles_name_key115; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key115 UNIQUE (name);


--
-- Name: roles roles_name_key116; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key116 UNIQUE (name);


--
-- Name: roles roles_name_key117; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key117 UNIQUE (name);


--
-- Name: roles roles_name_key118; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key118 UNIQUE (name);


--
-- Name: roles roles_name_key119; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key119 UNIQUE (name);


--
-- Name: roles roles_name_key12; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key12 UNIQUE (name);


--
-- Name: roles roles_name_key120; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key120 UNIQUE (name);


--
-- Name: roles roles_name_key121; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key121 UNIQUE (name);


--
-- Name: roles roles_name_key122; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key122 UNIQUE (name);


--
-- Name: roles roles_name_key123; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key123 UNIQUE (name);


--
-- Name: roles roles_name_key124; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key124 UNIQUE (name);


--
-- Name: roles roles_name_key125; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key125 UNIQUE (name);


--
-- Name: roles roles_name_key126; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key126 UNIQUE (name);


--
-- Name: roles roles_name_key127; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key127 UNIQUE (name);


--
-- Name: roles roles_name_key128; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key128 UNIQUE (name);


--
-- Name: roles roles_name_key129; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key129 UNIQUE (name);


--
-- Name: roles roles_name_key13; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key13 UNIQUE (name);


--
-- Name: roles roles_name_key130; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key130 UNIQUE (name);


--
-- Name: roles roles_name_key131; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key131 UNIQUE (name);


--
-- Name: roles roles_name_key132; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key132 UNIQUE (name);


--
-- Name: roles roles_name_key133; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key133 UNIQUE (name);


--
-- Name: roles roles_name_key134; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key134 UNIQUE (name);


--
-- Name: roles roles_name_key135; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key135 UNIQUE (name);


--
-- Name: roles roles_name_key136; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key136 UNIQUE (name);


--
-- Name: roles roles_name_key137; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key137 UNIQUE (name);


--
-- Name: roles roles_name_key138; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key138 UNIQUE (name);


--
-- Name: roles roles_name_key139; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key139 UNIQUE (name);


--
-- Name: roles roles_name_key14; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key14 UNIQUE (name);


--
-- Name: roles roles_name_key140; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key140 UNIQUE (name);


--
-- Name: roles roles_name_key141; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key141 UNIQUE (name);


--
-- Name: roles roles_name_key142; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key142 UNIQUE (name);


--
-- Name: roles roles_name_key143; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key143 UNIQUE (name);


--
-- Name: roles roles_name_key144; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key144 UNIQUE (name);


--
-- Name: roles roles_name_key145; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key145 UNIQUE (name);


--
-- Name: roles roles_name_key146; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key146 UNIQUE (name);


--
-- Name: roles roles_name_key147; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key147 UNIQUE (name);


--
-- Name: roles roles_name_key148; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key148 UNIQUE (name);


--
-- Name: roles roles_name_key149; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key149 UNIQUE (name);


--
-- Name: roles roles_name_key15; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key15 UNIQUE (name);


--
-- Name: roles roles_name_key150; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key150 UNIQUE (name);


--
-- Name: roles roles_name_key151; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key151 UNIQUE (name);


--
-- Name: roles roles_name_key152; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key152 UNIQUE (name);


--
-- Name: roles roles_name_key153; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key153 UNIQUE (name);


--
-- Name: roles roles_name_key154; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key154 UNIQUE (name);


--
-- Name: roles roles_name_key155; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key155 UNIQUE (name);


--
-- Name: roles roles_name_key156; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key156 UNIQUE (name);


--
-- Name: roles roles_name_key157; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key157 UNIQUE (name);


--
-- Name: roles roles_name_key158; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key158 UNIQUE (name);


--
-- Name: roles roles_name_key159; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key159 UNIQUE (name);


--
-- Name: roles roles_name_key16; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key16 UNIQUE (name);


--
-- Name: roles roles_name_key160; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key160 UNIQUE (name);


--
-- Name: roles roles_name_key161; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key161 UNIQUE (name);


--
-- Name: roles roles_name_key162; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key162 UNIQUE (name);


--
-- Name: roles roles_name_key163; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key163 UNIQUE (name);


--
-- Name: roles roles_name_key164; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key164 UNIQUE (name);


--
-- Name: roles roles_name_key165; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key165 UNIQUE (name);


--
-- Name: roles roles_name_key166; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key166 UNIQUE (name);


--
-- Name: roles roles_name_key167; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key167 UNIQUE (name);


--
-- Name: roles roles_name_key168; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key168 UNIQUE (name);


--
-- Name: roles roles_name_key169; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key169 UNIQUE (name);


--
-- Name: roles roles_name_key17; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key17 UNIQUE (name);


--
-- Name: roles roles_name_key170; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key170 UNIQUE (name);


--
-- Name: roles roles_name_key171; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key171 UNIQUE (name);


--
-- Name: roles roles_name_key172; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key172 UNIQUE (name);


--
-- Name: roles roles_name_key173; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key173 UNIQUE (name);


--
-- Name: roles roles_name_key174; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key174 UNIQUE (name);


--
-- Name: roles roles_name_key175; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key175 UNIQUE (name);


--
-- Name: roles roles_name_key176; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key176 UNIQUE (name);


--
-- Name: roles roles_name_key177; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key177 UNIQUE (name);


--
-- Name: roles roles_name_key178; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key178 UNIQUE (name);


--
-- Name: roles roles_name_key179; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key179 UNIQUE (name);


--
-- Name: roles roles_name_key18; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key18 UNIQUE (name);


--
-- Name: roles roles_name_key180; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key180 UNIQUE (name);


--
-- Name: roles roles_name_key181; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key181 UNIQUE (name);


--
-- Name: roles roles_name_key182; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key182 UNIQUE (name);


--
-- Name: roles roles_name_key183; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key183 UNIQUE (name);


--
-- Name: roles roles_name_key184; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key184 UNIQUE (name);


--
-- Name: roles roles_name_key185; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key185 UNIQUE (name);


--
-- Name: roles roles_name_key186; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key186 UNIQUE (name);


--
-- Name: roles roles_name_key187; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key187 UNIQUE (name);


--
-- Name: roles roles_name_key188; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key188 UNIQUE (name);


--
-- Name: roles roles_name_key189; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key189 UNIQUE (name);


--
-- Name: roles roles_name_key19; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key19 UNIQUE (name);


--
-- Name: roles roles_name_key190; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key190 UNIQUE (name);


--
-- Name: roles roles_name_key191; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key191 UNIQUE (name);


--
-- Name: roles roles_name_key192; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key192 UNIQUE (name);


--
-- Name: roles roles_name_key193; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key193 UNIQUE (name);


--
-- Name: roles roles_name_key194; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key194 UNIQUE (name);


--
-- Name: roles roles_name_key195; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key195 UNIQUE (name);


--
-- Name: roles roles_name_key196; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key196 UNIQUE (name);


--
-- Name: roles roles_name_key197; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key197 UNIQUE (name);


--
-- Name: roles roles_name_key198; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key198 UNIQUE (name);


--
-- Name: roles roles_name_key199; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key199 UNIQUE (name);


--
-- Name: roles roles_name_key2; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key2 UNIQUE (name);


--
-- Name: roles roles_name_key20; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key20 UNIQUE (name);


--
-- Name: roles roles_name_key200; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key200 UNIQUE (name);


--
-- Name: roles roles_name_key201; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key201 UNIQUE (name);


--
-- Name: roles roles_name_key202; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key202 UNIQUE (name);


--
-- Name: roles roles_name_key203; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key203 UNIQUE (name);


--
-- Name: roles roles_name_key204; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key204 UNIQUE (name);


--
-- Name: roles roles_name_key205; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key205 UNIQUE (name);


--
-- Name: roles roles_name_key206; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key206 UNIQUE (name);


--
-- Name: roles roles_name_key207; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key207 UNIQUE (name);


--
-- Name: roles roles_name_key208; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key208 UNIQUE (name);


--
-- Name: roles roles_name_key209; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key209 UNIQUE (name);


--
-- Name: roles roles_name_key21; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key21 UNIQUE (name);


--
-- Name: roles roles_name_key210; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key210 UNIQUE (name);


--
-- Name: roles roles_name_key211; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key211 UNIQUE (name);


--
-- Name: roles roles_name_key212; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key212 UNIQUE (name);


--
-- Name: roles roles_name_key213; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key213 UNIQUE (name);


--
-- Name: roles roles_name_key214; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key214 UNIQUE (name);


--
-- Name: roles roles_name_key215; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key215 UNIQUE (name);


--
-- Name: roles roles_name_key216; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key216 UNIQUE (name);


--
-- Name: roles roles_name_key217; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key217 UNIQUE (name);


--
-- Name: roles roles_name_key218; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key218 UNIQUE (name);


--
-- Name: roles roles_name_key219; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key219 UNIQUE (name);


--
-- Name: roles roles_name_key22; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key22 UNIQUE (name);


--
-- Name: roles roles_name_key220; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key220 UNIQUE (name);


--
-- Name: roles roles_name_key221; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key221 UNIQUE (name);


--
-- Name: roles roles_name_key222; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key222 UNIQUE (name);


--
-- Name: roles roles_name_key223; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key223 UNIQUE (name);


--
-- Name: roles roles_name_key224; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key224 UNIQUE (name);


--
-- Name: roles roles_name_key225; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key225 UNIQUE (name);


--
-- Name: roles roles_name_key226; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key226 UNIQUE (name);


--
-- Name: roles roles_name_key227; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key227 UNIQUE (name);


--
-- Name: roles roles_name_key228; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key228 UNIQUE (name);


--
-- Name: roles roles_name_key229; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key229 UNIQUE (name);


--
-- Name: roles roles_name_key23; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key23 UNIQUE (name);


--
-- Name: roles roles_name_key230; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key230 UNIQUE (name);


--
-- Name: roles roles_name_key231; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key231 UNIQUE (name);


--
-- Name: roles roles_name_key232; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key232 UNIQUE (name);


--
-- Name: roles roles_name_key233; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key233 UNIQUE (name);


--
-- Name: roles roles_name_key234; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key234 UNIQUE (name);


--
-- Name: roles roles_name_key235; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key235 UNIQUE (name);


--
-- Name: roles roles_name_key236; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key236 UNIQUE (name);


--
-- Name: roles roles_name_key237; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key237 UNIQUE (name);


--
-- Name: roles roles_name_key238; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key238 UNIQUE (name);


--
-- Name: roles roles_name_key239; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key239 UNIQUE (name);


--
-- Name: roles roles_name_key24; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key24 UNIQUE (name);


--
-- Name: roles roles_name_key240; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key240 UNIQUE (name);


--
-- Name: roles roles_name_key241; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key241 UNIQUE (name);


--
-- Name: roles roles_name_key242; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key242 UNIQUE (name);


--
-- Name: roles roles_name_key243; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key243 UNIQUE (name);


--
-- Name: roles roles_name_key244; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key244 UNIQUE (name);


--
-- Name: roles roles_name_key245; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key245 UNIQUE (name);


--
-- Name: roles roles_name_key246; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key246 UNIQUE (name);


--
-- Name: roles roles_name_key247; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key247 UNIQUE (name);


--
-- Name: roles roles_name_key248; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key248 UNIQUE (name);


--
-- Name: roles roles_name_key249; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key249 UNIQUE (name);


--
-- Name: roles roles_name_key25; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key25 UNIQUE (name);


--
-- Name: roles roles_name_key250; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key250 UNIQUE (name);


--
-- Name: roles roles_name_key251; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key251 UNIQUE (name);


--
-- Name: roles roles_name_key252; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key252 UNIQUE (name);


--
-- Name: roles roles_name_key253; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key253 UNIQUE (name);


--
-- Name: roles roles_name_key254; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key254 UNIQUE (name);


--
-- Name: roles roles_name_key255; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key255 UNIQUE (name);


--
-- Name: roles roles_name_key256; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key256 UNIQUE (name);


--
-- Name: roles roles_name_key257; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key257 UNIQUE (name);


--
-- Name: roles roles_name_key258; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key258 UNIQUE (name);


--
-- Name: roles roles_name_key259; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key259 UNIQUE (name);


--
-- Name: roles roles_name_key26; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key26 UNIQUE (name);


--
-- Name: roles roles_name_key260; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key260 UNIQUE (name);


--
-- Name: roles roles_name_key261; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key261 UNIQUE (name);


--
-- Name: roles roles_name_key262; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key262 UNIQUE (name);


--
-- Name: roles roles_name_key263; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key263 UNIQUE (name);


--
-- Name: roles roles_name_key264; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key264 UNIQUE (name);


--
-- Name: roles roles_name_key265; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key265 UNIQUE (name);


--
-- Name: roles roles_name_key266; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key266 UNIQUE (name);


--
-- Name: roles roles_name_key267; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key267 UNIQUE (name);


--
-- Name: roles roles_name_key268; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key268 UNIQUE (name);


--
-- Name: roles roles_name_key269; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key269 UNIQUE (name);


--
-- Name: roles roles_name_key27; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key27 UNIQUE (name);


--
-- Name: roles roles_name_key270; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key270 UNIQUE (name);


--
-- Name: roles roles_name_key271; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key271 UNIQUE (name);


--
-- Name: roles roles_name_key272; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key272 UNIQUE (name);


--
-- Name: roles roles_name_key273; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key273 UNIQUE (name);


--
-- Name: roles roles_name_key274; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key274 UNIQUE (name);


--
-- Name: roles roles_name_key275; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key275 UNIQUE (name);


--
-- Name: roles roles_name_key276; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key276 UNIQUE (name);


--
-- Name: roles roles_name_key277; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key277 UNIQUE (name);


--
-- Name: roles roles_name_key278; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key278 UNIQUE (name);


--
-- Name: roles roles_name_key279; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key279 UNIQUE (name);


--
-- Name: roles roles_name_key28; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key28 UNIQUE (name);


--
-- Name: roles roles_name_key280; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key280 UNIQUE (name);


--
-- Name: roles roles_name_key281; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key281 UNIQUE (name);


--
-- Name: roles roles_name_key282; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key282 UNIQUE (name);


--
-- Name: roles roles_name_key283; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key283 UNIQUE (name);


--
-- Name: roles roles_name_key284; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key284 UNIQUE (name);


--
-- Name: roles roles_name_key285; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key285 UNIQUE (name);


--
-- Name: roles roles_name_key286; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key286 UNIQUE (name);


--
-- Name: roles roles_name_key287; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key287 UNIQUE (name);


--
-- Name: roles roles_name_key288; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key288 UNIQUE (name);


--
-- Name: roles roles_name_key289; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key289 UNIQUE (name);


--
-- Name: roles roles_name_key29; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key29 UNIQUE (name);


--
-- Name: roles roles_name_key290; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key290 UNIQUE (name);


--
-- Name: roles roles_name_key291; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key291 UNIQUE (name);


--
-- Name: roles roles_name_key292; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key292 UNIQUE (name);


--
-- Name: roles roles_name_key293; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key293 UNIQUE (name);


--
-- Name: roles roles_name_key294; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key294 UNIQUE (name);


--
-- Name: roles roles_name_key295; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key295 UNIQUE (name);


--
-- Name: roles roles_name_key296; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key296 UNIQUE (name);


--
-- Name: roles roles_name_key297; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key297 UNIQUE (name);


--
-- Name: roles roles_name_key298; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key298 UNIQUE (name);


--
-- Name: roles roles_name_key299; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key299 UNIQUE (name);


--
-- Name: roles roles_name_key3; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key3 UNIQUE (name);


--
-- Name: roles roles_name_key30; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key30 UNIQUE (name);


--
-- Name: roles roles_name_key300; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key300 UNIQUE (name);


--
-- Name: roles roles_name_key301; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key301 UNIQUE (name);


--
-- Name: roles roles_name_key302; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key302 UNIQUE (name);


--
-- Name: roles roles_name_key303; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key303 UNIQUE (name);


--
-- Name: roles roles_name_key304; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key304 UNIQUE (name);


--
-- Name: roles roles_name_key305; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key305 UNIQUE (name);


--
-- Name: roles roles_name_key306; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key306 UNIQUE (name);


--
-- Name: roles roles_name_key307; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key307 UNIQUE (name);


--
-- Name: roles roles_name_key308; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key308 UNIQUE (name);


--
-- Name: roles roles_name_key309; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key309 UNIQUE (name);


--
-- Name: roles roles_name_key31; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key31 UNIQUE (name);


--
-- Name: roles roles_name_key310; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key310 UNIQUE (name);


--
-- Name: roles roles_name_key311; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key311 UNIQUE (name);


--
-- Name: roles roles_name_key312; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key312 UNIQUE (name);


--
-- Name: roles roles_name_key313; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key313 UNIQUE (name);


--
-- Name: roles roles_name_key314; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key314 UNIQUE (name);


--
-- Name: roles roles_name_key315; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key315 UNIQUE (name);


--
-- Name: roles roles_name_key316; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key316 UNIQUE (name);


--
-- Name: roles roles_name_key317; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key317 UNIQUE (name);


--
-- Name: roles roles_name_key318; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key318 UNIQUE (name);


--
-- Name: roles roles_name_key319; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key319 UNIQUE (name);


--
-- Name: roles roles_name_key32; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key32 UNIQUE (name);


--
-- Name: roles roles_name_key320; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key320 UNIQUE (name);


--
-- Name: roles roles_name_key321; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key321 UNIQUE (name);


--
-- Name: roles roles_name_key322; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key322 UNIQUE (name);


--
-- Name: roles roles_name_key323; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key323 UNIQUE (name);


--
-- Name: roles roles_name_key324; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key324 UNIQUE (name);


--
-- Name: roles roles_name_key325; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key325 UNIQUE (name);


--
-- Name: roles roles_name_key326; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key326 UNIQUE (name);


--
-- Name: roles roles_name_key327; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key327 UNIQUE (name);


--
-- Name: roles roles_name_key328; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key328 UNIQUE (name);


--
-- Name: roles roles_name_key329; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key329 UNIQUE (name);


--
-- Name: roles roles_name_key33; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key33 UNIQUE (name);


--
-- Name: roles roles_name_key330; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key330 UNIQUE (name);


--
-- Name: roles roles_name_key331; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key331 UNIQUE (name);


--
-- Name: roles roles_name_key332; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key332 UNIQUE (name);


--
-- Name: roles roles_name_key333; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key333 UNIQUE (name);


--
-- Name: roles roles_name_key334; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key334 UNIQUE (name);


--
-- Name: roles roles_name_key335; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key335 UNIQUE (name);


--
-- Name: roles roles_name_key336; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key336 UNIQUE (name);


--
-- Name: roles roles_name_key337; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key337 UNIQUE (name);


--
-- Name: roles roles_name_key338; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key338 UNIQUE (name);


--
-- Name: roles roles_name_key339; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key339 UNIQUE (name);


--
-- Name: roles roles_name_key34; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key34 UNIQUE (name);


--
-- Name: roles roles_name_key340; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key340 UNIQUE (name);


--
-- Name: roles roles_name_key341; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key341 UNIQUE (name);


--
-- Name: roles roles_name_key342; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key342 UNIQUE (name);


--
-- Name: roles roles_name_key343; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key343 UNIQUE (name);


--
-- Name: roles roles_name_key344; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key344 UNIQUE (name);


--
-- Name: roles roles_name_key345; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key345 UNIQUE (name);


--
-- Name: roles roles_name_key346; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key346 UNIQUE (name);


--
-- Name: roles roles_name_key347; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key347 UNIQUE (name);


--
-- Name: roles roles_name_key348; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key348 UNIQUE (name);


--
-- Name: roles roles_name_key349; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key349 UNIQUE (name);


--
-- Name: roles roles_name_key35; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key35 UNIQUE (name);


--
-- Name: roles roles_name_key350; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key350 UNIQUE (name);


--
-- Name: roles roles_name_key351; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key351 UNIQUE (name);


--
-- Name: roles roles_name_key352; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key352 UNIQUE (name);


--
-- Name: roles roles_name_key353; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key353 UNIQUE (name);


--
-- Name: roles roles_name_key354; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key354 UNIQUE (name);


--
-- Name: roles roles_name_key355; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key355 UNIQUE (name);


--
-- Name: roles roles_name_key356; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key356 UNIQUE (name);


--
-- Name: roles roles_name_key357; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key357 UNIQUE (name);


--
-- Name: roles roles_name_key358; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key358 UNIQUE (name);


--
-- Name: roles roles_name_key359; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key359 UNIQUE (name);


--
-- Name: roles roles_name_key36; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key36 UNIQUE (name);


--
-- Name: roles roles_name_key360; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key360 UNIQUE (name);


--
-- Name: roles roles_name_key361; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key361 UNIQUE (name);


--
-- Name: roles roles_name_key362; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key362 UNIQUE (name);


--
-- Name: roles roles_name_key363; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key363 UNIQUE (name);


--
-- Name: roles roles_name_key364; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key364 UNIQUE (name);


--
-- Name: roles roles_name_key365; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key365 UNIQUE (name);


--
-- Name: roles roles_name_key366; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key366 UNIQUE (name);


--
-- Name: roles roles_name_key367; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key367 UNIQUE (name);


--
-- Name: roles roles_name_key368; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key368 UNIQUE (name);


--
-- Name: roles roles_name_key369; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key369 UNIQUE (name);


--
-- Name: roles roles_name_key37; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key37 UNIQUE (name);


--
-- Name: roles roles_name_key370; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key370 UNIQUE (name);


--
-- Name: roles roles_name_key371; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key371 UNIQUE (name);


--
-- Name: roles roles_name_key372; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key372 UNIQUE (name);


--
-- Name: roles roles_name_key373; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key373 UNIQUE (name);


--
-- Name: roles roles_name_key374; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key374 UNIQUE (name);


--
-- Name: roles roles_name_key375; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key375 UNIQUE (name);


--
-- Name: roles roles_name_key376; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key376 UNIQUE (name);


--
-- Name: roles roles_name_key377; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key377 UNIQUE (name);


--
-- Name: roles roles_name_key378; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key378 UNIQUE (name);


--
-- Name: roles roles_name_key379; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key379 UNIQUE (name);


--
-- Name: roles roles_name_key38; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key38 UNIQUE (name);


--
-- Name: roles roles_name_key380; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key380 UNIQUE (name);


--
-- Name: roles roles_name_key381; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key381 UNIQUE (name);


--
-- Name: roles roles_name_key382; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key382 UNIQUE (name);


--
-- Name: roles roles_name_key383; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key383 UNIQUE (name);


--
-- Name: roles roles_name_key384; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key384 UNIQUE (name);


--
-- Name: roles roles_name_key385; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key385 UNIQUE (name);


--
-- Name: roles roles_name_key386; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key386 UNIQUE (name);


--
-- Name: roles roles_name_key387; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key387 UNIQUE (name);


--
-- Name: roles roles_name_key388; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key388 UNIQUE (name);


--
-- Name: roles roles_name_key389; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key389 UNIQUE (name);


--
-- Name: roles roles_name_key39; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key39 UNIQUE (name);


--
-- Name: roles roles_name_key390; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key390 UNIQUE (name);


--
-- Name: roles roles_name_key4; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key4 UNIQUE (name);


--
-- Name: roles roles_name_key40; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key40 UNIQUE (name);


--
-- Name: roles roles_name_key41; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key41 UNIQUE (name);


--
-- Name: roles roles_name_key42; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key42 UNIQUE (name);


--
-- Name: roles roles_name_key43; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key43 UNIQUE (name);


--
-- Name: roles roles_name_key44; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key44 UNIQUE (name);


--
-- Name: roles roles_name_key45; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key45 UNIQUE (name);


--
-- Name: roles roles_name_key46; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key46 UNIQUE (name);


--
-- Name: roles roles_name_key47; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key47 UNIQUE (name);


--
-- Name: roles roles_name_key48; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key48 UNIQUE (name);


--
-- Name: roles roles_name_key49; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key49 UNIQUE (name);


--
-- Name: roles roles_name_key5; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key5 UNIQUE (name);


--
-- Name: roles roles_name_key50; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key50 UNIQUE (name);


--
-- Name: roles roles_name_key51; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key51 UNIQUE (name);


--
-- Name: roles roles_name_key52; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key52 UNIQUE (name);


--
-- Name: roles roles_name_key53; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key53 UNIQUE (name);


--
-- Name: roles roles_name_key54; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key54 UNIQUE (name);


--
-- Name: roles roles_name_key55; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key55 UNIQUE (name);


--
-- Name: roles roles_name_key56; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key56 UNIQUE (name);


--
-- Name: roles roles_name_key57; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key57 UNIQUE (name);


--
-- Name: roles roles_name_key58; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key58 UNIQUE (name);


--
-- Name: roles roles_name_key59; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key59 UNIQUE (name);


--
-- Name: roles roles_name_key6; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key6 UNIQUE (name);


--
-- Name: roles roles_name_key60; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key60 UNIQUE (name);


--
-- Name: roles roles_name_key61; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key61 UNIQUE (name);


--
-- Name: roles roles_name_key62; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key62 UNIQUE (name);


--
-- Name: roles roles_name_key63; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key63 UNIQUE (name);


--
-- Name: roles roles_name_key64; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key64 UNIQUE (name);


--
-- Name: roles roles_name_key65; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key65 UNIQUE (name);


--
-- Name: roles roles_name_key66; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key66 UNIQUE (name);


--
-- Name: roles roles_name_key67; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key67 UNIQUE (name);


--
-- Name: roles roles_name_key68; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key68 UNIQUE (name);


--
-- Name: roles roles_name_key69; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key69 UNIQUE (name);


--
-- Name: roles roles_name_key7; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key7 UNIQUE (name);


--
-- Name: roles roles_name_key70; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key70 UNIQUE (name);


--
-- Name: roles roles_name_key71; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key71 UNIQUE (name);


--
-- Name: roles roles_name_key72; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key72 UNIQUE (name);


--
-- Name: roles roles_name_key73; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key73 UNIQUE (name);


--
-- Name: roles roles_name_key74; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key74 UNIQUE (name);


--
-- Name: roles roles_name_key75; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key75 UNIQUE (name);


--
-- Name: roles roles_name_key76; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key76 UNIQUE (name);


--
-- Name: roles roles_name_key77; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key77 UNIQUE (name);


--
-- Name: roles roles_name_key78; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key78 UNIQUE (name);


--
-- Name: roles roles_name_key79; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key79 UNIQUE (name);


--
-- Name: roles roles_name_key8; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key8 UNIQUE (name);


--
-- Name: roles roles_name_key80; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key80 UNIQUE (name);


--
-- Name: roles roles_name_key81; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key81 UNIQUE (name);


--
-- Name: roles roles_name_key82; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key82 UNIQUE (name);


--
-- Name: roles roles_name_key83; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key83 UNIQUE (name);


--
-- Name: roles roles_name_key84; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key84 UNIQUE (name);


--
-- Name: roles roles_name_key85; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key85 UNIQUE (name);


--
-- Name: roles roles_name_key86; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key86 UNIQUE (name);


--
-- Name: roles roles_name_key87; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key87 UNIQUE (name);


--
-- Name: roles roles_name_key88; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key88 UNIQUE (name);


--
-- Name: roles roles_name_key89; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key89 UNIQUE (name);


--
-- Name: roles roles_name_key9; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key9 UNIQUE (name);


--
-- Name: roles roles_name_key90; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key90 UNIQUE (name);


--
-- Name: roles roles_name_key91; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key91 UNIQUE (name);


--
-- Name: roles roles_name_key92; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key92 UNIQUE (name);


--
-- Name: roles roles_name_key93; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key93 UNIQUE (name);


--
-- Name: roles roles_name_key94; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key94 UNIQUE (name);


--
-- Name: roles roles_name_key95; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key95 UNIQUE (name);


--
-- Name: roles roles_name_key96; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key96 UNIQUE (name);


--
-- Name: roles roles_name_key97; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key97 UNIQUE (name);


--
-- Name: roles roles_name_key98; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key98 UNIQUE (name);


--
-- Name: roles roles_name_key99; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key99 UNIQUE (name);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: session_speakers session_speakers_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.session_speakers
    ADD CONSTRAINT session_speakers_pkey PRIMARY KEY (session_id, speaker_id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: speakers speakers_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.speakers
    ADD CONSTRAINT speakers_pkey PRIMARY KEY (id);


--
-- Name: ticket_types ticket_types_event_id_name_key; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.ticket_types
    ADD CONSTRAINT ticket_types_event_id_name_key UNIQUE (event_id, name);


--
-- Name: ticket_types ticket_types_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.ticket_types
    ADD CONSTRAINT ticket_types_pkey PRIMARY KEY (id);


--
-- Name: events unique_event_per_venue_date; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT unique_event_per_venue_date UNIQUE (title, start_date, venue_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_email_key1; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key1 UNIQUE (email);


--
-- Name: users users_email_key10; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key10 UNIQUE (email);


--
-- Name: users users_email_key100; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key100 UNIQUE (email);


--
-- Name: users users_email_key101; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key101 UNIQUE (email);


--
-- Name: users users_email_key102; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key102 UNIQUE (email);


--
-- Name: users users_email_key103; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key103 UNIQUE (email);


--
-- Name: users users_email_key104; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key104 UNIQUE (email);


--
-- Name: users users_email_key105; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key105 UNIQUE (email);


--
-- Name: users users_email_key106; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key106 UNIQUE (email);


--
-- Name: users users_email_key107; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key107 UNIQUE (email);


--
-- Name: users users_email_key108; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key108 UNIQUE (email);


--
-- Name: users users_email_key109; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key109 UNIQUE (email);


--
-- Name: users users_email_key11; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key11 UNIQUE (email);


--
-- Name: users users_email_key110; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key110 UNIQUE (email);


--
-- Name: users users_email_key111; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key111 UNIQUE (email);


--
-- Name: users users_email_key112; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key112 UNIQUE (email);


--
-- Name: users users_email_key113; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key113 UNIQUE (email);


--
-- Name: users users_email_key114; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key114 UNIQUE (email);


--
-- Name: users users_email_key115; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key115 UNIQUE (email);


--
-- Name: users users_email_key116; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key116 UNIQUE (email);


--
-- Name: users users_email_key117; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key117 UNIQUE (email);


--
-- Name: users users_email_key118; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key118 UNIQUE (email);


--
-- Name: users users_email_key119; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key119 UNIQUE (email);


--
-- Name: users users_email_key12; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key12 UNIQUE (email);


--
-- Name: users users_email_key120; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key120 UNIQUE (email);


--
-- Name: users users_email_key121; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key121 UNIQUE (email);


--
-- Name: users users_email_key122; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key122 UNIQUE (email);


--
-- Name: users users_email_key123; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key123 UNIQUE (email);


--
-- Name: users users_email_key124; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key124 UNIQUE (email);


--
-- Name: users users_email_key125; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key125 UNIQUE (email);


--
-- Name: users users_email_key126; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key126 UNIQUE (email);


--
-- Name: users users_email_key127; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key127 UNIQUE (email);


--
-- Name: users users_email_key128; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key128 UNIQUE (email);


--
-- Name: users users_email_key129; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key129 UNIQUE (email);


--
-- Name: users users_email_key13; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key13 UNIQUE (email);


--
-- Name: users users_email_key130; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key130 UNIQUE (email);


--
-- Name: users users_email_key131; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key131 UNIQUE (email);


--
-- Name: users users_email_key132; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key132 UNIQUE (email);


--
-- Name: users users_email_key133; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key133 UNIQUE (email);


--
-- Name: users users_email_key134; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key134 UNIQUE (email);


--
-- Name: users users_email_key135; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key135 UNIQUE (email);


--
-- Name: users users_email_key136; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key136 UNIQUE (email);


--
-- Name: users users_email_key137; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key137 UNIQUE (email);


--
-- Name: users users_email_key138; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key138 UNIQUE (email);


--
-- Name: users users_email_key139; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key139 UNIQUE (email);


--
-- Name: users users_email_key14; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key14 UNIQUE (email);


--
-- Name: users users_email_key140; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key140 UNIQUE (email);


--
-- Name: users users_email_key141; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key141 UNIQUE (email);


--
-- Name: users users_email_key142; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key142 UNIQUE (email);


--
-- Name: users users_email_key143; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key143 UNIQUE (email);


--
-- Name: users users_email_key144; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key144 UNIQUE (email);


--
-- Name: users users_email_key145; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key145 UNIQUE (email);


--
-- Name: users users_email_key146; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key146 UNIQUE (email);


--
-- Name: users users_email_key147; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key147 UNIQUE (email);


--
-- Name: users users_email_key148; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key148 UNIQUE (email);


--
-- Name: users users_email_key149; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key149 UNIQUE (email);


--
-- Name: users users_email_key15; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key15 UNIQUE (email);


--
-- Name: users users_email_key150; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key150 UNIQUE (email);


--
-- Name: users users_email_key151; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key151 UNIQUE (email);


--
-- Name: users users_email_key152; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key152 UNIQUE (email);


--
-- Name: users users_email_key153; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key153 UNIQUE (email);


--
-- Name: users users_email_key154; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key154 UNIQUE (email);


--
-- Name: users users_email_key155; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key155 UNIQUE (email);


--
-- Name: users users_email_key156; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key156 UNIQUE (email);


--
-- Name: users users_email_key157; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key157 UNIQUE (email);


--
-- Name: users users_email_key158; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key158 UNIQUE (email);


--
-- Name: users users_email_key159; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key159 UNIQUE (email);


--
-- Name: users users_email_key16; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key16 UNIQUE (email);


--
-- Name: users users_email_key160; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key160 UNIQUE (email);


--
-- Name: users users_email_key161; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key161 UNIQUE (email);


--
-- Name: users users_email_key162; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key162 UNIQUE (email);


--
-- Name: users users_email_key163; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key163 UNIQUE (email);


--
-- Name: users users_email_key164; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key164 UNIQUE (email);


--
-- Name: users users_email_key165; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key165 UNIQUE (email);


--
-- Name: users users_email_key166; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key166 UNIQUE (email);


--
-- Name: users users_email_key167; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key167 UNIQUE (email);


--
-- Name: users users_email_key168; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key168 UNIQUE (email);


--
-- Name: users users_email_key169; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key169 UNIQUE (email);


--
-- Name: users users_email_key17; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key17 UNIQUE (email);


--
-- Name: users users_email_key170; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key170 UNIQUE (email);


--
-- Name: users users_email_key171; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key171 UNIQUE (email);


--
-- Name: users users_email_key172; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key172 UNIQUE (email);


--
-- Name: users users_email_key173; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key173 UNIQUE (email);


--
-- Name: users users_email_key174; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key174 UNIQUE (email);


--
-- Name: users users_email_key175; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key175 UNIQUE (email);


--
-- Name: users users_email_key176; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key176 UNIQUE (email);


--
-- Name: users users_email_key177; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key177 UNIQUE (email);


--
-- Name: users users_email_key178; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key178 UNIQUE (email);


--
-- Name: users users_email_key179; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key179 UNIQUE (email);


--
-- Name: users users_email_key18; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key18 UNIQUE (email);


--
-- Name: users users_email_key180; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key180 UNIQUE (email);


--
-- Name: users users_email_key181; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key181 UNIQUE (email);


--
-- Name: users users_email_key182; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key182 UNIQUE (email);


--
-- Name: users users_email_key183; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key183 UNIQUE (email);


--
-- Name: users users_email_key184; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key184 UNIQUE (email);


--
-- Name: users users_email_key185; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key185 UNIQUE (email);


--
-- Name: users users_email_key186; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key186 UNIQUE (email);


--
-- Name: users users_email_key187; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key187 UNIQUE (email);


--
-- Name: users users_email_key188; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key188 UNIQUE (email);


--
-- Name: users users_email_key189; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key189 UNIQUE (email);


--
-- Name: users users_email_key19; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key19 UNIQUE (email);


--
-- Name: users users_email_key190; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key190 UNIQUE (email);


--
-- Name: users users_email_key191; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key191 UNIQUE (email);


--
-- Name: users users_email_key192; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key192 UNIQUE (email);


--
-- Name: users users_email_key193; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key193 UNIQUE (email);


--
-- Name: users users_email_key194; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key194 UNIQUE (email);


--
-- Name: users users_email_key195; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key195 UNIQUE (email);


--
-- Name: users users_email_key196; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key196 UNIQUE (email);


--
-- Name: users users_email_key197; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key197 UNIQUE (email);


--
-- Name: users users_email_key198; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key198 UNIQUE (email);


--
-- Name: users users_email_key199; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key199 UNIQUE (email);


--
-- Name: users users_email_key2; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key2 UNIQUE (email);


--
-- Name: users users_email_key20; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key20 UNIQUE (email);


--
-- Name: users users_email_key200; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key200 UNIQUE (email);


--
-- Name: users users_email_key201; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key201 UNIQUE (email);


--
-- Name: users users_email_key202; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key202 UNIQUE (email);


--
-- Name: users users_email_key203; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key203 UNIQUE (email);


--
-- Name: users users_email_key204; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key204 UNIQUE (email);


--
-- Name: users users_email_key205; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key205 UNIQUE (email);


--
-- Name: users users_email_key206; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key206 UNIQUE (email);


--
-- Name: users users_email_key207; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key207 UNIQUE (email);


--
-- Name: users users_email_key208; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key208 UNIQUE (email);


--
-- Name: users users_email_key209; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key209 UNIQUE (email);


--
-- Name: users users_email_key21; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key21 UNIQUE (email);


--
-- Name: users users_email_key210; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key210 UNIQUE (email);


--
-- Name: users users_email_key211; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key211 UNIQUE (email);


--
-- Name: users users_email_key212; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key212 UNIQUE (email);


--
-- Name: users users_email_key213; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key213 UNIQUE (email);


--
-- Name: users users_email_key214; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key214 UNIQUE (email);


--
-- Name: users users_email_key215; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key215 UNIQUE (email);


--
-- Name: users users_email_key216; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key216 UNIQUE (email);


--
-- Name: users users_email_key217; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key217 UNIQUE (email);


--
-- Name: users users_email_key218; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key218 UNIQUE (email);


--
-- Name: users users_email_key219; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key219 UNIQUE (email);


--
-- Name: users users_email_key22; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key22 UNIQUE (email);


--
-- Name: users users_email_key220; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key220 UNIQUE (email);


--
-- Name: users users_email_key221; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key221 UNIQUE (email);


--
-- Name: users users_email_key222; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key222 UNIQUE (email);


--
-- Name: users users_email_key223; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key223 UNIQUE (email);


--
-- Name: users users_email_key224; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key224 UNIQUE (email);


--
-- Name: users users_email_key225; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key225 UNIQUE (email);


--
-- Name: users users_email_key226; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key226 UNIQUE (email);


--
-- Name: users users_email_key227; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key227 UNIQUE (email);


--
-- Name: users users_email_key228; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key228 UNIQUE (email);


--
-- Name: users users_email_key229; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key229 UNIQUE (email);


--
-- Name: users users_email_key23; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key23 UNIQUE (email);


--
-- Name: users users_email_key230; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key230 UNIQUE (email);


--
-- Name: users users_email_key231; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key231 UNIQUE (email);


--
-- Name: users users_email_key232; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key232 UNIQUE (email);


--
-- Name: users users_email_key233; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key233 UNIQUE (email);


--
-- Name: users users_email_key234; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key234 UNIQUE (email);


--
-- Name: users users_email_key235; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key235 UNIQUE (email);


--
-- Name: users users_email_key236; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key236 UNIQUE (email);


--
-- Name: users users_email_key237; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key237 UNIQUE (email);


--
-- Name: users users_email_key238; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key238 UNIQUE (email);


--
-- Name: users users_email_key239; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key239 UNIQUE (email);


--
-- Name: users users_email_key24; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key24 UNIQUE (email);


--
-- Name: users users_email_key240; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key240 UNIQUE (email);


--
-- Name: users users_email_key241; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key241 UNIQUE (email);


--
-- Name: users users_email_key242; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key242 UNIQUE (email);


--
-- Name: users users_email_key243; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key243 UNIQUE (email);


--
-- Name: users users_email_key244; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key244 UNIQUE (email);


--
-- Name: users users_email_key245; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key245 UNIQUE (email);


--
-- Name: users users_email_key246; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key246 UNIQUE (email);


--
-- Name: users users_email_key247; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key247 UNIQUE (email);


--
-- Name: users users_email_key248; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key248 UNIQUE (email);


--
-- Name: users users_email_key249; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key249 UNIQUE (email);


--
-- Name: users users_email_key25; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key25 UNIQUE (email);


--
-- Name: users users_email_key250; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key250 UNIQUE (email);


--
-- Name: users users_email_key251; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key251 UNIQUE (email);


--
-- Name: users users_email_key252; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key252 UNIQUE (email);


--
-- Name: users users_email_key253; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key253 UNIQUE (email);


--
-- Name: users users_email_key254; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key254 UNIQUE (email);


--
-- Name: users users_email_key255; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key255 UNIQUE (email);


--
-- Name: users users_email_key256; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key256 UNIQUE (email);


--
-- Name: users users_email_key257; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key257 UNIQUE (email);


--
-- Name: users users_email_key258; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key258 UNIQUE (email);


--
-- Name: users users_email_key259; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key259 UNIQUE (email);


--
-- Name: users users_email_key26; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key26 UNIQUE (email);


--
-- Name: users users_email_key260; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key260 UNIQUE (email);


--
-- Name: users users_email_key261; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key261 UNIQUE (email);


--
-- Name: users users_email_key262; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key262 UNIQUE (email);


--
-- Name: users users_email_key263; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key263 UNIQUE (email);


--
-- Name: users users_email_key264; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key264 UNIQUE (email);


--
-- Name: users users_email_key265; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key265 UNIQUE (email);


--
-- Name: users users_email_key266; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key266 UNIQUE (email);


--
-- Name: users users_email_key267; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key267 UNIQUE (email);


--
-- Name: users users_email_key268; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key268 UNIQUE (email);


--
-- Name: users users_email_key269; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key269 UNIQUE (email);


--
-- Name: users users_email_key27; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key27 UNIQUE (email);


--
-- Name: users users_email_key270; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key270 UNIQUE (email);


--
-- Name: users users_email_key271; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key271 UNIQUE (email);


--
-- Name: users users_email_key272; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key272 UNIQUE (email);


--
-- Name: users users_email_key273; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key273 UNIQUE (email);


--
-- Name: users users_email_key274; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key274 UNIQUE (email);


--
-- Name: users users_email_key275; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key275 UNIQUE (email);


--
-- Name: users users_email_key276; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key276 UNIQUE (email);


--
-- Name: users users_email_key277; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key277 UNIQUE (email);


--
-- Name: users users_email_key278; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key278 UNIQUE (email);


--
-- Name: users users_email_key279; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key279 UNIQUE (email);


--
-- Name: users users_email_key28; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key28 UNIQUE (email);


--
-- Name: users users_email_key280; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key280 UNIQUE (email);


--
-- Name: users users_email_key281; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key281 UNIQUE (email);


--
-- Name: users users_email_key282; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key282 UNIQUE (email);


--
-- Name: users users_email_key283; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key283 UNIQUE (email);


--
-- Name: users users_email_key284; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key284 UNIQUE (email);


--
-- Name: users users_email_key285; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key285 UNIQUE (email);


--
-- Name: users users_email_key286; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key286 UNIQUE (email);


--
-- Name: users users_email_key287; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key287 UNIQUE (email);


--
-- Name: users users_email_key288; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key288 UNIQUE (email);


--
-- Name: users users_email_key289; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key289 UNIQUE (email);


--
-- Name: users users_email_key29; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key29 UNIQUE (email);


--
-- Name: users users_email_key290; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key290 UNIQUE (email);


--
-- Name: users users_email_key291; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key291 UNIQUE (email);


--
-- Name: users users_email_key292; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key292 UNIQUE (email);


--
-- Name: users users_email_key293; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key293 UNIQUE (email);


--
-- Name: users users_email_key294; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key294 UNIQUE (email);


--
-- Name: users users_email_key295; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key295 UNIQUE (email);


--
-- Name: users users_email_key296; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key296 UNIQUE (email);


--
-- Name: users users_email_key297; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key297 UNIQUE (email);


--
-- Name: users users_email_key298; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key298 UNIQUE (email);


--
-- Name: users users_email_key299; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key299 UNIQUE (email);


--
-- Name: users users_email_key3; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key3 UNIQUE (email);


--
-- Name: users users_email_key30; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key30 UNIQUE (email);


--
-- Name: users users_email_key300; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key300 UNIQUE (email);


--
-- Name: users users_email_key301; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key301 UNIQUE (email);


--
-- Name: users users_email_key302; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key302 UNIQUE (email);


--
-- Name: users users_email_key303; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key303 UNIQUE (email);


--
-- Name: users users_email_key304; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key304 UNIQUE (email);


--
-- Name: users users_email_key305; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key305 UNIQUE (email);


--
-- Name: users users_email_key306; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key306 UNIQUE (email);


--
-- Name: users users_email_key307; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key307 UNIQUE (email);


--
-- Name: users users_email_key308; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key308 UNIQUE (email);


--
-- Name: users users_email_key309; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key309 UNIQUE (email);


--
-- Name: users users_email_key31; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key31 UNIQUE (email);


--
-- Name: users users_email_key310; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key310 UNIQUE (email);


--
-- Name: users users_email_key311; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key311 UNIQUE (email);


--
-- Name: users users_email_key312; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key312 UNIQUE (email);


--
-- Name: users users_email_key313; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key313 UNIQUE (email);


--
-- Name: users users_email_key314; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key314 UNIQUE (email);


--
-- Name: users users_email_key315; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key315 UNIQUE (email);


--
-- Name: users users_email_key316; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key316 UNIQUE (email);


--
-- Name: users users_email_key317; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key317 UNIQUE (email);


--
-- Name: users users_email_key318; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key318 UNIQUE (email);


--
-- Name: users users_email_key319; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key319 UNIQUE (email);


--
-- Name: users users_email_key32; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key32 UNIQUE (email);


--
-- Name: users users_email_key320; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key320 UNIQUE (email);


--
-- Name: users users_email_key321; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key321 UNIQUE (email);


--
-- Name: users users_email_key322; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key322 UNIQUE (email);


--
-- Name: users users_email_key323; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key323 UNIQUE (email);


--
-- Name: users users_email_key324; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key324 UNIQUE (email);


--
-- Name: users users_email_key325; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key325 UNIQUE (email);


--
-- Name: users users_email_key326; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key326 UNIQUE (email);


--
-- Name: users users_email_key327; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key327 UNIQUE (email);


--
-- Name: users users_email_key328; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key328 UNIQUE (email);


--
-- Name: users users_email_key329; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key329 UNIQUE (email);


--
-- Name: users users_email_key33; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key33 UNIQUE (email);


--
-- Name: users users_email_key330; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key330 UNIQUE (email);


--
-- Name: users users_email_key331; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key331 UNIQUE (email);


--
-- Name: users users_email_key332; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key332 UNIQUE (email);


--
-- Name: users users_email_key333; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key333 UNIQUE (email);


--
-- Name: users users_email_key334; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key334 UNIQUE (email);


--
-- Name: users users_email_key335; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key335 UNIQUE (email);


--
-- Name: users users_email_key336; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key336 UNIQUE (email);


--
-- Name: users users_email_key337; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key337 UNIQUE (email);


--
-- Name: users users_email_key338; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key338 UNIQUE (email);


--
-- Name: users users_email_key339; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key339 UNIQUE (email);


--
-- Name: users users_email_key34; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key34 UNIQUE (email);


--
-- Name: users users_email_key340; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key340 UNIQUE (email);


--
-- Name: users users_email_key341; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key341 UNIQUE (email);


--
-- Name: users users_email_key342; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key342 UNIQUE (email);


--
-- Name: users users_email_key343; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key343 UNIQUE (email);


--
-- Name: users users_email_key344; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key344 UNIQUE (email);


--
-- Name: users users_email_key345; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key345 UNIQUE (email);


--
-- Name: users users_email_key346; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key346 UNIQUE (email);


--
-- Name: users users_email_key347; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key347 UNIQUE (email);


--
-- Name: users users_email_key348; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key348 UNIQUE (email);


--
-- Name: users users_email_key349; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key349 UNIQUE (email);


--
-- Name: users users_email_key35; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key35 UNIQUE (email);


--
-- Name: users users_email_key350; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key350 UNIQUE (email);


--
-- Name: users users_email_key351; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key351 UNIQUE (email);


--
-- Name: users users_email_key352; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key352 UNIQUE (email);


--
-- Name: users users_email_key353; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key353 UNIQUE (email);


--
-- Name: users users_email_key354; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key354 UNIQUE (email);


--
-- Name: users users_email_key355; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key355 UNIQUE (email);


--
-- Name: users users_email_key356; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key356 UNIQUE (email);


--
-- Name: users users_email_key357; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key357 UNIQUE (email);


--
-- Name: users users_email_key358; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key358 UNIQUE (email);


--
-- Name: users users_email_key359; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key359 UNIQUE (email);


--
-- Name: users users_email_key36; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key36 UNIQUE (email);


--
-- Name: users users_email_key360; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key360 UNIQUE (email);


--
-- Name: users users_email_key361; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key361 UNIQUE (email);


--
-- Name: users users_email_key362; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key362 UNIQUE (email);


--
-- Name: users users_email_key363; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key363 UNIQUE (email);


--
-- Name: users users_email_key364; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key364 UNIQUE (email);


--
-- Name: users users_email_key365; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key365 UNIQUE (email);


--
-- Name: users users_email_key366; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key366 UNIQUE (email);


--
-- Name: users users_email_key367; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key367 UNIQUE (email);


--
-- Name: users users_email_key368; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key368 UNIQUE (email);


--
-- Name: users users_email_key369; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key369 UNIQUE (email);


--
-- Name: users users_email_key37; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key37 UNIQUE (email);


--
-- Name: users users_email_key370; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key370 UNIQUE (email);


--
-- Name: users users_email_key371; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key371 UNIQUE (email);


--
-- Name: users users_email_key372; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key372 UNIQUE (email);


--
-- Name: users users_email_key373; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key373 UNIQUE (email);


--
-- Name: users users_email_key374; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key374 UNIQUE (email);


--
-- Name: users users_email_key375; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key375 UNIQUE (email);


--
-- Name: users users_email_key376; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key376 UNIQUE (email);


--
-- Name: users users_email_key377; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key377 UNIQUE (email);


--
-- Name: users users_email_key378; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key378 UNIQUE (email);


--
-- Name: users users_email_key379; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key379 UNIQUE (email);


--
-- Name: users users_email_key38; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key38 UNIQUE (email);


--
-- Name: users users_email_key380; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key380 UNIQUE (email);


--
-- Name: users users_email_key381; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key381 UNIQUE (email);


--
-- Name: users users_email_key382; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key382 UNIQUE (email);


--
-- Name: users users_email_key383; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key383 UNIQUE (email);


--
-- Name: users users_email_key384; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key384 UNIQUE (email);


--
-- Name: users users_email_key385; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key385 UNIQUE (email);


--
-- Name: users users_email_key386; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key386 UNIQUE (email);


--
-- Name: users users_email_key387; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key387 UNIQUE (email);


--
-- Name: users users_email_key388; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key388 UNIQUE (email);


--
-- Name: users users_email_key389; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key389 UNIQUE (email);


--
-- Name: users users_email_key39; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key39 UNIQUE (email);


--
-- Name: users users_email_key390; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key390 UNIQUE (email);


--
-- Name: users users_email_key391; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key391 UNIQUE (email);


--
-- Name: users users_email_key392; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key392 UNIQUE (email);


--
-- Name: users users_email_key393; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key393 UNIQUE (email);


--
-- Name: users users_email_key394; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key394 UNIQUE (email);


--
-- Name: users users_email_key395; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key395 UNIQUE (email);


--
-- Name: users users_email_key396; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key396 UNIQUE (email);


--
-- Name: users users_email_key397; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key397 UNIQUE (email);


--
-- Name: users users_email_key398; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key398 UNIQUE (email);


--
-- Name: users users_email_key399; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key399 UNIQUE (email);


--
-- Name: users users_email_key4; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key4 UNIQUE (email);


--
-- Name: users users_email_key40; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key40 UNIQUE (email);


--
-- Name: users users_email_key400; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key400 UNIQUE (email);


--
-- Name: users users_email_key401; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key401 UNIQUE (email);


--
-- Name: users users_email_key402; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key402 UNIQUE (email);


--
-- Name: users users_email_key403; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key403 UNIQUE (email);


--
-- Name: users users_email_key404; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key404 UNIQUE (email);


--
-- Name: users users_email_key405; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key405 UNIQUE (email);


--
-- Name: users users_email_key406; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key406 UNIQUE (email);


--
-- Name: users users_email_key407; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key407 UNIQUE (email);


--
-- Name: users users_email_key408; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key408 UNIQUE (email);


--
-- Name: users users_email_key409; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key409 UNIQUE (email);


--
-- Name: users users_email_key41; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key41 UNIQUE (email);


--
-- Name: users users_email_key410; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key410 UNIQUE (email);


--
-- Name: users users_email_key411; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key411 UNIQUE (email);


--
-- Name: users users_email_key412; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key412 UNIQUE (email);


--
-- Name: users users_email_key413; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key413 UNIQUE (email);


--
-- Name: users users_email_key414; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key414 UNIQUE (email);


--
-- Name: users users_email_key415; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key415 UNIQUE (email);


--
-- Name: users users_email_key416; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key416 UNIQUE (email);


--
-- Name: users users_email_key417; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key417 UNIQUE (email);


--
-- Name: users users_email_key418; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key418 UNIQUE (email);


--
-- Name: users users_email_key419; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key419 UNIQUE (email);


--
-- Name: users users_email_key42; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key42 UNIQUE (email);


--
-- Name: users users_email_key420; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key420 UNIQUE (email);


--
-- Name: users users_email_key421; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key421 UNIQUE (email);


--
-- Name: users users_email_key422; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key422 UNIQUE (email);


--
-- Name: users users_email_key423; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key423 UNIQUE (email);


--
-- Name: users users_email_key424; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key424 UNIQUE (email);


--
-- Name: users users_email_key425; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key425 UNIQUE (email);


--
-- Name: users users_email_key426; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key426 UNIQUE (email);


--
-- Name: users users_email_key427; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key427 UNIQUE (email);


--
-- Name: users users_email_key428; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key428 UNIQUE (email);


--
-- Name: users users_email_key429; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key429 UNIQUE (email);


--
-- Name: users users_email_key43; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key43 UNIQUE (email);


--
-- Name: users users_email_key430; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key430 UNIQUE (email);


--
-- Name: users users_email_key431; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key431 UNIQUE (email);


--
-- Name: users users_email_key432; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key432 UNIQUE (email);


--
-- Name: users users_email_key433; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key433 UNIQUE (email);


--
-- Name: users users_email_key434; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key434 UNIQUE (email);


--
-- Name: users users_email_key435; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key435 UNIQUE (email);


--
-- Name: users users_email_key436; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key436 UNIQUE (email);


--
-- Name: users users_email_key437; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key437 UNIQUE (email);


--
-- Name: users users_email_key438; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key438 UNIQUE (email);


--
-- Name: users users_email_key439; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key439 UNIQUE (email);


--
-- Name: users users_email_key44; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key44 UNIQUE (email);


--
-- Name: users users_email_key440; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key440 UNIQUE (email);


--
-- Name: users users_email_key441; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key441 UNIQUE (email);


--
-- Name: users users_email_key442; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key442 UNIQUE (email);


--
-- Name: users users_email_key443; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key443 UNIQUE (email);


--
-- Name: users users_email_key444; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key444 UNIQUE (email);


--
-- Name: users users_email_key445; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key445 UNIQUE (email);


--
-- Name: users users_email_key446; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key446 UNIQUE (email);


--
-- Name: users users_email_key447; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key447 UNIQUE (email);


--
-- Name: users users_email_key448; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key448 UNIQUE (email);


--
-- Name: users users_email_key449; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key449 UNIQUE (email);


--
-- Name: users users_email_key45; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key45 UNIQUE (email);


--
-- Name: users users_email_key450; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key450 UNIQUE (email);


--
-- Name: users users_email_key451; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key451 UNIQUE (email);


--
-- Name: users users_email_key452; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key452 UNIQUE (email);


--
-- Name: users users_email_key453; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key453 UNIQUE (email);


--
-- Name: users users_email_key46; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key46 UNIQUE (email);


--
-- Name: users users_email_key47; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key47 UNIQUE (email);


--
-- Name: users users_email_key48; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key48 UNIQUE (email);


--
-- Name: users users_email_key49; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key49 UNIQUE (email);


--
-- Name: users users_email_key5; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key5 UNIQUE (email);


--
-- Name: users users_email_key50; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key50 UNIQUE (email);


--
-- Name: users users_email_key51; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key51 UNIQUE (email);


--
-- Name: users users_email_key52; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key52 UNIQUE (email);


--
-- Name: users users_email_key53; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key53 UNIQUE (email);


--
-- Name: users users_email_key54; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key54 UNIQUE (email);


--
-- Name: users users_email_key55; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key55 UNIQUE (email);


--
-- Name: users users_email_key56; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key56 UNIQUE (email);


--
-- Name: users users_email_key57; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key57 UNIQUE (email);


--
-- Name: users users_email_key58; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key58 UNIQUE (email);


--
-- Name: users users_email_key59; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key59 UNIQUE (email);


--
-- Name: users users_email_key6; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key6 UNIQUE (email);


--
-- Name: users users_email_key60; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key60 UNIQUE (email);


--
-- Name: users users_email_key61; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key61 UNIQUE (email);


--
-- Name: users users_email_key62; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key62 UNIQUE (email);


--
-- Name: users users_email_key63; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key63 UNIQUE (email);


--
-- Name: users users_email_key64; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key64 UNIQUE (email);


--
-- Name: users users_email_key65; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key65 UNIQUE (email);


--
-- Name: users users_email_key66; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key66 UNIQUE (email);


--
-- Name: users users_email_key67; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key67 UNIQUE (email);


--
-- Name: users users_email_key68; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key68 UNIQUE (email);


--
-- Name: users users_email_key69; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key69 UNIQUE (email);


--
-- Name: users users_email_key7; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key7 UNIQUE (email);


--
-- Name: users users_email_key70; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key70 UNIQUE (email);


--
-- Name: users users_email_key71; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key71 UNIQUE (email);


--
-- Name: users users_email_key72; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key72 UNIQUE (email);


--
-- Name: users users_email_key73; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key73 UNIQUE (email);


--
-- Name: users users_email_key74; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key74 UNIQUE (email);


--
-- Name: users users_email_key75; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key75 UNIQUE (email);


--
-- Name: users users_email_key76; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key76 UNIQUE (email);


--
-- Name: users users_email_key77; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key77 UNIQUE (email);


--
-- Name: users users_email_key78; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key78 UNIQUE (email);


--
-- Name: users users_email_key79; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key79 UNIQUE (email);


--
-- Name: users users_email_key8; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key8 UNIQUE (email);


--
-- Name: users users_email_key80; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key80 UNIQUE (email);


--
-- Name: users users_email_key81; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key81 UNIQUE (email);


--
-- Name: users users_email_key82; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key82 UNIQUE (email);


--
-- Name: users users_email_key83; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key83 UNIQUE (email);


--
-- Name: users users_email_key84; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key84 UNIQUE (email);


--
-- Name: users users_email_key85; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key85 UNIQUE (email);


--
-- Name: users users_email_key86; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key86 UNIQUE (email);


--
-- Name: users users_email_key87; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key87 UNIQUE (email);


--
-- Name: users users_email_key88; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key88 UNIQUE (email);


--
-- Name: users users_email_key89; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key89 UNIQUE (email);


--
-- Name: users users_email_key9; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key9 UNIQUE (email);


--
-- Name: users users_email_key90; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key90 UNIQUE (email);


--
-- Name: users users_email_key91; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key91 UNIQUE (email);


--
-- Name: users users_email_key92; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key92 UNIQUE (email);


--
-- Name: users users_email_key93; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key93 UNIQUE (email);


--
-- Name: users users_email_key94; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key94 UNIQUE (email);


--
-- Name: users users_email_key95; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key95 UNIQUE (email);


--
-- Name: users users_email_key96; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key96 UNIQUE (email);


--
-- Name: users users_email_key97; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key97 UNIQUE (email);


--
-- Name: users users_email_key98; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key98 UNIQUE (email);


--
-- Name: users users_email_key99; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key99 UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vendors vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);


--
-- Name: venues venues_pkey; Type: CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.venues
    ADD CONSTRAINT venues_pkey PRIMARY KEY (id);


--
-- Name: event_vendors_event_id_vendor_id; Type: INDEX; Schema: public; Owner: nwmac
--

CREATE UNIQUE INDEX event_vendors_event_id_vendor_id ON public.event_vendors USING btree (event_id, vendor_id);


--
-- Name: events_title_start_date_venue_id; Type: INDEX; Schema: public; Owner: nwmac
--

CREATE UNIQUE INDEX events_title_start_date_venue_id ON public.events USING btree (title, start_date, venue_id);


--
-- Name: session_speakers_session_id_speaker_id; Type: INDEX; Schema: public; Owner: nwmac
--

CREATE UNIQUE INDEX session_speakers_session_id_speaker_id ON public.session_speakers USING btree (session_id, speaker_id);


--
-- Name: ticket_types_event_id_name; Type: INDEX; Schema: public; Owner: nwmac
--

CREATE UNIQUE INDEX ticket_types_event_id_name ON public.ticket_types USING btree (event_id, name);


--
-- Name: waitlists_event_id_user_id; Type: INDEX; Schema: public; Owner: nwmac
--

CREATE UNIQUE INDEX waitlists_event_id_user_id ON public.waitlists USING btree (event_id, user_id);


--
-- Name: event_metrics event_metrics_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.event_metrics
    ADD CONSTRAINT event_metrics_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: event_vendors event_vendors_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.event_vendors
    ADD CONSTRAINT event_vendors_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: event_vendors event_vendors_vendor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.event_vendors
    ADD CONSTRAINT event_vendors_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: events events_organizer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_organizer_id_fkey FOREIGN KEY (organizer_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: events events_venue_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_venue_id_fkey FOREIGN KEY (venue_id) REFERENCES public.venues(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: feedback feedback_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: feedback feedback_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: notifications notifications_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notifications notifications_target_role_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_target_role_fkey FOREIGN KEY (target_role) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: notifications notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: payments payments_registration_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_registration_id_fkey FOREIGN KEY (registration_id) REFERENCES public.registrations(id) ON DELETE CASCADE;


--
-- Name: registrations registrations_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: registrations registrations_ticket_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_ticket_type_id_fkey FOREIGN KEY (ticket_type_id) REFERENCES public.ticket_types(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: registrations registrations_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.registrations
    ADD CONSTRAINT registrations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: session_speakers session_speakers_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.session_speakers
    ADD CONSTRAINT session_speakers_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(id) ON DELETE CASCADE;


--
-- Name: session_speakers session_speakers_speaker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.session_speakers
    ADD CONSTRAINT session_speakers_speaker_id_fkey FOREIGN KEY (speaker_id) REFERENCES public.speakers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: speakers speakers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.speakers
    ADD CONSTRAINT speakers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: ticket_types ticket_types_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.ticket_types
    ADD CONSTRAINT ticket_types_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users users_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: vendors vendors_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE;


--
-- Name: waitlists waitlists_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.waitlists
    ADD CONSTRAINT waitlists_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: waitlists waitlists_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nwmac
--

ALTER TABLE ONLY public.waitlists
    ADD CONSTRAINT waitlists_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

