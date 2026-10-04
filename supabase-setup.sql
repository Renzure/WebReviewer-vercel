-- Reviewer Shelf: run this ONCE in Supabase > SQL Editor > New query > Run.
-- It creates two tables and locks them so each signed-in user can only
-- see and change their own rows.

create table if not exists public.items (
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  id         text not null,
  data       jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, id)
);

create table if not exists public.subjects (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  name    text not null,
  primary key (user_id, name)
);

alter table public.items    enable row level security;
alter table public.subjects enable row level security;

drop policy if exists "own items" on public.items;
create policy "own items" on public.items
  for all to authenticated
  using      (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

drop policy if exists "own subjects" on public.subjects;
create policy "own subjects" on public.subjects
  for all to authenticated
  using      (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
