-- ArcWright: let signed-in users delete their own account and all their cloud data.
-- Run once in: Supabase → SQL Editor → New query → Run
-- Expected result: "Success. No rows returned."

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
