-- Agrega la clasificación comercial de cada cliente.
-- Ejecutar una sola vez en Supabase > SQL Editor.
-- Los clientes existentes quedan clasificados como particulares por defecto.

alter table public.customers
  add column if not exists customer_type text not null default 'particular';

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'customers_customer_type_check'
      and conrelid = 'public.customers'::regclass
  ) then
    alter table public.customers
      add constraint customers_customer_type_check
      check (customer_type in ('particular', 'comercio'));
  end if;
end $$;

comment on column public.customers.customer_type is
  'Tipo de cliente: particular o comercio. Los comercios reciben envío a domicilio sin cargo.';
