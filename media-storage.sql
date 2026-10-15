-- ArcWright: private storage for map images, one folder per user.
-- Run once in: Supabase → SQL Editor → New query → Run
-- Expected result: "Success. No rows returned."

insert into storage.buckets (id, name, public)
values ('arcwright-media', 'arcwright-media', false)
on conflict (id) do nothing;

-- Each user can only see and change files inside their own folder: <user id>/<image id>
drop policy if exists "arcwright media: read own"   on storage.objects;
drop policy if exists "arcwright media: add own"    on storage.objects;
drop policy if exists "arcwright media: update own" on storage.objects;
drop policy if exists "arcwright media: delete own" on storage.objects;

create policy "arcwright media: read own" on storage.objects
  for select to authenticated
  using (bucket_id = 'arcwright-media' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "arcwright media: add own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'arcwright-media' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "arcwright media: update own" on storage.objects
  for update to authenticated
  using (bucket_id = 'arcwright-media' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "arcwright media: delete own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'arcwright-media' and (storage.foldername(name))[1] = auth.uid()::text);
