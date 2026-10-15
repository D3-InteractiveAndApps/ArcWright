-- ArcWright — Supabase schema
-- Run this in: Supabase → SQL Editor → New query → Run

-- ── projects index ──────────────────────────────────────────────────────────
create table if not exists arcwright_projects (
  id          text        not null,
  user_id     uuid        not null references auth.users(id) on delete cascade,
  name        text        not null default 'Untitled World',
  genre       text        not null default '',
  chars       int         not null default 0,
  created_at  timestamptz not null default now(),
  modified_at timestamptz not null default now(),
  primary key (id, user_id)
);

alter table arcwright_projects enable row level security;
create policy "users own their projects" on arcwright_projects
  for all using (auth.uid() = user_id);

-- ── project data blobs ───────────────────────────────────────────────────────
create table if not exists arcwright_data (
  project_id  text        not null,
  user_id     uuid        not null references auth.users(id) on delete cascade,
  payload     jsonb       not null default '{}',
  modified_at timestamptz not null default now(),
  primary key (project_id, user_id)
);

alter table arcwright_data enable row level security;
create policy "users own their data" on arcwright_data
  for all using (auth.uid() = user_id);

-- ── account deletion (also shipped separately as delete-account.sql) ──
create or replace function public.arcwright_delete_my_account()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Not signed in';
  end if;
  delete from public.arcwright_data     where user_id = uid;
  delete from public.arcwright_projects where user_id = uid;
  delete from auth.users                where id      = uid;
end;
$$;

-- Only signed-in users may call it, and it only ever touches the caller's own rows.
revoke all on function public.arcwright_delete_my_account() from public, anon;
grant execute on function public.arcwright_delete_my_account() to authenticated;
